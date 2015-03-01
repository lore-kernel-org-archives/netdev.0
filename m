From: Simon Farnsworth <simon@farnz.org.uk>
Subject: [PATCH net-next v2] pppoe: Use workqueue to die properly when a PADT is received
Date: Sun,  1 Mar 2015 10:54:39 +0000
Message-ID: <1425207279-4822-1-git-send-email-simon@farnz.org.uk>
Cc: linux-ppp@vger.kernel.org, Michal Ostrowski <mostrows@gmail.com>,
	Simon Farnsworth <simon@farnz.org.uk>
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a PADT frame is received, the socket may not be in a good state to
close down the PPP interface. The current implementation handles this by
simply blocking all further PPP traffic, and hoping that the lack of traffic
will trigger the user to investigate.

Use schedule_work to get to a process context from which we clear down the
PPP interface, in a fashion analogous to hangup on a TTY-based PPP
interface. This causes pppd to disconnect immediately, and allows tools to
take immediate corrective action.

Note that pppd's rp_pppoe.so plugin has code in it to disable the session
when it disconnects; however, as a consequence of this patch, the session is
already disabled before rp_pppoe.so is asked to disable the session. The
result is a harmless error message:

Failed to disconnect PPPoE socket: 114 Operation already in progress

This message is safe to ignore, as long as the error is 114 Operation
already in progress; in that specific case, it means that the PPPoE session
has already been disabled before pppd tried to disable it.

Signed-off-by: Simon Farnsworth <simon@farnz.org.uk>
Tested-by: Dan Williams <dcbw@redhat.com>
Tested-by: Christoph Schulz <develop@kristov.de>
---

Changes from v1:

 * Amend commit message to tell people about the harmless error from pppd

 * Add in Tested-by tags

 * Change subject to add net-next

 drivers/net/ppp/pppoe.c  | 17 ++++++++++++++++-
 include/linux/if_pppox.h |  2 ++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index d2408a5..9c97e9b 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -455,6 +455,18 @@ out:
 	return NET_RX_DROP;
 }
 
+static void pppoe_unbind_sock_work(struct work_struct *work)
+{
+	struct pppox_sock *po = container_of(work, struct pppox_sock,
+					     proto.pppoe.padt_work);
+	struct sock *sk = sk_pppox(po);
+
+	lock_sock(sk);
+	pppox_unbind_sock(sk);
+	release_sock(sk);
+	sock_put(sk);
+}
+
 /************************************************************************
  *
  * Receive a PPPoE Discovery frame.
@@ -500,7 +512,8 @@ static int pppoe_disc_rcv(struct sk_buff *skb, struct net_device *dev,
 		}
 
 		bh_unlock_sock(sk);
-		sock_put(sk);
+		if (!schedule_work(&po->proto.pppoe.padt_work))
+			sock_put(sk);
 	}
 
 abort:
@@ -613,6 +626,8 @@ static int pppoe_connect(struct socket *sock, struct sockaddr *uservaddr,
 
 	lock_sock(sk);
 
+	INIT_WORK(&po->proto.pppoe.padt_work, pppoe_unbind_sock_work);
+
 	error = -EINVAL;
 	if (sp->sa_protocol != PX_PROTO_OE)
 		goto end;
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index aff7ad8..66a7d76 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -19,6 +19,7 @@
 #include <linux/netdevice.h>
 #include <linux/ppp_channel.h>
 #include <linux/skbuff.h>
+#include <linux/workqueue.h>
 #include <uapi/linux/if_pppox.h>
 
 static inline struct pppoe_hdr *pppoe_hdr(const struct sk_buff *skb)
@@ -32,6 +33,7 @@ struct pppoe_opt {
 	struct pppoe_addr	pa;	  /* what this socket is bound to*/
 	struct sockaddr_pppox	relay;	  /* what socket data will be
 					     relayed to (PPPoE relaying) */
+	struct work_struct      padt_work;/* Work item for handling PADT */
 };
 
 struct pptp_opt {
-- 
2.1.0

