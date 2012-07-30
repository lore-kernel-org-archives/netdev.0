From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH v2] net/tun: fix ioctl() based info leaks
Date: Mon, 30 Jul 2012 07:45:14 +0200
Message-ID: <1343627114-17899-1-git-send-email-minipli@googlemail.com>
References: <CAFLxGvwUNxOn3vRLdJeS6hVZ_Oko0_QPZfLWAe+ztCHGdqBFOw@mail.gmail.com>
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44899 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab2G3FqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 01:46:02 -0400
Received: by bkwj10 with SMTP id j10so2653596bkw.19
        for <netdev@vger.kernel.org>; Sun, 29 Jul 2012 22:46:00 -0700 (PDT)
In-Reply-To: <CAFLxGvwUNxOn3vRLdJeS6hVZ_Oko0_QPZfLWAe+ztCHGdqBFOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tun module leaks up to 36 bytes of memory by not fully initializing
a structure located on the stack that gets copied to user memory by the
TUNGETIFF and SIOCGIFHWADDR ioctl()s.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
v2:
- removed braces around else branch
- minor adjustment of the commit message

 drivers/net/tun.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 987aeef..01255ff 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1252,9 +1252,11 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 	int vnet_hdr_sz;
 	int ret;
 
-	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89)
+	if (cmd == TUNSETIFF || _IOC_TYPE(cmd) == 0x89) {
 		if (copy_from_user(&ifr, argp, ifreq_len))
 			return -EFAULT;
+	} else
+		memset(&ifr, 0, sizeof(ifr));
 
 	if (cmd == TUNGETFEATURES) {
 		/* Currently this just means: "what IFF flags are valid?".
-- 
1.7.10.4
