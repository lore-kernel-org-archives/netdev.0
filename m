From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netlink: add NETLINK_BROADCAST_REPORT_ERROR socket option
Date: Mon, 16 Feb 2009 15:10:36 +0100
Message-ID: <499973DC.3000208@netfilter.org>
References: <20090216105200.29072.99944.stgit@Decadence> <49994A70.5000502@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49495 "EHLO us.es"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756390AbZBPOCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2009 09:02:24 -0500
In-Reply-To: <49994A70.5000502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Pablo Neira Ayuso wrote:
>> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
>> index 6ee69c2..29dd4fb 100644
>> --- a/net/netlink/af_netlink.c
>> +++ b/net/netlink/af_netlink.c
>> @@ -85,6 +85,7 @@ struct netlink_sock {
>>  
>>  #define NETLINK_KERNEL_SOCKET    0x1
>>  #define NETLINK_RECV_PKTINFO    0x2
>> +#define NETLINK_BROADCAST_SEND_REPORT_ERROR    0x4
> 
> The name seems to imply send twice (send/report).

Indeed. I didn't like this initial name a lot.

>>  static inline struct netlink_sock *nlk_sk(struct sock *sk)
>>  {
>> @@ -994,13 +995,15 @@ static inline int do_one_broadcast(struct sock *sk,
>>      if (p->skb2 == NULL) {
>>          netlink_overrun(sk);
>>          /* Clone failed. Notify ALL listeners. */
>> -        p->failure = 1;
>> +        if (nlk->flags & NETLINK_BROADCAST_SEND_REPORT_ERROR)
>> +            p->failure = 1;
> 
> This doesn't make sense. *Other* sockets get skipped only iff
> this socket had the error-report flag set? This should be done
> in a consistent manner, which means either not set the failure
> flag at all and retry for all sockets, or set it for any failed
> socket delivery and determine the return value based on whether
> one of the skipped sockets had the error-report flag set.

I can add a check for the flag to allow sockets without the flag set to 
try to send the message:

         if ((nlk->flags & NETLINK_BROADCAST_SEND_ERROR) && p->failure) {
                 netlink_overrun(sk);
                 goto out;
         }

Still, this "skip" behaviour looks to me strange. I don't see why a 
socket should skip if other socket's clone failed. Wouldn't it be better 
to remove this?

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
