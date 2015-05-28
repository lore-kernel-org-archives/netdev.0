From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] xfrm6: Do not use xfrm_local_error for path MTU issues
 in tunnels
Date: Thu, 28 May 2015 12:15:43 -0700
Message-ID: <5567695F.6070505@gmail.com>
References: <20150527173823.1415.96248.stgit@ahduyck-vm-fedora22> <20150528053607.GF27342@secunet.com> <5566C15B.7090403@gmail.com> <20150528084002.GI27342@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150528084002.GI27342@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/28/2015 01:40 AM, Steffen Klassert wrote:
> On Thu, May 28, 2015 at 12:18:51AM -0700, Alexander Duyck wrote:
>> On 05/27/2015 10:36 PM, Steffen Klassert wrote:
>>> On Wed, May 27, 2015 at 10:40:32AM -0700, Alexander Duyck wrote:
>>>> This change makes it so that we use icmpv6_send to report PMTU issues back
>>>> into tunnels in the case that the resulting packet is larger than the MTU
>>>> of the outgoing interface.  Previously xfrm_local_error was being used in
>>>> this case, however this was resulting in no changes, I suspect due to the
>>>> fact that the tunnel itself was being kept out of the loop.
>>>>
>>>> This patch fixes PMTU problems seen on ip6_vti tunnels and is based on the
>>>> behavior seen if the socket was orphaned.  Instead of requiring the socket
>>>> to be orphaned this patch simply defaults to using icmpv6_send in the case
>>>> that the frame came though a tunnel.
>>> We can use icmpv6_send() just in the case that the packet
>>> was already transmitted by a tunnel device, otherwise we
>>> get the bug back that I mentioned in my other mail.
>>>
>>> Not sure if we have something to know that the packet
>>> traversed a tunnel device. That's what I asked in the
>>> thread 'Looking for a lost patch'.
>> Okay I will try to do some more digging.  From what I can tell right
>> now it looks like my ping attempts are getting hung up on the
>> xfrm_local_error in __xfrm6_output.  I wonder if we couldn't somehow
>> make use of the skb->cb to store a pointer to the tunnel that could
>> be checked to determine if we are going through a VTI or not.
> Maybe it is as easy as the patch below, could you please test it?
>
> Subject: [PATCH RFC] vti6: Add pmtu handling to vti6_xmit.
>
> We currently rely on the PMTU discovery of xfrm.
> However if a packet is localy sent, the PMTU mechanism
> of xfrm tries to to local socket notification what
> might not work for applications like ping that don't
> check for this. So add pmtu handling to vti6_xmit to
> report MTU changes immediately.
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>   net/ipv6/ip6_vti.c | 10 ++++++++++
>   1 file changed, 10 insertions(+)
>
> diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
> index ff3bd86..13cb771 100644
> --- a/net/ipv6/ip6_vti.c
> +++ b/net/ipv6/ip6_vti.c
> @@ -434,6 +434,7 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
>   	struct dst_entry *dst = skb_dst(skb);
>   	struct net_device *tdev;
>   	struct xfrm_state *x;
> +	int mtu;
>   	int err = -1;
>   
>   	if (!dst)
> @@ -468,6 +469,15 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
>   	skb_dst_set(skb, dst);
>   	skb->dev = skb_dst(skb)->dev;
>   
> +	mtu = dst_mtu(dst);
> +	if (!skb->ignore_df && skb->len > mtu) {
> +		skb_dst(skb)->ops->update_pmtu(dst, NULL, skb, mtu);
> +
> +		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
> +
> +		return -EMSGSIZE;
> +	}
> +
>   	err = dst_output(skb);
>   	if (net_xmit_eval(err) == 0) {
>   		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);

That seems to be working for me.  I'm able to ping and while the first 
packet fails the second one and all that follow make it through 
correctly after the ptmu update.

- Alex
