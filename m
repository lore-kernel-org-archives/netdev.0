From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 06/13] net: original ingress device index in
 PKTINFO
Date: Thu, 5 May 2016 09:00:34 -0600
Message-ID: <572B6012.60806@cumulusnetworks.com>
References: <1462419210-10463-1-git-send-email-dsa@cumulusnetworks.com>
 <1462419210-10463-7-git-send-email-dsa@cumulusnetworks.com>
 <alpine.LFD.2.11.1605051040320.2118@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:36941 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756507AbcEEPAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 11:00:39 -0400
Received: by mail-ig0-f171.google.com with SMTP id s8so16067274ign.0
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 08:00:38 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1605051040320.2118@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/5/16 2:41 AM, Julian Anastasov wrote:
>
> 	Hello,
>
> On Wed, 4 May 2016, David Ahern wrote:
>
>> Applications such as OSPF and BFD need the original ingress device not
>> the VRF device; the latter can be derived from the former. To that end
>> add the skb_iif to inet_skb_parm and set it in ipv4 code after clearing
>> the skb control buffer similar to IPv6. From there the pktinfo can just
>> pull it from cb with the PKTINFO_SKB_CB cast.
>>
>> The previous patch moving the skb->dev change to L3 means nothing else
>> is needed for IPv6; it just works.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>> ---
>>   include/net/ip.h       | 1 +
>>   net/ipv4/ip_input.c    | 1 +
>>   net/ipv4/ip_sockglue.c | 9 +++++++--
>>   3 files changed, 9 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/net/ip.h b/include/net/ip.h
>> index 247ac82e9cf2..37165fba3741 100644
>> --- a/include/net/ip.h
>> +++ b/include/net/ip.h
>> @@ -36,6 +36,7 @@
>>   struct sock;
>>
>>   struct inet_skb_parm {
>> +	int			iif;
>>   	struct ip_options	opt;		/* Compiled IP options		*/
>>   	unsigned char		flags;
>>
>> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
>> index 37375eedeef9..4b351af3e67b 100644
>> --- a/net/ipv4/ip_input.c
>> +++ b/net/ipv4/ip_input.c
>> @@ -478,6 +478,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
>>
>>   	/* Remove any debris in the socket control block */
>>   	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
>> +	IPCB(skb)->iif = skb->skb_iif;
>
> 	For loopback traffic (including looped back multicast)
> this is now a zero :( Can inet_iif be moved to ip_rcv_finish
> instead? Still, we spend cycles in fast path in case nobody
> listens for such info.

Why is that? skb_iif is set to skb->dev->index in 
__netif_receive_skb_core and ip_rcv is called it. Is there another path 
to it?


>
>>   	/* Must drop socket now because of tproxy. */
>>   	skb_orphan(skb);
>> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
>> index bdb222c0c6a2..dbcd027c38e7 100644
>> --- a/net/ipv4/ip_sockglue.c
>> +++ b/net/ipv4/ip_sockglue.c
>> @@ -476,9 +476,9 @@ static bool ipv4_datagram_support_cmsg(const struct sock *sk,
>>   	    (!skb->dev))
>>   		return false;
>>
>> +	/* see comment in ipv4_pktinfo_prepare about CB re-use */
>>   	info = PKTINFO_SKB_CB(skb);
>>   	info->ipi_spec_dst.s_addr = ip_hdr(skb)->saddr;
>> -	info->ipi_ifindex = skb->dev->ifindex;
>
> 	This code is only for SOF_TIMESTAMPING_OPT_CMSG.
> I'm not sure skb passes ip_rcv in all cases. So, we can not
> easily remove it.

ok.
