From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 2/3] lib: add "on" and "off" to strtobool
Date: Thu, 28 Jan 2016 06:17:06 -0800
Message-ID: <1453990627-19164-3-git-send-email-keescook@chromium.org>
References: <1453990627-19164-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Joe Perches <joe@perches.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Steve French <sfrench@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34476 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbcA1OR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 09:17:57 -0500
Received: by mail-pf0-f182.google.com with SMTP id o185so19634963pfb.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 06:17:44 -0800 (PST)
In-Reply-To: <1453990627-19164-1-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several places in the kernel expect to use "on" and "off" for their
boolean signifiers, so add them to strtobool.

Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/string.c | 24 +++++++++++++++++++++---
 1 file changed, 21 insertions(+), 3 deletions(-)

diff --git a/lib/string.c b/lib/string.c
index 0323c0d5629a..091570708db7 100644
--- a/lib/string.c
+++ b/lib/string.c
@@ -635,12 +635,15 @@ EXPORT_SYMBOL(sysfs_streq);
  * @s: input string
  * @res: result
  *
- * This routine returns 0 iff the first character is one of 'Yy1Nn0'.
- * Otherwise it will return -EINVAL.  Value pointed to by res is
- * updated upon finding a match.
+ * This routine returns 0 iff the first character is one of 'Yy1Nn0', or
+ * [oO][NnFf] for "on" and "off". Otherwise it will return -EINVAL.  Value
+ * pointed to by res is updated upon finding a match.
  */
 int strtobool(const char *s, bool *res)
 {
+	if (!s)
+		return -EINVAL;
+
 	switch (s[0]) {
 	case 'y':
 	case 'Y':
@@ -652,6 +655,21 @@ int strtobool(const char *s, bool *res)
 	case '0':
 		*res = false;
 		break;
+	case 'o':
+	case 'O':
+		switch (s[1]) {
+		case 'n':
+		case 'N':
+			*res = true;
+			break;
+		case 'f':
+		case 'F':
+			*res = false;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
 	default:
 		return -EINVAL;
 	}
-- 
2.6.3
