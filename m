From: Lukasz Stelmach <stlman@poczta.fm>
Subject: Re: [PATCH] Temporary IPv6 address asignment (v.1.1)
Date: Mon, 04 May 2009 15:30:48 +0200
Message-ID: <49FEEE08.1090503@poczta.fm>
References: <49FE107A.4020406@poczta.fm>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060808010902090509020100"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, ebiederm@xmission.com
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp239.poczta.interia.pl ([217.74.64.239]:10554 "EHLO
	smtp239.poczta.interia.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754690AbZEDNa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 09:30:58 -0400
In-Reply-To: <49FE107A.4020406@poczta.fm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060808010902090509020100
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

A fixed mechanism to create and recreate temporary addresses,
even for very short preferred lifetimes.

A new RFC-compliant DESYNC_FACTOR implemented as a sysctl
variable desync_factor which is assigned a random value
each time max_desync_factor is written to.  Each interface
has its own desync_factor and max_desync_factor. Writes to
default/max_desync_factor influence only default values. Writes
to all/max_desync_factor influence "all" and default values but
not values of running interfaces.

The patch fixes issues described in bugs #13208 and #13221 at
http://bugzilla.kernel.org.

Signed-off-by: Łukasz Stelmach <stlman@poczta.fm>

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 476d946..678687d 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -146,6 +146,7 @@ struct ipv6_devconf {
 	__s32		temp_prefered_lft;
 	__s32		regen_max_retry;
 	__s32		max_desync_factor;
+	__s32		desync_factor;
 #endif
 	__s32		max_addresses;
 	__s32		accept_ra_defrtr;
@@ -201,6 +202,7 @@ enum {
 	DEVCONF_MC_FORWARDING,
 	DEVCONF_DISABLE_IPV6,
 	DEVCONF_ACCEPT_DAD,
+	DEVCONF_DESYNC_FACTOR,
 	DEVCONF_MAX
 };

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a8218bc..c883064 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -116,8 +116,6 @@ static inline void addrconf_sysctl_unregister(struct inet6_dev *idev)
 static int __ipv6_regen_rndid(struct inet6_dev *idev);
 static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr);
 static void ipv6_regen_rndid(unsigned long data);
-
-static int desync_factor = MAX_DESYNC_FACTOR * HZ;
 #endif

 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
@@ -172,6 +170,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
 	.regen_max_retry	= REGEN_MAX_RETRY,
 	.max_desync_factor	= MAX_DESYNC_FACTOR,
+	.desync_factor		= MAX_DESYNC_FACTOR / 2,
 #endif
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
@@ -206,6 +205,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
 	.regen_max_retry	= REGEN_MAX_RETRY,
 	.max_desync_factor	= MAX_DESYNC_FACTOR,
+	.desync_factor		= MAX_DESYNC_FACTOR / 2,
 #endif
 	.max_addresses		= IPV6_MAX_ADDRESSES,
 	.accept_ra_defrtr	= 1,
@@ -831,11 +831,13 @@ static void ipv6_del_addr(struct inet6_ifaddr *ifp)
 }

 #ifdef CONFIG_IPV6_PRIVACY
-static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *ift)
+static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp,
+				struct inet6_ifaddr *ift,
+				unsigned long now)
 {
 	struct inet6_dev *idev = ifp->idev;
 	struct in6_addr addr, *tmpaddr;
-	unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp;
+	unsigned long tmp_prefered_lft, tmp_valid_lft;
 	unsigned long regen_advance;
 	int tmp_plen;
 	int ret = 0;
@@ -890,11 +892,9 @@ retry:
 			      idev->cnf.temp_valid_lft);
 	tmp_prefered_lft = min_t(__u32,
 				 ifp->prefered_lft,
-				 idev->cnf.temp_prefered_lft - desync_factor / HZ);
+				 idev->cnf.temp_prefered_lft - idev->cnf.desync_factor);
 	tmp_plen = ifp->prefix_len;
 	max_addresses = idev->cnf.max_addresses;
-	tmp_cstamp = ifp->cstamp;
-	tmp_tstamp = ifp->tstamp;
 	spin_unlock_bh(&ifp->lock);

 	regen_advance = idev->cnf.regen_max_retry *
@@ -938,8 +938,7 @@ retry:
 	ift->ifpub = ifp;
 	ift->valid_lft = tmp_valid_lft;
 	ift->prefered_lft = tmp_prefered_lft;
-	ift->cstamp = tmp_cstamp;
-	ift->tstamp = tmp_tstamp;
+	ift->cstamp = ift->tstamp = now;
 	spin_unlock_bh(&ift->lock);

 	addrconf_dad_start(ift, 0);
