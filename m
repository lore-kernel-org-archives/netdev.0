From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] tun: avoid owner checks on IFF_ATTACH_QUEUE
Date: Thu, 10 Jan 2013 13:31:08 +0200
Message-ID: <20130110113108.GF13451@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the moment, we check owner when we enable queue in tun.
This seems redundant and will break some valid uses
where fd is passed around: I think TUNSETOWNER is there
to prevent others from attaching to a persistent device not
owned by them. Here the fd is already attached,
enabling/disabling queue is more like read/write.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

Note: this is unrelated to Stefan's bugfix.

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index fbd106e..78e3225 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1789,10 +1792,8 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
 		tun = tfile->detached;
 		if (!tun)
 			ret = -EINVAL;
-		else if (tun_not_capable(tun))
-			ret = -EPERM;
 		else
 			ret = tun_attach(tun, file);
 	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
 		tun = rcu_dereference_protected(tfile->tun,
 						lockdep_rtnl_is_held());
-- 
MST
