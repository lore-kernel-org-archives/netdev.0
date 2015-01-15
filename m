From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next RFC 1/5] net-timestamp: no-payload option
Date: Thu, 15 Jan 2015 13:22:22 -0500
Message-ID: <CA+FuTSc+8NVkN=KdOzs7cFh=QNtX6-naGrj=xFODm54sX3JkzA@mail.gmail.com>
References: <1420824719-28848-1-git-send-email-willemb@google.com>
 <1420824719-28848-2-git-send-email-willemb@google.com> <20150111202650.GB4214@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Lutomirski <luto@amacapital.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:34643 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348AbbAOSWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 13:22:54 -0500
Received: by mail-qc0-f174.google.com with SMTP id c9so13491538qcz.5
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 10:22:53 -0800 (PST)
In-Reply-To: <20150111202650.GB4214@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2015 at 3:26 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Fri, Jan 09, 2015 at 12:31:55PM -0500, Willem de Bruijn wrote:
>> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
>> index a317797..d81ef70 100644
>> --- a/net/ipv4/ip_sockglue.c
>> +++ b/net/ipv4/ip_sockglue.c
>> @@ -440,7 +440,7 @@ static bool ipv4_pktinfo_prepare_errqueue(const struct sock *sk,
>>
>>       if ((ee_origin != SO_EE_ORIGIN_TIMESTAMPING) ||
>>           (!(sk->sk_tsflags & SOF_TIMESTAMPING_OPT_CMSG)) ||
>> -         (!skb->dev))
>> +         (!skb->dev) || (!skb->len))
>>               return false;
>
> Nit: You have already tested for the condition (!skb->len) ...

Thanks! I'll fix that when I send v1.

I had planned to do that today, but will hold off a bit to avoid merge
conflicts with a fix queued for net (http://patchwork.ozlabs.org/patch/429553/)

I will drop patches 4 and 5 when sending out v1, btw.
>
>>
>>       info->ipi_spec_dst.s_addr = ip_hdr(skb)->saddr;
>> @@ -483,7 +483,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>>
>>       serr = SKB_EXT_ERR(skb);
>>
>> -     if (sin) {
>> +     if (sin && skb->len) {
>>               sin->sin_family = AF_INET;
>>               sin->sin_addr.s_addr = *(__be32 *)(skb_network_header(skb) +
>>                                                  serr->addr_offset);
>> @@ -496,8 +496,9 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>>       sin = &errhdr.offender;
>>       sin->sin_family = AF_UNSPEC;
>>
>> -     if (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
>> -         ipv4_pktinfo_prepare_errqueue(sk, skb, serr->ee.ee_origin)) {
>> +     if (skb->len &&
>> +         (serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
>> +          ipv4_pktinfo_prepare_errqueue(sk, skb, serr->ee.ee_origin))) {
>
> ... here.
>
>>               struct inet_sock *inet = inet_sk(sk);
>>
>>               sin->sin_family = AF_INET;
>
> Thanks,
> Richard
