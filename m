From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (12/13) ddp do netdev hold/put
Date: Fri, 29 Aug 2003 14:16:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829141638.70712365.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

DDP holds a pointer to underlying network device, but doesn't
do the refcount bookeeping that it should.

diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Fri Aug 29 13:33:24 2003
+++ b/net/appletalk/ddp.c	Fri Aug 29 13:33:24 2003
@@ -232,6 +232,7 @@
 	while ((tmp = *iface) != NULL) {
 		if (tmp->dev == dev) {
 			*iface = tmp->next;
+			dev_put(dev);
 			kfree(tmp);
 			dev->atalk_ptr = NULL;
 		} else
@@ -248,6 +249,7 @@
 	if (!iface)
 		goto out;
 
+	dev_hold(dev);
 	iface->dev = dev;
 	dev->atalk_ptr = iface;
 	iface->address = *sa;
@@ -609,6 +611,7 @@
 		    (!(tmp->flags&RTF_GATEWAY) ||
 		     tmp->target.s_node == addr->s_node)) {
 			*r = tmp->next;
+			dev_put(tmp->dev);
 			kfree(tmp);
 			goto out;
 		}
@@ -633,6 +636,7 @@
 	while ((tmp = *r) != NULL) {
 		if (tmp->dev == dev) {
 			*r = tmp->next;
+			dev_put(dev);
 			kfree(tmp);
 		} else
 			r = &tmp->next;
