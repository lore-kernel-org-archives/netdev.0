From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/4) Support for lots of netdev's -- faster dev_alloc_name
Date: Fri, 6 Feb 2004 10:12:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206101232.46bc30b1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert dev_alloc_name from O(n^2) lookup to O(n) by using a page as
bitmap to figure out how many devices of that pattern have been allocated.
This works for up to 32k devices (PAGE_SIZE*8) on i386, more on other
platforms.  Correctly handles the boundary cases where number of devices
won't fit because name length is limited.

Adds strnchr to the string libraries since we need to find the % format
character, but only care if it is in the first 15 bytes.

diff -Nru a/include/linux/string.h b/include/linux/string.h
--- a/include/linux/string.h	Thu Feb  5 15:17:53 2004
+++ b/include/linux/string.h	Thu Feb  5 15:17:53 2004
@@ -52,6 +52,9 @@
 #ifndef __HAVE_ARCH_STRCHR
 extern char * strchr(const char *,int);
 #endif
+#ifndef __HAVE_ARCH_STRNCHR
+extern char * strnchr(const char *, size_t, int);
+#endif
 #ifndef __HAVE_ARCH_STRRCHR
 extern char * strrchr(const char *,int);
 #endif
diff -Nru a/lib/string.c b/lib/string.c
--- a/lib/string.c	Thu Feb  5 15:17:53 2004
+++ b/lib/string.c	Thu Feb  5 15:17:53 2004
@@ -273,6 +273,22 @@
 }
 #endif
 
+#ifndef __HAVE_ARCH_STRNCHR
+/**
+ * strnchr - Find a character in a length limited string
+ * @s: The string to be searched
+ * @count: The number of characters to be searched
+ * @c: The character to search for
+ */
+char *strnchr(const char *s, size_t count, int c)
+{
+	for (; count-- && *s != '\0'; ++s)
+		if (*s == (char) c)
+			return (char *) s;
+	return NULL;
+}
+#endif
+
 #ifndef __HAVE_ARCH_STRLEN
 /**
  * strlen - Find the length of a string
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Thu Feb  5 15:17:53 2004
+++ b/net/core/dev.c	Thu Feb  5 15:17:53 2004
@@ -720,30 +720,55 @@
 
 int dev_alloc_name(struct net_device *dev, const char *name)
 {
-	int i;
-	char buf[32];
-	char *p;
-
-	/*
-	 * Verify the string as this thing may have come from
-	 * the user.  There must be either one "%d" and no other "%"
-	 * characters, or no "%" characters at all.
-	 */
-	p = strchr(name, '%');
-	if (p && (p[1] != 'd' || strchr(p + 2, '%')))
-		return -EINVAL;
+	int i = 0;
+	char buf[IFNAMSIZ];
+	const char *p;
+	const int max_netdevices = 8*PAGE_SIZE;
+	long *inuse;
+	struct net_device *d;
 
-	/*
-	 * If you need over 100 please also fix the algorithm...
-	 */
-	for (i = 0; i < 100; i++) {
-		snprintf(buf, sizeof(buf), name, i);
-		if (!__dev_get_by_name(buf)) {
-			strcpy(dev->name, buf);
-			return i;
+	p = strnchr(name, IFNAMSIZ-1, '%');
+	if (p) {
+		/*
+		 * Verify the string as this thing may have come from
+		 * the user.  There must be either one "%d" and no other "%"
+		 * characters.
+		 */
+		if (p[1] != 'd' || strchr(p + 2, '%'))
+			return -EINVAL;
+
+		/* Use one page as a bit array of possible slots */
+		inuse = (long *) get_zeroed_page(GFP_ATOMIC);
+		if (!inuse)
+			return -ENOMEM;
+
+		for (d = dev_base; d; d = d->next) {
+			if (!sscanf(d->name, name, &i))
+				continue;
+			if (i < 0 || i >= max_netdevices)
+				continue;
+
+			/*  avoid cases where sscanf is not exact inverse of printf */
+			snprintf(buf, sizeof(buf), name, i);
+			if (!strncmp(buf, d->name, IFNAMSIZ))
+				set_bit(i, inuse);
 		}
+
+		i = find_first_zero_bit(inuse, max_netdevices);
+		free_page((unsigned long) inuse);
+	}
+
+	snprintf(buf, sizeof(buf), name, i);
+	if (!__dev_get_by_name(buf)) {
+		strlcpy(dev->name, buf, IFNAMSIZ);
+		return i;
 	}
-	return -ENFILE;	/* Over 100 of the things .. bail out! */
+
+	/* It is possible to run out of possible slots
+	 * when the name is long and there isn't enough space left
+	 * for the digits, or if all bits are used.
+	 */
+	return -ENFILE;
 }
 
 
