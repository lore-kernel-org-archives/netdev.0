From: Cheng Renquan <crquan@gmail.com>
Subject: [PATCH] dev-alloc-name-by-check-name-existence.patch
Date: Sat, 24 May 2014 14:46:51 -0700
Message-ID: <1400968011-13023-1-git-send-email-crquan@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:53502 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbaEXVpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 17:45:35 -0400
Received: by mail-yh0-f44.google.com with SMTP id b6so5375194yha.3
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 14:45:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nowadays the net_device names have been mounted on a hash table,
check name existence should be much faster than ever before, hence
the extra page of memory for bitmap scanning is no longer needed.

Signed-off-by: Cheng Renquan <crquan@gmail.com>

---
 net/core/dev.c |   33 ++++++---------------------------
 1 file changed, 6 insertions(+), 27 deletions(-)

Index: linux-3.14.3/net/core/dev.c
===================================================================
--- linux-3.14.3.orig/net/core/dev.c	2014-05-06 07:59:58.000000000 -0700
+++ linux-3.14.3/net/core/dev.c	2014-05-24 13:56:02.592865482 -0700
@@ -960,54 +960,33 @@
  *	Returns the number of the unit assigned or a negative errno code.
  */
 
 static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 {
 	int i = 0;
 	const char *p;
-	const int max_netdevices = 8*PAGE_SIZE;
-	unsigned long *inuse;
-	struct net_device *d;
 
 	p = strnchr(name, IFNAMSIZ-1, '%');
 	if (p) {
 		/*
 		 * Verify the string as this thing may have come from
 		 * the user.  There must be either one "%d" and no other "%"
 		 * characters.
 		 */
 		if (p[1] != 'd' || strchr(p + 2, '%'))
 			return -EINVAL;
 
-		/* Use one page as a bit array of possible slots */
-		inuse = (unsigned long *) get_zeroed_page(GFP_ATOMIC);
-		if (!inuse)
-			return -ENOMEM;
-
-		for_each_netdev(net, d) {
-			if (!sscanf(d->name, name, &i))
-				continue;
-			if (i < 0 || i >= max_netdevices)
-				continue;
-
-			/*  avoid cases where sscanf is not exact inverse of printf */
-			snprintf(buf, IFNAMSIZ, name, i);
-			if (!strncmp(buf, d->name, IFNAMSIZ))
-				set_bit(i, inuse);
-		}
-
-		i = find_first_zero_bit(inuse, max_netdevices);
-		free_page((unsigned long) inuse);
+		do {
+			if (snprintf(buf, IFNAMSIZ, name, i) >= IFNAMSIZ)
+				break;
+			if (!__dev_get_by_name(net, buf))
+				return i;
+		} while (++i > 0);
 	}
 
-	if (buf != name)
-		snprintf(buf, IFNAMSIZ, name, i);
-	if (!__dev_get_by_name(net, buf))
-		return i;
-
 	/* It is possible to run out of possible slots
 	 * when the name is long and there isn't enough space left
 	 * for the digits, or if all bits are used.
 	 */
 	return -ENFILE;
 }
 
