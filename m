From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC] ipv6: stable privacy addresses
Date: Fri, 13 Dec 2013 09:55:50 +0100
Message-ID: <20131213085549.GA3685@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: fgont@si6networks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52668 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab3LMIzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 03:55:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This is a preview for the interface I envison for IPv6 stable privacy
addresses. This patch has still issues: I experience some problems with
dev_mc_add mc-addresses not forwarded to macvtaps here on my VM.

-- >8 --

This patch implements stable privacy addresses as currently specified
as a draft by Fernando Gont:

<http://tools.ietf.org/html/draft-ietf-6man-stable-privacy-addresses-16>

One can assume this will become a RFC any time soon. Recent updates
had only minor changes. For details please have a look at the draft.

Some time ago <http://tools.ietf.org/html/draft-iesg-serno-privacy-00>
stated that
"	Protocols intended to be used over the global Internet SHOULD NOT
depend on the inclusion of hardware serial numbers.  Protocols intended
to be used only in a local IP-based network, which use hardware serial
numbers, SHOULD define a means to keep those serial numbers from escaping
into the global Internet.
".

Despite the existence of Privacy Extensions Fernando Gont tries to abandon
EUI-64 based address for link-local as well as for global address scope
as it is too easy that the old EUI-64 based addresses could leak.

