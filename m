From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] support for large number of network devices.
Date: Tue, 13 Jan 2004 15:46:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113154610.38f5934c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When using pseudo network devices, and really big machines; there is
sometimes a need to have a lot of network devices.  This replaces the
existing 2.6.1 limit of 100 entries an was O(n^2)
with a algorithm that will handle up to 32768 entries with O(n) behaviour.

Does need a temporary page, but that shouldn't be a big deal.
It has the same semantics, it will find the first empty name and use it.

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Tue Jan 13 15:42:19 2004
+++ b/net/core/dev.c	Tue Jan 13 15:42:19 2004
@@ -650,8 +650,11 @@
 int dev_alloc_name(struct net_device *dev, const char *name)
 {
 	int i;
-	char buf[32];
 	char *p;
+	const int max_netdevices = 8*PAGE_SIZE;
+	long *inuse;
+	struct net_device *d;
+	char buf[IFNAMSIZ];
 
 	/*
 	 * Verify the string as this thing may have come from
@@ -662,17 +665,34 @@
 	if (p && (p[1] != 'd' || strchr(p + 2, '%')))
 		return -EINVAL;
 
-	/*
-	 * If you need over 100 please also fix the algorithm...
-	 */
-	for (i = 0; i < 100; i++) {
-		snprintf(buf, sizeof(buf), name, i);
-		if (!__dev_get_by_name(buf)) {
-			strcpy(dev->name, buf);
-			return i;
+	/* Use one page as a bit array of possible slots */
+	inuse = (long *) get_zeroed_page(GFP_ATOMIC);
+	if (!inuse) 
+		return -ENOMEM;
+
+	for (d = dev_base; d; d = d->next) {
+		if (sscanf(d->name, name, &i)) {
+			if (i < 0 || i >= max_netdevices)
+				continue;
+
+			set_bit(i, inuse);
 		}
 	}
-	return -ENFILE;	/* Over 100 of the things .. bail out! */
+
+	i = find_first_zero_bit(inuse, max_netdevices);
+	free_page((unsigned long) inuse);
+	snprintf(buf, sizeof(buf), name, i);
+
+	if (!__dev_get_by_name(buf)) {
+		strcpy(dev->name, buf);
+		return i;
+	}
+
+	/* It is possible to run out of possible slots
+	 * when the name is long and there isn't enough space left
+	 * for the digits, or if all bits are used.
+	 */
+	return -ENFILE;
 }
 
 
