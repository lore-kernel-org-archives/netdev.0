From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH net-next] tcp: Return error instead of partial read for saved syn headers
Date: Mon, 18 May 2015 14:35:58 -0400
Message-ID: <1431974158-28288-1-git-send-email-emunson@akamai.com>
Cc: Eric B Munson <emunson@akamai.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the getsockopt() requesting the cached contents of the syn
packet headers will fail silently if the caller uses a buffer that is
too small to contain the requested data.  Rather than fail silently and
discard the headers, getsockopt() should return an error and report the
required size to hold the data.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 net/ipv4/tcp.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c724195..bb9bb84 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2845,7 +2845,15 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 
 		lock_sock(sk);
 		if (tp->saved_syn) {
-			len = min_t(unsigned int, tp->saved_syn[0], len);
+			if (len < tp->saved_syn[0]) {
+				if (put_user(tp->saved_syn[0], optlen)) {
+					release_sock(sk);
+					return -EFAULT;
+				}
+				release_sock(sk);
+				return -EINVAL;
+			}
+			len = tp->saved_syn[0];
 			if (put_user(len, optlen)) {
 				release_sock(sk);
 				return -EFAULT;
-- 
1.9.1
