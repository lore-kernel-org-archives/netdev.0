From: Tom Quetchenbach <virtualphtn@gmail.com>
Subject: [PATCH 0/2] David Miller's rbtree patches for 2.6.22.6
Date: Wed, 19 Sep 2007 18:39:01 -0700
Message-ID: <46F1CF35.3030606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing-mail.its.caltech.edu ([131.215.239.19]:36149 "EHLO
	outgoing-mail.its.caltech.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750795AbXITBu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 21:50:56 -0400
Received: from water-dog.its.caltech.edu (water-dog [192.168.1.26])
	by fire-ox-postvirus (Postfix) with ESMTP id 4474613FA7
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 18:39:03 -0700 (PDT)
Received: from [10.1.234.14] (mystic.caltech.edu [131.215.220.112])
	(Authenticated sender: quetchen)
	by water-ox.its.caltech.edu (Postfix) with ESMTP id C252E1BBE5
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 18:39:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I've been experimenting with David Miller's red-black tree patch for
SACK processing. We're sending TCP traffic between two machines with
10Gbps cards over a 1Gbps bottleneck link and were getting very high CPU
load with large windows. With a few tweaks, this patch seems to provide
a pretty substantial improvement. David: this seems like excellent work
so far.

Here are a couple of patches against 2.6.22.6. The first one is just
David's patches tweaked for 2.6.22.6, with a couple of minor bugfixes to
get it to compile and not crash. (I also changed
__tcp_insert_write_queue_tail() to set the fack_count of the new packet
to the fack_count of the tail plus the packet count of the tail, not the
packet count of the new skb, because I think that's how it was intended
to be. Right?

In the second patch there are a couple of significant changes.  One is
(as Baruch suggested) to modify the existing SACK fast path so that we
don't tag packets we've already tagged when we advance by a packet.

The other issue is that the cached fack_counts seem to be wrong, because
they're set when we insert into the queue, but tcp_set_tso_segs() is
called later, just before we send, so all the fack_counts are zero. My
solution was to set the fack_count when we advance the send_head. Also I
changed tcp_reset_fack_counts() so that it exits when it hits an skb
whose tcp_skb_pcount() is zero or whose fack_count is already correct.
(This really helps when TSO is on, since there's lots of inserting into
the middle of the queue.)

Please let me know how I can help get this tested and debugged. Reducing
the SACK processing load is really going to be essential for us to start
testing experimental TCP variants with large windows.

Thanks
-Tom


