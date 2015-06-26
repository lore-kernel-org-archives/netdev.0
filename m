From: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Subject: Re: [PATCH] - vxlan: gro not effective for intel 82599
Date: Thu, 25 Jun 2015 18:06:08 -0700
Message-ID: <0b2eff60824ac7b7d3a672da9be9bf99@imap.linux.ibm.com>
References: <5981772fe36e64f8fec5997a4c7aa08f@imap.linux.ibm.com>
 <CALx6S36JQaPg9Otg4pv5ah16JGaEXzo1xDL4jXKBdziUTVvXmw@mail.gmail.com>
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
Received: from e18.ny.us.ibm.com ([129.33.205.208]:44311 "EHLO
	e18.ny.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbbFZBGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 21:06:16 -0400
Received: from /spool/local
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sramamur@linux.vnet.ibm.com>;
	Thu, 25 Jun 2015 21:06:15 -0400
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2C045C90046
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 20:57:18 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t5Q16BVG64291048
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 01:06:11 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t5Q169TL022898
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 21:06:11 -0400
In-Reply-To: <CALx6S36JQaPg9Otg4pv5ah16JGaEXzo1xDL4jXKBdziUTVvXmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-06-25 17:20, Tom Herbert wrote:
> On Thu, Jun 25, 2015 at 5:03 PM, Ramu Ramamurthy
> <sramamur@linux.vnet.ibm.com> wrote:
>> Problem:
>> -------
>> 
>> GRO is enabled on the interfaces in the following test,
>> but GRO does not take effect for vxlan-encapsulated tcp streams. The 
>> root
>> cause of why GRO does not take effect is described below.
>> 
>> VM nic (mtu 1450)---bridge---vxlan----10Gb nic (intel 82599ES)-----|
>> VM nic (mtu 1450)---bridge---vxlan----10Gb nic (intel 82599ES)-----|
>> 
>> Because gro is not effective, the throughput for vxlan-encapsulated
>> tcp-stream is around 3 Gbps.
>> 
>> With the proposed patch, gro takes effect for vxlan-encapsulated tcp
>> streams,
>> and performance in the same test is around 8.6 Gbps.
>> 
>> 
>> Root Cause:
>> ----------
>> 
>> 
>> At entry to udp4_gro_receive(), the gro parameters are set as follows:
>> 
>>     skb->ip_summed  == 0 (CHECKSUM_NONE)
>>     NAPI_GRO_CB(skb)->csum_cnt == 0
>>     NAPI_GRO_CB(skb)->csum_valid == 0
>> 
>>     UDH header checksum is 0.
>> 
>> static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
>>                                          struct sk_buff *skb)
>> {
>> 
>>          <snip>
>> 
>>         if (skb_gro_checksum_validate_zero_check(skb, IPPROTO_UDP,
>> uh->check,
>>                                                  
>> inet_gro_compute_pseudo))
>> 
>>>>>             This calls __skb_incr_checksum_unnecessary which sets
>>>>>                     skb->ip_summed to  CHECKSUM_UNNECESSARY
>>>>> 
>> 
>>                 goto flush;
>>         else if (uh->check)
>>                 skb_gro_checksum_try_convert(skb, IPPROTO_UDP, 
>> uh->check,
>>                                              inet_gro_compute_pseudo);
>> skip:
>>         NAPI_GRO_CB(skb)->is_ipv6 = 0;
>>         return udp_gro_receive(head, skb, uh);
>> 
>> }
>> 
>> struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff 
>> *skb,
>>                                  struct udphdr *uh)
>> {
>>         struct udp_offload_priv *uo_priv;
>>         struct sk_buff *p, **pp = NULL;
>>         struct udphdr *uh2;
>>         unsigned int off = skb_gro_offset(skb);
>>         int flush = 1;
>> 
>>         if (NAPI_GRO_CB(skb)->udp_mark ||
>>             (skb->ip_summed != CHECKSUM_PARTIAL &&
>>              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
>>              !NAPI_GRO_CB(skb)->csum_valid))
>>                 goto out;
>>>>> 
>>>>> 
>>>>>      vxlan GRO gets skipped due to the above condition because 
>>>>> here,:
>>>>>          skb->ip_summed == CHECKSUM_UNNECESSARY
>>>>>          NAPI_GRO_CB(skb)->csum_cnt == 0
>>>>>          NAPI_GRO_CB(skb)->csum_valid == 0
>> 
>> 
>> There is no reason for skipping vxlan gro in the above combination of
>> conditions,
>> because, tcp4_gro_receive() validates the inner tcp checksum anyway !
>> 
>> 
>> Patch:
>> ------
>> 
>> Signed-off-by: Ramu Ramamurthy <ramu.ramamurthy@us.ibm.com>
>> ---
>>  net/ipv4/udp_offload.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>> 
>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>> index f938616..17fc12b 100644
>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>> @@ -301,6 +301,7 @@ struct sk_buff **udp_gro_receive(struct sk_buff 
>> **head,
>> struct sk_buff *skb,
>> 
>>         if (NAPI_GRO_CB(skb)->udp_mark ||
>>             (skb->ip_summed != CHECKSUM_PARTIAL &&
>> +            skb->ip_summed != CHECKSUM_UNNECESSARY &&
>>              NAPI_GRO_CB(skb)->csum_cnt == 0 &&
>>              !NAPI_GRO_CB(skb)->csum_valid))
>>                 goto out;
>> --
> 
> This isn't right. The CHECKSUM_UNNECESSARY only refers to the outer
> checksum which is zero in this case so it is trivially unnecessary.
> The inner checksum still needs to be computed on the host. By
> convention, we do not do GRO if it is required to compute the inner
> checksum (csum_cnt == 0 checks that). If we want to allow checksum
> calculation to occur in the GRO path, meaning we understand the
> ramifications and can show this is better for performance, then all
> the checks about checksum here should be removed.
> 

Isnt the inner checksum computed on the gro-path from tcp4_gro_receive() 
as follows ?
This trace is from my testbed.

In my tests, I consistently get 8.5-9 Gbps with vxlan gro (inspite of
the added sw inner checksumming), whereas without vxlan GRO  the 
performance
drops down to 3Gbps or so. So, a significant performance benefit can be 
gained
on intel 10G nics which are widely deployed. Hence the interest in 
pursuing this or a modified patch.

      vxlan_gro_receive <-udp4_gro_receive
      ksoftirqd/1-94    [001] ..s. 11421.420280: __pskb_pull_tail 
<-vxlan_gro_receive
      ksoftirqd/1-94    [001] ..s. 11421.420280: skb_copy_bits 
<-__pskb_pull_tail
      ksoftirqd/1-94    [001] ..s. 11421.420280: __pskb_pull_tail 
<-vxlan_gro_receive
      ksoftirqd/1-94    [001] ..s. 11421.420281: skb_copy_bits 
<-__pskb_pull_tail
      ksoftirqd/1-94    [001] ..s. 11421.420281: gro_find_receive_by_type 
<-vxlan_gro_receive
      ksoftirqd/1-94    [001] ..s. 11421.420281: inet_gro_receive 
<-vxlan_gro_receive
      ksoftirqd/1-94    [001] ..s. 11421.420281: __pskb_pull_tail 
<-inet_gro_receive
      ksoftirqd/1-94    [001] ..s. 11421.420281: skb_copy_bits 
<-__pskb_pull_tail
      ksoftirqd/1-94    [001] ..s. 11421.420281: tcp4_gro_receive 
<-inet_gro_receive
      ksoftirqd/1-94    [001] ..s. 11421.420281: 
__skb_gro_checksum_complete <-tcp4_gro_receive
      ksoftirqd/1-94    [001] ..s. 11421.420281: skb_checksum 
<-__skb_gro_checksum_complete
      ksoftirqd/1-94    [001] ..s. 11421.420281: __skb_checksum 
<-skb_checksum
      ksoftirqd/1-94    [001] ..s1 11421.420281: csum_partial 
<-csum_partial_ext
      ksoftirqd/1-94    [001] ..s1 11421.420281: do_csum <-csum_partial



>> 1.7.1
>> 
>> 
>> 
>> 
>> 
>> Notes:
>> -------
>> 
>> The above gro fix applies to all udp-encapsulation protocols (vxlan, 
>> geneve)
>> 
>> 
>> 
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
