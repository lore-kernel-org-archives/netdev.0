From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH net-next] core: Simplify logic in dev_load().
Date: Tue, 2 Sep 2014 13:51:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174856D6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59001 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752460AbaIBNxY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 09:53:24 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11556-10 for <netdev@vger.kernel.org>;
 Tue,  2 Sep 2014 14:53:15 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in dev_load() is convoluted.
Return early and remove the 'no_module' variable.
---

Note that this patch will only apply after the one that adds the
check for name[0].

 net/core/dev_ioctl.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index 84edf16..4b7ab54 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -356,7 +356,6 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 void dev_load(struct net *net, const char *name)
 {
 	struct net_device *dev;
-	int no_module;
 
 	if (!name[0])
 		return;
@@ -364,15 +363,15 @@ void dev_load(struct net *net, const char *name)
 	rcu_read_lock();
 	dev = dev_get_by_name_rcu(net, name);
 	rcu_read_unlock();
+	if (dev)
+		return;
 
-	no_module = !dev;
-	if (no_module && capable(CAP_NET_ADMIN))
-		no_module = request_module("netdev-%s", name);
-	if (no_module && capable(CAP_SYS_MODULE)) {
-		if (!request_module("%s", name))
-			pr_warn("Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.\n",
-				name);
-	}
+	if (capable(CAP_NET_ADMIN) && !request_module("netdev-%s", name))
+		return;
+
+	if (capable(CAP_SYS_MODULE) && !request_module("%s", name))
+		pr_warn("Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.\n",
+			name);
 }
 EXPORT_SYMBOL(dev_load);
 
-- 
1.8.1.2
