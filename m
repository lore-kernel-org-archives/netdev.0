From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: [PATCH net-2.6] ethtool: Allow zero-length register dumps again
Date: Thu, 21 Jul 2011 19:54:00 +0200
Message-ID: <1311270840.28569.34.camel@localhost>
References: <20110720091850.32210.2059.stgit@localhost6.localdomain6>
	 <1311161889.1041.11.camel@localhost> <4E26C2DC.8090208@qca.qualcomm.com>
	 <20110720143611.GA18231@tuxdriver.com>
	 <1311270409.28569.32.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1311270409.28569.32.camel@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some drivers (ab)use the ethtool_ops::get_regs operation to expose
only a hardware revision ID.  Commit
a77f5db361ed9953b5b749353ea2c7fed2bf8d93 ('ethtool: Allocate register
dump buffer with vmalloc()') had the side-effect of breaking these, as
vmalloc() returns a null pointer for size=0 whereas kmalloc() did not.

For backward-compatibility, allow zero-length dumps again.

Reported-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Signed-off-by: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org [2.6.37+]
---
This is compile-tested only.  I'm on vacation, damnit.

Ben.

 net/core/ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index fd14116..4fb7704 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1227,7 +1227,7 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 		regs.len = reglen;
 
 	regbuf = vzalloc(reglen);
-	if (!regbuf)
+	if (reglen && !regbuf)
 		return -ENOMEM;
 
 	ops->get_regs(dev, &regs, regbuf);
@@ -1236,7 +1236,7 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 	if (copy_to_user(useraddr, &regs, sizeof(regs)))
 		goto out;
 	useraddr += offsetof(struct ethtool_regs, data);
-	if (copy_to_user(useraddr, regbuf, regs.len))
+	if (regbuf && copy_to_user(useraddr, regbuf, regs.len))
 		goto out;
 	ret = 0;
 
-- 
1.7.5.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