This patch currently only implements the switch of the address generation
mode at compile- or boot-time (as the patch already includes documentation
on how to use it, I'll leave it out here). The stable secret will get
loaded via procfs.

The draft offers more than one version which attributes to hash to
get a stable host identifier.  I decided to pick SHA-1 as the hashing
function and use the device address as the Net_Iface identifier. I did
not implement the optional Network_ID yet.

Futher algorithms can be easily implemented and can be distinguished by
the address generation mode.

Cc: Fernando Gont <fgont@si6networks.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 Documentation/kernel-parameters.txt    |  10 +
 Documentation/networking/ip-sysctl.txt |  16 ++
 include/linux/ipv6.h                   |   2 +
 include/net/addrconf.h                 |   4 +
 include/net/if_inet6.h                 |   1 +
 include/net/netns/ipv6.h               |   3 +
 include/uapi/linux/if_addr.h           |   1 +
 include/uapi/linux/ipv6.h              |   2 +
 kernel/x509_certificate_list           |   0
 net/ipv6/Kconfig                       |  41 ++++
 net/ipv6/addrconf.c                    | 341 +++++++++++++++++++++++++++++++--
 net/ipv6/sysctl_net_ipv6.c             |  22 +++
 12 files changed, 425 insertions(+), 18 deletions(-)
 create mode 100644 kernel/x509_certificate_list

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 50680a5..d50f044 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -346,6 +346,13 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	add_efi_memmap	[EFI; X86] Include EFI memory map in
 			kernel's map of available physical RAM.
 
+	address_generation_mode= [IPV6] Method of address
+				 generation. Following modes are
+				 currently supported:
+
+				    0	EUI-64 address generation
+				    1	stable privacy generation v1
+
 	agp=		[AGP]
 			{ off | try_unsupported }
 			off: disable AGP support
@@ -2995,6 +3002,9 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	spia_pedr=
 	spia_peddr=
 
+	stable_privacy_address_secret= [IPV6] Secret for stable
+				       privacy address generation.
+
 	stacktrace	[FTRACE]
 			Enabled the stack tracer on boot up.
 
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 12ba2cd..db8d481 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1084,6 +1084,13 @@ bindv6only - BOOLEAN
 
 	Default: FALSE (as specified in RFC3493)
 
+stable_address_secret - UNSIGNED LONG
+	If stable privacy addresses are enabled then on the first
+	write to this file link-local addresses are generated and
+	router solicitions are send out. The generated addresses are
+	based on this secret.  If the same secret is reused across
+	reboots the generated addresses will be the same.
+
 IPv6 Fragmentation:
 
 ip6frag_high_thresh - INTEGER
@@ -1365,6 +1372,15 @@ suppress_frag_ndisc - INTEGER
 	1 - (default) discard fragmented neighbor discovery packets
 	0 - allow fragmented neighbor discovery packets
 
+idgen_retries - INTEGER
+	Number of retries to generate a stable privacy address in case
+	of a duplicate address.
+	Default: 3
+
+idgen_delay - INTEGER
+	Seconds to delay another attempt to generate a stable privacy address.
+	Default: 1000 (1 second)
+
 icmp/*:
 ratelimit - INTEGER
 	Limit the maximal rates for sending ICMPv6 packets.
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 3fde066..e4d4b15 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -50,6 +50,8 @@ struct ipv6_devconf {
 	__s32		force_tllao;
 	__s32           ndisc_notify;
 	__s32		suppress_frag_ndisc;
+	__s32		idgen_retries;
+	__s32		idgen_delay;
 	void		*sysctl;
 };
 
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 66c4a44..1e572f2 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -216,6 +216,10 @@ int inet6addr_notifier_call_chain(unsigned long val, void *v);
 void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
 				  struct ipv6_devconf *devconf);
 
+int addrconf_sysctl_stbladdr_secret_change(struct ctl_table *ctl, int write,
+					   void __user *buffer, size_t *lenp,
+					   loff_t *ppos);
+
 /**
  * __in6_dev_get - get inet6_dev pointer from netdevice
  * @dev: network device
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index b58c36c..25b6706 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -52,6 +52,7 @@ struct inet6_ifaddr {
 
 	__u32			flags;
 	__u8			dad_probes;
+	__u8			dad_retry_cnt;
 
 	__u16			scope;
 
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 0fb2401..4ac56d9 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -73,6 +73,9 @@ struct netns_ipv6 {
 #endif
 	atomic_t		dev_addr_genid;
 	atomic_t		rt_genid;
+
+	int			addrgen_mode;
+	unsigned long		stbladdr_secret;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.h
index cfed10b..68b94f4 100644
--- a/include/uapi/linux/if_addr.h
+++ b/include/uapi/linux/if_addr.h
@@ -49,6 +49,7 @@ enum {
 #define IFA_F_TENTATIVE		0x40
 #define IFA_F_PERMANENT		0x80
 #define IFA_F_MANAGETEMPADDR	0x100
+#define IFA_F_PRIVSTBLADDR	0x200
 
 struct ifa_cacheinfo {
 	__u32	ifa_prefered;
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 593b0e3..5238716 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -163,6 +163,8 @@ enum {
 	DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL,
 	DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL,
 	DEVCONF_SUPPRESS_FRAG_NDISC,
+	DEVCONF_IDGEN_RETRIES,
+	DEVCONF_IDGEN_DELAY,
 	DEVCONF_MAX
 };
 
diff --git a/kernel/x509_certificate_list b/kernel/x509_certificate_list
new file mode 100644
index 0000000..e69de29
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index d92e558..6f30001 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -21,6 +21,47 @@ menuconfig IPV6
 
 if IPV6
 
+choice
+	prompt "Autoconf address generation mode"
+	default IPV6_ADDRESS_GEN_MODE_EUI64
+	help
+
+	  Selects the default generation mode for IPv6 addresses. This
+	  option specifies the compile-time default. It can be
+	  overwritten by ipv6.address_generation_mode kernel command
+	  line parameter at boot. Please see the specific options for
+	  furhter help.
+
+	  If unsure, select the EUI-64 based address generation (at
+	  least for now).
+
+config IPV6_ADDRESS_GEN_MODE_EUI64
+       bool "EUI-64 based address generation"
+       help
+         Old link-local address generation mode. Use the interface
+         hardware address for IPv6 address generation. This is
+         currently the default mode but it is advised to switch to
+         stable privacy addresses in future. As the other option may
+         need support from distributions to manage the stable secret,
+         stick to this option until it is advised to switch.
+
+config IPV6_ADDRESS_GEN_MODE_STABLE_PRIVACY_V1
+       bool "Stable privacy address generation v1"
+       help
+         Stable privacy address generation mode v1. Further
+         information can be found here:
+	 http://tools.ietf.org/html/draft-ietf-6man-stable-privacy-addresses-16
+
+	 This option may need support from distributions to install
+	 the stable secret early at boot up (otherwise link-local
+	 addresses will be generated too late). If you don't have
+	 services depending on link-local addresses on boot-up you can
+	 activate this mode and install the stable secret any time
+	 later by hand by writing it to
+	 /proc/sys/net/ipv6/stable_privacy_secret.
+
+endchoice
+
 config IPV6_ROUTER_PREF
 	bool "IPv6: Router Preference (RFC 4191) support"
 	---help---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3c3425e..a178389 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -43,6 +43,7 @@
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/socket.h>
 #include <linux/sockios.h>
 #include <linux/net.h>
@@ -102,6 +103,20 @@
 
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
 
+static int addrgen_mode_param = -1;
+
+module_param_named(address_generation_mode,
+		   addrgen_mode_param,
+		   int, 0444);
+MODULE_PARM_DESC(address_generation_mode,
+		 "Mode of address generation (0=eui-64, 1=privacy stable)");
+
+module_param_named(stable_privacy_address_secret,
+		   init_net.ipv6.stbladdr_secret,
+		   ulong, 0444);
+MODULE_PARM_DESC(stable_privacy_address_secret,
+		 "Key for stable privacy address generation (non-zero)");
+
 static inline u32 cstamp_delta(unsigned long cstamp)
 {
 	return (cstamp - INITIAL_JIFFIES) * 100UL / HZ;
@@ -163,6 +178,9 @@ static void inet6_prefix_notify(int event, struct inet6_dev *idev,
 static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 			       struct net_device *dev);
 
+static int ipv6_generate_stblpriv_addr(struct in6_addr *addr,
+				       struct inet6_dev *idev, __u8 dad_count);
+
 static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.forwarding		= 0,
 	.hop_limit		= IPV6_DEFAULT_HOPLIMIT,
@@ -197,6 +215,8 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
+	.idgen_retries		= 3,
+	.idgen_delay		= 1 * HZ,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -233,6 +253,8 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
+	.idgen_retries		= 3,
+	.idgen_delay		= 1 * HZ,
 };
 
 /* Check if a valid qdisc is available */
@@ -852,6 +874,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	ifa->prefered_lft = prefered_lft;
 	ifa->cstamp = ifa->tstamp = jiffies;
 	ifa->tokenized = false;
+	ifa->dad_retry_cnt = 0;
 
 	ifa->rt = rt;
 
@@ -1570,11 +1593,98 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 	return result;
 }
 
