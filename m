From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC] tun: remove of user-controlled memory allocation
Date: Mon, 1 Nov 2010 10:27:49 +0200
Message-ID: <20101101082749.GA25860@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754417Ab0KAI2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 04:28:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Untested, this is just an RFC.

tun does a kmalloc where userspace controls the length. This will
produce warnings in kernel log when the length is too large, or might
block for a long while. A simple fix is to avoid the allocatiuon
altogether, and copy from user in a loop.

However, with this patch an illegal address passed to the ioctl might
leave the filter disabled.  Is this something we care about?  If
yes we could recover by creating a copy of the filter.  Thoughts?

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c |   30 ++++++++++++++----------------
 1 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 55f3a3e..ea36888 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -220,28 +220,23 @@ static unsigned int addr_hash_test(const u32 *mask, const u8 *addr)
 
 static int update_filter(struct tap_filter *filter, void __user *arg)
 {
-	struct { u8 u[ETH_ALEN]; } *addr;
+	struct { u8 u[ETH_ALEN]; } __user *addr;
 	struct tun_filter uf;
-	int err, alen, n, nexact;
+	int err = -EFAULT, n, nexact;
 
 	if (copy_from_user(&uf, arg, sizeof(uf)))
-		return -EFAULT;
+		goto done;
 
 	if (!uf.count) {
 		/* Disabled */
 		filter->count = 0;
-		return 0;
+		err = 0;
+		goto done;
 	}
 
-	alen = ETH_ALEN * uf.count;
-	addr = kmalloc(alen, GFP_KERNEL);
-	if (!addr)
-		return -ENOMEM;
-
-	if (copy_from_user(addr, arg + sizeof(uf), alen)) {
-		err = -EFAULT;
+	addr = arg + sizeof(uf);
+	if (!access_ok(VERIFY_READ, addr, ETH_ALEN * uf.count))
 		goto done;
-	}
 
 	/* The filter is updated without holding any locks. Which is
 	 * perfectly safe. We disable it first and in the worst
@@ -251,7 +246,8 @@ static int update_filter(struct tap_filter *filter, void __user *arg)
 
 	/* Use first set of addresses as an exact filter */
 	for (n = 0; n < uf.count && n < FLT_EXACT_COUNT; n++)
-		memcpy(filter->addr[n], addr[n].u, ETH_ALEN);
+		if (__copy_from_user(filter->addr[n], addr[n].u, ETH_ALEN))
+			goto done;
 
 	nexact = n;
 
@@ -259,11 +255,14 @@ static int update_filter(struct tap_filter *filter, void __user *arg)
 	 * unicast will leave the filter disabled. */
 	memset(filter->mask, 0, sizeof(filter->mask));
 	for (; n < uf.count; n++) {
-		if (!is_multicast_ether_addr(addr[n].u)) {
+		u8 u[ETH_ALEN];
+		if (__copy_from_user(u, addr[n].u, ETH_ALEN))
+			goto done;
+		if (!is_multicast_ether_addr(u)) {
 			err = 0; /* no filter */
 			goto done;
 		}
-		addr_hash_set(filter->mask, addr[n].u);
+		addr_hash_set(filter->mask, u);
 	}
 
 	/* For ALLMULTI just set the mask to all ones.
@@ -279,7 +278,6 @@ static int update_filter(struct tap_filter *filter, void __user *arg)
 	err = nexact;
 
 done:
-	kfree(addr);
 	return err;
 }
 
-- 
1.7.3.2.91.g446ac
