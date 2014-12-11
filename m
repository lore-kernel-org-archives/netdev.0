From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH net v2] Fix race condition between vxlan_sock_add and vxlan_sock_release
Date: Thu, 11 Dec 2014 10:02:22 -0200
Message-ID: <125fcb71bfb239711f03d3344b4275b304db6bb8.1418298054.git.mleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754536AbaLKMCa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 07:02:30 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBBC2SCc015916
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 07:02:29 -0500
Received: from localhost.localdomain.com (vpn1-5-145.gru2.redhat.com [10.97.5.145])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sBBC2RJU017681
	for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 07:02:28 -0500
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


So when we look for a reusable socket, we check if it wasn't freed
already before reusing it.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Fixes: 7c47cedf43a8b3 ("vxlan: move IGMP join/leave to work queue")
---

Notes:
    v1->v2: addressed Dave's comment on better to use atomic_add_unless()
    than grabbing the lock earlier on vxlan_sock_release()
    
    Note that there are two search&reuse places, on vxlan_init() and
    vxlan_sock_add(), both handled.

 drivers/net/vxlan.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 31ecb03368c6dc3d581fdbd30b409b88190f3c71..49d9f229199851c48f5a9e6f1b282b42cedc2a41 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1985,9 +1985,8 @@ static int vxlan_init(struct net_device *dev)
 	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(vxlan->net, ipv6 ? AF_INET6 : AF_INET,
 			     vxlan->dst_port);
-	if (vs) {
+	if (vs && atomic_add_unless(&vs->refcnt, 1, 0)) {
 		/* If we have a socket with same port already, reuse it */
-		atomic_inc(&vs->refcnt);
 		vxlan_vs_add_dev(vs, vxlan);
 	} else {
 		/* otherwise make new socket outside of RTNL */
@@ -2389,12 +2388,9 @@ struct vxlan_sock *vxlan_sock_add(struct net *net, __be16 port,
 
 	spin_lock(&vn->sock_lock);
 	vs = vxlan_find_sock(net, ipv6 ? AF_INET6 : AF_INET, port);
-	if (vs) {
-		if (vs->rcv == rcv)
-			atomic_inc(&vs->refcnt);
-		else
+	if (vs && ((vs->rcv != rcv) ||
+		   !atomic_add_unless(&vs->refcnt, 1, 0)))
 			vs = ERR_PTR(-EBUSY);
-	}
 	spin_unlock(&vn->sock_lock);
 
 	if (!vs)
-- 
1.9.3
