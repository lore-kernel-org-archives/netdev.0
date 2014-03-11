From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 02/11] bnx2: Call dev_kfree_skby_any instead of dev_kfree_skb.
Date: Mon, 10 Mar 2014 21:10:26 -0700
Message-ID: <87eh29ml3h.fsf@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
	<871ty9qvaf.fsf_-_@xmission.com> <87ppltpgme.fsf_-_@xmission.com>
	<1394509677.21721.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47674 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbaCKEKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 00:10:34 -0400
In-Reply-To: <1394509677.21721.4.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Mon, 10 Mar 2014 20:47:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Mon, 2014-03-10 at 20:18 -0700, Eric W. Biederman wrote:
>> Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
>> be called in hard irq and other contexts.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>  drivers/net/ethernet/broadcom/bnx2.c |   10 +++++-----
>>  1 files changed, 5 insertions(+), 5 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
>> index ca6b36220d94..c94735de808d 100644
>> --- a/drivers/net/ethernet/broadcom/bnx2.c
>> +++ b/drivers/net/ethernet/broadcom/bnx2.c
>> @@ -2885,7 +2885,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
>>  		sw_cons = BNX2_NEXT_TX_BD(sw_cons);
>>  
>>  		tx_bytes += skb->len;
>> -		dev_kfree_skb(skb);
>> +		dev_kfree_skb_any(skb);
>
> This looks like a dev_consume_skb_any() candidate ?

That seems reasonable.  I am focusing on one dimension at a time.

> Anyway, why can this be called from hard irq ?

netpoll_poll_dev
   bnx2_poll
     bnx2_poll_work
       bnx2_tx_int

> I'll stop my review here, it seems either me or you are confused/tired.

I did my best to verify the code paths I am changing actually exist.  I
think I even have a stack backtrace from skb_release_head_state around
somewhere.  Transmitted packets frequently have dst cache entries,
conntrack entries, and destructores which make them actually problematic
to free in hard irq context.

Eric
