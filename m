From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6.9]: Fix netdevice/inet6_dev reference leaks in ip6_route_add
 error paths
Date: Wed, 20 Oct 2004 00:13:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417591A2.4090201@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040705080908040609060609"
Cc: netdev@oss.sgi.com, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040705080908040609060609
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The recent changes to ip6_route_add added multiple leaks in
error paths. This patch should fix them.

Regards
Patrick


--------------040705080908040609060609
Content-Type: text/plain;
 name="p2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="p2"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/19 23:46:56+02:00 kaber@coreworks.de 
#   [IPV6]: Fix netdevice/inet6_dev reference leaks in ip6_route_add error paths
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/route.c
#   2004/10/19 23:46:17+02:00 kaber@coreworks.de +8 -3
#   [IPV6]: Fix netdevice/inet6_dev reference leaks in ip6_route_add error paths
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-10-19 23:52:23 +02:00
+++ b/net/ipv6/route.c	2004-10-19 23:52:23 +02:00
@@ -798,8 +798,10 @@
 
 	rt = ip6_dst_alloc();
 
-	if (rt == NULL)
-		return -ENOMEM;
+	if (rt == NULL) {
+		err = -ENOMEM;
+		goto out;
+	}
 
 	rt->u.dst.obsolete = -1;
 	rt->rt6i_expires = clock_t_to_jiffies(rtmsg->rtmsg_info);
@@ -962,7 +964,10 @@
 out:
 	if (dev)
 		dev_put(dev);
-	dst_free((struct dst_entry *) rt);
+	if (idev)
+		in6_dev_put(idev);
+	if (rt)
+		dst_free((struct dst_entry *) rt);
 	return err;
 }
 

--------------040705080908040609060609--
