From: Yi Li <lovelylich@gmail.com>
Subject: Why tcp_sacktag_walk specially process next_dup?
Date: Tue, 25 Dec 2012 18:35:41 +0800
Message-ID: <50D9817D.2010206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:38639 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641Ab2LYKfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2012 05:35:45 -0500
Received: by mail-da0-f51.google.com with SMTP id i30so3454935dad.38
        for <netdev@vger.kernel.org>; Tue, 25 Dec 2012 02:35:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ilpo,
I am a kernel newbie, maybe this question is simple.
If you have some free time, could you help me ?

I am reading your commit 
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=68f8353b480e5f2e136c38a511abdbb88eaa8ce2, 
through this code path:

tcp_sacktag_write_queue() {
     if (tcp_sack_cache_ok(tp, cache) && !dup_sack &&
             after(end_seq, cache->start_seq)) {

             /* Head todo? */
             if (before(start_seq, cache->start_seq)) {
                         skb = tcp_sacktag_skip(skb, sk, &state,
                                start_seq);
                 skb = tcp_sacktag_walk(skb, sk, next_dup,
                                &state,
                                start_seq,
                                cache->start_seq,
                                dup_sack);
             }

}

and when we come to tcp_sacktag_walk(), comparing the current processing 
sack block
with cache, we have:  start_seq < cache->start_seq, and we now need to 
process the
bytes between (start_seq, cache->start_seq) in tcp_write_queue.

But in tcp_sacktag_walk(), why we first check the seqence space in 
next_dup ?
I know this is about D-SACK, and I have read the rfc2883, but I am still 
confused.
I have some questions:
1. Why we introduce a next_dup variable in SACK processing, is it better 
for performance optimization?
      As there is dup_sack variable, will this pre-processing of sack 
block be mixed with dup_sack ?
2. What does this test statement means in tcp_sacktag_walk:
      if ((next_dup != NULL) &&
             before(TCP_SKB_CB(skb)->seq, next_dup->end_seq)) { 
---------------------> A
             in_sack = tcp_match_skb_to_sack(sk, skb,
                             next_dup->start_seq,
                             next_dup->end_seq);
             if (in_sack > 0)
                 dup_sack = true;
         }
as far as i know, if tcp_skb_pcout(skb)>1, this condition maybe exist:
        skb->seq   < current_sack_block.start_seq < 
current_sack_block.end_seq < next_dup->start_seq < next_dup->end_seq.
So, I do not understand what the code A really does.
