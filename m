From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/2] ipv4: Use standard iovec primitive in raw_probe_proto_opt
Date: Fri, 07 Nov 2014 21:27:08 +0800
Message-ID: <E1XmjZE-0005GW-Dp@gondolin.me.apana.org.au>
References: <20141107132553.GA20190@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>, viro@ZenIV.linux.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bcrl@kvack.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	nakam@linux-ipv6.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function raw_probe_proto_opt tries to extract the first two
bytes from the user input in order to seed the IPsec lookup for
ICMP packets.  In doing so it's processing iovec by hand and
overcomplicating things.

This patch replaces the manual iovec processing with a call to
memcpy_fromiovecend.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/raw.c |   50 +++++++++++---------------------------------------
 1 file changed, 11 insertions(+), 39 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index ee8fa4b..9be9050 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -422,48 +422,20 @@ error:
 
 static int raw_probe_proto_opt(struct flowi4 *fl4, struct msghdr *msg)
 {
-	struct iovec *iov;
-	u8 __user *type = NULL;
-	u8 __user *code = NULL;
-	int probed = 0;
-	unsigned int i;
+	struct icmphdr icmph;
+	int err;
 
-	if (!msg->msg_iov)
+	if (fl4->flowi4_proto != IPPROTO_ICMP)
 		return 0;
 
-	for (i = 0; i < msg->msg_iovlen; i++) {
-		iov = &msg->msg_iov[i];
-		if (!iov)
-			continue;
-
-		switch (fl4->flowi4_proto) {
-		case IPPROTO_ICMP:
-			/* check if one-byte field is readable or not. */
-			if (iov->iov_base && iov->iov_len < 1)
-				break;
-
-			if (!type) {
-				type = iov->iov_base;
-				/* check if code field is readable or not. */
-				if (iov->iov_len > 1)
-					code = type + 1;
-			} else if (!code)
-				code = iov->iov_base;
-
-			if (type && code) {
-				if (get_user(fl4->fl4_icmp_type, type) ||
-				    get_user(fl4->fl4_icmp_code, code))
-					return -EFAULT;
-				probed = 1;
-			}
-			break;
-		default:
-			probed = 1;
-			break;
-		}
-		if (probed)
-			break;
-	}
+	/* We only need the first two bytes. */
+	err = memcpy_fromiovecend((void *)&icmph, msg->msg_iov, 0, 2);
+	if (err)
+		return err;
+
+	fl4->fl4_icmp_type = icmph.type;
+	fl4->fl4_icmp_code = icmph.code;
+
 	return 0;
 }
 
