From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] more improvement to dev_alloc_name -- strnchr
Date: Mon, 19 Jan 2004 11:32:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119113204.5913a8d6.shemminger@osdl.org>
References: <1074302619.40088e9bd44a6@www.geekmail.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alex Pankratov <ap@cipherica.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1074302619.40088e9bd44a6@www.geekmail.cc>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 16 Jan 2004 20:23:39 -0500
Alex Pankratov <ap@cipherica.com> wrote:

> Stephen,
> 
> perhaps it'd make sense to bail out from dev_alloc_name()
> without iterating if the name is not wildcarded ? 

Okay, this patch avoids the loop if no wildcarding present, and keeps
the same behaviour as original.  It adds the string function strnchr
to avoid searching past the maximum ifname size to find the format character.

diff -Nru a/include/linux/string.h b/include/linux/string.h
--- a/include/linux/string.h	Mon Jan 19 11:30:38 2004
+++ b/include/linux/string.h	Mon Jan 19 11:30:38 2004
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
--- a/lib/string.c	Mon Jan 19 11:30:38 2004
+++ b/lib/string.c	Mon Jan 19 11:30:38 2004
@@ -271,6 +271,22 @@
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
--- a/net/core/dev.c	Mon Jan 19 11:30:38 2004
+++ b/net/core/dev.c	Mon Jan 19 11:30:38 2004
@@ -697,42 +697,43 @@
 
 int dev_alloc_name(struct net_device *dev, const char *name)
 {
-	int i;
+	int i = 0;
 	char buf[IFNAMSIZ];
 	const char *p;
 	const int max_netdevices = 8*PAGE_SIZE;
 	long *inuse;
 	struct net_device *d;
 
-	/*
-	 * Verify the string as this thing may have come from
-	 * the user.  There must be either one "%d" and no other "%"
-	 * characters, or no "%" characters at all.
-	 */
-	p = strchr(name, '%');
-	if (p && ((p[1] != 'd' || strchr(p + 2, '%'))
-		  || (p - name) > IFNAMSIZ-2))
-		return -EINVAL;
+	p = strnchr(name, IFNAMSIZ-1, '%');
+	if (p) {
+		/*
+		 * Verify the string as this thing may have come from
+		 * the user.  There must be either one "%d" and no other "%"
+		 * characters.
+		 */
+		if (p[1] != 'd' || strchr(p + 2, '%'))
+			return -EINVAL;
 
-	/* Use one page as a bit array of possible slots */
-	inuse = (long *) get_zeroed_page(GFP_ATOMIC);
-	if (!inuse)
-		return -ENOMEM;
+		/* Use one page as a bit array of possible slots */
+		inuse = (long *) get_zeroed_page(GFP_ATOMIC);
+		if (!inuse)
+			return -ENOMEM;
 
-	for (d = dev_base; d; d = d->next) {
-		if (!sscanf(d->name, name, &i))
-			continue;
-		if (i < 0 || i >= max_netdevices)
-			continue;
+		for (d = dev_base; d; d = d->next) {
+			if (!sscanf(d->name, name, &i))
+				continue;
+			if (i < 0 || i >= max_netdevices)
+				continue;
 
-		/*  avoid cases where sscanf is not exact inverse of printf */
-		snprintf(buf, sizeof(buf), name, i);
-		if (!strncmp(buf, d->name, IFNAMSIZ))
-			set_bit(i, inuse);
-	}
+			/*  avoid cases where sscanf is not exact inverse of printf */
+			snprintf(buf, sizeof(buf), name, i);
+			if (!strncmp(buf, d->name, IFNAMSIZ))
+				set_bit(i, inuse);
+		}
 
-	i = find_first_zero_bit(inuse, max_netdevices);
-	free_page((unsigned long) inuse);
+		i = find_first_zero_bit(inuse, max_netdevices);
+		free_page((unsigned long) inuse);
+	}
 
 	snprintf(buf, sizeof(buf), name, i);
 	if (!__dev_get_by_name(buf)) {
