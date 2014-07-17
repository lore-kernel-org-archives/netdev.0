From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] wan/x25_asy: integer overflow in x25_asy_change_mtu()
Date: Thu, 17 Jul 2014 13:50:45 +0300
Message-ID: <20140717105044.GA28140@mwanda>
References: <1405588471.10255.70.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Gundersen <teg@jklm.no>,
	David Herrmann <dh.herrmann@gmail.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1405588471.10255.70.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If "newmtu * 2 + 4" is too large then it can cause an integer overflow
leading to memory corruption.  Eric Dumazet suggests that 65534 is a
reasonable upper limit.

Btw, "newmtu" is not allowed to be a negative number because of the
check in dev_set_mtu(), so that's ok.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: Cap it at 65534 instead of just testing for integer overflows.
    Thanks David and Eric!

diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index df6c073..5c47b01 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -122,8 +122,12 @@ static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
 {
 	struct x25_asy *sl = netdev_priv(dev);
 	unsigned char *xbuff, *rbuff;
-	int len = 2 * newmtu;
+	int len;
 
+	if (newmtu > 65534)
+		return -EINVAL;
+
+	len = 2 * newmtu;
 	xbuff = kmalloc(len + 4, GFP_ATOMIC);
 	rbuff = kmalloc(len + 4, GFP_ATOMIC);
 
