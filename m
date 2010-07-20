From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] drop_monitor: convert some kfree_skb call sites to
 consume_skb
Date: Tue, 20 Jul 2010 12:45:56 -0400
Message-ID: <20100720164556.GF1995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, viro@zeniv.linux.org.uk, eparis@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:32783 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761377Ab0GTQs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 12:48:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert a few calls from kfree_skb to consume_skb

Noticed while I was working on dropwatch that I was detecting lots of internal
skb drops in several places.  While some are legitimate, several were not,
freeing skbs that were at the end of their life, rather than being discarded due
to an error.  This patch converts those calls sites from using kfree_skb to
consume_skb, which quiets the in-kernel drop_monitor code from detecting them as
drops.  Tested successfully by myself

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Eric Paris <eparis@redhat.com>
CC: Al Viro <viro@zeniv.linux.org.uk>


 kernel/audit.c           |    2 +-
 net/netlink/af_netlink.c |    9 +++++----
 net/unix/af_unix.c       |    2 +-
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index c71bd26..8296aa5 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -407,7 +407,7 @@ static void kauditd_send_skb(struct sk_buff *skb)
 		audit_hold_skb(skb);
 	} else
 		/* drop the extra reference if sent ok */
-		kfree_skb(skb);
+		consume_skb(skb);
 }
 
 static int kauditd_thread(void *dummy)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7aeaa83..8648a99 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1076,14 +1076,15 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 pid,
 	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
 		do_one_broadcast(sk, &info);
 
-	kfree_skb(skb);
+	consume_skb(skb);
 
 	netlink_unlock_table();
 
-	kfree_skb(info.skb2);
-
-	if (info.delivery_failure)
+	if (info.delivery_failure) {
+		kfree_skb(info.skb2);
 		return -ENOBUFS;
+	} else
+		consume_skb(info.skb2);
 
 	if (info.delivered) {
 		if (info.congested && (allocation & __GFP_WAIT))
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 75ba48b..4414a18 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1906,7 +1906,7 @@ static int unix_stream_recvmsg(struct kiocb *iocb, struct socket *sock,
 				break;
 			}
 
-			kfree_skb(skb);
+			consume_skb(skb);
 
 			if (siocb->scm->fp)
 				break;
