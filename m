From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Uninitialized timer in ip_mc_down
Date: Thu, 25 Mar 2004 13:57:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040325125755.GA8500@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="n8g4imXOkfNTN/H1"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Hi,

if you do the following on a downed interface on 2.6, you get two
"uninitialized timer" messages from the kernel, along with a stack trace.

	ip addr add 1.2.3.4 dev eth1
	ip addr del 1.2.3.4 dev eth1

The reason is that inetdev_create calls ip_mc_up if and only if the device
is up. However, inetdev_destroy calls ip_mc_destroy_dev unconditionally,
so that del_timer gets called for the two multicast timers which are
uninitialized.

The attached patch seems to fix this. An alternative patch would
be to add a check to ip_mc_down to see whether the timers are
actually active before deleting them.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 

--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=ipv4-mcast-timer

--- ../linux-2.6.4.orig/net/ipv4/devinet.c	2004-03-12 12:17:31.000000000 +0100
+++ ../linux-2.6.4/net/ipv4/devinet.c	2004-03-25 13:07:24.000000000 +0100
@@ -183,7 +183,10 @@
 
 	in_dev->dead = 1;
 
-	ip_mc_destroy_dev(in_dev);
+	/* If the device isn't up, the multicast info isn't
+	 * initialized. */
+	if (in_dev->dev->flags & IFF_UP)
+		ip_mc_destroy_dev(in_dev);
 
 	while ((ifa = in_dev->ifa_list) != NULL) {
 		inet_del_ifa(in_dev, &in_dev->ifa_list, 0);

--n8g4imXOkfNTN/H1--