@@ -1388,7 +1387,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
 		if (ifpub) {
 			in6_ifa_hold(ifpub);
 			spin_unlock_bh(&ifp->lock);
-			ipv6_create_tempaddr(ifpub, ifp);
+			ipv6_create_tempaddr(ifpub, ifp, jiffies);
 			in6_ifa_put(ifpub);
 		} else {
 			spin_unlock_bh(&ifp->lock);
@@ -1624,7 +1623,8 @@ static void ipv6_regen_rndid(unsigned long data)

 	expires = jiffies +
 		idev->cnf.temp_prefered_lft * HZ -
-		idev->cnf.regen_max_retry * idev->cnf.dad_transmits * idev->nd_parms->retrans_time - desync_factor;
+		idev->cnf.regen_max_retry * idev->cnf.dad_transmits * idev->nd_parms->retrans_time -
+		idev->cnf.desync_factor * HZ;
 	if (time_before(expires, jiffies)) {
 		printk(KERN_WARNING
 			"ipv6_regen_rndid(): too short regeneration interval; timer disabled for %s.\n",
@@ -1971,7 +1971,7 @@ ok:
 				 * also create a new temporary address.
 				 */
 				read_unlock_bh(&in6_dev->lock);
-				ipv6_create_tempaddr(ifp, NULL);
+				ipv6_create_tempaddr(ifp, NULL, jiffies);
 			} else {
 				read_unlock_bh(&in6_dev->lock);
 			}
@@ -2809,6 +2809,11 @@ static void addrconf_dad_timer(unsigned long data)
 		read_unlock_bh(&idev->lock);

 		addrconf_dad_completed(ifp);
+		/*
+		 * Required to expire properly temporary addresses
+		 * with preferred lifetimes < ADDR_CHECK_FREQUENCY
+		 */
+		addrconf_verify(0);

 		goto out;
 	}
@@ -3121,7 +3126,7 @@ restart:
 						spin_lock(&ifpub->lock);
 						ifpub->regen_count = 0;
 						spin_unlock(&ifpub->lock);
-						ipv6_create_tempaddr(ifpub, ifp);
+						ipv6_create_tempaddr(ifpub, ifp, now);
 						in6_ifa_put(ifpub);
 						in6_ifa_put(ifp);
 						goto restart;
@@ -3638,6 +3643,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_TEMP_PREFERED_LFT] = cnf->temp_prefered_lft;
 	array[DEVCONF_REGEN_MAX_RETRY] = cnf->regen_max_retry;
 	array[DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
+	array[DEVCONF_DESYNC_FACTOR] = cnf->desync_factor;
 #endif
 	array[DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
 	array[DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
@@ -3935,6 +3941,43 @@ static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 }

 #ifdef CONFIG_SYSCTL
+#ifdef CONFIG_IPV6_PRIVACY
+static int addrconf_sysctl_desync(ctl_table *ctl, int write,
+				 struct file *filp, void __user *buffer,
+				 size_t *lenp, loff_t *ppos)
+{
+	int ret;
+
+	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+
+	if (write) {
+		__s32 df;
+		int *valp = ctl->data;
+		struct ipv6_devconf *all, *dflt;
+		struct inet6_dev *idev = ctl->extra1;
+		struct net *net = ctl->extra2;
+		all = net->ipv6.devconf_all;
+		dflt = net->ipv6.devconf_dflt;
+
+		get_random_bytes(&df, sizeof(df));
+		/* The global abs() casts to int. */;
+		df = ((df) < 0 ? -(df) : df) % (*valp)
+
+		/* XXX How about some locking? */
+		if(idev)
+			idev->cnf.desync_factor = df;
+		else if (valp == &dflt->max_desync_factor)
+			dflt->desync_factor = df;
+		else if (valp == &all->max_desync_factor) {
+			all->desync_factor = df;
+			dflt->max_desync_factor = all->max_desync_factor;
+			dflt->desync_factor = df;
+		}
+
+	}
+	return ret;
+}
+#endif

 static
 int addrconf_sysctl_forward(ctl_table *ctl, int write, struct file * filp,
@@ -4124,6 +4167,14 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.max_desync_factor,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
+			.proc_handler	=	addrconf_sysctl_desync,
+		},
+		{
+			.ctl_name	=	CTL_UNNUMBERED,
+			.procname	=	"desync_factor",
+			.data		=	&ipv6_devconf.desync_factor,
+			.maxlen		=	sizeof(int),
+			.mode		=	0444,
 			.proc_handler	=	proc_dointvec,
 		},
 #endif
@@ -4449,6 +4500,11 @@ int __init addrconf_init(void)
 	rtnl_unlock();
 	if (err)
 		goto errlo;
+#ifdef CONFIG_IPV6_PRIVACY
+	get_random_bytes(&ipv6_devconf.desync_factor, sizeof(ipv6_devconf.desync_factor));
+	ipv6_devconf.desync_factor = abs(ipv6_devconf.desync_factor) % ipv6_devconf.max_desync_factor;
+	ipv6_devconf_dflt.desync_factor = ipv6_devconf.desync_factor;
+#endif

 	register_netdevice_notifier(&ipv6_dev_notf);


-- 
Było mi bardzo miło.               Czwarta pospolita klęska, [...]
>Łukasz<                 Już nie katolicka lecz złodziejska.  (c)PP


----------------------------------------------------------------------
Dzwonki na komork�!
Sprawdz >> http://link.interia.pl/f2152 

--------------060808010902090509020100
Content-Type: text/x-vcard; charset=utf-8;
 name="stlman.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="stlman.vcf"

YmVnaW46dmNhcmQNCmZuO3F1b3RlZC1wcmludGFibGU6PUM1PTgxdWthc3ogU3RlbG1hY2gN
Cm47cXVvdGVkLXByaW50YWJsZTpTdGVsbWFjaDs9QzU9ODF1a2Fzeg0KZW1haWw7aW50ZXJu
ZXQ6c3RsbWFuQHBvY3p0YS5mbQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4x
DQplbmQ6dmNhcmQNCg0K
--------------060808010902090509020100--
