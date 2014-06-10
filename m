From: Milos Vyletel <milos.vyletel@gmail.com>
Subject: [patch net-next 3/5] ipv6: consider net.ipv6.conf.all sysctls when making decisions
Date: Tue, 10 Jun 2014 12:19:11 -0400
Message-ID: <1402417153-2551-4-git-send-email-milos.vyletel@gmail.com>
References: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
Cc: Milos Vyletel <milos.vyletel@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	stephen hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florent Fourcot <florent.fourcot@enst-bretagne.fr>,
	Eric Dumazet <edumazet@google.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	linux-usb@vger.kernel.org (open list:USB CDC ETHERNET...),
	linux-kernel@vger.kernel.org (open list)
To: davem@davemloft.net, amwang@redhat.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As it is right now net.ipv6.conf.all.* are mostly ignored and instead
we're only making decisions based on interface specific settings. These
settings are coppied from net.ipv6.conf.default and changing either all
or default settings have no effect.

This patch changes ipv6 code to look more like the one in ipv4 world. It
will introduce new macros (IN6_DEV_{AND,OR,MAX}CONF) that will take
settings in net.ipv6.conf.all into account when making decisions.

Furthermore code is now almost identical to the ipv4 one. ipv6_devconf
no longer defines each entry but instead uses array of IPV6_DEVCONF_MAX
size to store all data to simplify access to these data from macros.

Each sysctl tunable has it's own macro defined and they use one of the
IN6_DEV_{AND,OR,MAX}CONF with the exception of IN6_DEV_FORWARD which
returns device specific setting. They are defined as:

IN6_DEV_ANDCONF
	IN6_DEV_AUTOCONF
	IN6_DEV_MFORWARD
	IN6_DEV_ACCEPT_REDIRECTS
	IN6_DEV_ACCEPT_RA_DEFRTR
	IN6_DEV_ACCEPT_RA_PINFO
	IN6_DEV_ACCEPT_RA_RTR_PREF
	IN6_DEV_NDISC_NOTIFY
	IN6_DEV_SUPPRESS_FRAG_NDISC
	IN6_DEV_FORCE_TLLAO

IN6_DEV_ORCONF
	IN6_DEV_DISABLE_IPV6
	IN6_DEV_PROXY_NDP

IN6_DEV_MAXCONF
	IN6_DEV_HOPLIMIT
	IN6_DEV_MTU
	IN6_DEV_RTR_SOLICITS
	IN6_DEV_RTR_SOLICIT_INTERVAL
	IN6_DEV_RTR_SOLICIT_DELAY
	IN6_DEV_USE_TEMPADDR
	IN6_DEV_ACCEPT_RA
	IN6_DEV_ACCEPT_RA_RT_INFO_MAX_PLEN
	IN6_DEV_ACCEPT_SOURCE_ROUTE
	IN6_DEV_RTR_PROBE_INTERVAL
	IN6_DEV_REGEN_MAX_RETRY
	IN6_DEV_TEMP_VALID_LFT
	IN6_DEV_TEMP_PREFERED_LFT
	IN6_DEV_MAX_DESYNC_FACTOR
	IN6_DEV_MAX_ADDRESSES
	IN6_DEV_ACCEPT_DAD
	IN6_DEV_OPTIMISTIC_DAD
	IN6_DEV_DAD_TRANSMITS

All places which were using accesing these settings directly from
ipv6_devconf stuct were updated to use these new macros.

Signed-off-by: Milos Vyletel <milos.vyletel@gmail.com>
---
 drivers/net/usb/cdc_mbim.c |   2 +-
 drivers/net/vxlan.c        |   2 +-
 include/linux/ipv6.h       |  44 +----
 include/net/addrconf.h     |   4 +-
 include/net/ipv6.h         |  98 +++++++++-
 net/ipv6/addrconf.c        | 466 ++++++++++++++++++++++-----------------------
 net/ipv6/anycast.c         |   4 +-
 net/ipv6/exthdrs.c         |   8 +-
 net/ipv6/ip6_input.c       |   4 +-
 net/ipv6/ip6_output.c      |   9 +-
 net/ipv6/ip6mr.c           |   8 +-
 net/ipv6/ipv6_sockglue.c   |   2 +-
 net/ipv6/mcast.c           |  31 +--
 net/ipv6/ndisc.c           |  41 ++--
 net/ipv6/output_core.c     |   4 +-
 net/ipv6/route.c           |  13 +-
 16 files changed, 379 insertions(+), 361 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index 5ee7a1d..deb21de 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -338,7 +338,7 @@ static void do_neigh_solicit(struct usbnet *dev, u8 *buf, u16 tci)
 	in6_dev = in6_dev_get(netdev);
 	if (!in6_dev)
 		goto out;
