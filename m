From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) support large number of network devices -- alloc_name
 bitmap
Date: Fri, 16 Jan 2004 15:50:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116155007.6b68844f.shemminger@osdl.org>
References: <20040116154652.04dd3324.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040116154652.04dd3324.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert dev_alloc_name from O(n^2) algorithm with a limit
of 100 of same prefix; to a two pass O(n) algorithim with a limit of 
32k devices with the same prefix.

This version finds the first free slot, and handles overflow correctly
for long names.

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Fri Jan 16 15:45:04 2004
+++ b/net/core/dev.c	Fri Jan 16 15:45:04 2004
@@ -698,8 +698,11 @@
 int dev_alloc_name(struct net_device *dev, const char *name)
 {
 	int i;
-	char buf[32];
-	char *p;
+	char buf[IFNAMSIZ];
+	const char *p;
+	const int max_netdevices = 8*PAGE_SIZE;
+	long *inuse;
+	struct net_device *d;
 
 	/*
 	 * Verify the string as this thing may have come from
@@ -707,20 +710,41 @@
 	 * characters, or no "%" characters at all.
 	 */
 	p = strchr(name, '%');
-	if (p && (p[1] != 'd' || strchr(p + 2, '%')))
+	if (p && ((p[1] != 'd' || strchr(p + 2, '%'))
+		  || (p - name) > IFNAMSIZ-2))
 		return -EINVAL;
 
-	/*
-	 * If you need over 100 please also fix the algorithm...
-	 */
-	for (i = 0; i < 100; i++) {
+	/* Use one page as a bit array of possible slots */
+	inuse = (long *) get_zeroed_page(GFP_ATOMIC);
+	if (!inuse)
+		return -ENOMEM;
+
+	for (d = dev_base; d; d = d->next) {
+		if (!sscanf(d->name, name, &i))
+			continue;
+		if (i < 0 || i >= max_netdevices)
+			continue;
+
+		/*  avoid cases where sscanf is not exact inverse of printf */
 		snprintf(buf, sizeof(buf), name, i);
-		if (!__dev_get_by_name(buf)) {
-			strcpy(dev->name, buf);
-			return i;
-		}
+		if (!strncmp(buf, d->name, IFNAMSIZ))
+			set_bit(i, inuse);
 	}
-	return -ENFILE;	/* Over 100 of the things .. bail out! */
+
+	i = find_first_zero_bit(inuse, max_netdevices);
+	free_page((unsigned long) inuse);
+
+	snprintf(buf, sizeof(buf), name, i);
+	if (!__dev_get_by_name(buf)) {
+		strlcpy(dev->name, buf, IFNAMSIZ);
+		return i;
+	}
+
+	/* It is possible to run out of possible slots
+	 * when the name is long and there isn't enough space left
+	 * for the digits, or if all bits are used.
+	 */
+	return -ENFILE;
 }
 
 
