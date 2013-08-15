From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] tun: signedness bug in tun_get_user()
Date: Thu, 15 Aug 2013 15:52:57 +0300
Message-ID: <20130815125257.GA16932@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19539 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755378Ab3HOMxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 08:53:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent fix d9bf5f1309 "tun: compare with 0 instead of total_len" is
not totally correct.  Because "len" and "sizeof()" are size_t type, that
means they are never less than zero.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index af987f0..7ed13cc 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -977,8 +977,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	u32 rxhash;
 
 	if (!(tun->flags & TUN_NO_PI)) {
-		if ((len -= sizeof(pi)) < 0)
+		if (len < sizeof(pi))
 			return -EINVAL;
+		len -= sizeof(pi);
 
 		if (memcpy_fromiovecend((void *)&pi, iv, 0, sizeof(pi)))
 			return -EFAULT;
@@ -986,8 +987,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	if (tun->flags & TUN_VNET_HDR) {
-		if ((len -= tun->vnet_hdr_sz) < 0)
+		if (len < tun->vnet_hdr_sz)
 			return -EINVAL;
+		len -= tun->vnet_hdr_sz;
 
 		if (memcpy_fromiovecend((void *)&gso, iv, offset, sizeof(gso)))
 			return -EFAULT;
