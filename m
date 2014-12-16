From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 1/5] macvtap: fix uninitialized access on TUNSETIFF
Date: Tue, 16 Dec 2014 15:04:56 +0200
Message-ID: <1418732988-3535-2-git-send-email-mst@redhat.com>
References: <1418732988-3535-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Jason Wang <jasowang@redhat.com>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1418732988-3535-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

flags field in ifreq is only 16 bit wide, but
we read it as a 32 bit value.
If userspace doesn't zero-initialize unused fields,
this will lead to failures.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/macvtap.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index af90ab5..de88285 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1011,7 +1011,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 	void __user *argp = (void __user *)arg;
 	struct ifreq __user *ifr = argp;
 	unsigned int __user *up = argp;
-	unsigned int u;
+	unsigned short u;
 	int __user *sp = argp;
 	int s;
 	int ret;
@@ -1026,7 +1026,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		if ((u & ~MACVTAP_FEATURES) != (IFF_NO_PI | IFF_TAP))
 			ret = -EINVAL;
 		else
-			q->flags = u;
+			q->flags = (q->flags & ~MACVTAP_FEATURES) | u;
 
 		return ret;
 
@@ -1039,8 +1039,9 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		}
 
 		ret = 0;
+		u = q->flags;
 		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
-		    put_user(q->flags, &ifr->ifr_flags))
+		    put_user(u, &ifr->ifr_flags))
 			ret = -EFAULT;
 		macvtap_put_vlan(vlan);
 		rtnl_unlock();
-- 
MST
