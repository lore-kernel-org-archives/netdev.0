From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] rocker: fix harmless warning on 32-bit machines
Date: Tue, 13 Jan 2015 15:23:52 +0100
Message-ID: <4047824.AYNhYQQ6UI@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:55950 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbbAMOYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 09:24:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rocker driver tries to assign a pointer to a 64-bit integer
and then back to a pointer. This is safe on all architectures,
but causes a compiler warning when pointers are shorter than
64-bit:

rocker/rocker.c: In function 'rocker_desc_cookie_ptr_get':
rocker/rocker.c:809:9: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
  return (void *) desc_info->desc->cookie;
         ^

This adds another cast to uintptr_t to tell the compiler
that it's safe.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2f398fa4b9e6..cad8cf962cdf 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -806,13 +806,13 @@ static bool rocker_desc_gen(struct rocker_desc_info *desc_info)
 
 static void *rocker_desc_cookie_ptr_get(struct rocker_desc_info *desc_info)
 {
-	return (void *) desc_info->desc->cookie;
+	return (void *)(uintptr_t)desc_info->desc->cookie;
 }
 
 static void rocker_desc_cookie_ptr_set(struct rocker_desc_info *desc_info,
 				       void *ptr)
 {
-	desc_info->desc->cookie = (long) ptr;
+	desc_info->desc->cookie = (uintptr_t) ptr;
 }
 
 static struct rocker_desc_info *
