From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] support for large number of network devices.
Date: Wed, 14 Jan 2004 16:24:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114162411.08322247.shemminger@osdl.org>
References: <20040113154610.38f5934c.shemminger@osdl.org>
	<20040113155921.342db463.davem@redhat.com>
	<20040113161303.20f1159d.shemminger@osdl.org>
	<20040114071303.GG28521@waste.org>
	<20040114113734.4e9a0865.shemminger@osdl.org>
	<20040114121155.7dabd70e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040114121155.7dabd70e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This should make it match the existing semantics more exactly.
It will skip the false positive matchs from sscanf trailing chars
or blanks.

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Wed Jan 14 16:24:08 2004
+++ b/net/core/dev.c	Wed Jan 14 16:24:08 2004
@@ -654,7 +654,7 @@
 	const int max_netdevices = 8*PAGE_SIZE;
 	long *inuse;
 	struct net_device *d;
-	char buf[IFNAMSIZ];
+	char buf[32];
 
 	/*
 	 * Verify the string as this thing may have come from
@@ -671,12 +671,14 @@
 		return -ENOMEM;
 
 	for (d = dev_base; d; d = d->next) {
-		if (sscanf(d->name, name, &i)) {
-			if (i < 0 || i >= max_netdevices)
-				continue;
+		if (!sscanf(d->name, name, &i))
+			continue;
+		if (i < 0 || i >= max_netdevices)
+			continue;
 
+		snprintf(buf, sizeof(buf), name, i);
+		if (!strncmp(buf, d->name, IFNAMSIZ))
 			set_bit(i, inuse);
-		}
 	}
 
 	i = find_first_zero_bit(inuse, max_netdevices);
@@ -684,7 +686,7 @@
 	snprintf(buf, sizeof(buf), name, i);
 
 	if (!__dev_get_by_name(buf)) {
-		strcpy(dev->name, buf);
+		strlcpy(dev->name, buf, IFNAMSIZ);
 		return i;
 	}
 