+struct __addrconf_idgen_work {
+	struct delayed_work work;
+
+	struct inet6_dev *idev;
+	struct in6_addr addr;
+	int pfxlen;
+	int scope;
+	u32 flags;
+	u32 valid_lft;
+	u32 prefered_lft;
+	int dad_retry_cnt;
+};
+
+static void __addrconf_retry_stblpriv_deferred(struct work_struct *w)
+{
+	struct inet6_ifaddr *ifp;
+	struct __addrconf_idgen_work *work =
+		container_of(w, struct __addrconf_idgen_work, work.work);
+
+	/* protect that the interface is not going to be dead */
+	rtnl_lock();
+	if (work->idev->dead)
+		goto out;
+
+	work->addr.s6_addr32[2] = 0;
+	work->addr.s6_addr32[3] = 0;
+	if (ipv6_generate_stblpriv_addr(&work->addr, work->idev,
+					work->dad_retry_cnt))
+		goto out;
+
+	ifp = ipv6_add_addr(work->idev, &work->addr, NULL, work->pfxlen,
+		      work->scope, work->flags, work->valid_lft,
+		      work->prefered_lft);
+	if (IS_ERR(ifp))
+		goto out;
+
+	spin_lock_bh(&ifp->lock);
+	ifp->dad_retry_cnt = work->dad_retry_cnt;
+	spin_unlock_bh(&ifp->lock);
+	addrconf_dad_start(ifp);
+	in6_ifa_put(ifp);
+out:
+	rtnl_unlock();
+	in6_dev_put(work->idev);
+	kfree(w);
+}
+
+/* called with ifp locked */
+static void addrconf_retry_stblpriv(struct inet6_ifaddr *ifp)
+{
+	struct __addrconf_idgen_work *work;
+
+	addrconf_del_dad_timer(ifp);
+
+	work = kmalloc(sizeof(*work), GFP_ATOMIC);
+	if (!work)
+		return;
+
+	INIT_DELAYED_WORK(&work->work, __addrconf_retry_stblpriv_deferred);
+	work->idev = ifp->idev;
+	in6_dev_hold(work->idev);
+	work->addr = ifp->addr;
+	work->pfxlen = ifp->prefix_len;
+	work->scope = ifp->scope;
+	work->flags = ifp->flags;
+	work->valid_lft = ifp->valid_lft;
+	work->prefered_lft = ifp->prefered_lft;
+	work->dad_retry_cnt = ifp->dad_retry_cnt;
+	schedule_delayed_work(&work->work,
+			      ifp->idev->cnf.idgen_delay);
+}
+
 /* Gets referenced address, destroys ifaddr */
 
