From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 2/3] tuntap: forbid calling TUNSETIFF when detached
Date: Sat, 12 Jan 2013 10:59:33 +0800
Message-ID: <1357959574-13113-3-git-send-email-jasowang@redhat.com>
References: <1357959574-13113-1-git-send-email-jasowang@redhat.com>
Cc: edumazet@google.com, stefanha@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755830Ab3ALDIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 22:08:02 -0500
In-Reply-To: <1357959574-13113-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index aa963c4..a36b56f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -488,8 +488,6 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	err = -EINVAL;
 	if (rtnl_dereference(tfile->tun))
 		goto out;
-	if (tfile->detached && tun != tfile->detached)
-		goto out;
 
 	err = -EBUSY;
 	if (!(tun->flags & TUN_TAP_MQ) && tun->numqueues == 1)
@@ -1543,6 +1541,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 	struct net_device *dev;
 	int err;
 
+	if (tfile->detached)
+		return -EINVAL;
+
 	dev = __dev_get_by_name(net, ifr->ifr_name);
 	if (dev) {
 		if (ifr->ifr_flags & IFF_TUN_EXCL)
-- 
1.7.1
