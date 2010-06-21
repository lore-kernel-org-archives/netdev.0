From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Code flow: tcp_input.c : tcp_prune_queue : Dropping frames
Date: Mon, 21 Jun 2010 14:25:09 -0700
Message-ID: <A76B6C17-B457-4DCA-82C6-A801E1E4D25B@earthlink.net>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:35070 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758492Ab0FUVZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 17:25:51 -0400
Received: from [71.202.111.27] (helo=[192.168.1.3])
	by elasmtp-galgo.atl.sa.earthlink.net with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.67)
	(envelope-from <erblichs@earthlink.net>)
	id 1OQoUq-000195-DJ
	for netdev@vger.kernel.org; Mon, 21 Jun 2010 17:25:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

group,

The tcp_prune_queue() calls tcp_collapse() is called to
prevent frames/pkts from being dropped due to buffer
?"ooo"? overcommit.

However, tcp_collapse() calls alloc_skb() with GFP_ATOMIC
which can grab the last of reserveable memory.

nskb = alloc_skb(copy + header, GFP_ATOMIC); 
if (!nskb) 
     return; 

It should be called with GFP_NOWAIT to keep the NON-SLEEP
aspect of the mem reservation, but not grap the last bits of mem.

Because, if the over-commit was that bad, all other allocations
have ALREADY STARTED TO FAIL. The system SHOULD be
dead.

Secondly, if the alloc failed, why try to do the reclaim?

Thus, 

  tcp_collapse() should return int instead of void and the
  alloc return should return -1 upon failure.

  tcp_prune_queue_should check for the return and skip
  sk_mem_reclaim().

  Why not some logging message?
  Didn't see one.

  Rename ofo to "ooo" as this is known as "out-of-order".

  Lastly, follow-up should be done to identify the GFP_ mem
  type and SHOULD not be alloc'ing mem with ATOMIC
  for an "out-of-order" queue as this COULD be a form of
  DENIAL of Service (DoS) attack.

Mitchell Erblich

   