-static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
+static void addrconf_dad_stop(struct inet6_ifaddr *ifp, bool dad_failed)
 {
-	if (ifp->flags&IFA_F_PERMANENT) {
+	/* privacy stable addresses may retry DAD with newly
+	 * generated address up to idgen_retries times
+	 */
+	if (dad_failed) {
+		spin_lock_bh(&ifp->lock);
+		if (ifp->flags & IFA_F_PRIVSTBLADDR &&
+		    ifp->dad_retry_cnt < ifp->idev->cnf.idgen_retries) {
+			addrconf_retry_stblpriv(ifp);
+			spin_unlock_bh(&ifp->lock);
+			ipv6_del_addr(ifp);
+			return;
+		}
+		spin_unlock_bh(&ifp->lock);
+	}
+
+	if (ifp->flags & IFA_F_PERMANENT) {
 		spin_lock_bh(&ifp->lock);
 		addrconf_del_dad_timer(ifp);
 		ifp->flags |= IFA_F_TENTATIVE;
@@ -1584,7 +1694,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 		if (dad_failed)
 			ipv6_ifa_notify(0, ifp);
 		in6_ifa_put(ifp);
-	} else if (ifp->flags&IFA_F_TEMPORARY) {
+	} else if (ifp->flags & IFA_F_TEMPORARY) {
 		struct inet6_ifaddr *ifpub;
 		spin_lock_bh(&ifp->lock);
 		ifpub = ifp->ifpub;
@@ -1597,8 +1707,9 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp, int dad_failed)
 			spin_unlock_bh(&ifp->lock);
 		}
 		ipv6_del_addr(ifp);
-	} else
+	} else {
 		ipv6_del_addr(ifp);
+	}
 }
 
 static int addrconf_dad_end(struct inet6_ifaddr *ifp)
@@ -1627,14 +1738,20 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 	net_info_ratelimited("%s: IPv6 duplicate address %pI6c detected!\n",
 			     ifp->idev->dev->name, &ifp->addr);
 
+	spin_lock_bh(&ifp->lock);
+	++ifp->dad_retry_cnt;
+	spin_unlock_bh(&ifp->lock);
+
 	if (idev->cnf.accept_dad > 1 && !idev->cnf.disable_ipv6) {
 		struct in6_addr addr;
 
 		addr.s6_addr32[0] = htonl(0xfe800000);
 		addr.s6_addr32[1] = 0;
 
-		if (!ipv6_generate_eui64(addr.s6_addr + 8, idev->dev) &&
-		    ipv6_addr_equal(&ifp->addr, &addr)) {
+		if ((!ipv6_generate_eui64(addr.s6_addr + 8, idev->dev) &&
+		     ipv6_addr_equal(&ifp->addr, &addr)) ||
+		    (ifp->flags & IFA_F_PRIVSTBLADDR &&
+		     ifp->scope == IFA_LINK)) {
 			/* DAD failed for link-local based on MAC address */
 			idev->cnf.disable_ipv6 = 1;
 
@@ -1643,7 +1760,7 @@ void addrconf_dad_failure(struct inet6_ifaddr *ifp)
 		}
 	}
 
-	addrconf_dad_stop(ifp, 1);
+	addrconf_dad_stop(ifp, true);
 }
 
 /* Join to solicited addr multicast group. */
@@ -1845,6 +1962,101 @@ static int ipv6_inherit_eui64(u8 *eui, struct inet6_dev *idev)
 	return err;
 }
 
