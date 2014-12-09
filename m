From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH net] Fix race condition between vxlan_sock_add and vxlan_sock_release
Date: Tue,  9 Dec 2014 12:28:28 -0200
Message-ID: <e76bb0b4377c56583148323ada9b479e4628e35e.1418135271.git.mleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58315 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940AbaLIO2i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:28:38 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sB9ESb5h012656
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 9 Dec 2014 09:28:38 -0500
Received: from localhost.localdomain.com (vpn1-5-99.gru2.redhat.com [10.97.5.99])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sB9ESaP3008137
	for <netdev@vger.kernel.org>; Tue, 9 Dec 2014 09:28:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when trying to reuse a socket, vxlan_sock_add will grab
vn->sock_lock, locate a reusable socket, inc refcount and release
vn->sock_lock.

But vxlan_sock_release() will first decrement refcount, and then grab
that lock. refcnt operations are atomic but as currently we have
deferred works which hold vs->refcnt each, this might happen, leading to
a use after free (specially after vxlan_igmp_leave):

  CPU 1                            CPU 2

deferred work                    vxlan_sock_add
  ...                              ...
                                   spin_lock(&vn->sock_lock)
                                   vs = vxlan_find_sock();
  vxlan_sock_release
    dec vs->refcnt, reaches 0
    spin_lock(&vn->sock_lock)
                                   vxlan_sock_hold(vs), refcnt=1
                                   spin_unlock(&vn->sock_lock)
    hlist_del_rcu(&vs->hlist);
    vxlan_notify_del_rx_port(vs)
    spin_unlock(&vn->sock_lock)


With current logic, as vxlan_sock_add is the only "search and hold",
it's easier to fix this by just making vxlan_sock_release grab that lock
before checking refcnt.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
---
 drivers/net/vxlan.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 31ecb03368c6dc3d581fdbd30b409b88190f3c71..287e718c8a419394fb17b9a8eb5957aafb8d19da 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1057,10 +1057,15 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 	struct net *net = sock_net(sk);
 	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
 
-	if (!atomic_dec_and_test(&vs->refcnt))
+	/* We have to take this lock now, otherwise vxlan_sock_add may
+	 * reuse a socket that vxlan_igmp_leave just freed.
+	 */
+	spin_lock(&vn->sock_lock);
+	if (!atomic_dec_and_test(&vs->refcnt)) {
+		spin_unlock(&vn->sock_lock);
 		return;
+	}
 
-	spin_lock(&vn->sock_lock);
 	hlist_del_rcu(&vs->hlist);
 	vxlan_notify_del_rx_port(vs);
 	spin_unlock(&vn->sock_lock);
@@ -1987,7 +1992,7 @@ static int vxlan_init(struct net_device *dev)
 			     vxlan->dst_port);
 	if (vs) {
 		/* If we have a socket with same port already, reuse it */
-		atomic_inc(&vs->refcnt);
+		vxlan_sock_hold(vs);
 		vxlan_vs_add_dev(vs, vxlan);
 	} else {
 		/* otherwise make new socket outside of RTNL */
@@ -2391,7 +2396,7 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 	vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port);
 	if (vs) {
 		if (vs->rcv == rcv)
-			atomic_inc(&vs->refcnt);
+			vxlan_sock_hold(vs);
 		else
 			vs = ERR_PTR(-EBUSY);
 	}
-- 
1.9.3
