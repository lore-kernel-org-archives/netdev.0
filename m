From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next] net: IP_MULTICAST_IF setsockopt now recognizes struct mreq
Date: Fri,  4 May 2012 10:37:45 +0200
Message-ID: <1336120665-954-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752129Ab2EDIi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 04:38:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, struct mreq has not been recognized and it was worked with
as with struct in_addr. That means imr_multiaddr was copied to
imr_address. So do recognize struct mreq here and copy that correctly.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/ipv4/ip_sockglue.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 51c6c67..0d11f23 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -673,10 +673,15 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 				break;
 		} else {
 			memset(&mreq, 0, sizeof(mreq));
-			if (optlen >= sizeof(struct in_addr) &&
-			    copy_from_user(&mreq.imr_address, optval,
-					   sizeof(struct in_addr)))
-				break;
+			if (optlen >= sizeof(struct ip_mreq)) {
+				if (copy_from_user(&mreq, optval,
+						   sizeof(struct ip_mreq)))
+					break;
+			} else if (optlen >= sizeof(struct in_addr)) {
+				if (copy_from_user(&mreq.imr_address, optval,
+						   sizeof(struct in_addr)))
+					break;
+			}
 		}
 
 		if (!mreq.imr_ifindex) {
-- 
1.7.9.1