+static bool ipv6_valid_stblpriv_hostid(struct in6_addr *addr)
+{
+	/* Subnet-Router Anycast */
+	if ((addr->s6_addr32[2]|addr->s6_addr32[3]) == 0)
+		return false;
+	if (addr->s6_addr32[2] == htonl(0x02005eff)) {
+		/* Reserved IPv6 Interface Identifiers corresponding to the
+		 * IANA Ethernet Block
+		 */
+		if (addr->s6_addr32[3] >= htonl(0xfe000000) &&
+		    addr->s6_addr32[3] <= htonl(0xfe005212))
+			return false;
+		/* Proxy Mobile IPv6 */
+		if (addr->s6_addr32[3] == htonl(0xfe005213))
+			return false;
+		/* Reserved IPv6 Interface Identifiers corresponding to the
+		 * IANA Ethernet Block
+		 */
+		if (addr->s6_addr32[3] >= htonl(0xfe005214) &&
+		    addr->s6_addr32[3] <= htonl(0xfeffffff))
+			return false;
+	}
+	/* Reserved Subnet Anycast Addresses */
+	if (addr->s6_addr32[2] == htonl(0xfdffffff) &&
+	    addr->s6_addr32[3] >= htonl(0xffffff80) &&
+	    addr->s6_addr32[3] <= htonl(0xffffffff))
+		return false;
+	return true;
+}
+
+static int ipv6_generate_stblpriv_addr(struct in6_addr *addr,
+				       struct inet6_dev *idev, __u8 dad_count)
+{
+	/* move large allocations out of the stack */
+	static DEFINE_SPINLOCK(lock);
+	static __u32 workspace[SHA_WORKSPACE_WORDS];
+	static __u32 digest[SHA_DIGEST_WORDS];
+	static __u8 buffer[SHA_MESSAGE_BYTES];
+	const size_t buflen = sizeof(buffer);
+
+	struct net_device *dev = idev->dev;
+	struct net *net = dev_net(dev);
+	int version = net->ipv6.addrgen_mode;
+	int err;
+
+	spin_lock_bh(&lock);
+
+again:
+	sha_init(digest);
+	memset(workspace, 0, sizeof(workspace));
+
+	switch (version) {
+	case 1: {
+		int addr_len = min_t(int, dev->addr_len, buflen);
+
+		memcpy(buffer, addr, sizeof(*addr));
+		memset(buffer + sizeof(*addr), 0,
+		       buflen - sizeof(*addr));
+		sha_transform(digest, buffer, workspace);
+		memcpy(buffer, dev->dev_addr, addr_len);
+		memset(buffer + addr_len, 0,
+		       buflen - addr_len);
+		sha_transform(digest, buffer, workspace);
+		memcpy(buffer, &dad_count, sizeof(dad_count));
+		memset(buffer + sizeof(dad_count), 0,
+		       buflen - sizeof(dad_count));
+		sha_transform(digest, buffer, workspace);
+		memcpy(buffer, &net->ipv6.stbladdr_secret,
+		       sizeof(net->ipv6.stbladdr_secret));
+		memset(buffer + sizeof(net->ipv6.stbladdr_secret), 0,
+		       buflen - sizeof(net->ipv6.stbladdr_secret));
+		sha_transform(digest, buffer, workspace);
+		break;
+	}
+	default:
+		WARN_ON(!version);
+		pr_crit("%s: link-local generation mode %d unavailable. disabling ipv6, reboot needed.\n",
+			__func__, version);
+		idev->cnf.disable_ipv6 = 1;
+		err = -1;
+		goto out;
+	}
+
+	addr->s6_addr32[2] = htonl(digest[0]);
+	addr->s6_addr32[3] = htonl(digest[1]);
+	if (!ipv6_valid_stblpriv_hostid(addr)) {
+		++dad_count;
+		goto again;
+	}
+	err = 0;
+out:
+	spin_unlock_bh(&lock);
+	return err;
+}
+
 /* (re)generation of randomized interface identifier (RFC 3041 3.2, 3.5) */
 static void __ipv6_regen_rndid(struct inet6_dev *idev)
 {
@@ -2094,6 +2306,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 	int addr_type;
 	struct inet6_dev *in6_dev;
 	struct net *net = dev_net(dev);
+	u32 addr_flags = 0;
 
 	pinfo = (struct prefix_info *) opt;
 
@@ -2198,6 +2411,13 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 				       in6_dev->token.s6_addr + 8, 8);
 				read_unlock_bh(&in6_dev->lock);
 				tokenized = true;