-	is_router = !!in6_dev->cnf.forwarding;
+	is_router = !!IN6_DEV_FORWARD(in6_dev);
 	in6_dev_put(in6_dev);
 
 	/* ipv6_stub != NULL if in6_dev_get returned an inet6_dev */
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 4e2caaf..38d4029 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2633,7 +2633,7 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 #if IS_ENABLED(CONFIG_IPV6)
 		if (use_ipv6) {
 			struct inet6_dev *idev = __in6_dev_get(lowerdev);
-			if (idev && idev->cnf.disable_ipv6) {
+			if (idev && IN6_DEV_DISABLE_IPV6(idev)) {
 				pr_info("IPv6 is disabled via sysctl\n");
 				return -EPERM;
 			}
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 2faef33..fe8d38d 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -9,48 +9,8 @@
  * This structure contains configuration options per IPv6 link.
  */
 struct ipv6_devconf {
-	__s32		forwarding;
-	__s32		hop_limit;
-	__s32		mtu6;
-	__s32		accept_ra;
-	__s32		accept_redirects;
-	__s32		autoconf;
-	__s32		dad_transmits;
-	__s32		rtr_solicits;
-	__s32		rtr_solicit_interval;
-	__s32		rtr_solicit_delay;
-	__s32		force_mld_version;
-	__s32		mldv1_unsolicited_report_interval;
-	__s32		mldv2_unsolicited_report_interval;
-	__s32		use_tempaddr;
-	__s32		temp_valid_lft;
-	__s32		temp_prefered_lft;
-	__s32		regen_max_retry;
-	__s32		max_desync_factor;
-	__s32		max_addresses;
-	__s32		accept_ra_defrtr;
-	__s32		accept_ra_pinfo;
-#ifdef CONFIG_IPV6_ROUTER_PREF
-	__s32		accept_ra_rtr_pref;
-	__s32		rtr_probe_interval;
-#ifdef CONFIG_IPV6_ROUTE_INFO
-	__s32		accept_ra_rt_info_max_plen;
-#endif
-#endif
-	__s32		proxy_ndp;
-	__s32		accept_source_route;
-#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-	__s32		optimistic_dad;
-#endif
-#ifdef CONFIG_IPV6_MROUTE
-	__s32		mc_forwarding;
-#endif
-	__s32		disable_ipv6;
-	__s32		accept_dad;
-	__s32		force_tllao;
-	__s32           ndisc_notify;
-	__s32		suppress_frag_ndisc;
-	void		*sysctl;
+	void	*sysctl;
+	__s32	data[IPV6_DEVCONF_MAX];
 };
 
 struct ipv6_params {
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index f679877..7eb463e 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -8,8 +8,8 @@
 
 #define TEMP_VALID_LIFETIME		(7*86400)
 #define TEMP_PREFERRED_LIFETIME		(86400)
-#define REGEN_MAX_RETRY			(3)
-#define MAX_DESYNC_FACTOR		(600)
+#define _REGEN_MAX_RETRY		(3)
+#define _MAX_DESYNC_FACTOR		(600)
 
 #define ADDR_CHECK_FREQUENCY		(120*HZ)
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 574337f..1ee39a5 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -288,13 +288,107 @@ struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 
 bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb);
 
+#define IPV6_DEVCONF(cnf, attr) ((cnf).data[IPV6_DEVCONF_ ## attr])
+#define IPV6_DEVCONF_ALL(net, attr) \
+	IPV6_DEVCONF((*(net)->ipv6.devconf_all), attr)
+#define IPV6_DEVCONF_DFLT(net, attr) \
+	IPV6_DEVCONF((*(net)->ipv6.devconf_dflt), attr)
+
+static inline int ipv6_devconf_get(struct inet6_dev *idev, int index)
+{
+	return idev->cnf.data[index];
+}
+
+static inline void ipv6_devconf_set(struct inet6_dev *idev, int index,
+				    int val)
+{
+	idev->cnf.data[index] = val;
+}
+
+#define IN6_DEV_CONF_GET(idev, attr) \
+	ipv6_devconf_get((idev), IPV6_DEVCONF_ ## attr)
+#define IN6_DEV_CONF_SET(idev, attr, val) \
+	ipv6_devconf_set((idev), IPV6_DEVCONF_ ## attr, (val))
+
+#define IN6_DEV_ANDCONF(idev, attr) \
+	(IPV6_DEVCONF_ALL(dev_net(idev->dev), attr) && \
+	 IN6_DEV_CONF_GET((idev), attr))
+#define IN6_DEV_ORCONF(idev, attr) \
+	(IPV6_DEVCONF_ALL(dev_net(idev->dev), attr) || \
+	 IN6_DEV_CONF_GET((idev), attr))
+#define IN6_DEV_MAXCONF(idev, attr) \
+	(max(IPV6_DEVCONF_ALL(dev_net(idev->dev), attr), \
+	     IN6_DEV_CONF_GET((idev), attr)))
+
+#define IN6_DEV_DISABLE_IPV6(idev)\
+			unlikely(IN6_DEV_ORCONF((idev), DISABLE_IPV6))
+#define IN6_DEV_AUTOCONF(idev)	IN6_DEV_ANDCONF((idev), AUTOCONF)
+
+#define IN6_DEV_FORWARD(idev)		IN6_DEV_CONF_GET((idev), FORWARDING)
+#define IN6_DEV_MFORWARD(idev)	IN6_DEV_ANDCONF((idev), MC_FORWARDING)
+#define IN6_DEV_MFORWARD_INC(idev) \
+	IN6_DEV_CONF_SET((idev), MC_FORWARDING, \
+		IN6_DEV_CONF_GET((idev), MC_FORWARDING) + 1)
+#define IN6_DEV_MFORWARD_DEC(idev) \
+	IN6_DEV_CONF_SET((idev), MC_FORWARDING, \
+		IN6_DEV_CONF_GET((idev), MC_FORWARDING) - 1)
+
+#define IN6_DEV_HOPLIMIT(idev)	IN6_DEV_MAXCONF((idev), HOPLIMIT)
+#define IN6_DEV_MTU(idev)		IN6_DEV_MAXCONF((idev), MTU6)
+
+#define IN6_DEV_RTR_SOLICITS(idev)	IN6_DEV_MAXCONF((idev), RTR_SOLICITS)
+#define IN6_DEV_RTR_SOLICIT_INTERVAL(idev) \
+			IN6_DEV_MAXCONF((idev), RTR_SOLICIT_INTERVAL)
+#define IN6_DEV_RTR_SOLICIT_DELAY(idev) \
+			IN6_DEV_MAXCONF((idev), RTR_SOLICIT_DELAY)
+#define IN6_DEV_USE_TEMPADDR(idev)	IN6_DEV_MAXCONF((idev), USE_TEMPADDR)
+
+#define IN6_DEV_ACCEPT_RA(idev)	IN6_DEV_MAXCONF((idev), ACCEPT_RA)
+#define IN6_DEV_ACCEPT_REDIRECTS(idev) \
+			IN6_DEV_ANDCONF((idev), ACCEPT_REDIRECTS)
+#define IN6_DEV_ACCEPT_RA_DEFRTR(idev) \
+			IN6_DEV_ANDCONF((idev), ACCEPT_RA_DEFRTR)
+#define IN6_DEV_ACCEPT_RA_PINFO(idev) \
+			IN6_DEV_ANDCONF((idev), ACCEPT_RA_PINFO)
+#define IN6_DEV_ACCEPT_RA_RTR_PREF(idev) \
+			IN6_DEV_ANDCONF((idev), ACCEPT_RA_RTR_PREF)
+#define IN6_DEV_ACCEPT_RA_RT_INFO_MAX_PLEN(idev) \
+			IN6_DEV_MAXCONF((idev), ACCEPT_RA_RT_INFO_MAX_PLEN)
+
+#define IN6_DEV_ACCEPT_SOURCE_ROUTE(idev) \
+			IN6_DEV_MAXCONF((idev), ACCEPT_SOURCE_ROUTE)
+#define IN6_DEV_PROXY_NDP(idev)	IN6_DEV_ORCONF((idev), PROXY_NDP)
+#define IN6_DEV_FORCE_MLD_VERSION(idev) \
+			IN6_DEV_MAXCONF((idev), FORCE_MLD_VERSION)
+
+#define IN6_DEV_NDISC_NOTIFY(idev)	IN6_DEV_ANDCONF((idev), NDISC_NOTIFY)
+#define IN6_DEV_SUPPRESS_FRAG_NDISC(idev) \
+			IN6_DEV_ANDCONF((idev), SUPPRESS_FRAG_NDISC)
+#define IN6_DEV_FORCE_TLLAO(idev)	 IN6_DEV_ANDCONF((idev), FORCE_TLLAO)
+#define IN6_DEV_RTR_PROBE_INTERVAL(idev) \
+			IN6_DEV_MAXCONF((idev), RTR_PROBE_INTERVAL)
+#define IN6_DEV_REGEN_MAX_RETRY(idev) \
+			IN6_DEV_MAXCONF((idev), REGEN_MAX_RETRY)
+#define IN6_DEV_TEMP_VALID_LFT(idev) \
+			IN6_DEV_MAXCONF((idev), TEMP_VALID_LFT)
+#define IN6_DEV_TEMP_PREFERED_LFT(idev) \
+			IN6_DEV_MAXCONF((idev), TEMP_PREFERED_LFT)
+#define IN6_DEV_MAX_DESYNC_FACTOR(idev) \
+			IN6_DEV_MAXCONF((idev), MAX_DESYNC_FACTOR)
+#define IN6_DEV_MAX_ADDRESSES(idev)	IN6_DEV_MAXCONF((idev), MAX_ADDRESSES)
+
+#define IN6_DEV_ACCEPT_DAD(idev)	IN6_DEV_MAXCONF((idev), ACCEPT_DAD)
+#define IN6_DEV_OPTIMISTIC_DAD(idev)	IN6_DEV_ANDCONF((idev), OPTIMISTIC_DAD)
+#define IN6_DEV_DAD_TRANSMITS(idev)	IN6_DEV_MAXCONF((idev), DAD_TRANSMITS)
+
 static inline bool ipv6_accept_ra(struct inet6_dev *idev)
 {
 	/* If forwarding is enabled, RA are not accepted unless the special
 	 * hybrid mode (accept_ra=2) is enabled.
 	 */
-	return idev->cnf.forwarding ? idev->cnf.accept_ra == 2 :
-	    idev->cnf.accept_ra;
+	return IN6_DEV_FORWARD(idev) ?
+		IN6_DEV_ACCEPT_RA(idev) == 2 :
+		IN6_DEV_ACCEPT_RA(idev);
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 24fbb38..5b1b578 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -166,75 +166,81 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 			       struct net_device *dev);
 
 static struct ipv6_devconf ipv6_devconf __read_mostly = {
-	.forwarding		= 0,
-	.hop_limit		= IPV6_DEFAULT_HOPLIMIT,
-	.mtu6			= IPV6_MIN_MTU,
-	.accept_ra		= 1,
-	.accept_redirects	= 1,
-	.autoconf		= 1,
-	.force_mld_version	= 0,
-	.mldv1_unsolicited_report_interval = 10 * HZ,
-	.mldv2_unsolicited_report_interval = HZ,
-	.dad_transmits		= 1,
-	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
-	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
-	.rtr_solicit_delay	= MAX_RTR_SOLICITATION_DELAY,
-	.use_tempaddr 		= 0,
-	.temp_valid_lft		= TEMP_VALID_LIFETIME,
-	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
-	.regen_max_retry	= REGEN_MAX_RETRY,
-	.max_desync_factor	= MAX_DESYNC_FACTOR,
-	.max_addresses		= IPV6_MAX_ADDRESSES,
-	.accept_ra_defrtr	= 1,
-	.accept_ra_pinfo	= 1,
+	.data = {
+		[IPV6_DEVCONF_FORWARDING] = 0,
+		[IPV6_DEVCONF_HOPLIMIT] = IPV6_DEFAULT_HOPLIMIT,
+		[IPV6_DEVCONF_MTU6] = IPV6_MIN_MTU,
+		[IPV6_DEVCONF_ACCEPT_RA] = 1,
+		[IPV6_DEVCONF_ACCEPT_REDIRECTS] = 1,
+		[IPV6_DEVCONF_AUTOCONF] = 1,
+		[IPV6_DEVCONF_FORCE_MLD_VERSION] = 0,
+		[IPV6_DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL] = 10 * HZ,
+		[IPV6_DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL] = HZ,
+		[IPV6_DEVCONF_DAD_TRANSMITS] = 1,
+		[IPV6_DEVCONF_RTR_SOLICITS] = MAX_RTR_SOLICITATIONS,
+		[IPV6_DEVCONF_RTR_SOLICIT_INTERVAL] = RTR_SOLICITATION_INTERVAL,
+		[IPV6_DEVCONF_RTR_SOLICIT_DELAY] = MAX_RTR_SOLICITATION_DELAY,
+		[IPV6_DEVCONF_USE_TEMPADDR] = 0,
+		[IPV6_DEVCONF_TEMP_VALID_LFT] = TEMP_VALID_LIFETIME,
+		[IPV6_DEVCONF_TEMP_PREFERED_LFT] = TEMP_PREFERRED_LIFETIME,
+		[IPV6_DEVCONF_REGEN_MAX_RETRY] = _REGEN_MAX_RETRY,
+		[IPV6_DEVCONF_MAX_DESYNC_FACTOR] = _MAX_DESYNC_FACTOR,
+		[IPV6_DEVCONF_MAX_ADDRESSES] = IPV6_MAX_ADDRESSES,
+		[IPV6_DEVCONF_ACCEPT_RA_DEFRTR] = 1,
+		[IPV6_DEVCONF_ACCEPT_RA_PINFO] = 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
-	.accept_ra_rtr_pref	= 1,
-	.rtr_probe_interval	= 60 * HZ,
+		[IPV6_DEVCONF_ACCEPT_RA_RTR_PREF] = 1,
+		[IPV6_DEVCONF_RTR_PROBE_INTERVAL] = 60 * HZ,
 #ifdef CONFIG_IPV6_ROUTE_INFO
-	.accept_ra_rt_info_max_plen = 0,
+		[IPV6_DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN] = 0,
 #endif
 #endif
-	.proxy_ndp		= 0,
-	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
-	.disable_ipv6		= 0,
-	.accept_dad		= 1,
-	.suppress_frag_ndisc	= 1,
+		[IPV6_DEVCONF_PROXY_NDP] = 0,
+		/* we do not accept RH0 by default. */
+		[IPV6_DEVCONF_ACCEPT_SOURCE_ROUTE] = 0,
+		[IPV6_DEVCONF_DISABLE_IPV6] = 0,
+		[IPV6_DEVCONF_ACCEPT_DAD] = 1,
+		[IPV6_DEVCONF_SUPPRESS_FRAG_NDISC] = 1,
+	},
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
-	.forwarding		= 0,
-	.hop_limit		= IPV6_DEFAULT_HOPLIMIT,
-	.mtu6			= IPV6_MIN_MTU,
-	.accept_ra		= 1,
-	.accept_redirects	= 1,
-	.autoconf		= 1,
-	.force_mld_version	= 0,
-	.mldv1_unsolicited_report_interval = 10 * HZ,
-	.mldv2_unsolicited_report_interval = HZ,
-	.dad_transmits		= 1,
-	.rtr_solicits		= MAX_RTR_SOLICITATIONS,
-	.rtr_solicit_interval	= RTR_SOLICITATION_INTERVAL,
-	.rtr_solicit_delay	= MAX_RTR_SOLICITATION_DELAY,
-	.use_tempaddr		= 0,
-	.temp_valid_lft		= TEMP_VALID_LIFETIME,
-	.temp_prefered_lft	= TEMP_PREFERRED_LIFETIME,
-	.regen_max_retry	= REGEN_MAX_RETRY,
-	.max_desync_factor	= MAX_DESYNC_FACTOR,
-	.max_addresses		= IPV6_MAX_ADDRESSES,
-	.accept_ra_defrtr	= 1,
-	.accept_ra_pinfo	= 1,
+	.data = {
+		[IPV6_DEVCONF_FORWARDING] = 0,
+		[IPV6_DEVCONF_HOPLIMIT] = IPV6_DEFAULT_HOPLIMIT,
+		[IPV6_DEVCONF_MTU6] = IPV6_MIN_MTU,
+		[IPV6_DEVCONF_ACCEPT_RA] = 1,
+		[IPV6_DEVCONF_ACCEPT_REDIRECTS] = 1,
+		[IPV6_DEVCONF_AUTOCONF] = 1,
+		[IPV6_DEVCONF_FORCE_MLD_VERSION] = 0,
+		[IPV6_DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL] = 10 * HZ,
+		[IPV6_DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL] = HZ,
+		[IPV6_DEVCONF_DAD_TRANSMITS] = 1,
+		[IPV6_DEVCONF_RTR_SOLICITS] = MAX_RTR_SOLICITATIONS,
+		[IPV6_DEVCONF_RTR_SOLICIT_INTERVAL] = RTR_SOLICITATION_INTERVAL,
+		[IPV6_DEVCONF_RTR_SOLICIT_DELAY] = MAX_RTR_SOLICITATION_DELAY,
+		[IPV6_DEVCONF_USE_TEMPADDR] = 0,
+		[IPV6_DEVCONF_TEMP_VALID_LFT] = TEMP_VALID_LIFETIME,
+		[IPV6_DEVCONF_TEMP_PREFERED_LFT] = TEMP_PREFERRED_LIFETIME,
+		[IPV6_DEVCONF_REGEN_MAX_RETRY] = _REGEN_MAX_RETRY,
+		[IPV6_DEVCONF_MAX_DESYNC_FACTOR] = _MAX_DESYNC_FACTOR,
+		[IPV6_DEVCONF_MAX_ADDRESSES] = IPV6_MAX_ADDRESSES,
+		[IPV6_DEVCONF_ACCEPT_RA_DEFRTR] = 1,
+		[IPV6_DEVCONF_ACCEPT_RA_PINFO] = 1,
 #ifdef CONFIG_IPV6_ROUTER_PREF
-	.accept_ra_rtr_pref	= 1,
-	.rtr_probe_interval	= 60 * HZ,
+		[IPV6_DEVCONF_ACCEPT_RA_RTR_PREF] = 1,
+		[IPV6_DEVCONF_RTR_PROBE_INTERVAL] = 60 * HZ,
 #ifdef CONFIG_IPV6_ROUTE_INFO
-	.accept_ra_rt_info_max_plen = 0,
+		[IPV6_DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN] = 0,
 #endif
 #endif
-	.proxy_ndp		= 0,
-	.accept_source_route	= 0,	/* we do not accept RH0 by default. */
-	.disable_ipv6		= 0,
-	.accept_dad		= 1,
-	.suppress_frag_ndisc	= 1,
+		[IPV6_DEVCONF_PROXY_NDP] = 0,
+		/* we do not accept RH0 by default. */
+		[IPV6_DEVCONF_ACCEPT_SOURCE_ROUTE] = 0,
+		[IPV6_DEVCONF_DISABLE_IPV6] = 0,
+		[IPV6_DEVCONF_ACCEPT_DAD] = 1,
+		[IPV6_DEVCONF_SUPPRESS_FRAG_NDISC] = 1,
+	},
 };
 
 /* Check if a valid qdisc is available */
@@ -325,14 +331,14 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	setup_timer(&ndev->rs_timer, addrconf_rs_timer,
 		    (unsigned long)ndev);
 	memcpy(&ndev->cnf, dev_net(dev)->ipv6.devconf_dflt, sizeof(ndev->cnf));
-	ndev->cnf.mtu6 = dev->mtu;
+	IN6_DEV_CONF_SET(ndev, MTU6, dev->mtu);
 	ndev->cnf.sysctl = NULL;
 	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
 	if (ndev->nd_parms == NULL) {
 		kfree(ndev);
 		return NULL;
 	}
-	if (ndev->cnf.forwarding)
+	if (IN6_DEV_FORWARD(ndev))
 		dev_disable_lro(dev);
 	/* We refer to the device */
 	dev_hold(dev);
@@ -363,12 +369,12 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	in6_dev_hold(ndev);
 
 	if (dev->flags & (IFF_NOARP | IFF_LOOPBACK))
-		ndev->cnf.accept_dad = -1;
+		IN6_DEV_CONF_SET(ndev, ACCEPT_DAD, -1);
 
 #if IS_ENABLED(CONFIG_IPV6_SIT)
 	if (dev->type == ARPHRD_SIT && (dev->priv_flags & IFF_ISATAP)) {
 		pr_info("%s: Disabled Multicast RS\n", dev->name);
-		ndev->cnf.rtr_solicits = 0;
+		IN6_DEV_CONF_SET(ndev, RTR_SOLICITS, 0);
 	}
 #endif
 
@@ -379,7 +385,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	    dev->type == ARPHRD_TUNNEL6 ||
 	    dev->type == ARPHRD_SIT ||
 	    dev->type == ARPHRD_NONE) {
-		ndev->cnf.use_tempaddr = -1;
+		IN6_DEV_CONF_SET(ndev, USE_TEMPADDR, -1);
 	} else {
 		in6_dev_hold(ndev);
 		ipv6_regen_rndid((unsigned long) ndev);
@@ -403,7 +409,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	ipv6_dev_mc_inc(dev, &in6addr_linklocal_allnodes);
 
 	/* Join all-router multicast group if forwarding is set */
-	if (ndev->cnf.forwarding && (dev->flags & IFF_MULTICAST))
+	if (IN6_DEV_FORWARD(ndev) && (dev->flags & IFF_MULTICAST))
 		ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
 
 	return ndev;
@@ -466,16 +472,18 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
 
 	/* type -1 is used for ALL */
 	if ((type == -1 || type == NETCONFA_FORWARDING) &&
-	    nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0)
+	    nla_put_s32(skb, NETCONFA_FORWARDING,
+			IPV6_DEVCONF(*devconf, FORWARDING)) < 0)
 		goto nla_put_failure;
 #ifdef CONFIG_IPV6_MROUTE
 	if ((type == -1 || type == NETCONFA_MC_FORWARDING) &&
 	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
-			devconf->mc_forwarding) < 0)
+			IPV6_DEVCONF(*devconf, MC_FORWARDING)) < 0)
 		goto nla_put_failure;
 #endif
 	if ((type == -1 || type == NETCONFA_PROXY_NEIGH) &&
-	    nla_put_s32(skb, NETCONFA_PROXY_NEIGH, devconf->proxy_ndp) < 0)
+	    nla_put_s32(skb, NETCONFA_PROXY_NEIGH,
+			IPV6_DEVCONF(*devconf, PROXY_NDP)) < 0)
 		goto nla_put_failure;
 
 	return nlmsg_end(skb, nlh);
