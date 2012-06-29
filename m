From: Andreas Gruenbacher <agruen@linbit.com>
Subject: [RFC] [TCP 1/3] tcp: Add MSG_NEW_PACKET flag to indicate preferable
 packet boundaries
Date: Fri, 29 Jun 2012 16:54:50 +0200
Message-ID: <1340981690.25226.3.camel@gurkel.linbit>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MSG_NEW_PACKET flag indicates to sendmsg / sendpage that the message or
page should be put into a new packet even when there is still room left in the
previous packet.

In the tcp protocol, messages which are not sent immediately are queued.  When
more data is sent, it will be added to the last segment in that queue until
that segment is "full" whenever possible; only then is a new segment added.
Right now, there is no way to indicate when tcp should start a new segment.
The new flag allows to control that.

Signed-off-by: Andreas Gruenbacher <agruen@linbit.com>
---
 include/linux/socket.h |    1 +
 net/ipv4/tcp.c         |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 25d6322..be166de 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -266,6 +266,7 @@ struct ucred {
 #define MSG_MORE	0x8000	/* Sender will send more */
 #define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets avail */
 #define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the last page */
+#define MSG_NEW_PACKET	0x40000	/* tcp: try to put message into a new packet */
 #define MSG_EOF         MSG_FIN
 
 #define MSG_CMSG_CLOEXEC 0x40000000	/* Set close_on_exit for file
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3ba605f..148aebe 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -854,7 +854,8 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
 		bool can_coalesce;
 
-		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
+		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0 ||
+		    (flags & MSG_NEW_PACKET)) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
@@ -1044,7 +1045,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				copy = max - skb->len;
 			}
 
-			if (copy <= 0) {
+			if (copy <= 0 || (flags & MSG_NEW_PACKET)) {
 new_segment:
 				/* Allocate new segment. If the interface is SG,
 				 * allocate skb fitting to single page.
-- 
1.7.10.2
