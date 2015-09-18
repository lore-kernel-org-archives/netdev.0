From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] macvtap: fix TUNSETSNDBUF values > 64k
Date: Fri, 18 Sep 2015 13:41:09 +0300
Message-ID: <1442572808-6438-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Matthew Rosato <mjrosato@linux.vnet.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jason Wang <jasowang@redhat.com>,
	David Gibson <david@gibson.dropbear.id.au>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Justin Cormack <justin@myriabit.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Upon TUNSETSNDBUF,  macvtap reads the requested sndbuf size into
a local variable u.
commit 39ec7de7092b ("macvtap: fix uninitialized access on
TUNSETIFF") changed its type to u16 (which is the right thing to
do for all other macvtap ioctls), breaking all values > 64k.

The value of TUNSETSNDBUF is actually a signed 32 bit integer, so
the right thing to do is to read it into an int.

Cc: David S. Miller <davem@davemloft.net>
Fixes: 39ec7de7092b ("macvtap: fix uninitialized access on TUNSETIFF")
Reported-by: Mark A. Peloquin
Bisected-by: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

This patch probably makes sense on stable.

 drivers/net/macvtap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index edd7734..248478c 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1111,10 +1111,10 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		return 0;
 
 	case TUNSETSNDBUF:
-		if (get_user(u, up))
+		if (get_user(s, sp))
 			return -EFAULT;
 
-		q->sk.sk_sndbuf = u;
+		q->sk.sk_sndbuf = s;
 		return 0;
 
 	case TUNGETVNETHDRSZ:
-- 
MST
