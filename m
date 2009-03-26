From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 26 Mar 2009 18:41:35 +0300
Message-ID: <20090326154135.GA30712@ioremap.net>
References: <20090326141405.GA25404@ioremap.net> <49CB8EC6.6070705@trash.net> <20090326145946.GA28563@ioremap.net> <49CB9A57.6030903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netgear.net.ru ([195.178.208.66]:50462 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756538AbZCZPlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 11:41:55 -0400
Content-Disposition: inline
In-Reply-To: <49CB9A57.6030903@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2009 at 04:08:07PM +0100, Patrick McHardy (kaber@trash.net) wrote:
> nfnetlink also supports notifications. Please get rid of this,
> it should be no problem to resurrect the necessary parts later
> if this is desired.

Ok, patch below does not contain it.

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 7d8e045..71babbd 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -46,7 +46,8 @@ struct nfgenmsg {
 #define NFNL_SUBSYS_CTNETLINK_EXP	2
 #define NFNL_SUBSYS_QUEUE		3
 #define NFNL_SUBSYS_ULOG		4
-#define NFNL_SUBSYS_COUNT		5
+#define NFNL_SUBSYS_OSF			5
+#define NFNL_SUBSYS_COUNT		6
 
 #ifdef __KERNEL__
 
diff --git a/include/linux/netfilter/xt_osf.h b/include/linux/netfilter/xt_osf.h
new file mode 100644
index 0000000..11903a9
--- /dev/null
+++ b/include/linux/netfilter/xt_osf.h
@@ -0,0 +1,119 @@
+/*
+ * Copyright (c) 2003+ Evgeniy Polyakov <johnpol@2ka.mxt.ru>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#ifndef _XT_OSF_H
+#define _XT_OSF_H
+
+#define MAXGENRELEN		32
+#define MAXDETLEN		64
+
+#define XT_OSF_GENRE		(1<<0)
+#define	XT_OSF_TTL		(1<<1)
+#define XT_OSF_LOG		(1<<2)
+#define XT_OSF_UNUSED		(1<<3)
+#define XT_OSF_CONNECTOR	(1<<4)
+#define XT_OSF_INVERT		(1<<5)
+
+#define XT_OSF_LOGLEVEL_ALL	0
+#define XT_OSF_LOGLEVEL_FIRST	1
+#define XT_OSF_LOGLEVEL_ALL_KNOWN	2
+
+#define XT_OSF_TTL_TRUE		0	/* True ip and fingerprint TTL comparison */
+#define XT_OSF_TTL_LESS		1	/* Check if ip TTL is less than fingerprint one */
+#define XT_OSF_TTL_NOCHECK	2	/* Do not compare ip and fingerprint TTL at all */
+
+struct xt_osf_info {
+	char			genre[MAXGENRELEN];
+	__u32			len;
+	__u32			flags;
+	__u32			loglevel;
+	__u32			ttl;
+};
+
+/*
+ * Wildcard MSS (kind of).
+ * It is used to implement a state machine for the different wildcard values
+ * of the MSS and window sizes.
+ */
+struct xt_osf_wc {
+	__u32			wc;
+	__u32			val;
+};
+
+/*
+ * This struct represents IANA options
+ * http://www.iana.org/assignments/tcp-parameters
+ */
+struct xt_osf_opt {
+	__u16			kind, length;
+	struct xt_osf_wc	wc;
+};
+
+struct xt_osf_user_finger {
+	struct xt_osf_wc	wss;
+
+	__u8			ttl, df;
+	__u16			ss, mss;
+	__u16			opt_num;
+
+	char			genre[MAXGENRELEN];
+	char			version[MAXGENRELEN];
+	char			subtype[MAXGENRELEN];
+
+	/* MAX_IPOPTLEN is maximum if all options are NOPs or EOLs */
+	struct xt_osf_opt	opt[MAX_IPOPTLEN];
+};
+
+struct xt_osf_nlmsg {
+	struct xt_osf_user_finger	f;
+	struct iphdr		ip;
+	struct tcphdr		tcp;
+};
+
+/* Defines for IANA option kinds */
+
+enum iana_options {
+	OSFOPT_EOL = 0,		/* End of options */
+	OSFOPT_NOP, 		/* NOP */
+	OSFOPT_MSS, 		/* Maximum segment size */
+	OSFOPT_WSO, 		/* Window scale option */
+	OSFOPT_SACKP,		/* SACK permitted */
+	OSFOPT_SACK,		/* SACK */
+	OSFOPT_ECHO,
+	OSFOPT_ECHOREPLY,
+	OSFOPT_TS,		/* Timestamp option */
+	OSFOPT_POCP,		/* Partial Order Connection Permitted */
+	OSFOPT_POSP,		/* Partial Order Service Profile */
+
+	/* Others are not used in the current OSF */
+	OSFOPT_EMPTY = 255,
+};
+
+enum xt_osf_msg_types {
+	OSF_MSG_SETUP,
+	OSF_MSG_MAX,
+};
+
+enum xt_osf_attr_type {
+	OSF_ATTR_UNSPEC,
+	OSF_ATTR_FINGER,
+	OSF_ATTR_MAX,
+};
+
+#endif				/* _XT_OSF_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index c2bac9c..1e74c97 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -853,6 +853,19 @@ config NETFILTER_XT_MATCH_U32
 
 	  Details and examples are in the kernel module source.
 
+config NETFILTER_XT_MATCH_OSF
+	tristate '"osf" Passive OS fingerprint match'
+	depends on NETFILTER_ADVANCED
+	help
+	  This option selects the Passive OS Fingerprinting match module
+	  that allows to passively match the remote operating system by
+	  analyzing incoming TCP SYN packets.
+
+	  Rules and loading software can be downloaded from
+	  http://www.ioremap.net/projects/osf
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 endif # NETFILTER_XTABLES
 
 endmenu
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index da3d909..96b7754 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -73,6 +73,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_LIMIT) += xt_limit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MAC) += xt_mac.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MARK) += xt_mark.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_MULTIPORT) += xt_multiport.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_OSF) += xt_osf.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_OWNER) += xt_owner.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_PHYSDEV) += xt_physdev.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_PKTTYPE) += xt_pkttype.o
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
new file mode 100644
index 0000000..65e94ad
--- /dev/null
+++ b/net/netfilter/xt_osf.c
@@ -0,0 +1,469 @@
+/*
+ * Copyright (c) 2003+ Evgeniy Polyakov <zbr@ioremap.net>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+
+#include <linux/connector.h>
+#include <linux/if.h>
+#include <linux/inetdevice.h>
+#include <linux/ip.h>
+#include <linux/list.h>
+#include <linux/percpu.h>
+#include <linux/rculist.h>
+#include <linux/smp.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/tcp.h>
+#include <linux/types.h>
+
+#include <net/ip.h>
+#include <net/tcp.h>
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_osf.h>
+
+struct xt_osf_finger {
+	struct rcu_head			rcu_head;
+	struct list_head		finger_entry;
+	struct xt_osf_user_finger	finger;
+};
+
+enum osf_fmatch_states {
+	/* Packet does not match the fingerprint */
+	FMATCH_WRONG = 0,
+	/* Packet matches the fingerprint */
+	FMATCH_OK,
+	/* Options do not match the fingerprint, but header does */
+	FMATCH_OPT_WRONG,
+};
+
+struct xt_osf_finger_storage
+{
+	struct list_head		finger_list;
+	spinlock_t			finger_lock;
+};
+
+/*
+ * Indexed by dont-fragment bit.
+ * It is the only constant value in the fingerprint.
+ */
+struct xt_osf_finger_storage xt_osf_fingers[2];
+
+struct xt_osf_message {
+	struct cn_msg		cmsg;
+	struct xt_osf_nlmsg	nlmsg;
+};
+
+static const struct nla_policy xt_osf_policy[OSF_ATTR_MAX + 1] = {
+	[OSF_ATTR_FINGER]	= { .len = sizeof(struct xt_osf_user_finger) },
+};
+
+static void xt_osf_finger_free_rcu(struct rcu_head *rcu_head)
+{
+	struct xt_osf_finger *f = container_of(rcu_head, struct xt_osf_finger, rcu_head);
+
+	kfree(f);
+}
+
+static int xt_osf_setup_callback(struct sock *ctnl, struct sk_buff *skb,
+			struct nlmsghdr *nlh, struct nlattr *osf_attrs[])
+{
+	struct xt_osf_user_finger *f;
+	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
+	u16 delete = ntohs(nfmsg->res_id);
+	struct xt_osf_finger *kf = NULL, *sf;
+	struct xt_osf_finger_storage *st;
+	int err;
+
+	if (!osf_attrs[OSF_ATTR_FINGER])
+		return -EINVAL;
+
+	f = nla_data(osf_attrs[OSF_ATTR_FINGER]);
+	st = &xt_osf_fingers[!!f->df];
+
+	/*
+	 * If 'delete' is set to 0 then we add attached fingerprint,
+	 * otherwise remove, and in this case we do not need to allocate data.
+	 */
+	if (!delete) {
+		kf = kmalloc(sizeof(struct xt_osf_finger), GFP_KERNEL);
+		if (!kf)
+			return -ENOMEM;
+
+		memcpy(&kf->finger, f, sizeof(struct xt_osf_user_finger));
+	}
+
+	err = -ENOENT;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(sf, &st->finger_list, finger_entry) {
+		if (memcmp(&sf->finger, f, sizeof(struct xt_osf_user_finger)))
+			continue;
+
+		if (delete) {
+			spin_lock_bh(&st->finger_lock);
+			list_del_rcu(&sf->finger_entry);
+			spin_unlock_bh(&st->finger_lock);
+			call_rcu(&sf->rcu_head, xt_osf_finger_free_rcu);
+		} else {
+			kfree(kf);
+			kf = NULL;
+		}
+
+		err = 0;
+		break;
+	}
+
+	if (kf) {
+		spin_lock_bh(&st->finger_lock);
+		list_add_tail_rcu(&kf->finger_entry, &st->finger_list);
+		spin_unlock_bh(&st->finger_lock);
+#if 0
+		printk(KERN_INFO "Added rule for %s:%s:%s.\n",
+			kf->finger.genre, kf->finger.version, kf->finger.subtype);
+#endif
+	}
+	rcu_read_unlock();
+
+	return 0;
+}
+
+static const struct nfnl_callback xt_osf_nfnetlink_callbacks[OSF_MSG_MAX] = {
+	[OSF_MSG_SETUP]	= {
+		.call		= xt_osf_setup_callback,
+		.attr_count	= OSF_ATTR_MAX,
+		.policy		= xt_osf_policy,
+	},
+};
+
+static const struct nfnetlink_subsystem xt_osf_nfnetlink = {
+	.name			= "osf",
+	.subsys_id		= NFNL_SUBSYS_OSF,
+	.cb_count		= OSF_MSG_MAX,
+	.cb			= xt_osf_nfnetlink_callbacks,
+};
+
+static inline int xt_osf_ttl(const struct sk_buff *skb, const struct xt_osf_info *info,
+			    unsigned char f_ttl)
+{
+	const struct iphdr *ip = ip_hdr(skb);
+
+	if (info->flags & XT_OSF_TTL) {
+		if (info->ttl == XT_OSF_TTL_TRUE)
+			return ip->ttl == f_ttl;
+		if (info->ttl == XT_OSF_TTL_NOCHECK)
+			return 1;
+		else if (ip->ttl <= f_ttl)
+			return 1;
+		else {
+			struct in_device *in_dev = in_dev_get(skb->dev);
+			int ret = 0;
+
+			for_ifa(in_dev) {
+				if (inet_ifa_match(ip->saddr, ifa)) {
+					ret = (ip->ttl == f_ttl);
+					break;
+				}
+			}
+			endfor_ifa(in_dev);
+
+			in_dev_put(in_dev);
+			return ret;
+		}
+	}
+	
+	return ip->ttl == f_ttl;
+}
+
+static bool xt_osf_match_packet(const struct sk_buff *skb,
+		const struct xt_match_param *p)
+{
+	const struct xt_osf_info *info = p->matchinfo;
+	const struct iphdr *ip = ip_hdr(skb);
+	const struct tcphdr *tcp;
+	struct tcphdr _tcph;
+	int fmatch = FMATCH_WRONG, fcount = 0;
+	unsigned int optsize = 0, check_WSS = 0;
+	u16 window, totlen, mss = 0;
+	bool df;
+	const unsigned char *optp = NULL, *_optp = NULL;
+	unsigned char opts[MAX_IPOPTLEN];
+	const struct xt_osf_finger *kf;
+	const struct xt_osf_user_finger *f;
+	const struct xt_osf_finger_storage *st;
+
+	if (!info)
+		return false;
+
+	tcp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(struct tcphdr), &_tcph);
+	if (!tcp)
+		return false;
+
+	if (!tcp->syn)
+		return false;
+
+	totlen = ntohs(ip->tot_len);
+	df = ntohs(ip->frag_off) & IP_DF;
+	window = ntohs(tcp->window);
+
+	if (tcp->doff * 4 > sizeof(struct tcphdr)) {
+		optsize = tcp->doff * 4 - sizeof(struct tcphdr);
+
+		if (optsize > sizeof(opts))
+			optsize = sizeof(opts);
+
+		_optp = optp = skb_header_pointer(skb, ip_hdrlen(skb) + sizeof(struct tcphdr), 
+				optsize, opts);
+	}
+
+	st = &xt_osf_fingers[df];
+	
+	rcu_read_lock();
+	list_for_each_entry_rcu(kf, &st->finger_list, finger_entry) {
+		f = &kf->finger;
+
+		if (!(info->flags & XT_OSF_LOG) && strcmp(info->genre, f->genre))
+			continue;
+
+		optp = _optp;
+		fmatch = FMATCH_WRONG;
+
+		if (totlen == f->ss && xt_osf_ttl(skb, info, f->ttl)) {
+			int foptsize, optnum;
+
+			check_WSS = 0;
+
+			switch (f->wss.wc) {
+			case 0:
+				check_WSS = 0;
+				break;
+			case 'S':
+				check_WSS = 1;
+				break;
+			case 'T':
+				check_WSS = 2;
+				break;
+			case '%':
+				check_WSS = 3;
+				break;
+			default:
+				check_WSS = 4;
+				break;
+			}
+			if (check_WSS == 4)
+				continue;
+
+			/* Check options */
+
+			foptsize = 0;
+			for (optnum = 0; optnum < f->opt_num; ++optnum)
+				foptsize += f->opt[optnum].length;
+
+			if (foptsize > MAX_IPOPTLEN || optsize > MAX_IPOPTLEN || optsize != foptsize)
+				continue;
+
+			for (optnum = 0; optnum < f->opt_num; ++optnum) {
+				if (f->opt[optnum].kind == (*optp)) {
+					__u32 len = f->opt[optnum].length;
+					const __u8 *optend = optp + len;
+					int loop_cont = 0;
+
+					fmatch = FMATCH_OK;
+
+					switch (*optp) {
+					case OSFOPT_MSS:
+						mss = optp[3];
+						mss <<= 8;
+						mss |= optp[2];
+
+						mss = ntohs(mss);
+						break;
+					case OSFOPT_TS:
+						loop_cont = 1;
+						break;
+					}
+
+					optp = optend;
+				} else
+					fmatch = FMATCH_OPT_WRONG;
+
+				if (fmatch != FMATCH_OK)
+					break;
+			}
+
+			if (fmatch != FMATCH_OPT_WRONG) {
+				fmatch = FMATCH_WRONG;
+
+				switch (check_WSS) {
+				case 0:
+					if (f->wss.val == 0 || window == f->wss.val)
+						fmatch = FMATCH_OK;
+					break;
+				case 1:	/* MSS */
+#define SMART_MSS_1	1460
+#define SMART_MSS_2	1448
+					if (window == f->wss.val * mss ||
+					    window == f->wss.val * SMART_MSS_1 ||
+					    window == f->wss.val * SMART_MSS_2)
+						fmatch = FMATCH_OK;
+					break;
+				case 2:	/* MTU */
+					if (window == f->wss.val * (mss + 40) ||
+					    window == f->wss.val * (SMART_MSS_1 + 40) ||
+					    window == f->wss.val * (SMART_MSS_2 + 40))
+						fmatch = FMATCH_OK;
+					break;
+				case 3:	/* MOD */
+					if ((window % f->wss.val) == 0)
+						fmatch = FMATCH_OK;
+					break;
+				}
+			}
+			
+			if (fmatch != FMATCH_OK)
+				continue;
+
+			fcount++;
+			if (info->flags & XT_OSF_LOG)
+				printk(KERN_INFO "%s [%s:%s] : "
+					"%pi4:%d -> %pi4:%d hops=%d\n",
+					f->genre, f->version, f->subtype, 
+					&ip->saddr, ntohs(tcp->source), 
+					&ip->daddr, ntohs(tcp->dest), 
+					f->ttl - ip->ttl);
+
+			if ((info->flags & XT_OSF_LOG) &&
+			    info->loglevel == XT_OSF_LOGLEVEL_FIRST)
+				break;
+		}
+	}
+	rcu_read_unlock();
+
+	if (!fcount && (info->flags & (XT_OSF_LOG | XT_OSF_CONNECTOR))) {
+		unsigned int i;
+		struct xt_osf_user_finger fg;
+
+		memset(&fg, 0, sizeof(fg));
+#if 1
+		if (info->flags & XT_OSF_LOG) {
+			if (info->loglevel != XT_OSF_LOGLEVEL_ALL_KNOWN)
+				printk(KERN_INFO "Unknown: win: %u, mss: %u, "
+					"totlen: %u, df: %d, ttl: %u : ",
+					window, mss, totlen, df, ip->ttl);
+			else
+				printk(KERN_INFO "");
+			if (_optp) {
+				optp = _optp;
+				for (i = 0; i < optsize; i++)
+					printk("%02X ", optp[i]);
+			}
+
+			printk("%pi4:%u -> %pi4:%u\n",
+			     &ip->saddr, ntohs(tcp->source),
+			     &ip->daddr, ntohs(tcp->dest));
+		}
+#endif
+	}
+
+	if (fcount)
+		fmatch = FMATCH_OK;
+
+	return fmatch == FMATCH_OK;
+}
+
+static struct xt_match xt_osf_match = {
+	.name 		= "osf",
+	.revision	= 0,
+	.family		= NFPROTO_IPV4,
+	.proto		= IPPROTO_TCP,
+	.hooks      	= (1 << NF_INET_LOCAL_IN) | (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_FORWARD),
+	.match 		= xt_osf_match_packet,
+	.matchsize	= sizeof(struct xt_osf_info),
+	.me		= THIS_MODULE,
+};
+
+static int __init xt_osf_init(void)
+{
+	int err = -EINVAL;
+	int i;
+
+	for (i=0; i<ARRAY_SIZE(xt_osf_fingers); ++i) {
+		struct xt_osf_finger_storage *st = &xt_osf_fingers[i];
+
+		INIT_LIST_HEAD(&st->finger_list);
+		spin_lock_init(&st->finger_lock);
+	}
+
+	err = nfnetlink_subsys_register(&xt_osf_nfnetlink);
+	if (err < 0) {
+		printk(KERN_ERR "Failed (%d) to register OSF nsfnetlink helper.\n", err);
+		goto err_out_exit;
+	}
+
+	err = xt_register_match(&xt_osf_match);
+	if (err) {
+		printk(KERN_ERR "Failed (%d) to register OS fingerprint "
+				"matching module.\n", err);
+		goto err_out_remove;
+	}
+
+	printk(KERN_INFO "Started passive OS fingerprint matching module.\n");
+
+	return 0;
+
+err_out_remove:
+	nfnetlink_subsys_unregister(&xt_osf_nfnetlink);
+err_out_exit:
+	return err;
+}
+
+static void __exit xt_osf_fini(void)
+{
+	struct xt_osf_finger *f;
+	int i;
+
+	nfnetlink_subsys_unregister(&xt_osf_nfnetlink);
+	xt_unregister_match(&xt_osf_match);
+
+	rcu_read_lock();
+	for (i=0; i<ARRAY_SIZE(xt_osf_fingers); ++i) {
+		struct xt_osf_finger_storage *st = &xt_osf_fingers[i];
+
+		list_for_each_entry_rcu(f, &st->finger_list, finger_entry) {
+			list_del_rcu(&f->finger_entry);
+			call_rcu(&f->rcu_head, xt_osf_finger_free_rcu);
+		}
+	}
+	rcu_read_unlock();
+
+	rcu_barrier();
+
+	printk(KERN_INFO "Passive OS fingerprint matching module finished.\n");
+}
+
+module_init(xt_osf_init);
+module_exit(xt_osf_fini);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Evgeniy Polyakov <zbr@ioremap.net>");
+MODULE_DESCRIPTION("Passive OS fingerprint matching.");
+MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_OSF);


-- 
	Evgeniy Polyakov
