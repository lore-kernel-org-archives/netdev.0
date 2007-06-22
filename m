From: Zach Brown <zach.brown@oracle.com>
Subject: [PATCH] sctp: lock_sock_nested in sctp_sock_migrate
Date: Fri, 22 Jun 2007 15:14:46 -0700
Message-ID: <20070622221446.GB7547@mami.zabbo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Arjan van de Ven <arjan@linux.intel.com>
To: vladislav.yasevich@hp.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from tetsuo.zabbo.net ([207.173.201.20]:36872 "EHLO tetsuo.zabbo.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049AbXFVWiy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 18:38:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not sure that I've gotten either the sctp or lockdep details right,
but with this patch I don't get lockdep yelling at me any more :)

------

sctp: lock_sock_nested in sctp_sock_migrate

sctp_sock_migrate() grabs the socket lock on a newly allocated socket while
holding the socket lock on an old socket.  lockdep worries that this might
be a recursive lock attempt.

 task/3026 is trying to acquire lock:
  (sk_lock-AF_INET){--..}, at: [<ffffffff88105b8c>] sctp_sock_migrate+0x2e3/0x327 [sctp]
 but task is already holding lock:
  (sk_lock-AF_INET){--..}, at: [<ffffffff8810891f>] sctp_accept+0xdf/0x1e3 [sctp]

This patch tells lockdep that this locking is safe by using
lock_sock_nested().

Signed-off-by: Zach Brown <zach.brown@oracle.com>

diff -r 8adcfdf2545b net/sctp/socket.c
--- a/net/sctp/socket.c	Fri Jun 22 11:11:33 2007 -0700
+++ b/net/sctp/socket.c	Fri Jun 22 15:05:22 2007 -0700
@@ -6084,8 +6084,11 @@ static void sctp_sock_migrate(struct soc
 	 * queued to the backlog.  This prevents a potential race between
 	 * backlog processing on the old socket and new-packet processing
 	 * on the new socket.
-	 */
-	sctp_lock_sock(newsk);
+	 *
+	 * The caller has just allocated newsk so we can guarantee that other
+	 * paths won't try to lock it and then oldsk.
+	 */
+	lock_sock_nested(newsk, SINGLE_DEPTH_NESTING);
 	sctp_assoc_migrate(assoc, newsk);
 
 	/* If the association on the newsk is already closed before accept()

