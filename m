From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 2/3] net: ipconfig: Support using "delayed" DHCP replies
Date: Fri, 29 Jul 2016 11:30:38 +0200
Message-ID: <1469784639-15705-3-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20160728112613.n72e6pein3b5lm4b@pengutronix.de>
 <1469784639-15705-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Chris Friesen <cfriesen@nortel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:41776 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751557AbcG2JbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 05:31:25 -0400
In-Reply-To: <1469784639-15705-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dhcp code only waits 1s between sending DHCP requests on different
devices and only accepts an answer for the device that sent out the las=
t
request. Only the timeout at the end of a loop is increased iteratively
which favours only the last device. This makes it impossible to work
with a dhcp server that takes little more than 1s connected to a device
that is not the last one.

Instead of also increasing the inter-device timeout, teach the code to
handle delayed replies.

To accomplish that, make *ic_dev track the current ic_device instead of
the current net_device and adapt all users accordingly. The relevant
change then is to reset d to ic_dev on a reply to assert that the
followup request goes through the right device.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 net/ipv4/ipconfig.c | 29 ++++++++++-------------------
 1 file changed, 10 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 369e4a004850..5af6736bd384 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -188,7 +188,7 @@ struct ic_device {
 };
=20
 static struct ic_device *ic_first_dev __initdata;	/* List of open devi=
ce */
-static struct net_device *ic_dev __initdata;		/* Selected device */
+static struct ic_device *ic_dev __initdata;		/* Selected device */
=20
 static bool __init ic_is_init_dev(struct net_device *dev)
 {
@@ -307,7 +307,7 @@ static void __init ic_close_devs(void)
 	while ((d =3D next)) {
 		next =3D d->next;
 		dev =3D d->dev;
-		if (dev !=3D ic_dev && !netdev_uses_dsa(dev)) {
+		if (dev !=3D ic_dev->dev && !netdev_uses_dsa(dev)) {
 			pr_debug("IP-Config: Downing %s\n", dev->name);
 			dev_change_flags(dev, d->flags);
 		}
@@ -372,7 +372,7 @@ static int __init ic_setup_if(void)
 	int err;
=20
 	memset(&ir, 0, sizeof(ir));
-	strcpy(ir.ifr_ifrn.ifrn_name, ic_dev->name);
+	strcpy(ir.ifr_ifrn.ifrn_name, ic_dev->dev->name);
 	set_sockaddr(sin, ic_myaddr, 0);
 	if ((err =3D ic_devinet_ioctl(SIOCSIFADDR, &ir)) < 0) {
 		pr_err("IP-Config: Unable to set interface address (%d)\n",
@@ -396,7 +396,7 @@ static int __init ic_setup_if(void)
 	 * out, we'll try to muddle along.
 	 */
 	if (ic_dev_mtu !=3D 0) {
-		strcpy(ir.ifr_name, ic_dev->name);
+		strcpy(ir.ifr_name, ic_dev->dev->name);
 		ir.ifr_mtu =3D ic_dev_mtu;
 		if ((err =3D ic_dev_ioctl(SIOCSIFMTU, &ir)) < 0)
 			pr_err("IP-Config: Unable to set interface mtu to %d (%d)\n",
@@ -568,7 +568,7 @@ ic_rarp_recv(struct sk_buff *skb, struct net_device=
 *dev, struct packet_type *pt
 		goto drop_unlock;
=20
 	/* We have a winner! */
-	ic_dev =3D dev;
+	ic_dev =3D d;
 	if (ic_myaddr =3D=3D NONE)
 		ic_myaddr =3D tip;
 	ic_servaddr =3D sip;
@@ -655,8 +655,6 @@ static struct packet_type bootp_packet_type __initd=
ata =3D {
 	.func =3D	ic_bootp_recv,
 };
=20
-static __be32 ic_dev_xid;		/* Device under configuration */
-
 /*
  *  Initialize DHCP/BOOTP extension fields in the request.
  */
@@ -1038,12 +1036,6 @@ static int __init ic_bootp_recv(struct sk_buff *=
skb, struct net_device *dev, str
 		goto drop_unlock;
 	}
=20
-	/* Is it a reply for the device we are configuring? */
-	if (b->xid !=3D ic_dev_xid) {
-		net_err_ratelimited("DHCP/BOOTP: Ignoring delayed packet\n");
-		goto drop_unlock;
-	}
-
 	/* Parse extensions */
 	if (ext_len >=3D 4 &&
 	    !memcmp(b->exten, ic_bootp_cookie, 4)) { /* Check magic cookie */
@@ -1130,7 +1122,7 @@ static int __init ic_bootp_recv(struct sk_buff *s=
kb, struct net_device *dev, str
 	}
=20
 	/* We have a winner! */
-	ic_dev =3D dev;
+	ic_dev =3D d;
 	ic_myaddr =3D b->your_ip;
 	ic_servaddr =3D b->server_ip;
 	ic_addrservaddr =3D b->iph.saddr;
@@ -1225,9 +1217,6 @@ static int __init ic_dynamic(void)
 	timeout =3D CONF_BASE_TIMEOUT + (timeout % (unsigned int) CONF_TIMEOU=
T_RANDOM);
 	for (;;) {
 #ifdef IPCONFIG_BOOTP
-		/* Track the device we are configuring */
-		ic_dev_xid =3D d->xid;
-
 		if (do_bootp && (d->able & IC_BOOTP))
 			ic_bootp_send_if(d, jiffies - start_jiffies);
 #endif
@@ -1245,6 +1234,8 @@ static int __init ic_dynamic(void)
 		    (ic_proto_enabled & IC_USE_DHCP) &&
 		    ic_dhcp_msgtype !=3D DHCPACK) {
 			ic_got_reply =3D 0;
+			/* continue on device that got the reply */
+			d =3D ic_dev;
 			pr_cont(",");
 			continue;
 		}
@@ -1487,7 +1478,7 @@ static int __init ip_auto_config(void)
 #endif /* IPCONFIG_DYNAMIC */
 	} else {
 		/* Device selected manually or only one device -> use it */
-		ic_dev =3D ic_first_dev->dev;
+		ic_dev =3D ic_first_dev;
 	}
=20
 	addr =3D root_nfs_parse_addr(root_server_path);
@@ -1522,7 +1513,7 @@ static int __init ip_auto_config(void)
 	pr_info("IP-Config: Complete:\n");
=20
 	pr_info("     device=3D%s, hwaddr=3D%*phC, ipaddr=3D%pI4, mask=3D%pI4=
, gw=3D%pI4\n",
-		ic_dev->name, ic_dev->addr_len, ic_dev->dev_addr,
+		ic_dev->dev->name, ic_dev->dev->addr_len, ic_dev->dev->dev_addr,
 		&ic_myaddr, &ic_netmask, &ic_gateway);
 	pr_info("     host=3D%s, domain=3D%s, nis-domain=3D%s\n",
 		utsname()->nodename, ic_domain, utsname()->domainname);
--=20
2.8.1
