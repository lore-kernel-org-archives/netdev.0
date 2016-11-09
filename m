From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] ibmveth: v1 calculate correct gso_size and set
 gso_type
Date: Wed, 9 Nov 2016 10:02:19 -0600
Message-ID: <da1aa901-3698-f582-6beb-de94740e91d5@linux.vnet.ibm.com>
References: <1477440555-21133-1-git-send-email-jmaxwell37@gmail.com>
 <1477582016.7065.212.camel@edumazet-glaptop3.roam.corp.google.com>
 <6b7003ec-6059-c309-dfee-761216f3d058@linux.vnet.ibm.com>
 <CAGHK07Cvh2QnGrUg5eu_aC=cV7DaL9wJm8adZ0rv4s0DmF-tzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
 Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
 Jon Maxwell <jmaxwell@redhat.com>, linux-kernel@vger.kernel.org,
 jarod@redhat.com, paulus@samba.org, hofrat@osadl.org,
 Marcelo Ricardo Leitner <mleitner@redhat.com>,
 Tom Herbert <tom@herbertland.com>, linuxppc-dev@lists.ozlabs.org,
 David Miller <davem@davemloft.net>
To: Jonathan Maxwell <jmaxwell37@gmail.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <CAGHK07Cvh2QnGrUg5eu_aC=cV7DaL9wJm8adZ0rv4s0DmF-tzw@mail.gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On 11/06/2016 03:22 PM, Jonathan Maxwell wrote:
> On Thu, Nov 3, 2016 at 8:40 AM, Brian King <brking@linux.vnet.ibm.com> wrote:
>> On 10/27/2016 10:26 AM, Eric Dumazet wrote:
>>> On Wed, 2016-10-26 at 11:09 +1100, Jon Maxwell wrote:
>>>> We recently encountered a bug where a few customers using ibmveth on the
>>>> same LPAR hit an issue where a TCP session hung when large receive was
>>>> enabled. Closer analysis revealed that the session was stuck because the
>>>> one side was advertising a zero window repeatedly.
>>>>
>>>> We narrowed this down to the fact the ibmveth driver did not set gso_size
>>>> which is translated by TCP into the MSS later up the stack. The MSS is
>>>> used to calculate the TCP window size and as that was abnormally large,
>>>> it was calculating a zero window, even although the sockets receive buffer
>>>> was completely empty.
>>>>
>>>> We were able to reproduce this and worked with IBM to fix this. Thanks Tom
>>>> and Marcelo for all your help and review on this.
>>>>
>>>> The patch fixes both our internal reproduction tests and our customers tests.
>>>>
>>>> Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
>>>> ---
>>>>  drivers/net/ethernet/ibm/ibmveth.c | 20 ++++++++++++++++++++
>>>>  1 file changed, 20 insertions(+)
>>>>
>>>> diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
>>>> index 29c05d0..c51717e 100644
>>>> --- a/drivers/net/ethernet/ibm/ibmveth.c
>>>> +++ b/drivers/net/ethernet/ibm/ibmveth.c
>>>> @@ -1182,6 +1182,8 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
>>>>      int frames_processed = 0;
>>>>      unsigned long lpar_rc;
>>>>      struct iphdr *iph;
>>>> +    bool large_packet = 0;
>>>> +    u16 hdr_len = ETH_HLEN + sizeof(struct tcphdr);
>>>>
>>>>  restart_poll:
>>>>      while (frames_processed < budget) {
>>>> @@ -1236,10 +1238,28 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
>>>>                                              iph->check = 0;
>>>>                                              iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
>>>>                                              adapter->rx_large_packets++;
>>>> +                                            large_packet = 1;
>>>>                                      }
>>>>                              }
>>>>                      }
>>>>
>>>> +                    if (skb->len > netdev->mtu) {
>>>> +                            iph = (struct iphdr *)skb->data;
>>>> +                            if (be16_to_cpu(skb->protocol) == ETH_P_IP &&
>>>> +                                iph->protocol == IPPROTO_TCP) {
>>>> +                                    hdr_len += sizeof(struct iphdr);
>>>> +                                    skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
>>>> +                                    skb_shinfo(skb)->gso_size = netdev->mtu - hdr_len;
>>>> +                            } else if (be16_to_cpu(skb->protocol) == ETH_P_IPV6 &&
>>>> +                                       iph->protocol == IPPROTO_TCP) {
>>>> +                                    hdr_len += sizeof(struct ipv6hdr);
>>>> +                                    skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
>>>> +                                    skb_shinfo(skb)->gso_size = netdev->mtu - hdr_len;
>>>> +                            }
>>>> +                            if (!large_packet)
>>>> +                                    adapter->rx_large_packets++;
>>>> +                    }
>>>> +
>>>>
>>>
>>> This might break forwarding and PMTU discovery.
>>>
>>> You force gso_size to device mtu, regardless of real MSS used by the TCP
>>> sender.
>>>
>>> Don't you have the MSS provided in RX descriptor, instead of guessing
>>> the value ?
>>
>> We've had some further discussions on this with the Virtual I/O Server (VIOS)
>> development team. The large receive aggregation in the VIOS (AIX based) is actually
>> being done by software in the VIOS. What they may be able to do is when performing
>> this aggregation, they could look at the packet lengths of all the packets being
>> aggregated and take the largest packet size within the aggregation unit, minus the
>> header length and return that to the virtual ethernet client which we could then stuff
>> into gso_size. They are currently assessing how feasible this would be to do and whether
>> it would impact other bits of the code. However, assuming this does end up being an option,
>> would this address the concerns here or is that going to break something else I'm
>> not thinking of?
> 
> I was discussing this with a colleague and although this is better than
> what we have so far. We wonder if there could be a corner case where
> it ends up with a smaller value than the current MSS. For example if
> the application sent a burst of small TCP packets with the PUSH
> bit set. In that case they may not be coalesced by GRO. The VIOS could

Would that be a big problem though? Other than a performance degradation
in this specific case, do you see a functional issue with this approach?

> probably be coded to detect that condition and use the previous MSS.
> But that may not necessarily be the current MSS.
> 
> The ibmveth driver passes the MSS via gso_size to the VIOS. Either as the
> 3rd argument of ibmveth_send() or via tcp_hdr(skb)->check which is
> presumably over-written when the VIOS does the TSO. Would it be possible
> to keep a copy of this value on the TX side on the VIOS before it over-written
> and then some how pass that up to the RX side along with frame and set
> gso_size to that which should be the current MSS?

That seems like it might be more difficult. Wouldn't that require the VIOS
to track the MSS on a per connection basis, since the MSS might differ
based on the source / destination? I discussed with VIOS development, and
they don't do any connection tracking where they'd be able to insert this.

Unless there is a functional issue with the approach to have the VIOS insert
the MSS based on the size of the packets received off the wire, I think that
might be our best option...

Thanks,

Brian



> 
> Regards
> 
> Jon
> 
>>
>> Unfortunately, I don't think we'd have a good way to get gso_segs set correctly as I don't
>> see how that would get passed back up the interface.
>>
>> Thanks,
>>
>> Brian
>>
>>
>> --
>> Brian King
>> Power Linux I/O
>> IBM Linux Technology Center
>>
> 


-- 
Brian King
Power Linux I/O
IBM Linux Technology Center
