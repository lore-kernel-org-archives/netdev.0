From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4] Make loopback idev stick around
Date: Sat, 5 Feb 2005 16:30:30 +1100
Message-ID: <20050205053030.GA17412@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
To: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

As it is when loopback_dev loses all of its IPv4 addresses its
corresponding idev will be destroyed.  Unfortunately as of last
August route.c relies on the loopback idev to kill references
to other idev objects.

The end result is that when you do ip a f dev lo, unregistering
other devices will hang until those dst objects referring to
their idev objects die of natural causes.  Of course this may
never happen if the processes holding those references get
dead-locked by invoking an operation that takes the RTNL.

A simple solution is to make sure that loopback's idev sticks
around all the time.

Incidentally this also fixes the setting of some flags on the
loopback idev object as currently the code that does it won't
be called if you add the addresses to lo after bring it up.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=idev-1

===== net/ipv4/devinet.c 1.42 vs edited =====
--- 1.42/net/ipv4/devinet.c	2005-01-11 08:43:25 +11:00
+++ edited/net/ipv4/devinet.c	2005-02-05 14:25:56 +11:00
@@ -187,6 +187,10 @@
 
 	ASSERT_RTNL();
 
+	dev = in_dev->dev;
+	if (dev == &loopback_dev)
+		return;
+
 	in_dev->dead = 1;
 
 	ip_mc_destroy_dev(in_dev);
@@ -200,7 +204,6 @@
 	devinet_sysctl_unregister(&in_dev->cnf);
 #endif
 
-	dev = in_dev->dev;
 	dev->ip_ptr = NULL;
 
 #ifdef CONFIG_SYSCTL
@@ -943,8 +946,16 @@
 
 	ASSERT_RTNL();
 
-	if (!in_dev)
+	if (!in_dev) {
+		if (event == NETDEV_REGISTER && dev == &loopback_dev) {
+			in_dev = inetdev_init(dev);
+			if (!in_dev)
+				panic("devinet: Failed to create loopback\n");
+			in_dev->cnf.no_xfrm = 1;
+			in_dev->cnf.no_policy = 1;
+		}
 		goto out;
+	}
 
 	switch (event) {
 	case NETDEV_REGISTER:
@@ -967,8 +978,6 @@
 				memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
 				inet_insert_ifa(ifa);
 			}
-			in_dev->cnf.no_xfrm = 1;
-			in_dev->cnf.no_policy = 1;
 		}
 		ip_mc_up(in_dev);
 		break;

--AhhlLboLdkugWU4S--
