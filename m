From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/2] tun: Use memdup_user() rather than duplicating its
 implementation
Date: Sat, 20 Aug 2016 09:34:56 +0200
Message-ID: <a2ee9925-1241-0328-6d35-9a9c9f567ea4@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <9cf06275-924d-6c22-d8a8-f733a03cca23@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9cf06275-924d-6c22-d8a8-f733a03cca23@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 20 Aug 2016 08:54:15 +0200

Reuse existing functionality from memdup_user() instead of keeping
duplicate source code.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/tun.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 9c8b5bc..a1aeccb 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -731,14 +731,9 @@ static int update_filter(struct tap_filter *filter, void __user *arg)
 	}
 
 	alen = ETH_ALEN * uf.count;
-	addr = kmalloc(alen, GFP_KERNEL);
-	if (!addr)
-		return -ENOMEM;
-
-	if (copy_from_user(addr, arg + sizeof(uf), alen)) {
-		err = -EFAULT;
-		goto done;
-	}
+	addr = memdup_user(arg + sizeof(uf), alen);
+	if (IS_ERR(addr))
+		return PTR_ERR(addr);
 
 	/* The filter is updated without holding any locks. Which is
 	 * perfectly safe. We disable it first and in the worst
-- 
2.9.3
