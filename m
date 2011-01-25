From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: fix a bug that triggers large number of TCP RST
 by mistake
Date: Tue, 25 Jan 2011 13:48:16 -0800 (PST)
Message-ID: <20110125.134816.48501871.davem@davemloft.net>
References: <1295723177-23576-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751980Ab1AYVrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 16:47:41 -0500
In-Reply-To: <1295723177-23576-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Sat, 22 Jan 2011 11:06:17 -0800

> From: Jerry Chu <hkchu@google.com>
> 
> This patch fixes a bug that causes TCP RST packets to be generated
> on otherwise correctly behaved applications, e.g., no unread data
> on close,..., etc. To trigger the bug, at least two conditions must
> be met:
> 
> 1. The FIN flag is set on the last data packet, i.e., it's not on a
> separate, FIN only packet.
> 2. The size of the last data chunk on the receive side matches
> exactly with the size of buffer posted by the receiver, and the
> receiver closes the socket without any further read attempt.
> 
> This bug was first noticed on our netperf based testbed for our IW10
> proposal to IETF where a large number of RST packets were observed.
> netperf's read side code meets the condition 2 above 100%.
> 
> Before the fix, tcp_data_queue() will queue the last skb that meets
> condition 1 to sk_receive_queue even though it has fully copied out
> (skb_copy_datagram_iovec()) the data. Then if condition 2 is also met,
> tcp_recvmsg() often returns all the copied out data successfully
> without actually consuming the skb, due to a check
> "if ((chunk = len - tp->ucopy.len) != 0) {"
> and
> "len -= chunk;"
> after tcp_prequeue_process() that causes "len" to become 0 and an
> early exit from the big while loop.
> 
> I don't see any reason not to free the skb whose data have been fully
> consumed in tcp_data_queue(), regardless of the FIN flag.  We won't
> get there if MSG_PEEK is on. Am I missing some arcane cases related
> to urgent data?
> 
> Signed-off-by: H.K. Jerry Chu <hkchu@google.com>

This bug goes as far back as January, 2000 right after the softnet
mega-merge happened via the netdev CVS tree (netdev-vger-cvs GIT
commit 214d457e)

Good work, applied, thanks!
