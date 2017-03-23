From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH v2 2/8] tcp: Record Rx hash and NAPI ID in
 tcp_child_process
Date: Thu, 23 Mar 2017 14:36:44 -0700
Message-ID: <20170323213644.12615.27158.stgit@localhost.localdomain>
References: <20170323211820.12615.88907.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net, linux-api@vger.kernel.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170323211820.12615.88907.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Duyck <alexander.h.duyck@intel.com>

While working on some recent busy poll changes we found that child sockets
were being instantiated without NAPI ID being set.  In our first attempt to
fix it, it was suggested that we should just pull programming the NAPI ID
into the function itself since all callers will need to have it set.

In addition to the NAPI ID change I have dropped the code that was
populating the Rx hash since it was actually being populated in
tcp_get_cookie_sock.

Reported-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/ipv4/tcp_ipv4.c      |    2 --
 net/ipv4/tcp_minisocks.c |    4 ++++
 net/ipv6/tcp_ipv6.c      |    2 --
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7482b5d11861..20cbd2f07f28 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1409,8 +1409,6 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 		if (!nsk)
 			goto discard;
 		if (nsk != sk) {
-			sock_rps_save_rxhash(nsk, skb);
-			sk_mark_napi_id(nsk, skb);
 			if (tcp_child_process(sk, nsk, skb)) {
 				rsk = nsk;
 				goto reset;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 692f974e5abe..40f125b19988 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -26,6 +26,7 @@
 #include <net/tcp.h>
 #include <net/inet_common.h>
 #include <net/xfrm.h>
+#include <net/busy_poll.h>
 
 int sysctl_tcp_abort_on_overflow __read_mostly;
 
@@ -798,6 +799,9 @@ int tcp_child_process(struct sock *parent, struct sock *child,
 	int ret = 0;
 	int state = child->sk_state;
 
+	/* record NAPI ID of child */
+	sk_mark_napi_id(child, skb);
+
 	tcp_segs_in(tcp_sk(child), skb);
 	if (!sock_owned_by_user(child)) {
 		ret = tcp_rcv_state_process(child, skb);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0f08d718a002..ee13e380c0dd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1293,8 +1293,6 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 			goto discard;
 
 		if (nsk != sk) {
-			sock_rps_save_rxhash(nsk, skb);
-			sk_mark_napi_id(nsk, skb);
 			if (tcp_child_process(sk, nsk, skb))
 				goto reset;
 			if (opt_skb)
