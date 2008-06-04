From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/3] [IPV6]: Do not change protocol for UDPv6 sockets with pending sent data.
Date: Wed,  4 Jun 2008 15:49:08 +0400
Message-ID: <1212580148-9885-3-git-send-email-den@openvz.org>
References: <1212580148-9885-1-git-send-email-den@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	"Denis V. Lunev" <den@openvz.org>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16720 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753944AbYFDLtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2008 07:49:22 -0400
In-Reply-To: <1212580148-9885-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv6/ipv6_sockglue.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 763230e..3152aaa 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -164,9 +164,14 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 			if (sk->sk_type == SOCK_RAW)
 				break;
 
-			if (sk->sk_protocol != IPPROTO_UDP &&
-			    sk->sk_protocol != IPPROTO_UDPLITE &&
-			    sk->sk_protocol != IPPROTO_TCP)
+			if (sk->sk_protocol == IPPROTO_UDP ||
+			    sk->sk_protocol == IPPROTO_UDPLITE) {
+				struct udp_sock *up = udp_sk(sk);
+				if (up->pending == AF_INET6) {
+					retv = -EBUSY;
+					break;
+				}
+			} else if (sk->sk_protocol != IPPROTO_TCP)
 				break;
 
 			if (sk->sk_state != TCP_ESTABLISHED) {
-- 
1.5.3.rc5

