From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 14/25] raw.c: stick msghdr into raw_frag_vec
Date: Tue,  9 Dec 2014 22:50:27 +0000
Message-ID: <1418165438-2205-14-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

we'll want access to ->msg_iter

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/ipv4/raw.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 43385a9..5c901eb 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -82,7 +82,7 @@
 #include <linux/uio.h>
 
 struct raw_frag_vec {
-	struct iovec *iov;
+	struct msghdr *msg;
 	union {
 		struct icmphdr icmph;
 		char c[1];
@@ -440,7 +440,7 @@ static int raw_probe_proto_opt(struct raw_frag_vec *rfv, struct flowi4 *fl4)
 	/* We only need the first two bytes. */
 	rfv->hlen = 2;
 
-	err = memcpy_fromiovec(rfv->hdr.c, rfv->iov, rfv->hlen);
+	err = memcpy_from_msg(rfv->hdr.c, rfv->msg, rfv->hlen);
 	if (err)
 		return err;
 
@@ -478,7 +478,7 @@ static int raw_getfrag(void *from, char *to, int offset, int len, int odd,
 
 	offset -= rfv->hlen;
 
-	return ip_generic_getfrag(rfv->iov, to, offset, len, odd, skb);
+	return ip_generic_getfrag(rfv->msg->msg_iov, to, offset, len, odd, skb);
 }
 
 static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
@@ -600,7 +600,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			   daddr, saddr, 0, 0);
 
 	if (!inet->hdrincl) {
-		rfv.iov = msg->msg_iov;
+		rfv.msg = msg;
 		rfv.hlen = 0;
 
 		err = raw_probe_proto_opt(&rfv, &fl4);
-- 
2.1.3