@@ -656,10 +664,10 @@ static void dev_forward_change(struct inet6_dev *idev)
 	if (!idev)
 		return;
 	dev = idev->dev;
-	if (idev->cnf.forwarding)
+	if (IN6_DEV_FORWARD(idev))
 		dev_disable_lro(dev);
 	if (dev->flags & IFF_MULTICAST) {
-		if (idev->cnf.forwarding) {
+		if (IN6_DEV_FORWARD(idev)) {
 			ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
 			ipv6_dev_mc_inc(dev, &in6addr_interfacelocal_allrouters);
 			ipv6_dev_mc_inc(dev, &in6addr_sitelocal_allrouters);
@@ -673,7 +681,7 @@ static void dev_forward_change(struct inet6_dev *idev)
 	list_for_each_entry(ifa, &idev->addr_list, if_list) {
 		if (ifa->flags&IFA_F_TENTATIVE)
 			continue;
-		if (idev->cnf.forwarding)
+		if (IN6_DEV_FORWARD(idev))
 			addrconf_join_anycast(ifa);
 		else
 			addrconf_leave_anycast(ifa);
@@ -691,8 +699,9 @@ static void addrconf_forward_change(struct net *net, __s32 newf)
 	for_each_netdev(net, dev) {
 		idev = __in6_dev_get(dev);
 		if (idev) {
-			int changed = (!idev->cnf.forwarding) ^ (!newf);
-			idev->cnf.forwarding = newf;
+			int changed = (!IN6_DEV_FORWARD(idev)) ^ (!newf);
+
+			IN6_DEV_CONF_SET(idev, FORWARDING, newf);
 			if (changed)
 				dev_forward_change(idev);
 		}
@@ -711,7 +720,7 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 	old = *p;
 	*p = newf;
 
-	if (p == &net->ipv6.devconf_dflt->forwarding) {
+	if (p == &IPV6_DEVCONF_DFLT(net, FORWARDING)) {
 		if ((!newf) ^ (!old))
 			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
 						     NETCONFA_IFINDEX_DEFAULT,
@@ -720,15 +729,19 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int newf)
 		return 0;
 	}
 
-	if (p == &net->ipv6.devconf_all->forwarding) {
-		net->ipv6.devconf_dflt->forwarding = newf;
+	if (p == &IPV6_DEVCONF_ALL(net, FORWARDING)) {
+		IPV6_DEVCONF_DFLT(net, FORWARDING) = newf;
 		addrconf_forward_change(net, newf);
 		if ((!newf) ^ (!old))
 			inet6_netconf_notify_devconf(net, NETCONFA_FORWARDING,
 						     NETCONFA_IFINDEX_ALL,
 						     net->ipv6.devconf_all);
-	} else if ((!newf) ^ (!old))
-		dev_forward_change((struct inet6_dev *)table->extra1);
+	} else if ((!newf) ^ (!old)) {
+		struct ipv6_devconf *cnf = table->extra1;
+		struct inet6_dev *idev =
+			container_of(cnf, struct inet6_dev, cnf);
+		dev_forward_change(idev);
+	}
 	rtnl_unlock();
 
 	if (newf)
@@ -811,7 +824,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 		goto out2;
 	}
 
-	if (idev->cnf.disable_ipv6) {
+	if (IN6_DEV_DISABLE_IPV6(idev)) {
 		err = -EACCES;
 		goto out2;
 	}
@@ -1059,7 +1072,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 	}
 retry:
 	in6_dev_hold(idev);
-	if (idev->cnf.use_tempaddr <= 0) {
+	if (IN6_DEV_USE_TEMPADDR(idev) <= 0) {
 		write_unlock_bh(&idev->lock);
 		pr_info("%s: use_tempaddr is disabled\n", __func__);
 		in6_dev_put(idev);
@@ -1067,8 +1080,8 @@ retry:
 		goto out;
 	}
 	spin_lock_bh(&ifp->lock);
-	if (ifp->regen_count++ >= idev->cnf.regen_max_retry) {
-		idev->cnf.use_tempaddr = -1;	/*XXX*/
+	if (ifp->regen_count++ >= IN6_DEV_REGEN_MAX_RETRY(idev)) {
+		IN6_DEV_CONF_SET(idev, USE_TEMPADDR, -1);	/*XXX*/
 		spin_unlock_bh(&ifp->lock);
 		write_unlock_bh(&idev->lock);
 		pr_warn("%s: regeneration time exceeded - disabled temporary address support\n",
@@ -1084,18 +1097,18 @@ retry:
 	age = (now - ifp->tstamp) / HZ;
 	tmp_valid_lft = min_t(__u32,
 			      ifp->valid_lft,
-			      idev->cnf.temp_valid_lft + age);
+			      IN6_DEV_TEMP_VALID_LFT(idev) + age);
 	tmp_prefered_lft = min_t(__u32,
 				 ifp->prefered_lft,
-				 idev->cnf.temp_prefered_lft + age -
-				 idev->cnf.max_desync_factor);
+				 IN6_DEV_TEMP_PREFERED_LFT(idev) + age -
+				 IN6_DEV_MAX_DESYNC_FACTOR(idev));
 	tmp_plen = ifp->prefix_len;
 	tmp_tstamp = ifp->tstamp;
 	spin_unlock_bh(&ifp->lock);
 
-	regen_advance = idev->cnf.regen_max_retry *
-	                idev->cnf.dad_transmits *
-	                NEIGH_VAR(idev->nd_parms, RETRANS_TIME) / HZ;
+	regen_advance = IN6_DEV_REGEN_MAX_RETRY(idev) *
+			IN6_DEV_DAD_TRANSMITS(idev) *
+			NEIGH_VAR(idev->nd_parms, RETRANS_TIME) / HZ;
 	write_unlock_bh(&idev->lock);
 
 	/* A temporary address is created only if this calculated Preferred
@@ -1277,7 +1290,7 @@ static int ipv6_get_saddr_eval(struct net *net,
 		 */
 		int preftmp = dst->prefs & (IPV6_PREFER_SRC_PUBLIC|IPV6_PREFER_SRC_TMP) ?
 				!!(dst->prefs & IPV6_PREFER_SRC_TMP) :
-				score->ifa->idev->cnf.use_tempaddr >= 2;
+				IN6_DEV_USE_TEMPADDR(score->ifa->idev) >= 2;
 		ret = (!(score->ifa->flags & IFA_F_TEMPORARY)) ^ preftmp;
 		break;
 	    }
@@ -1655,7 +1668,8 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 	net_info_ratelimited("%s: IPv6 duplicate address %pI6c detected!\n",
 			     ifp->idev->dev->name, &ifp->addr);
 
-	if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
+	if (IN6_DEV_ACCEPT_DAD(idev) > 1 &&
+	    !IN6_DEV_DISABLE_IPV6(idev)) {
 		struct in6_addr addr;
 
 		addr.s6_addr32[0] = htonl(0xfe800000);
@@ -1664,7 +1678,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 		if (!ipv6_generate_eui64(addr.s6_addr + 8, idev->dev) &&
 		    ipv6_addr_equal(&ifp->addr, &addr)) {
 			/* DAD failed for link-local based on MAC address */
-			idev->cnf.disable_ipv6 = 1;
+			IN6_DEV_CONF_SET(idev, DISABLE_IPV6, 1);
 
 			pr_info("%s: IPv6 being disabled!\n",
 				ifp->idev->dev->name);
@@ -1935,10 +1949,11 @@ static void ipv6_regen_rndid(unsigned long data)
 	__ipv6_regen_rndid(idev);
 
 	expires = jiffies +
-		idev->cnf.temp_prefered_lft * HZ -
-		idev->cnf.regen_max_retry * idev->cnf.dad_transmits *
+		IN6_DEV_TEMP_PREFERED_LFT(idev) * HZ -
+		IN6_DEV_REGEN_MAX_RETRY(idev) *
+		IN6_DEV_DAD_TRANSMITS(idev) *
 		NEIGH_VAR(idev->nd_parms, RETRANS_TIME) -
-		idev->cnf.max_desync_factor * HZ;
+		IN6_DEV_MAX_DESYNC_FACTOR(idev) * HZ;
 	if (time_before(expires, jiffies)) {
 		pr_warn("%s: too short regeneration interval; timer disabled for %s\n",
 			__func__, idev->dev->name);
@@ -2055,7 +2070,7 @@ static struct inet6_dev *addrconf_add_dev(struct net_device *dev)
 	if (!idev)
 		return ERR_PTR(-ENOBUFS);
 
-	if (idev->cnf.disable_ipv6)
+	if (IN6_DEV_DISABLE_IPV6(idev))
 		return ERR_PTR(-EACCES);
 
 	/* Add default multicast route */
@@ -2090,12 +2105,13 @@ static void manage_tempaddrs(struct inet6_dev *idev,
 		 * (TEMP_PREFERRED_LIFETIME - DESYNC_FACTOR), respectively.
 		 */
 		age = (now - ift->cstamp) / HZ;
-		max_valid = idev->cnf.temp_valid_lft - age;
+		max_valid = IN6_DEV_TEMP_VALID_LFT(idev) - age;
 		if (max_valid < 0)
 			max_valid = 0;
 
-		max_prefered = idev->cnf.temp_prefered_lft -
-			       idev->cnf.max_desync_factor - age;
+		max_prefered = IN6_DEV_TEMP_PREFERED_LFT(idev) -
+			       IN6_DEV_MAX_DESYNC_FACTOR(idev) -
+			       age;
 		if (max_prefered < 0)
 			max_prefered = 0;
 
@@ -2119,7 +2135,7 @@ static void manage_tempaddrs(struct inet6_dev *idev,
 	}
 
 	if ((create || list_empty(&idev->tempaddr_list)) &&
-	    idev->cnf.use_tempaddr > 0) {
+	    IN6_DEV_USE_TEMPADDR(idev) > 0) {
 		/* When a new public address is created as described
 		 * in [ADDRCONF], also create a new temporary address.
 		 * Also create a temporary address if it's enabled but
@@ -2229,7 +2245,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 
 	/* Try to figure out our local address for this prefix */
 
-	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
+	if (pinfo->autoconf && IN6_DEV_AUTOCONF(in6_dev)) {
 		struct inet6_ifaddr *ifp;
 		struct in6_addr addr;
 		int create = 0, update_lft = 0;
@@ -2261,12 +2277,12 @@ ok:
 		ifp = ipv6_get_ifaddr(net, &addr, dev, 1);
 
 		if (ifp == NULL && valid_lft) {
-			int max_addresses = in6_dev->cnf.max_addresses;
+			int max_addresses = IN6_DEV_MAX_ADDRESSES(in6_dev);
 			u32 addr_flags = 0;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-			if (in6_dev->cnf.optimistic_dad &&
-			    !net->ipv6.devconf_all->forwarding && sllao)
+			if (IN6_DEV_OPTIMISTIC_DAD(in6_dev) &&
+			    !IPV6_DEVCONF_ALL(net, FORWARDING) && sllao)
 				addr_flags = IFA_F_OPTIMISTIC;
 #endif
 
@@ -2713,8 +2729,8 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr
 	u32 addr_flags = IFA_F_PERMANENT;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-	if (idev->cnf.optimistic_dad &&
-	    !dev_net(idev->dev)->ipv6.devconf_all->forwarding)
+	if (IN6_DEV_OPTIMISTIC_DAD(idev) &&
+	    !IPV6_DEVCONF_ALL(dev_net(idev->dev), FORWARDING))
 		addr_flags |= IFA_F_OPTIMISTIC;
 #endif
 
@@ -2898,10 +2914,10 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			 * when the interface up, the changed MTU must be
 			 * reflected in the idev as well as routers.
 			 */
-			if (idev->cnf.mtu6 != dev->mtu &&
+			if (IN6_DEV_MTU(idev) != dev->mtu &&
 			    dev->mtu >= IPV6_MIN_MTU) {
 				rt6_mtu_change(dev, dev->mtu);
-				idev->cnf.mtu6 = dev->mtu;
+				IN6_DEV_CONF_SET(idev, MTU6, dev->mtu);
 			}
 			idev->tstamp = jiffies;
 			inet6_ifinfo_notify(RTM_NEWLINK, idev);
@@ -2918,7 +2934,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 	case NETDEV_CHANGEMTU:
 		if (idev && dev->mtu >= IPV6_MIN_MTU) {
 			rt6_mtu_change(dev, dev->mtu);
-			idev->cnf.mtu6 = dev->mtu;
+			IN6_DEV_CONF_SET(idev, MTU6, dev->mtu);
 			break;
 		}
 
@@ -3116,7 +3132,7 @@ static void addrconf_rs_timer(unsigned long data)
 	if (idev->if_flags & IF_RA_RCVD)
 		goto out;
 
-	if (idev->rs_probes++ < idev->cnf.rtr_solicits) {
+	if (idev->rs_probes++ < IN6_DEV_RTR_SOLICITS(idev)) {
 		write_unlock(&idev->lock);
 		if (!ipv6_get_lladdr(dev, &lladdr, IFA_F_TENTATIVE))
 			ndisc_send_rs(dev, &lladdr,
@@ -3127,9 +3143,9 @@ static void addrconf_rs_timer(unsigned long data)
 		write_lock(&idev->lock);
 		/* The wait after the last probe can be shorter */
 		addrconf_mod_rs_timer(idev, (idev->rs_probes ==
-					     idev->cnf.rtr_solicits) ?
-				      idev->cnf.rtr_solicit_delay :
-				      idev->cnf.rtr_solicit_interval);
+					     IN6_DEV_RTR_SOLICITS(idev)) ?
+				      IN6_DEV_RTR_SOLICIT_DELAY(idev) :
+				      IN6_DEV_RTR_SOLICIT_INTERVAL(idev));
 	} else {
 		/*
 		 * Note: we do not support deprecated "all on-link"
@@ -3155,9 +3171,10 @@ static void addrconf_dad_kick(struct inet6_ifaddr *ifp)
 	if (ifp->flags & IFA_F_OPTIMISTIC)
 		rand_num = 0;
 	else
-		rand_num = prandom_u32() % (idev->cnf.rtr_solicit_delay ? : 1);
+		rand_num = prandom_u32() %
+			   (IN6_DEV_RTR_SOLICIT_DELAY(idev) ? : 1);
 
-	ifp->dad_probes = idev->cnf.dad_transmits;
+	ifp->dad_probes = IN6_DEV_DAD_TRANSMITS(idev);
 	addrconf_mod_dad_work(ifp, rand_num);
 }
 
@@ -3176,7 +3193,7 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 		goto out;
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
-	    idev->cnf.accept_dad < 1 ||
+	    IN6_DEV_ACCEPT_DAD(idev) < 1 ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC|IFA_F_DADFAILED);
@@ -3346,7 +3363,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 	send_mld = ifp->scope == IFA_LINK && ipv6_lonely_lladdr(ifp);
 	send_rs = send_mld &&
 		  ipv6_accept_ra(ifp->idev) &&
-		  ifp->idev->cnf.rtr_solicits > 0 &&
+		  IN6_DEV_RTR_SOLICITS(ifp->idev) > 0 &&
 		  (dev->flags&IFF_LOOPBACK) == 0;
 	read_unlock_bh(&ifp->idev->lock);
 
@@ -3371,7 +3388,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 		ifp->idev->rs_probes = 1;
 		ifp->idev->if_flags |= IF_RS_SENT;
 		addrconf_mod_rs_timer(ifp->idev,
-				      ifp->idev->cnf.rtr_solicit_interval);
+				      IN6_DEV_RTR_SOLICIT_INTERVAL(ifp->idev));
 		spin_unlock(&ifp->lock);
 		write_unlock_bh(&ifp->idev->lock);
 	}
@@ -3635,8 +3652,9 @@ restart:
 				}
 			} else if ((ifp->flags&IFA_F_TEMPORARY) &&
 				   !(ifp->flags&IFA_F_TENTATIVE)) {
-				unsigned long regen_advance = ifp->idev->cnf.regen_max_retry *
-					ifp->idev->cnf.dad_transmits *
+				unsigned long regen_advance =
+					IN6_DEV_REGEN_MAX_RETRY(ifp->idev) *
+					IN6_DEV_DAD_TRANSMITS(ifp->idev) *
 					NEIGH_VAR(ifp->idev->nd_parms, RETRANS_TIME) / HZ;
 
 				if (age >= ifp->prefered_lft - regen_advance) {
@@ -4275,52 +4293,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	BUG_ON(bytes < (IPV6_DEVCONF_MAX * 4));
 
 	memset(array, 0, bytes);
-	array[IPV6_DEVCONF_FORWARDING] = cnf->forwarding;
-	array[IPV6_DEVCONF_HOPLIMIT] = cnf->hop_limit;
-	array[IPV6_DEVCONF_MTU6] = cnf->mtu6;
-	array[IPV6_DEVCONF_ACCEPT_RA] = cnf->accept_ra;
-	array[IPV6_DEVCONF_ACCEPT_REDIRECTS] = cnf->accept_redirects;
-	array[IPV6_DEVCONF_AUTOCONF] = cnf->autoconf;
-	array[IPV6_DEVCONF_DAD_TRANSMITS] = cnf->dad_transmits;
-	array[IPV6_DEVCONF_RTR_SOLICITS] = cnf->rtr_solicits;
-	array[IPV6_DEVCONF_RTR_SOLICIT_INTERVAL] =
-		jiffies_to_msecs(cnf->rtr_solicit_interval);
-	array[IPV6_DEVCONF_RTR_SOLICIT_DELAY] =
-		jiffies_to_msecs(cnf->rtr_solicit_delay);
-	array[IPV6_DEVCONF_FORCE_MLD_VERSION] = cnf->force_mld_version;
-	array[IPV6_DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL] =
-		jiffies_to_msecs(cnf->mldv1_unsolicited_report_interval);
-	array[IPV6_DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL] =
-		jiffies_to_msecs(cnf->mldv2_unsolicited_report_interval);
-	array[IPV6_DEVCONF_USE_TEMPADDR] = cnf->use_tempaddr;
-	array[IPV6_DEVCONF_TEMP_VALID_LFT] = cnf->temp_valid_lft;
-	array[IPV6_DEVCONF_TEMP_PREFERED_LFT] = cnf->temp_prefered_lft;
-	array[IPV6_DEVCONF_REGEN_MAX_RETRY] = cnf->regen_max_retry;
-	array[IPV6_DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
-	array[IPV6_DEVCONF_MAX_ADDRESSES] = cnf->max_addresses;
-	array[IPV6_DEVCONF_ACCEPT_RA_DEFRTR] = cnf->accept_ra_defrtr;
-	array[IPV6_DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
-#ifdef CONFIG_IPV6_ROUTER_PREF
-	array[IPV6_DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
-	array[IPV6_DEVCONF_RTR_PROBE_INTERVAL] =
-		jiffies_to_msecs(cnf->rtr_probe_interval);
-#ifdef CONFIG_IPV6_ROUTE_INFO
-	array[IPV6_DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN] = cnf->accept_ra_rt_info_max_plen;
-#endif
-#endif
-	array[IPV6_DEVCONF_PROXY_NDP] = cnf->proxy_ndp;
-	array[IPV6_DEVCONF_ACCEPT_SOURCE_ROUTE] = cnf->accept_source_route;
-#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-	array[IPV6_DEVCONF_OPTIMISTIC_DAD] = cnf->optimistic_dad;
-#endif
-#ifdef CONFIG_IPV6_MROUTE
-	array[IPV6_DEVCONF_MC_FORWARDING] = cnf->mc_forwarding;
-#endif
-	array[IPV6_DEVCONF_DISABLE_IPV6] = cnf->disable_ipv6;
-	array[IPV6_DEVCONF_ACCEPT_DAD] = cnf->accept_dad;
-	array[IPV6_DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
-	array[IPV6_DEVCONF_NDISC_NOTIFY] = cnf->ndisc_notify;
-	array[IPV6_DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
+	memcpy(array, cnf->data, bytes);
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -4468,7 +4441,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 		return -EINVAL;
 	if (!ipv6_accept_ra(idev))
 		return -EINVAL;
-	if (idev->cnf.rtr_solicits <= 0)
+	if (IN6_DEV_RTR_SOLICITS(idev) <= 0)
 		return -EINVAL;
 
 	write_lock_bh(&idev->lock);
@@ -4494,7 +4467,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 	if (update_rs) {
 		idev->if_flags |= IF_RS_SENT;
 		idev->rs_probes = 1;
-		addrconf_mod_rs_timer(idev, idev->cnf.rtr_solicit_interval);
+		addrconf_mod_rs_timer(idev, IN6_DEV_RTR_SOLICIT_INTERVAL(idev));
 	}
 
 	/* Well, that's kinda nasty ... */
@@ -4725,14 +4698,14 @@ static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 		 */
 		if (!(ifp->rt->rt6i_node))
 			ip6_ins_rt(ifp->rt);
-		if (ifp->idev->cnf.forwarding)
+		if (IN6_DEV_FORWARD(ifp->idev))
 			addrconf_join_anycast(ifp);
 		if (!ipv6_addr_any(&ifp->peer_addr))
 			addrconf_prefix_route(&ifp->peer_addr, 128,
 					      ifp->idev->dev, 0, 0);
 		break;
 	case RTM_DELADDR:
-		if (ifp->idev->cnf.forwarding)
+		if (IN6_DEV_FORWARD(ifp->idev))
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
 		if (!ipv6_addr_any(&ifp->peer_addr)) {
@@ -4778,8 +4751,8 @@ int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
 	int ret;
 
 	/*
-	 * ctl->data points to idev->cnf.forwarding, we should
-	 * not modify it until we get the rtnl lock.
+	 * ctl->data points to idev->cnf.data[IPV6_DEVCONF_FORWARDING],
+	 * we should not modify it until we get the rtnl lock.
 	 */
 	lctl = *ctl;
 	lctl.data = &val;
@@ -4801,7 +4774,7 @@ static void dev_disable_change(struct inet6_dev *idev)
 		return;
 
 	netdev_notifier_info_init(&info, idev->dev);
-	if (idev->cnf.disable_ipv6)
+	if (IN6_DEV_DISABLE_IPV6(idev))
 		addrconf_notify(NULL, NETDEV_DOWN, &info);
 	else
 		addrconf_notify(NULL, NETDEV_UP, &info);
@@ -4816,8 +4789,9 @@ static void addrconf_disable_change(struct net *net, __s32 newf)
 	for_each_netdev_rcu(net, dev) {
 		idev = __in6_dev_get(dev);
 		if (idev) {
-			int changed = (!idev->cnf.disable_ipv6) ^ (!newf);
-			idev->cnf.disable_ipv6 = newf;
+			int changed = (!IN6_DEV_DISABLE_IPV6(idev)) ^ (!newf);
+
+			IN6_DEV_CONF_SET(idev, DISABLE_IPV6, newf);
 			if (changed)
 				dev_disable_change(idev);
 		}
@@ -4837,16 +4811,20 @@ static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int newf)
 	old = *p;
 	*p = newf;
 
-	if (p == &net->ipv6.devconf_dflt->disable_ipv6) {
+	if (p == &IPV6_DEVCONF_DFLT(net, DISABLE_IPV6)) {
 		rtnl_unlock();
 		return 0;
 	}
 
-	if (p == &net->ipv6.devconf_all->disable_ipv6) {
-		net->ipv6.devconf_dflt->disable_ipv6 = newf;
+	if (p == &IPV6_DEVCONF_ALL(net, DISABLE_IPV6)) {
+		IPV6_DEVCONF_DFLT(net, DISABLE_IPV6) = newf;
 		addrconf_disable_change(net, newf);
-	} else if ((!newf) ^ (!old))
-		dev_disable_change((struct inet6_dev *)table->extra1);
+	} else if ((!newf) ^ (!old)) {
+		struct ipv6_devconf *cnf = table->extra1;
+		struct inet6_dev *idev =
+			container_of(cnf, struct inet6_dev, cnf);
+		dev_disable_change(idev);
+	}
 
 	rtnl_unlock();
 	return 0;
@@ -4863,8 +4841,8 @@ int addrconf_sysctl_disable(struct ctl_table *ctl, int write,
 	int ret;
 
 	/*
-	 * ctl->data points to idev->cnf.disable_ipv6, we should
-	 * not modify it until we get the rtnl lock.
+	 * ctl->data points to idev->cnf.data[IPV6_DEVCONF_DISABLE_IPV6],
+	 * we should not modify it until we get the rtnl lock.
 	 */
 	lctl = *ctl;
 	lctl.data = &val;
@@ -4896,16 +4874,18 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *ctl, int write,
 		if (!rtnl_trylock())
 			return restart_syscall();
 
-		if (valp == &net->ipv6.devconf_dflt->proxy_ndp)
+		if (valp == &IPV6_DEVCONF_DFLT(net, PROXY_NDP))
 			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
 						     NETCONFA_IFINDEX_DEFAULT,
 						     net->ipv6.devconf_dflt);
-		else if (valp == &net->ipv6.devconf_all->proxy_ndp)
+		else if (valp == &IPV6_DEVCONF_ALL(net, PROXY_NDP))
 			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
 						     NETCONFA_IFINDEX_ALL,
 						     net->ipv6.devconf_all);
 		else {
-			struct inet6_dev *idev = ctl->extra1;
+			struct ipv6_devconf *cnf = ctl->extra1;
+			struct inet6_dev *idev =
+				container_of(cnf, struct inet6_dev, cnf);
 
 			inet6_netconf_notify_devconf(net, NETCONFA_PROXY_NEIGH,
 						     idev->dev->ifindex,
@@ -4917,27 +4897,25 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *ctl, int write,
 	return ret;
 }
 
-#define ADDRCONF_SYSCTL_ENTRY(name, var, mval, proc) \
+#define ADDRCONF_SYSCTL_ENTRY(attr, name, mval, proc) \
 	{ \
 		.procname	= #name, \
-		.data		= (void *)&ipv6_devconf + \
-				offsetof(struct ipv6_devconf, var), \
+		.data		= ipv6_devconf.data + \
+				  IPV6_DEVCONF_ ## attr, \
 		.maxlen		= sizeof(int), \
 		.mode		= mval, \
 		.proc_handler	= proc, \
+		.extra1		= &ipv6_devconf, \
 	}
 
-#define ADDRCONF_SYSCTL_RW_ENTRY(name) \
-	ADDRCONF_SYSCTL_ENTRY(name, name, 0644, proc_dointvec)
+#define ADDRCONF_SYSCTL_RW_ENTRY(attr, name) \
+	ADDRCONF_SYSCTL_ENTRY(attr, name, 0644, proc_dointvec)
 
-#define ADDRCONF_SYSCTL_RO_ENTRY(name) \
-	ADDRCONF_SYSCTL_ENTRY(name, name, 0444, proc_dointvec)
+#define ADDRCONF_SYSCTL_RO_ENTRY(attr, name) \
+	ADDRCONF_SYSCTL_ENTRY(attr, name, 0444, proc_dointvec)
 
-#define ADDRCONF_SYSCTL_COMPLEX_ENTRY(name, proc) \
-	ADDRCONF_SYSCTL_ENTRY(name, name, 0644, proc)
-
-#define ADDRCONF_SYSCTL_CUSTOM_ENTRY(name, var, proc) \
-	ADDRCONF_SYSCTL_ENTRY(name, var, 0644, proc)
+#define ADDRCONF_SYSCTL_COMPLEX_ENTRY(attr, name, proc) \
+	ADDRCONF_SYSCTL_ENTRY(attr, name, 0644, proc)
 
 static struct addrconf_sysctl_table
 {
@@ -4946,62 +4924,64 @@ static struct addrconf_sysctl_table
 } addrconf_sysctl __read_mostly = {
 	.sysctl_header = NULL,
 	.addrconf_vars = {
-		ADDRCONF_SYSCTL_COMPLEX_ENTRY(forwarding,
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(FORWARDING, forwarding,
 					      addrconf_sysctl_forward),
-		ADDRCONF_SYSCTL_RW_ENTRY(hop_limit),
-		ADDRCONF_SYSCTL_CUSTOM_ENTRY(mtu, mtu6, proc_dointvec),
-		ADDRCONF_SYSCTL_RW_ENTRY(accept_ra),
-		ADDRCONF_SYSCTL_RW_ENTRY(accept_redirects),
-		ADDRCONF_SYSCTL_RW_ENTRY(autoconf),
-		ADDRCONF_SYSCTL_RW_ENTRY(dad_transmits),
-		ADDRCONF_SYSCTL_CUSTOM_ENTRY(router_solicitations, rtr_solicits,
-					     proc_dointvec),
-		ADDRCONF_SYSCTL_CUSTOM_ENTRY(router_solicitation_interval,
-					     rtr_solicit_interval,
-					     proc_dointvec_jiffies),
-		ADDRCONF_SYSCTL_CUSTOM_ENTRY(router_solicitation_delay,
-					     rtr_solicit_delay,
-					     proc_dointvec_jiffies),
-		ADDRCONF_SYSCTL_RW_ENTRY(force_mld_version),
-		ADDRCONF_SYSCTL_COMPLEX_ENTRY(mldv1_unsolicited_report_interval,
-					      proc_dointvec_ms_jiffies),
-		ADDRCONF_SYSCTL_COMPLEX_ENTRY(mldv2_unsolicited_report_interval,
-					      proc_dointvec_ms_jiffies),
-		ADDRCONF_SYSCTL_RW_ENTRY(use_tempaddr),
-		ADDRCONF_SYSCTL_RW_ENTRY(temp_valid_lft),
-		ADDRCONF_SYSCTL_RW_ENTRY(temp_prefered_lft),
-		ADDRCONF_SYSCTL_RW_ENTRY(regen_max_retry),
-		ADDRCONF_SYSCTL_RW_ENTRY(max_desync_factor),
-		ADDRCONF_SYSCTL_RW_ENTRY(max_addresses),
-		ADDRCONF_SYSCTL_RW_ENTRY(accept_ra_defrtr),
-		ADDRCONF_SYSCTL_RW_ENTRY(accept_ra_pinfo),
+		ADDRCONF_SYSCTL_RW_ENTRY(HOPLIMIT, hop_limit),
+		ADDRCONF_SYSCTL_RW_ENTRY(MTU6, mtu),
+		ADDRCONF_SYSCTL_RW_ENTRY(ACCEPT_RA, accept_ra),
+		ADDRCONF_SYSCTL_RW_ENTRY(ACCEPT_REDIRECTS, accept_redirects),
+		ADDRCONF_SYSCTL_RW_ENTRY(AUTOCONF, autoconf),
+		ADDRCONF_SYSCTL_RW_ENTRY(DAD_TRANSMITS, dad_transmits),
+		ADDRCONF_SYSCTL_RW_ENTRY(RTR_SOLICITS, router_solicitations),
+		ADDRCONF_SYSCTL_RW_ENTRY(RTR_SOLICIT_INTERVAL,
+					 router_solicitation_interval),
+		ADDRCONF_SYSCTL_RW_ENTRY(RTR_SOLICIT_DELAY,
+					 router_solicitation_delay),
+		ADDRCONF_SYSCTL_RW_ENTRY(FORCE_MLD_VERSION, force_mld_version),
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(
+				MLDV1_UNSOLICITED_REPORT_INTERVAL,
+				mldv1_unsolicited_report_interval,
+				proc_dointvec_ms_jiffies),
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(
+				MLDV2_UNSOLICITED_REPORT_INTERVAL,
+				mldv2_unsolicited_report_interval,
+				proc_dointvec_ms_jiffies),
+		ADDRCONF_SYSCTL_RW_ENTRY(USE_TEMPADDR, use_tempaddr),
+		ADDRCONF_SYSCTL_RW_ENTRY(TEMP_VALID_LFT, temp_valid_lft),
+		ADDRCONF_SYSCTL_RW_ENTRY(TEMP_PREFERED_LFT, temp_prefered_lft),
+		ADDRCONF_SYSCTL_RW_ENTRY(REGEN_MAX_RETRY, regen_max_retry),
+		ADDRCONF_SYSCTL_RW_ENTRY(MAX_DESYNC_FACTOR, max_desync_factor),
+		ADDRCONF_SYSCTL_RW_ENTRY(MAX_ADDRESSES, max_addresses),
+		ADDRCONF_SYSCTL_RW_ENTRY(ACCEPT_RA_DEFRTR, accept_ra_defrtr),
+		ADDRCONF_SYSCTL_RW_ENTRY(ACCEPT_RA_PINFO, accept_ra_pinfo),
 #ifdef CONFIG_IPV6_ROUTER_PREF
-		ADDRCONF_SYSCTL_RW_ENTRY(accept_ra_rtr_pref),
-		ADDRCONF_SYSCTL_CUSTOM_ENTRY(router_probe_interval,
-					     rtr_probe_interval,
-					     proc_dointvec_jiffies),
+		ADDRCONF_SYSCTL_RW_ENTRY(ACCEPT_RA_RTR_PREF,
+					 accept_ra_rtr_pref),
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(RTR_PROBE_INTERVAL,
+					      router_probe_interval,
+					      proc_dointvec_jiffies),
 #ifdef CONFIG_IPV6_ROUTE_INFO
-		ADDRCONF_SYSCTL_RW_ENTRY(accept_ra_rt_info_max_plen),
+		ADDRCONF_SYSCTL_RW_ENTRY(ACCEPT_RA_RT_INFO_MAX_PLEN,
+					 accept_ra_rt_info_max_plen),
 #endif
 #endif
-		ADDRCONF_SYSCTL_COMPLEX_ENTRY(proxy_ndp,
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(PROXY_NDP, proxy_ndp,
 					      addrconf_sysctl_proxy_ndp),
-		ADDRCONF_SYSCTL_RW_ENTRY(accept_source_route),
+		ADDRCONF_SYSCTL_RW_ENTRY(ACCEPT_SOURCE_ROUTE,
+					 accept_source_route),
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-		ADDRCONF_SYSCTL_RW_ENTRY(optimistic_dad),
+		ADDRCONF_SYSCTL_RW_ENTRY(OPTIMISTIC_DAD, optimistic_dad),
 #endif
 #ifdef CONFIG_IPV6_MROUTE
-		ADDRCONF_SYSCTL_RO_ENTRY(mc_forwarding),
+		ADDRCONF_SYSCTL_RO_ENTRY(MC_FORWARDING, mc_forwarding),
 #endif
-		ADDRCONF_SYSCTL_COMPLEX_ENTRY(disable_ipv6,
+		ADDRCONF_SYSCTL_COMPLEX_ENTRY(DISABLE_IPV6, disable_ipv6,
 					      addrconf_sysctl_disable),
-		ADDRCONF_SYSCTL_RW_ENTRY(accept_dad),
-		ADDRCONF_SYSCTL_RW_ENTRY(force_tllao),
-		ADDRCONF_SYSCTL_RW_ENTRY(ndisc_notify),
-		ADDRCONF_SYSCTL_RW_ENTRY(suppress_frag_ndisc),
-		{
-			/* sentinel */
-		}
+		ADDRCONF_SYSCTL_RW_ENTRY(ACCEPT_DAD, accept_dad),
+		ADDRCONF_SYSCTL_RW_ENTRY(FORCE_TLLAO, force_tllao),
+		ADDRCONF_SYSCTL_RW_ENTRY(NDISC_NOTIFY, ndisc_notify),
+		ADDRCONF_SYSCTL_RW_ENTRY(SUPPRESS_FRAG_NDISC,
+					 suppress_frag_ndisc),
 	},
 };
 
@@ -5018,7 +4998,7 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 
 	for (i = 0; t->addrconf_vars[i].data; i++) {
 		t->addrconf_vars[i].data += (char *)p - (char *)&ipv6_devconf;
-		t->addrconf_vars[i].extra1 = idev; /* embedded; no ref */
+		t->addrconf_vars[i].extra1 = p;
 		t->addrconf_vars[i].extra2 = net;
 	}
 
@@ -5081,8 +5061,8 @@ static int __net_init addrconf_init_net(struct net *net)
 		goto err_alloc_dflt;
 
 	/* these will be inherited by all namespaces */
-	dflt->autoconf = ipv6_defaults.autoconf;
-	dflt->disable_ipv6 = ipv6_defaults.disable_ipv6;
+	IPV6_DEVCONF(*dflt, AUTOCONF) = ipv6_defaults.autoconf;
+	IPV6_DEVCONF(*dflt, DISABLE_IPV6) = ipv6_defaults.disable_ipv6;
 
 	net->ipv6.devconf_all = all;
 	net->ipv6.devconf_dflt = dflt;
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 2101832..4a9beac 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -61,7 +61,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	struct inet6_dev *idev;
 	struct ipv6_ac_socklist *pac;
 	struct net *net = sock_net(sk);
-	int	ishost = !net->ipv6.devconf_all->forwarding;
+	int	ishost = !IPV6_DEVCONF_ALL(net, FORWARDING);
 	int	err = 0;
 
 	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
@@ -110,7 +110,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		goto error;
 	}
 	/* reset ishost, now that we have a specific device */
-	ishost = !idev->cnf.forwarding;
+	ishost = !IN6_DEV_FORWARD(idev);
 
 	pac->acl_ifindex = dev->ifindex;
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 8d67900..9fcf463 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -295,16 +295,12 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 	struct inet6_skb_parm *opt = IP6CB(skb);
 	struct in6_addr *addr = NULL;
 	struct in6_addr daddr;
-	struct inet6_dev *idev;
 	int n, i;
 	struct ipv6_rt_hdr *hdr;
 	struct rt0_hdr *rthdr;
 	struct net *net = dev_net(skb->dev);
-	int accept_source_route = net->ipv6.devconf_all->accept_source_route;
-
-	idev = __in6_dev_get(skb->dev);
-	if (idev && accept_source_route > idev->cnf.accept_source_route)
-		accept_source_route = idev->cnf.accept_source_route;
+	int accept_source_route =
+		IN6_DEV_ACCEPT_SOURCE_ROUTE(__in6_dev_get(skb->dev));
 
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 51d54dc..67345a4 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -81,7 +81,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_IN, skb->len);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL ||
-	    !idev || unlikely(idev->cnf.disable_ipv6)) {
+	    !idev || IN6_DEV_DISABLE_IPV6(idev)) {
 		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
@@ -296,7 +296,7 @@ int ip6_mc_input(struct sk_buff *skb)
 	/*
 	 *      IPv6 multicast router mode is now supported ;)
 	 */
-	if (dev_net(skb->dev)->ipv6.devconf_all->mc_forwarding &&
+	if (IN6_DEV_MFORWARD(__in6_dev_get(skb->dev)) &&
 	    !(ipv6_addr_type(&hdr->daddr) &
 	      (IPV6_ADDR_LOOPBACK|IPV6_ADDR_LINKLOCAL)) &&
 	    likely(!(IP6CB(skb)->flags & IP6SKB_FORWARDED))) {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index cb9df0e..db05c4c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -136,7 +136,7 @@ int ip6_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
 	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
-	if (unlikely(idev->cnf.disable_ipv6)) {
+	if (IN6_DEV_DISABLE_IPV6(idev)) {
 		IP6_INC_STATS(dev_net(dev), idev,
 			      IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
@@ -336,7 +336,7 @@ static unsigned int ip6_dst_mtu_forward(const struct dst_entry *dst)
 	rcu_read_lock();
 	idev = __in6_dev_get(dst->dev);
 	if (idev)
-		mtu = idev->cnf.mtu6;
+		mtu = IN6_DEV_MTU(idev);
 	rcu_read_unlock();
 
 	return mtu;
@@ -368,7 +368,7 @@ int ip6_forward(struct sk_buff *skb)
 	struct net *net = dev_net(dst->dev);
 	u32 mtu;
 
-	if (net->ipv6.devconf_all->forwarding == 0)
+	if (IPV6_DEVCONF_ALL(net, FORWARDING) == 0)
 		goto error;
 
 	if (skb->pkt_type != PACKET_HOST)
@@ -417,8 +417,7 @@ int ip6_forward(struct sk_buff *skb)
 		return -ETIMEDOUT;
 	}
 
-	/* XXX: idev->cnf.proxy_ndp? */
-	if (net->ipv6.devconf_all->proxy_ndp &&
+	if (IN6_DEV_PROXY_NDP(ip6_dst_idev(dst)) &&
 	    pneigh_lookup(&nd_tbl, net, &hdr->daddr, skb->dev, 0)) {
 		int proxied = ip6_forward_proxy_check(skb);
 		if (proxied > 0)
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 8250474..2722e24 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -816,7 +816,7 @@ static int mif6_delete(struct mr6_table *mrt, int vifi, struct list_head *head)
 
 	in6_dev = __in6_dev_get(dev);
 	if (in6_dev) {
-		in6_dev->cnf.mc_forwarding--;
+		IN6_DEV_MFORWARD_DEC(in6_dev);
 		inet6_netconf_notify_devconf(dev_net(dev),
 					     NETCONFA_MC_FORWARDING,
 					     dev->ifindex, &in6_dev->cnf);
@@ -974,7 +974,7 @@ static int mif6_add(struct net *net, struct mr6_table *mrt,
 
 	in6_dev = __in6_dev_get(dev);
 	if (in6_dev) {
-		in6_dev->cnf.mc_forwarding++;
+		IN6_DEV_MFORWARD_INC(in6_dev);
 		inet6_netconf_notify_devconf(dev_net(dev),
 					     NETCONFA_MC_FORWARDING,
 					     dev->ifindex, &in6_dev->cnf);
@@ -1587,7 +1587,7 @@ static int ip6mr_sk_init(struct mr6_table *mrt, struct sock *sk)
 	write_lock_bh(&mrt_lock);
 	if (likely(mrt->mroute6_sk == NULL)) {
 		mrt->mroute6_sk = sk;
-		net->ipv6.devconf_all->mc_forwarding++;
+		IPV6_DEVCONF_ALL(net, MC_FORWARDING)++;
 		inet6_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
 					     NETCONFA_IFINDEX_ALL,
 					     net->ipv6.devconf_all);
@@ -1612,7 +1612,7 @@ int ip6mr_sk_done(struct sock *sk)
 		if (sk == mrt->mroute6_sk) {
 			write_lock_bh(&mrt_lock);
 			mrt->mroute6_sk = NULL;
-			net->ipv6.devconf_all->mc_forwarding--;
+			IPV6_DEVCONF_ALL(net, MC_FORWARDING)--;
 			inet6_netconf_notify_devconf(net,
 						     NETCONFA_MC_FORWARDING,
 						     NETCONFA_IFINDEX_ALL,
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index edb58af..d91f501 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1188,7 +1188,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		}
 
 		if (val < 0)
-			val = sock_net(sk)->ipv6.devconf_all->hop_limit;
+			val = IPV6_DEVCONF_ALL(sock_net(sk), HOPLIMIT);
 		break;
 	}
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 08b367c..cd49bb5 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -95,7 +95,7 @@ static void mld_ifc_event(struct inet6_dev *idev);
 static void mld_add_delrec(struct inet6_dev *idev, struct ifmcaddr6 *pmc);
 static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *addr);
 static void mld_clear_delrec(struct inet6_dev *idev);
-static bool mld_in_v1_mode(const struct inet6_dev *idev);
+static bool mld_in_v1_mode(struct inet6_dev *idev);
 static int sf_setstate(struct ifmcaddr6 *pmc);
 static void sf_markstate(struct ifmcaddr6 *pmc);
 static void ip6_mc_clear_src(struct ifmcaddr6 *pmc);
@@ -136,9 +136,9 @@ static int unsolicited_report_interval(struct inet6_dev *idev)
 	int iv;
 
 	if (mld_in_v1_mode(idev))
-		iv = idev->cnf.mldv1_unsolicited_report_interval;
+		iv = IN6_DEV_CONF_GET(idev, MLDV1_UNSOLICITED_REPORT_INTERVAL);
 	else
-		iv = idev->cnf.mldv2_unsolicited_report_interval;
+		iv = IN6_DEV_CONF_GET(idev, MLDV2_UNSOLICITED_REPORT_INTERVAL);
 
 	return iv > 0 ? iv : 1;
 }
@@ -1129,30 +1129,17 @@ static bool mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	return true;
 }
 
-static int mld_force_mld_version(const struct inet6_dev *idev)
+static bool mld_in_v2_mode_only(struct inet6_dev *idev)
 {
-	/* Normally, both are 0 here. If enforcement to a particular is
-	 * being used, individual device enforcement will have a lower
-	 * precedence over 'all' device (.../conf/all/force_mld_version).
-	 */
-
-	if (dev_net(idev->dev)->ipv6.devconf_all->force_mld_version != 0)
-		return dev_net(idev->dev)->ipv6.devconf_all->force_mld_version;
-	else
-		return idev->cnf.force_mld_version;
-}
-
-static bool mld_in_v2_mode_only(const struct inet6_dev *idev)
-{
-	return mld_force_mld_version(idev) == 2;
+	return IN6_DEV_FORCE_MLD_VERSION(idev) == 2;
 }
 
-static bool mld_in_v1_mode_only(const struct inet6_dev *idev)
+static bool mld_in_v1_mode_only(struct inet6_dev *idev)
 {
-	return mld_force_mld_version(idev) == 1;
+	return IN6_DEV_FORCE_MLD_VERSION(idev) == 1;
 }
 
-static bool mld_in_v1_mode(const struct inet6_dev *idev)
+static bool mld_in_v1_mode(struct inet6_dev *idev)
 {
 	if (mld_in_v2_mode_only(idev))
 		return false;
@@ -2527,7 +2514,7 @@ void ipv6_mc_destroy_dev(struct inet6_dev *idev)
 	 */
 	__ipv6_dev_mc_dec(idev, &in6addr_linklocal_allnodes);
 
-	if (idev->cnf.forwarding)
+	if (IN6_DEV_FORWARD(idev))
 		__ipv6_dev_mc_dec(idev, &in6addr_linklocal_allrouters);
 
 	write_lock_bh(&idev->lock);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ca8d4ea..6803f3f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -483,7 +483,7 @@ void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 		src_addr = solicited_addr;
 		if (ifp->flags & IFA_F_OPTIMISTIC)
 			override = false;
-		inc_opt |= ifp->idev->cnf.force_tllao;
+		inc_opt |= IN6_DEV_FORCE_TLLAO(ifp->idev);
 		in6_ifa_put(ifp);
 	} else {
 		if (ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
@@ -533,7 +533,7 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 	read_lock_bh(&idev->lock);
 	list_for_each_entry(ifa, &idev->addr_list, if_list) {
 		ndisc_send_na(dev, NULL, &in6addr_linklocal_allnodes, &ifa->addr,
-			      /*router=*/ !!idev->cnf.forwarding,
+			      /*router=*/ !!IN6_DEV_FORWARD(idev),
 			      /*solicited=*/ false, /*override=*/ true,
 			      /*inc_opt=*/ true);
 	}
@@ -786,8 +786,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		}
 
 		if (ipv6_chk_acast_addr(net, dev, &msg->target) ||
-		    (idev->cnf.forwarding &&
-		     (net->ipv6.devconf_all->proxy_ndp || idev->cnf.proxy_ndp) &&
+		    (IN6_DEV_FORWARD(idev) && IN6_DEV_PROXY_NDP(idev) &&
 		     (is_router = pndisc_is_router(&msg->target, dev)) >= 0)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
@@ -810,7 +809,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	}
 
 	if (is_router < 0)
-		is_router = idev->cnf.forwarding;
+		is_router = IN6_DEV_FORWARD(idev);
 
 	if (dad) {
 		ndisc_send_na(dev, NULL, &in6addr_linklocal_allnodes, &msg->target,
@@ -927,9 +926,9 @@ static void ndisc_recv_na(struct sk_buff *skb)
 		 * has already sent a NA to us.
 		 */
 		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
-		    net->ipv6.devconf_all->forwarding && net->ipv6.devconf_all->proxy_ndp &&
+		    IN6_DEV_FORWARD(__in6_dev_get(dev)) &&
+		    IN6_DEV_PROXY_NDP(__in6_dev_get(dev)) &&
 		    pneigh_lookup(&nd_tbl, net, &msg->target, dev, 0)) {
-			/* XXX: idev->cnf.proxy_ndp */
 			goto out;
 		}
 
@@ -972,7 +971,7 @@ static void ndisc_recv_rs(struct sk_buff *skb)
 	}
 
 	/* Don't accept RS if we're not in router mode */
-	if (!idev->cnf.forwarding)
+	if (!IN6_DEV_FORWARD(idev))
 		goto out;
 
 	/*
@@ -1130,7 +1129,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 				(ra_msg->icmph.icmp6_addrconf_other ?
 					IF_RA_OTHERCONF : 0);
 
-	if (!in6_dev->cnf.accept_ra_defrtr)
+	if (!IN6_DEV_ACCEPT_RA_DEFRTR(in6_dev))
 		goto skip_defrtr;
 
 	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr, NULL, 0))
@@ -1142,7 +1141,7 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	pref = ra_msg->icmph.icmp6_router_pref;
 	/* 10b is handled as if it were 00b (medium) */
 	if (pref == ICMPV6_ROUTER_PREF_INVALID ||
-	    !in6_dev->cnf.accept_ra_rtr_pref)
+	    !IN6_DEV_ACCEPT_RA_RTR_PREF(in6_dev))
 		pref = ICMPV6_ROUTER_PREF_MEDIUM;
 #endif
 
@@ -1190,7 +1189,8 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 	if (rt)
 		rt6_set_expires(rt, jiffies + (HZ * lifetime));
 	if (ra_msg->icmph.icmp6_hop_limit) {
-		in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
+		IN6_DEV_CONF_SET(in6_dev, HOPLIMIT,
+				 ra_msg->icmph.icmp6_hop_limit);
 		if (rt)
 			dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
 				       ra_msg->icmph.icmp6_hop_limit);
@@ -1267,7 +1267,7 @@ skip_linkparms:
 	if (ipv6_chk_addr(dev_net(in6_dev->dev), &ipv6_hdr(skb)->saddr, NULL, 0))
 		goto skip_routeinfo;
 
-	if (in6_dev->cnf.accept_ra_rtr_pref && ndopts.nd_opts_ri) {
+	if (IN6_DEV_ACCEPT_RA_RTR_PREF(in6_dev) && ndopts.nd_opts_ri) {
 		struct nd_opt_hdr *p;
 		for (p = ndopts.nd_opts_ri;
 		     p;
@@ -1279,9 +1279,10 @@ skip_linkparms:
 				continue;
 #endif
 			if (ri->prefix_len == 0 &&
-			    !in6_dev->cnf.accept_ra_defrtr)
+			    !IN6_DEV_ACCEPT_RA_DEFRTR(in6_dev))
 				continue;
-			if (ri->prefix_len > in6_dev->cnf.accept_ra_rt_info_max_plen)
+			if (ri->prefix_len >
+			    IN6_DEV_ACCEPT_RA_RT_INFO_MAX_PLEN(in6_dev))
 				continue;
 			rt6_route_rcv(skb->dev, (u8*)p, (p->nd_opt_len) << 3,
 				      &ipv6_hdr(skb)->saddr);
@@ -1297,7 +1298,7 @@ skip_routeinfo:
 		goto out;
 #endif
 
-	if (in6_dev->cnf.accept_ra_pinfo && ndopts.nd_opts_pi) {
+	if (IN6_DEV_ACCEPT_RA_PINFO(in6_dev) && ndopts.nd_opts_pi) {
 		struct nd_opt_hdr *p;
 		for (p = ndopts.nd_opts_pi;
 		     p;
@@ -1317,8 +1318,8 @@ skip_routeinfo:
 
 		if (mtu < IPV6_MIN_MTU || mtu > skb->dev->mtu) {
 			ND_PRINTK(2, warn, "RA: invalid mtu: %d\n", mtu);
-		} else if (in6_dev->cnf.mtu6 != mtu) {
-			in6_dev->cnf.mtu6 = mtu;
+		} else if (IN6_DEV_CONF_GET(in6_dev, MTU6) != mtu) {
+			IN6_DEV_CONF_SET(in6_dev, MTU6, mtu);
 
 			if (rt)
 				dst_metric_set(&rt->dst, RTAX_MTU, mtu);
@@ -1530,8 +1531,8 @@ static bool ndisc_suppress_frag_ndisc(struct sk_buff *skb)
 	if (!idev)
 		return true;
 	if (IP6CB(skb)->flags & IP6SKB_FRAGMENTED &&
-	    idev->cnf.suppress_frag_ndisc) {
-		net_warn_ratelimited("Received fragmented ndisc packet. Carefully consider disabling suppress_frag_ndisc.\n");
+	    IN6_DEV_SUPPRESS_FRAG_NDISC(idev)) {
+		ND_PRINTK(1, warn, "Received fragmented ndisc packet. Carefully consider disabling suppress_frag_ndisc.\n");
 		return true;
 	}
 	return false;
@@ -1603,7 +1604,7 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
 		idev = in6_dev_get(dev);
 		if (!idev)
 			break;
-		if (idev->cnf.ndisc_notify)
+		if (IN6_DEV_NDISC_NOTIFY(idev))
 			ndisc_send_unsol_na(dev);
 		in6_dev_put(idev);
 		break;
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index ffa0293..f86ffd4 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -60,9 +60,9 @@ int ip6_dst_hoplimit(struct dst_entry *dst)
 		rcu_read_lock();
 		idev = __in6_dev_get(dev);
 		if (idev)
-			hoplimit = idev->cnf.hop_limit;
+			hoplimit = IN6_DEV_HOPLIMIT(idev);
 		else
-			hoplimit = dev_net(dev)->ipv6.devconf_all->hop_limit;
+			hoplimit = IPV6_DEVCONF_ALL(dev_net(dev), HOPLIMIT);
 		rcu_read_unlock();
 	}
 	return hoplimit;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f23fbd2..0459cf9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -525,7 +525,8 @@ static void rt6_probe(struct rt6_info *rt)
 	}
 
 	if (!neigh ||
-	    time_after(jiffies, neigh->updated + rt->rt6i_idev->cnf.rtr_probe_interval)) {
+	    time_after(jiffies, neigh->updated +
+				IN6_DEV_RTR_PROBE_INTERVAL(rt->rt6i_idev))) {
 		struct __rt6_probe_work *work;
 
 		work = kmalloc(sizeof(*work), GFP_ATOMIC);
@@ -922,7 +923,7 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 	int strict = 0;
 	int attempts = 3;
 	int err;
-	int reachable = net->ipv6.devconf_all->forwarding ? 0 : RT6_LOOKUP_F_REACHABLE;
+	int reachable = IPV6_DEVCONF_ALL(net, FORWARDING) ? 0 : RT6_LOOKUP_F_REACHABLE;
 
 	strict |= flags & RT6_LOOKUP_F_IFACE;
 
@@ -1347,7 +1348,7 @@ static unsigned int ip6_mtu(const struct dst_entry *dst)
 	rcu_read_lock();
 	idev = __in6_dev_get(dst->dev);
 	if (idev)
-		mtu = idev->cnf.mtu6;
+		mtu = IN6_DEV_MTU(idev);
 	rcu_read_unlock();
 
 out:
@@ -1790,7 +1791,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	in6_dev = __in6_dev_get(skb->dev);
 	if (!in6_dev)
 		return;
-	if (in6_dev->cnf.forwarding || !in6_dev->cnf.accept_redirects)
+	if (IN6_DEV_FORWARD(in6_dev) || !IN6_DEV_ACCEPT_REDIRECTS(in6_dev))
 		return;
 
 	/* RFC2461 8.1:
@@ -2031,7 +2032,7 @@ restart:
 	read_lock_bh(&table->tb6_lock);
 	for (rt = table->tb6_root.leaf; rt; rt = rt->dst.rt6_next) {
 		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF) &&
-		    (!rt->rt6i_idev || rt->rt6i_idev->cnf.accept_ra != 2)) {
+		    (!rt->rt6i_idev || IN6_DEV_ACCEPT_RA(rt->rt6i_idev) != 2)) {
 			dst_hold(&rt->dst);
 			read_unlock_bh(&table->tb6_lock);
 			ip6_del_rt(rt);
@@ -2321,7 +2322,7 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	    !dst_metric_locked(&rt->dst, RTAX_MTU) &&
 	    (dst_mtu(&rt->dst) >= arg->mtu ||
 	     (dst_mtu(&rt->dst) < arg->mtu &&
-	      dst_mtu(&rt->dst) == idev->cnf.mtu6))) {
+	      dst_mtu(&rt->dst) == IN6_DEV_MTU(idev)))) {
 		dst_metric_set(&rt->dst, RTAX_MTU, arg->mtu);
 	}
 	return 0;
-- 
1.9.0
