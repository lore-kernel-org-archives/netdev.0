From: Tom Herbert <therbert@google.com>
Subject: [PATCH iproute2 1/5] iplink: Fix setting of -1 as ifindex
Date: Fri,  3 Oct 2014 08:55:14 -0700
Message-ID: <1412351718-22921-2-git-send-email-therbert@google.com>
References: <1412351718-22921-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:60962 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078AbaJCPzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:55:46 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so2775381pdj.9
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 08:55:46 -0700 (PDT)
In-Reply-To: <1412351718-22921-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3c682146aeff157ec3540 ("iplink: forbid negative ifindex and
modifying ifindex") initializes index to -1 in iplink_modify. When
creating a link, req.i.ifi_index is then set to -1 if the link option is
not used. In the kernel this is then used to set dev->ifindex. For
dev->ifindex, zero is considered to be unset and -1 is treated as
a set index, so when a second tunnel is create the new device conflicts
with the old one (both have ifindex of -1) so -EBUSY is returned.

This patch set zero in req.i.ifi_index is index is unset (still -1).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 ip/iplink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index cb9c870..1b6ffc6 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -689,7 +689,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 			addattr_l(&req.n, sizeof(req), IFLA_LINK, &ifindex, 4);
 		}
 
-		req.i.ifi_index = index;
+		req.i.ifi_index = (index > 0) ? : 0;
 	}
 
 	if (name) {
-- 
2.1.0.rc2.206.gedb03e5
