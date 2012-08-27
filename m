From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH] af_unix: fix shutdown parameter checking
Date: Sun, 26 Aug 2012 22:47:13 -0400
Message-ID: <1346035633-2492-1-git-send-email-xi.wang@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Xi Wang <xi.wang@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return -EINVAL rather than 0 given an invalid "mode" parameter.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
Another way to check "mode" is as in inet_shutdown():

	mode++;
	if ((mode & ~SHUTDOWN_MASK) || !mode)
		return -EINVAL;

This patch uses a simpler form, to check if "mode" is in the range
SHUT_RD ... SHUT_RDWR.
---
 net/unix/af_unix.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index c5ee4ff..8a84ab6 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2060,10 +2060,14 @@ static int unix_shutdown(struct socket *sock, int mode)
 	struct sock *sk = sock->sk;
 	struct sock *other;
 
-	mode = (mode+1)&(RCV_SHUTDOWN|SEND_SHUTDOWN);
-
-	if (!mode)
-		return 0;
+	if (mode < SHUT_RD || mode > SHUT_RDWR)
+		return -EINVAL;
+	/* This maps:
+	 * SHUT_RD   (0) -> RCV_SHUTDOWN  (1)
+	 * SHUT_WR   (1) -> SEND_SHUTDOWN (2)
+	 * SHUT_RDWR (2) -> SHUTDOWN_MASK (3)
+	 */
+	++mode;
 
 	unix_state_lock(sk);
 	sk->sk_shutdown |= mode;
-- 
1.7.9.5