+			} else if (net->ipv6.addrgen_mode) {
+				if (ipv6_generate_stblpriv_addr(&addr,
+								in6_dev, 0)) {
+					in6_dev_put(in6_dev);
+					return;
+				}
+				addr_flags |= IFA_F_PRIVSTBLADDR;
 			} else if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
 				   ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
 				in6_dev_put(in6_dev);
@@ -2216,12 +2436,11 @@ ok:
 
 		if (ifp == NULL && valid_lft) {
 			int max_addresses = in6_dev->cnf.max_addresses;
-			u32 addr_flags = 0;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 			if (in6_dev->cnf.optimistic_dad &&
 			    !net->ipv6.devconf_all->forwarding && sllao)
-				addr_flags = IFA_F_OPTIMISTIC;
+				addr_flags |= IFA_F_OPTIMISTIC;
 #endif
 
 			/* Do not allow to create too much of autoconfigured
@@ -2640,10 +2859,12 @@ static void init_loopback(struct net_device *dev)
 	}
 }
 
-static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr *addr)
+static void addrconf_add_linklocal(struct inet6_dev *idev,
+				   const struct in6_addr *addr,
+				   u32 addr_flags)
 {
 	struct inet6_ifaddr *ifp;
-	u32 addr_flags = IFA_F_PERMANENT;
+	addr_flags |= IFA_F_PERMANENT;
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 	if (idev->cnf.optimistic_dad &&
@@ -2651,7 +2872,6 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr
 		addr_flags |= IFA_F_OPTIMISTIC;
 #endif
 
-
 	ifp = ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags, 0, 0);
 	if (!IS_ERR(ifp)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
@@ -2662,6 +2882,7 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr
 
 static void addrconf_dev_config(struct net_device *dev)
 {
+	struct net *net = dev_net(dev);
 	struct in6_addr addr;
 	struct inet6_dev *idev;
 
@@ -2685,8 +2906,14 @@ static void addrconf_dev_config(struct net_device *dev)
 	memset(&addr, 0, sizeof(struct in6_addr));
 	addr.s6_addr32[0] = htonl(0xFE800000);
 
-	if (ipv6_generate_eui64(addr.s6_addr + 8, dev) == 0)
-		addrconf_add_linklocal(idev, &addr);
+	if (net->ipv6.addrgen_mode) {
+		if (ipv6_generate_stblpriv_addr(&addr, idev, 0) == 0)
+			addrconf_add_linklocal(idev, &addr,
+					       IFA_F_PRIVSTBLADDR);
+	} else {
+		if (ipv6_generate_eui64(addr.s6_addr + 8, dev) == 0)
+			addrconf_add_linklocal(idev, &addr, 0);
+	}
 }
 
 #if IS_ENABLED(CONFIG_IPV6_SIT)
@@ -2712,7 +2939,7 @@ static void addrconf_sit_config(struct net_device *dev)
 
 		ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
 		if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
-			addrconf_add_linklocal(idev, &addr);
+			addrconf_add_linklocal(idev, &addr, 0);
 		return;
 	}
 
@@ -2738,7 +2965,7 @@ static void addrconf_gre_config(struct net_device *dev)
 
 	ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
 	if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
-		addrconf_add_linklocal(idev, &addr);
+		addrconf_add_linklocal(idev, &addr, 0);
 }
 #endif
 
@@ -2748,7 +2975,7 @@ ipv6_inherit_linklocal(struct inet6_dev *idev, struct net_device *link_dev)
 	struct in6_addr lladdr;
 
 	if (!ipv6_get_lladdr(link_dev, &lladdr, IFA_F_TENTATIVE)) {
-		addrconf_add_linklocal(idev, &lladdr);
+		addrconf_add_linklocal(idev, &lladdr, 0);
 		return 0;
 	}
 	return -1;
@@ -2784,6 +3011,13 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 				break;
 			}
 
+			if (dev_net(dev)->ipv6.addrgen_mode &&
+			    !dev_net(dev)->ipv6.stbladdr_secret) {
+				pr_info("ADDRCONF(NETDEV_UP): %s: no stable secret configured for stable privacy address generation\n",
+					dev->name);
+				break;
+			}
+
 			if (!idev && dev->mtu >= IPV6_MIN_MTU)
 				idev = ipv6_add_dev(dev);
 
@@ -2797,6 +3031,10 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 				break;
 			}
 
+			if (dev_net(dev)->ipv6.addrgen_mode &&
+			    !dev_net(dev)->ipv6.stbladdr_secret)
+				break;
+
 			if (idev) {
 				if (idev->if_flags & IF_READY)
 					/* device is already configured. */
@@ -3137,7 +3375,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp)
 		 * - otherwise, kill it.
 		 */
 		in6_ifa_hold(ifp);
