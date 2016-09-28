From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: fix the issue sctp_diag uses lock_sock in rcu_read_lock
Date: Thu, 29 Sep 2016 02:55:44 +0800
Message-ID: <bd1a86ba935ffa02392b6c1271e7c06433967856.1475088944.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35055 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751451AbcI1Szu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 14:55:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sctp dumps all the ep->assocs, it needs to lock_sock first,
but now it locks sock in rcu_read_lock, and lock_sock may sleep,
which would break rcu_read_lock.

This patch is to get and hold one sock when traversing the list.
After that and get out of rcu_read_lock, lock and dump it. Then
it will traverse the list again to get the next one until all
sctp socks are dumped.

For sctp_diag_dump_one, it fixes this issue by holding asoc and
moving cb() out of rcu_read_lock in sctp_transport_lookup_process.

Fixes: 8f840e47f190 ("sctp: add the sctp_diag.c file")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sctp_diag.c | 58 ++++++++++++++++++++++++++++++++++++----------------
 net/sctp/socket.c    | 10 ++++++---
 2 files changed, 47 insertions(+), 21 deletions(-)

diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index f3508aa..cef0cee 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -272,28 +272,17 @@ out:
 	return err;
 }
 
-static int sctp_tsp_dump(struct sctp_transport *tsp, void *p)
+static int sctp_sock_dump(struct sock *sk, void *p)
 {
-	struct sctp_endpoint *ep = tsp->asoc->ep;
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	struct sctp_comm_param *commp = p;
-	struct sock *sk = ep->base.sk;
 	struct sk_buff *skb = commp->skb;
 	struct netlink_callback *cb = commp->cb;
 	const struct inet_diag_req_v2 *r = commp->r;
-	struct sctp_association *assoc =
-		list_entry(ep->asocs.next, struct sctp_association, asocs);
+	struct sctp_association *assoc;
 	int err = 0;
 
-	/* find the ep only once through the transports by this condition */
-	if (tsp->asoc != assoc)
-		goto out;
-
-	if (r->sdiag_family != AF_UNSPEC && sk->sk_family != r->sdiag_family)
-		goto out;
-
 	lock_sock(sk);
-	if (sk != assoc->base.sk)
-		goto release;
 	list_for_each_entry(assoc, &ep->asocs, asocs) {
 		if (cb->args[4] < cb->args[1])
 			goto next;
@@ -312,7 +301,7 @@ static int sctp_tsp_dump(struct sctp_transport *tsp, void *p)
 					cb->nlh->nlmsg_seq,
 					NLM_F_MULTI, cb->nlh) < 0) {
 			cb->args[3] = 1;
-			err = 2;
+			err = 1;
 			goto release;
 		}
 		cb->args[3] = 1;
@@ -321,7 +310,7 @@ static int sctp_tsp_dump(struct sctp_transport *tsp, void *p)
 					sk_user_ns(NETLINK_CB(cb->skb).sk),
 					NETLINK_CB(cb->skb).portid,
 					cb->nlh->nlmsg_seq, 0, cb->nlh) < 0) {
-			err = 2;
+			err = 1;
 			goto release;
 		}
 next:
@@ -333,10 +322,35 @@ next:
 	cb->args[4] = 0;
 release:
 	release_sock(sk);
+	sock_put(sk);
 	return err;
+}
+
+static int sctp_get_sock(struct sctp_transport *tsp, void *p)
+{
+	struct sctp_endpoint *ep = tsp->asoc->ep;
+	struct sctp_comm_param *commp = p;
+	struct sock *sk = ep->base.sk;
+	struct netlink_callback *cb = commp->cb;
+	const struct inet_diag_req_v2 *r = commp->r;
+	struct sctp_association *assoc =
+		list_entry(ep->asocs.next, struct sctp_association, asocs);
+
+	/* find the ep only once through the transports by this condition */
+	if (tsp->asoc != assoc)
+		goto out;
+
+	if (r->sdiag_family != AF_UNSPEC && sk->sk_family != r->sdiag_family)
+		goto out;
+
+	sock_hold(sk);
+	cb->args[5] = (long)sk;
+
+	return 1;
+
 out:
 	cb->args[2]++;
-	return err;
+	return 0;
 }
 
 static int sctp_ep_dump(struct sctp_endpoint *ep, void *p)
@@ -472,10 +486,18 @@ skip:
 	 * 2 : to record the transport pos of this time's traversal
 	 * 3 : to mark if we have dumped the ep info of the current asoc
 	 * 4 : to work as a temporary variable to traversal list
+	 * 5 : to save the sk we get from travelsing the tsp list.
 	 */
 	if (!(idiag_states & ~(TCPF_LISTEN | TCPF_CLOSE)))
 		goto done;
-	sctp_for_each_transport(sctp_tsp_dump, net, cb->args[2], &commp);
+
+next:
+	cb->args[5] = 0;
+	sctp_for_each_transport(sctp_get_sock, net, cb->args[2], &commp);
+
+	if (cb->args[5] && !sctp_sock_dump((struct sock *)cb->args[5], &commp))
+		goto next;
+
 done:
 	cb->args[1] = cb->args[4];
 	cb->args[4] = 0;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9fc417a..8ed2d99 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4469,17 +4469,21 @@ int sctp_transport_lookup_process(int (*cb)(struct sctp_transport *, void *),
 				  const union sctp_addr *paddr, void *p)
 {
 	struct sctp_transport *transport;
-	int err = 0;
+	int err = -ENOENT;
 
 	rcu_read_lock();
 	transport = sctp_addrs_lookup_transport(net, laddr, paddr);
 	if (!transport || !sctp_transport_hold(transport))
 		goto out;
-	err = cb(transport, p);
+
+	sctp_association_hold(transport->asoc);
 	sctp_transport_put(transport);
 
-out:
 	rcu_read_unlock();
+	err = cb(transport, p);
+	sctp_association_put(transport->asoc);
+
+out:
 	return err;
 }
 EXPORT_SYMBOL_GPL(sctp_transport_lookup_process);
-- 
2.1.0
