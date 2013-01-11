From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 1/2] tuntap: forbid calling TUNSETIFF when detached
Date: Fri, 11 Jan 2013 16:50:41 +0800
Message-ID: <1357894242-25020-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	Stefan Hajnoczi <stefanha@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael points out that even after Stefan's fix the TUNSETIFF is still allowed
to create a new tap device. This because we only check tfile->tun but the
tfile->detached were introduced. Fix this by failing early in tun_set_iff() if
the file is detached. After this fix, there's no need to do the check again in
tun_set_iff(), so this patch removes it.

Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Stefan Hajnoczi <stefanha@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 99b58d8..9a46d70 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -491,8 +491,6 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	err = -EINVAL;
 	if (rcu_dereference_protected(tfile->tun, lockdep_rtnl_is_held()))
 		goto out;
-	if (tfile->detached && tun != tfile->detached)
-		goto out;
 
 	err = -EBUSY;
 	if (!(tun->flags & TUN_TAP_MQ) && tun->numqueues == 1)
@@ -1546,6 +1544,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	struct net_device *dev;
 	int err;
 
+	if (rcu_dereference_protected(tfile->detached, lockdep_rtnl_is_held()))
+		return -EINVAL;
+
 	dev = __dev_get_by_name(net, ifr->ifr_name);
 	if (dev) {
 		if (ifr->ifr_flags & IFF_TUN_EXCL)
-- 
1.7.1
