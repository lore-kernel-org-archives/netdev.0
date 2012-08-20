From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] iproute: Fix errno propagation from rtnl_talk
Date: Mon, 20 Aug 2012 12:08:40 +0400
Message-ID: <5031F088.1030404@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:10947 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271Ab2HTIIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 04:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Callers of rtnl_talk check errno value for their needs. In particular, the addrs
and routes restoring code validly reports success if the EEXISTS is in there.

However, the errno value can be sometimes screwed up by the perror call. Thus
we should only set it _after_ the message was emitted.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 878911e..8e8c8b9 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -360,13 +360,14 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n, pid_t peer,
 				if (l < sizeof(struct nlmsgerr)) {
 					fprintf(stderr, "ERROR truncated\n");
 				} else {
-					errno = -err->error;
-					if (errno == 0) {
+					if (!err->error) {
 						if (answer)
 							memcpy(answer, h, h->nlmsg_len);
 						return 0;
 					}
-					perror("RTNETLINK answers");
+
+					fprintf(stderr, "RTNETLINK answers: %s\n", strerror(-err->error));
+					errno = -err->error;
 				}
 				return -1;
 			}
