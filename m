From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH] pptp: use idr for allocation of callids
Date: Thu,  5 Nov 2015 15:07:44 -0500
Message-ID: <1446754064-1195-1-git-send-email-sasha.levin@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sasha Levin <sasha.levin@oracle.com>
To: xeb@mail.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current implementation used a bitfield with a corresponding array to
manage assignment of call ids. Rather than open-coding it, use IDR for
this.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 drivers/net/ppp/pptp.c |   67 +++++++++++++++++++++---------------------------
 1 file changed, 29 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index fc69e41..4637314 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -30,6 +30,7 @@
 #include <linux/ip.h>
 #include <linux/rcupdate.h>
 #include <linux/spinlock.h>
+#include <linux/idr.h>
 
 #include <net/sock.h>
 #include <net/protocol.h>
@@ -43,10 +44,7 @@
 #define PPTP_DRIVER_VERSION "0.8.5"
 
 #define MAX_CALLID 65535
-
-static DECLARE_BITMAP(callid_bitmap, MAX_CALLID + 1);
-static struct pppox_sock __rcu **callid_sock;
-
+static struct idr callid;
 static DEFINE_SPINLOCK(chan_lock);
 
 static struct proto pptp_sk_proto __read_mostly;
@@ -94,7 +92,7 @@ static struct pppox_sock *lookup_chan(u16 call_id, __be32 s_addr)
 	struct pptp_opt *opt;
 
 	rcu_read_lock();
-	sock = rcu_dereference(callid_sock[call_id]);
+	sock = idr_find(&callid, call_id);
 	if (sock) {
 		opt = &sock->proto.pptp;
 		if (opt->dst_addr.sin_addr.s_addr != s_addr)
@@ -107,60 +105,55 @@ static struct pppox_sock *lookup_chan(u16 call_id, __be32 s_addr)
 	return sock;
 }
 
-static int lookup_chan_dst(u16 call_id, __be32 d_addr)
+static bool lookup_chan_dst(u16 call_id, __be32 d_addr)
 {
 	struct pppox_sock *sock;
 	struct pptp_opt *opt;
 	int i;
+	bool found = false;
 
 	rcu_read_lock();
-	i = 1;
-	for_each_set_bit_from(i, callid_bitmap, MAX_CALLID) {
-		sock = rcu_dereference(callid_sock[i]);
-		if (!sock)
-			continue;
+	idr_for_each_entry(&callid, sock, i) {
 		opt = &sock->proto.pptp;
 		if (opt->dst_addr.call_id == call_id &&
-			  opt->dst_addr.sin_addr.s_addr == d_addr)
+			  opt->dst_addr.sin_addr.s_addr == d_addr) {
+			found = true;
 			break;
+		}
 	}
 	rcu_read_unlock();
 
-	return i < MAX_CALLID;
+	return found;
 }
 
 static int add_chan(struct pppox_sock *sock)
 {
-	static int call_id;
+	int ret, requested;
 
-	spin_lock(&chan_lock);
-	if (!sock->proto.pptp.src_addr.call_id)	{
-		call_id = find_next_zero_bit(callid_bitmap, MAX_CALLID, call_id + 1);
-		if (call_id == MAX_CALLID) {
-			call_id = find_next_zero_bit(callid_bitmap, MAX_CALLID, 1);
-			if (call_id == MAX_CALLID)
-				goto out_err;
-		}
-		sock->proto.pptp.src_addr.call_id = call_id;
-	} else if (test_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap))
-		goto out_err;
+	idr_preload(GFP_KERNEL);
 
-	set_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap);
-	rcu_assign_pointer(callid_sock[sock->proto.pptp.src_addr.call_id], sock);
+	spin_lock(&chan_lock);
+	requested = sock->proto.pptp.src_addr.call_id;
+	if (!requested)
+		ret = idr_alloc(&callid, sock, 1, MAX_CALLID, GFP_ATOMIC);
+	else
+		ret = idr_alloc(&callid, sock, requested, requested + 1, GFP_ATOMIC);
 	spin_unlock(&chan_lock);
 
-	return 0;
+	idr_preload_end();
 
-out_err:
-	spin_unlock(&chan_lock);
-	return -1;
+	return ret;
 }
 
 static void del_chan(struct pppox_sock *sock)
 {
 	spin_lock(&chan_lock);
-	clear_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap);
-	RCU_INIT_POINTER(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
+	/*
+	 * It's possible the sock was created but never bound, let's verify
+	 * that this isn't the case before blindly deleting a different sock.
+	 */
+	if (idr_find(&callid, sock->proto.pptp.src_addr.call_id) == sock)
+		idr_remove(&callid, sock->proto.pptp.src_addr.call_id);
 	spin_unlock(&chan_lock);
 	synchronize_rcu();
 }
@@ -670,9 +663,7 @@ static int __init pptp_init_module(void)
 	int err = 0;
 	pr_info("PPTP driver version " PPTP_DRIVER_VERSION "\n");
 
-	callid_sock = vzalloc((MAX_CALLID + 1) * sizeof(void *));
-	if (!callid_sock)
-		return -ENOMEM;
+	idr_init(&callid);
 
 	err = gre_add_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
 	if (err) {
@@ -699,7 +690,7 @@ out_unregister_sk_proto:
 out_gre_del_protocol:
 	gre_del_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
 out_mem_free:
-	vfree(callid_sock);
+	idr_destroy(&callid);
 
 	return err;
 }
@@ -709,7 +700,7 @@ static void __exit pptp_exit_module(void)
 	unregister_pppox_proto(PX_PROTO_PPTP);
 	proto_unregister(&pptp_sk_proto);
 	gre_del_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
-	vfree(callid_sock);
+	idr_destroy(&callid);
 }
 
 module_init(pptp_init_module);
-- 
1.7.10.4