-		addrconf_dad_stop(ifp, 0);
+		addrconf_dad_stop(ifp, false);
 		return;
 	}
 
@@ -4159,6 +4397,8 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
 	array[DEVCONF_NDISC_NOTIFY] = cnf->ndisc_notify;
 	array[DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
+	array[DEVCONF_IDGEN_RETRIES] = cnf->idgen_retries;
+	array[DEVCONF_IDGEN_DELAY] = cnf->idgen_delay;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -4617,6 +4857,50 @@ static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 
 #ifdef CONFIG_SYSCTL
 
+int addrconf_sysctl_stbladdr_secret_change(struct ctl_table *ctl, int write,
+					   void __user *buffer, size_t *lenp,
+					   loff_t *ppos)
+{
+	struct net *net = ctl->extra2;
+	struct ctl_table lctl;
+	unsigned long secret = *(unsigned long *)ctl->data;
+	loff_t pos = *ppos;
+	int ret;
+
+	if (write && *(unsigned long *)ctl->data)
+		return -EIO;
+
+	if (!net->ipv6.addrgen_mode)
+		return -EIO;
+
+	lctl = *ctl;
+	lctl.data = &secret;
+	lctl.extra2 = NULL;
+	ret = proc_doulongvec_minmax(&lctl, write, buffer, lenp, ppos);
+	if (write) {
+		struct net_device *dev;
+
+		if (!rtnl_trylock())
+			return restart_syscall();
+
+		*(unsigned long *)ctl->data = secret;
+
+		if (secret) {
+			for_each_netdev(net, dev) {
+				struct netdev_notifier_info info;
+
+				netdev_notifier_info_init(&info, dev);
+				addrconf_notify(NULL, NETDEV_UP, &info);
+			}
+		}
+
+		rtnl_unlock();
+	}
+	if (ret)
+		*ppos = pos;
+	return ret;
+}
+
 static
 int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
@@ -4978,6 +5262,20 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec
 		},
 		{
+			.procname	= "idgen_retries",
+			.data		= &ipv6_devconf.idgen_retries,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
+		{
+			.procname	= "idgen_delay",
+			.data		= &ipv6_devconf.idgen_delay,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec_ms_jiffies,
+		},
+		{
 			/* sentinel */
 		}
 	},
@@ -5120,6 +5418,13 @@ int __init addrconf_init(void)
 {
 	int i, err;
 
+	if (addrgen_mode_param != -1)
+		init_net.ipv6.addrgen_mode = addrgen_mode_param;
+	else if (IS_ENABLED(CONFIG_IPV6_ADDRESS_GEN_MODE_STABLE_PRIVACY_V1))
+		init_net.ipv6.addrgen_mode = 1;
+	else /* if (IS_ENABLED(CONFIG_IPV6_ADDRESS_GEN_MODE_EUI64)) */
+		init_net.ipv6.addrgen_mode = 0;
+
 	err = ipv6_addr_label_init();
 	if (err < 0) {
 		pr_crit("%s: cannot initialize default policy table: %d\n",
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 107b2f1..4811b9d 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -24,6 +24,21 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "stable_address_secret",
+		.data		= &init_net.ipv6.stbladdr_secret,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0600,
+		.proc_handler	= addrconf_sysctl_stbladdr_secret_change,
+		.extra2		= &init_net
+	},
+	{
+		.procname	= "address_generation_mode",
+		.data		= &init_net.ipv6.addrgen_mode,
+		.maxlen		= sizeof(int),
+		.mode		= 0444,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
@@ -52,6 +67,13 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 		goto out;
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
 
+	/* new namespaces do not inherit the stbladdr_secret */
+	net->ipv6.stbladdr_secret = 0UL;
+	ipv6_table[1].data = &net->ipv6.stbladdr_secret;
+	ipv6_table[1].extra2 = net;
+
+	ipv6_table[2].data = &net->ipv6.addrgen_mode;
+
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
 		goto out_ipv6_table;
-- 
1.8.3.1
