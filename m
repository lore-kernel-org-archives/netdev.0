From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Wed, 21 Dec 2016 14:04:31 -0500 (EST)
Message-ID: <20161221.140431.1651188849352763159.davem@davemloft.net>
References: <CAM_iQpXWCWMKDjLVTLuHNSKKGq5MWf5ZRLpyE=PDD3EgQ7PS4Q@mail.gmail.com>
        <1482323232.2260.2.camel@stressinduktion.org>
        <1482324073.2260.4.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davej@codemonkey.org.uk,
        netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34360 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756310AbcLUTEf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 14:04:35 -0500
In-Reply-To: <1482324073.2260.4.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 21 Dec 2016 13:41:13 +0100

> On Wed, 2016-12-21 at 13:27 +0100, Hannes Frederic Sowa wrote: 
>> @@ -555,8 +566,8 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
>>                 goto out;
>>  
>>         offset = rp->offset;
>> -       total_len = inet_sk(sk)->cork.base.length;
>> -       if (offset >= total_len - 1) {
>> +       transport_len = raw6_corked_transport_len(sk);
>> +       if (offset >= transport_len - 1) {
>>                 err = -EINVAL;
>>                 ip6_flush_pending_frames(sk);
>>                 goto out;
>> @@ -598,7 +609,7 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
>>                 tmp_csum = csum_sub(tmp_csum, csum_unfold(csum));
>>  
>>         csum = csum_ipv6_magic(&fl6->saddr, &fl6->daddr,
>> -                              total_len, fl6->flowi6_proto, tmp_csum);
>> +                              transport_len, fl6->flowi6_proto, tmp_csum);
>>  
>> 
> 
> Ops, here we need actually the total_len plus the opt->opt_nflen to
> always calculate the correct checksum.

It's a real shame we can't just use skb_transport_offset().  This value
has essentially been calculated for us already.

Also, if we iterate over multiple SKBs in the write queue, don't you have
to redo this calculation for every SKB we iterate over?

Furthermore, what if the user queued up some SKBs in the raw socket
with MSG_MORE, and then changed some of the options for a subsequent
sendmsg() call?

Given all of this, I think the best thing to do is validate the offset
after the queue walks, which is pretty much what Dave Jones's original
patch was doing.

Sigh... well, at least we now understand what's going on here.
