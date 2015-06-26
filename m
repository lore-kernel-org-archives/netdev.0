From: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Subject: Re: [PATCH] - vxlan: gro not effective for intel 82599
Date: Fri, 26 Jun 2015 10:36:08 -0700
Message-ID: <3df94e04daebca29c94b6d32fb372177@imap.linux.ibm.com>
References: <5981772fe36e64f8fec5997a4c7aa08f@imap.linux.ibm.com>
 <CALx6S36JQaPg9Otg4pv5ah16JGaEXzo1xDL4jXKBdziUTVvXmw@mail.gmail.com>
 <0b2eff60824ac7b7d3a672da9be9bf99@imap.linux.ibm.com>
 <CALx6S35o-KgViFy6dU5FXA=B2wCJFQjaGPxp22MMhUWP94ZS=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Benc <jbenc@redhat.com>, James Morris <jmorris@namei.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	pradeeps@linux.vnet.ibm.com, jkidambi@us.ibm.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:43834 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717AbbFZRgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 13:36:12 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sramamur@linux.vnet.ibm.com>;
	Fri, 26 Jun 2015 11:36:11 -0600
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id F3DCE1FF002E
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 11:27:19 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08025.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5QHZTTl57475274
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 10:35:29 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5QHa97f013253
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 11:36:10 -0600
In-Reply-To: <CALx6S35o-KgViFy6dU5FXA=B2wCJFQjaGPxp22MMhUWP94ZS=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-06-25 19:57, Tom Herbert wrote:
> On Thu, Jun 25, 2015 at 6:06 PM, Ramu Ramamurthy
> <sramamur@linux.vnet.ibm.com> wrote:
>> On 2015-06-25 17:20, Tom Herbert wrote:
>>> 
>>> On Thu, Jun 25, 2015 at 5:03 PM, Ramu Ramamurthy
>>> <sramamur@linux.vnet.ibm.com> wrote:
>>>> 
>>>> Problem:
>>>> -------
>>>> 
>>>> GRO is enabled on the interfaces in the following test,
>>>> but GRO does not take effect for vxlan-encapsulated tcp streams. The 
>>>> root
>>>> cause of why GRO does not take effect is described below.
>>>> 
>>>> VM nic (mtu 1450)---bridge---vxlan----10Gb nic (intel 82599ES)-----|
>>>> VM nic (mtu 1450)---bridge---vxlan----10Gb nic (intel 82599ES)-----|
>>>> 
>>>> Because gro is not effective, the throughput for vxlan-encapsulated
>>>> tcp-stream is around 3 Gbps.
>>>> 
>>>> With the proposed patch, gro takes effect for vxlan-encapsulated tcp
>>>> streams,
>>>> and performance in the same test is around 8.6 Gbps.
>>>> 
>>>> 
>>>> Root Cause:
>>>> ----------
>>>> 
>>>> 
>>>> At entry to udp4_gro_receive(), the gro parameters are set as 
>>>> follows:
>>>> 
>>>>     skb->ip_summed  == 0 (CHECKSUM_NONE)
>>>>     NAPI_GRO_CB(skb)->csum_cnt == 0
>>>>     NAPI_GRO_CB(skb)->csum_valid == 0
>>>> 
>>>>     UDH header checksum is 0.
>>>> 
>>>> static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
>>>>                                          struct sk_buff *skb)
>>>> {
>>>> 
>>>>          <snip>
>>>> 
>>>>         if (skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP,
>>>> uh->check,
>>>> 
>>>> inet_gro_compute_pseudo))
>>>> 
>>>>>>>             This calls __skb_incr_checksum_unnecessary which sets
>>>>>>>                     skb->ip_summed to  CHECKSUM_UNNECESSARY
>>>>>>> 
>>>> 
>>>>                 goto flush;
>>>>         else if (uh->check)
>>>>                 skb_gro_checksum_try_convert(skb, IPPROTO_UDP, 
>>>> uh->check,
>>>>                                              
>>>> inet_gro_compute_pseudo);
>>>> skip:
>>>>         NAPI_GRO_CB(skb)->is_ipv6 = 0;
>>>>         return udp_gro_receive(head, skb, uh);
>>>> 
>>>> }
>>>> 
>>>> struct sk_buff **udp_gro_receive(struct sk_buff **head, struct 
>>>> sk_buff
>>>> *skb,
>>>>                                  struct udphdr *uh)
>>>> {
>>>>         struct udp_offload_priv *uo_priv;
>>>>         struct sk_buff *p, **pp = NULL;
>>>>         struct udphdr *uh2;
>>>>         unsigned int off = skb_gro_offset(skb);
>>>>         int flush = 1;
>>>> 
>>>>         if (NAPI_GRO_CB(skb)->udp_mark ||
>>>>             (skb->ip_summed != CHECKSUM_PARTIAL &&
>>>>              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
>>>>              !NAPI_GRO_CB(skb)->csum_valid))
>>>>                 goto out;
>>>>>>> 
>>>>>>> 
>>>>>>> 
>>>>>>>      vxlan GRO gets skipped due to the above condition because 
>>>>>>> here,:
>>>>>>>          skb->ip_summed == CHECKSUM_UNNECESSARY
>>>>>>>          NAPI_GRO_CB(skb)->csum_cnt == 0
>>>>>>>          NAPI_GRO_CB(skb)->csum_valid == 0
>>>> 
>>>> 
>>>> 
>>>> There is no reason for skipping vxlan gro in the above combination 
>>>> of
>>>> conditions,
>>>> because, tcp4_gro_receive() validates the inner tcp checksum anyway 
>>>> !
>>>> 
>>>> 
>>>> Patch:
>>>> ------
>>>> 
>>>> Signed-off-by: Ramu Ramamurthy <ramu.ramamurthy@us.ibm.com>
>>>> ---
>>>>  net/ipv4/udp_offload.c |    1 +
>>>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>>> 
>>>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>>>> index f938616..17fc12b 100644
>>>> --- a/net/ipv4/udp_offload.c
>>>> +++ b/net/ipv4/udp_offload.c
>>>> @@ -301,6 +301,7 @@ struct sk_buff **udp_gro_receive(struct sk_buff
>>>> **head,
>>>> struct sk_buff *skb,
>>>> 
>>>>         if (NAPI_GRO_CB(skb)->udp_mark ||
>>>>             (skb->ip_summed != CHECKSUM_PARTIAL &&
>>>> +            skb->ip_summed != CHECKSUM_UNNECESSARY &&
>>>>              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
>>>>              !NAPI_GRO_CB(skb)->csum_valid))
>>>>                 goto out;
>>>> --
>>> 
>>> 
>>> This isn't right. The CHECKSUM_UNNECESSARY only refers to the outer
>>> checksum which is zero in this case so it is trivially unnecessary.
>>> The inner checksum still needs to be computed on the host. By
>>> convention, we do not do GRO if it is required to compute the inner
>>> checksum (csum_cnt == 0 checks that). If we want to allow checksum
>>> calculation to occur in the GRO path, meaning we understand the
>>> ramifications and can show this is better for performance, then all
>>> the checks about checksum here should be removed.
>>> 
>> 
>> Isnt the inner checksum computed on the gro-path from 
>> tcp4_gro_receive() as
>> follows ?
>> This trace is from my testbed.
>> 
>> In my tests, I consistently get 8.5-9 Gbps with vxlan gro (inspite of
>> the added sw inner checksumming), whereas without vxlan GRO  the 
>> performance
>> drops down to 3Gbps or so. So, a significant performance benefit can 
>> be
>> gained
>> on intel 10G nics which are widely deployed. Hence the interest in 
>> pursuing
>> this or a modified patch.
>> 
> That may be, but this change would affect all uses of GRO with UDP
> encapsulation not just for intel 10G NICs. For instance, pushing a lot
> of checksum calculation into the napi for a single queue device could
> overwhelm the corresponding CPU-- this is the motivation for the
> restriction in the first place. We need to do a little more diligence
> here.
> 
> Can you please provide more details about your tests and configuration
> (# of flows, #queues, etc.). Also, please try enabling UDP checksum
> this should eliminate need for checksum computation on the receiver
> and allow GRO to be used. Enabling RCO should then eliminate checksum
> computation on the host.
> 
> Thanks,
> Tom
> 

I am testing the simplest configuration which has 1 TCP flow generated 
by iperf from
a VM connected to a linux bridge with a vxlan tunnel interface. The 10G 
nic (82599 ES) has
multiple receive queues, but in this simple test, it is likely 
immaterial (because, the
tuple on which it hashes would be fixed). The real difference in 
performance appears to
be whether or not vxlan gro is performed by software.

The vxlan spec requires UDP checksums to be zero. So, we should expect 
by default, vxlan traffic coming
in with a zero checksum, either from other devices or operating systems.
          UDP Checksum: It SHOULD be transmitted as zero.  When a packet
          is received with a UDP checksum of zero, it MUST be accepted
          for decapsulation.  Optionally, if the encapsulating end point
          includes a non-zero UDP checksum, it MUST be correctly
          calculated across the entire packet including the IP header,
          UDP header, VXLAN header, and encapsulated MAC frame.
https://datatracker.ietf.org/doc/rfc7348/

The geneve spec also by default allows UDP checksums to be zero.
https://tools.ietf.org/html/draft-gross-geneve-00#section-3.3

In summary, if we can remove the checksum checks in udp_offload.c and 
allow by default to perform
vxlan/geneve GRO if configured.








>>      vxlan_gro_receive <-udp4_gro_receive
>>      ksoftirqd/1-94    [001] ..s. 11421.420280: __pskb_pull_tail
>> <-vxlan_gro_receive
>>      ksoftirqd/1-94    [001] ..s. 11421.420280: skb_copy_bits
>> <-__pskb_pull_tail
>>      ksoftirqd/1-94    [001] ..s. 11421.420280: __pskb_pull_tail
>> <-vxlan_gro_receive
>>      ksoftirqd/1-94    [001] ..s. 11421.420281: skb_copy_bits
>> <-__pskb_pull_tail
>>      ksoftirqd/1-94    [001] ..s. 11421.420281: 
>> gro_find_receive_by_type
>> <-vxlan_gro_receive
>>      ksoftirqd/1-94    [001] ..s. 11421.420281: inet_gro_receive
>> <-vxlan_gro_receive
>>      ksoftirqd/1-94    [001] ..s. 11421.420281: __pskb_pull_tail
>> <-inet_gro_receive
>>      ksoftirqd/1-94    [001] ..s. 11421.420281: skb_copy_bits
>> <-__pskb_pull_tail
>>      ksoftirqd/1-94    [001] ..s. 11421.420281: tcp4_gro_receive
>> <-inet_gro_receive
>>      ksoftirqd/1-94    [001] ..s. 11421.420281: 
>> __skb_gro_checksum_complete
>> <-tcp4_gro_receive
>>      ksoftirqd/1-94    [001] ..s. 11421.420281: skb_checksum
>> <-__skb_gro_checksum_complete
>>      ksoftirqd/1-94    [001] ..s. 11421.420281: __skb_checksum
>> <-skb_checksum
>>      ksoftirqd/1-94    [001] ..s1 11421.420281: csum_partial
>> <-csum_partial_ext
>>      ksoftirqd/1-94    [001] ..s1 11421.420281: do_csum <-csum_partial
>> 
>> 
>> 
>> 
>>>> 1.7.1
>>>> 
>>>> 
>>>> 
>>>> 
>>>> 
>>>> Notes:
>>>> -------
>>>> 
>>>> The above gro fix applies to all udp-encapsulation protocols (vxlan,
>>>> geneve)
>>>> 
>>>> 
>>>> 
>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> 
