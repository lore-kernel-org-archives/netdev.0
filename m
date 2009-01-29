From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] decnet: incorrect optlen size
Date: Thu, 29 Jan 2009 09:21:15 +0100
Message-ID: <498166FB.5030104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: christine.caulfield@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:47998 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbZA2IVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 03:21:17 -0500
Received: by ewy14 with SMTP id 14so3841382ewy.13
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2009 00:21:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several functions with something like this occur:

int sock_set_foo(int optlen, ...)
{
	struct food foo;

	if (optlen < sizeof(foo))
		return -EINVAL;

	if (copy_from_user(&foo, optval, sizeof(foo)))
		return -EFAULT;
	...
}

see for instance:
grep -C5 -E -R -n "copy_from_user\(&([a-zA-Z0-9]*), optval, sizeof\(\1\)\)" net

but in __dn_setsockopt, below, the checks are slightly different.
Should maybe the changes below be apllied?

-------------->8----------------8<-----------------------
fix size checks before copy_from_user

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index cf0e184..45b9199 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1359,10 +1359,10 @@ static int __dn_setsockopt(struct socket *sock, int level,int optname, char __us
 	if (optlen && !optval)
 		return -EINVAL;
 
-	if (optlen > sizeof(u))
+	if (optlen < sizeof(u))
 		return -EINVAL;
 
-	if (copy_from_user(&u, optval, optlen))
+	if (copy_from_user(&u, optval, sizeof(u)))
 		return -EFAULT;
 
 	switch(optname) {
