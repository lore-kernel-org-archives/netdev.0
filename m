From: Seif Mazareeb <seif.mazareeb@gmail.com>
Subject: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL
Date: Thu, 17 Oct 2013 20:33:21 -0700
Message-ID: <1382067201-8286-1-git-send-email-seif.mazareeb@gmail.com>
Cc: seif@marvell.com, netdev@vger.kernel.org
To: paul@paul-moore.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:45245 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab3JRDeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 23:34:12 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so3205343pbb.6
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 20:34:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Seif Mazareeb <seif@marvell.com>

When CONFIG_NETLABEL is disabled, the cipso_v4_validate() function could loop
forever in the main loop if opt[opt_iter +1] == 0, this will causing a kernel
crash in an SMP system, since the CPU executing this function will
stall /not respond to IPIs.

This problem can be reproduced by running the IP Stack Integrity Checker
(http://isic.sourceforge.net) using the following command on a Linux machine
connected to DUT:

"icmpsic -s rand -d <DUT IP address> -r 123456"
wait (1-2 min)

Signed-off-by: Seif Mazareeb <seif@marvell.com>
---
 include/net/cipso_ipv4.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index a7a683e..a8c2ef6 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -290,6 +290,7 @@ static inline int cipso_v4_validate(const struct sk_buff *skb,
 	unsigned char err_offset = 0;
 	u8 opt_len = opt[1];
 	u8 opt_iter;
+	u8 tag_len;
 
 	if (opt_len < 8) {
 		err_offset = 1;
@@ -302,11 +303,12 @@ static inline int cipso_v4_validate(const struct sk_buff *skb,
 	}
 
 	for (opt_iter = 6; opt_iter < opt_len;) {
-		if (opt[opt_iter + 1] > (opt_len - opt_iter)) {
+		tag_len = opt[opt_iter + 1];
+		if ((tag_len == 0) || (opt[opt_iter + 1] > (opt_len - opt_iter))) {
 			err_offset = opt_iter + 1;
 			goto out;
 		}
-		opt_iter += opt[opt_iter + 1];
+		opt_iter += tag_len;
 	}
 
 out:
-- 
1.8.1.2
