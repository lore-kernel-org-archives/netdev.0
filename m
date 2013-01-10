From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 3.8-rc] tuntap: refuse to re-attach to different tun_struct
Date: Thu, 10 Jan 2013 08:59:48 +0100
Message-ID: <1357804788-19976-1-git-send-email-stefanha@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stefan Hajnoczi <stefanha@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Multiqueue tun devices support detaching a tun_file from its tun_struct
and re-attaching at a later point in time.  This allows users to disable
a specific queue temporarily.

ioctl(TUNSETIFF) allows the user to specify the network interface to
attach by name.  This means the user can attempt to attach to interface
"B" after detaching from interface "A".

The driver is not designed to support this so check we are re-attaching
to the right tun_struct.  Failure to do so may lead to oops.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
This fix is for 3.8-rc.

 drivers/net/tun.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index fbd106e..cf6da6e 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -491,6 +491,8 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	err = -EINVAL;
 	if (rcu_dereference_protected(tfile->tun, lockdep_rtnl_is_held()))
 		goto out;
+	if (tfile->detached && tun != tfile->detached)
+		goto out;
 
 	err = -EBUSY;
 	if (!(tun->flags & TUN_TAP_MQ) && tun->numqueues == 1)
-- 
1.8.0.2
