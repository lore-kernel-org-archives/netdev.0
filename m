From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH] net/tun: fix ioctl() based info leaks
Date: Sun, 29 Jul 2012 22:58:14 +0200
Message-ID: <1343595494-10414-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:45525 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab2G2U64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2012 16:58:56 -0400
Received: by wibhr14 with SMTP id hr14so1231875wib.1
        for <netdev@vger.kernel.org>; Sun, 29 Jul 2012 13:58:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tun module leaks up to 36 bytes of memory by not initializing a
structure located on the stack that gets copied to user memory by the
TUNGETIFF and SIOCGIFHWADDR ioctl()s.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 drivers/net/tun.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 987aeef..cadeb94 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1252,9 +1252,12 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	int vnet_hdr_sz;
 	int ret;
 
-	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
+	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89) {
 		if (copy_from_user(&ifr, argp, ifreq_len))
 			return -EFAULT;
+	} else {
+		memset(&ifr, 0, sizeof(ifr));
+	}
 
 	if (cmd == TUNGETFEATURES) {
 		/* Currently this just means: "what IFF flags are valid?".
-- 
1.7.10.4
