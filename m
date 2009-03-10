From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Passive OS fingerprint xtables match.
Date: Tue, 10 Mar 2009 18:13:57 +0300
Message-ID: <20090310151357.GA10658@ioremap.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:39343 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961AbZCJPOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 11:14:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi.

Passive OS fingerprinting netfilter module allows to passively detect
remote OS and perform various netfilter actions based on that knowledge.
This module compares some data (WS, MSS, options and it's order, ttl, df
and others) from packets with SYN bit set with dynamically loaded OS
fingerprints.

Fingerprint matching rules can be downloaded from OpenBSD source tree
and loaded via netlink connector into the kernel via special util found
in archive. It will also listen for events about matching packets.

Archive also contains library file (also attached), which was shipped
with iptables extensions some time ago (at least when ipt_osf existed
in patch-o-matic).

This release implements suggestions found during the code review like
codying style, structure split and tighter packing, bool and %pi4
usage and similar changes.

Fingerprints can be downloaded from
http://www.openbsd.org/cgi-bin/cvsweb/src/etc/pf.os

Example usage:
# modrpobe xt_osf
# ./ucon_osf -f ./pf.os
^C Daemon will listen for incoming match events 
-d switch removes fingerprints
# iptables -I INPUT -j ACCEPT -p tcp -m osf --genre Linux --log 0 --ttl 2 --connector

You will find something like this in the syslog:
ipt_osf: Windows [2000:SP3:Windows XP Pro SP1, 2000 SP3]: 11.22.33.55:4024 -> 11.22.33.44:139

Please consider for inclusion.
Thank you.

Passive OS fingerprint homepage (archives, examples):
http://www.ioremap.net/projects/osf

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/include/linux/connector.h b/include/linux/connector.h
index 34f2789..da6595e 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -39,6 +39,8 @@
 #define CN_IDX_V86D			0x4
 #define CN_VAL_V86D_UVESAFB		0x1
 #define CN_IDX_BB			0x5	/* BlackBoard, from the TSP GPL sampling framework */
+#define CN_IDX_OSF			0x6	/* Passive OS fingerprint iptables module */
+#define CN_VAL_OSF			0x0
 
 #define CN_NETLINK_USERS		6
 
diff --git a/include/linux/netfilter/xt_osf.h b/include/linux/netfilter/xt_osf.h
new file mode 100644
index 0000000..a7696be
--- /dev/null
+++ b/include/linux/netfilter/xt_osf.h
@@ -0,0 +1,110 @@
+/*
+ * xt_osf.h
+ *
+ * Copyright (c) 2003 Evgeniy Polyakov <johnpol@2ka.mipt.ru>
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
+#ifndef _IPT_OSF_H
+#define _IPT_OSF_H
+
+#define MAXGENRELEN		32
+#define MAXDETLEN		64
+
+#define IPT_OSF_GENRE		(1<<0)
+#define	IPT_OSF_TTL		(1<<1)
+#define IPT_OSF_LOG		(1<<2)
+#define IPT_OSF_UNUSED		(1<<3)
+#define IPT_OSF_CONNECTOR	(1<<4)
+#define IPT_OSF_INVERT		(1<<5)
+
+#define IPT_OSF_LOGLEVEL_ALL	0
+#define IPT_OSF_LOGLEVEL_FIRST	1
+#define IPT_OSF_LOGLEVEL_ALL_KNOWN	2
+
+#define IPT_OSF_TTL_TRUE	0	/* True ip and fingerprint TTL comparison */
+#define IPT_OSF_TTL_LESS	1	/* Check if ip TTL is less than fingerprint one */
+#define IPT_OSF_TTL_NOCHECK	2	/* Do not compare ip and fingerprint TTL at all */
+
+struct ipt_osf_info {
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
+struct ipt_osf_wc {
+	__u32			wc;
+	__u32			val;
+};
+
+/*
+ * This struct represents IANA options
+ * http://www.iana.org/assignments/tcp-parameters
+ */
+struct ipt_osf_opt {
+	__u16			kind, length;
+	struct ipt_osf_wc	wc;
+};
+
+struct ipt_osf_user_finger {
+	struct ipt_osf_wc	wss;
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
+	struct ipt_osf_opt	opt[MAX_IPOPTLEN];
+};
+
+struct ipt_osf_nlmsg {
+	struct ipt_osf_user_finger	f;
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
+#endif				/* _IPT_OSF_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index c2bac9c..34aafec 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -853,6 +853,19 @@ config NETFILTER_XT_MATCH_U32
 
 	  Details and examples are in the kernel module source.
 
+config NETFILTER_XT_MATCH_OSF
+	tristate 'Passive OS fingerprint match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  Passive OS fingerprint matching module. Allows to passively match
+	  remote operation system analyzing incoming TCP packets with SYN
+	  bit set.
+
+	  You should download and install rule loading software from
+	  http://www.ioremap.net/projects/osf
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 endif # NETFILTER_XTABLES
 
 endmenu
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index da3d909..ec3a6e0 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -89,6 +89,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_STRING) += xt_string.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_TCPMSS) += xt_tcpmss.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_TIME) += xt_time.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_U32) += xt_u32.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_OSF) += xt_osf.o
 
 # IPVS
 obj-$(CONFIG_IP_VS) += ipvs/
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
new file mode 100644
index 0000000..f8b5a16
--- /dev/null
+++ b/net/netfilter/xt_osf.c
@@ -0,0 +1,475 @@
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
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter/xt_osf.h>
+
+struct ipt_osf_finger {
+	struct rcu_head			rcu_head;
+	struct list_head		finger_entry;
+	struct ipt_osf_user_finger	finger;
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
+struct ipt_osf_finger_storage
+{
+	struct list_head		finger_list;
+	spinlock_t			finger_lock;
+};
+
+/*
+ * Indexed by dont-fragment bit.
+ * It is the only constant value in the fingerprint.
+ */
+struct ipt_osf_finger_storage ipt_osf_fingers[2];
+
+struct ipt_osf_message {
+	struct cn_msg		cmsg;
+	struct ipt_osf_nlmsg	nlmsg;
+};
+
+static DEFINE_PER_CPU(struct ipt_osf_message, ipt_osf_mbuf);
+
+static struct cb_id cn_osf_id = { CN_IDX_OSF, CN_VAL_OSF };
+static u32 osf_seq;
+
+static void ipt_osf_send_connector(struct ipt_osf_user_finger *f,
+				   const struct sk_buff *skb)
+{
+	struct ipt_osf_message *msg = &per_cpu(ipt_osf_mbuf, smp_processor_id());
+	struct ipt_osf_nlmsg *data = &msg->nlmsg;
+	struct iphdr *iph = ip_hdr(skb);
+	struct tcphdr *tcph = tcp_hdr(skb);
+
+	memcpy(&msg->cmsg.id, &cn_osf_id, sizeof(struct cn_msg));
+	msg->cmsg.seq = osf_seq++;
+	msg->cmsg.ack = 0;
+	msg->cmsg.len = sizeof(struct ipt_osf_nlmsg);
+
+	memcpy(&data->f, f, sizeof(struct ipt_osf_user_finger));
+	memcpy(&data->ip, iph, sizeof(struct iphdr));
+	memcpy(&data->tcp, tcph, sizeof(struct tcphdr));
+
+	cn_netlink_send(&msg->cmsg, CN_IDX_OSF, GFP_ATOMIC);
+}
+
+static inline int ipt_osf_ttl(const struct sk_buff *skb, struct ipt_osf_info *info,
+			    unsigned char f_ttl)
+{
+	struct iphdr *ip = ip_hdr(skb);
+
+	if (info->flags & IPT_OSF_TTL) {
+		if (info->ttl == IPT_OSF_TTL_TRUE)
+			return (ip->ttl == f_ttl);
+		if (info->ttl == IPT_OSF_TTL_NOCHECK)
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
+	return (ip->ttl == f_ttl);
+}
+
+static bool ipt_osf_match_packet(const struct sk_buff *skb,
+		const struct xt_match_param *p)
+{
+	struct ipt_osf_info *info = (struct ipt_osf_info *)p->matchinfo;
+	struct iphdr *ip;
+	struct tcphdr _tcph, *tcp;
+	int fmatch = FMATCH_WRONG, fcount = 0;
+	unsigned int optsize = 0, check_WSS = 0;
+	u16 window, totlen, mss = 0;
+	bool df;
+	unsigned char *optp = NULL, *_optp = NULL;
+	unsigned char opts[MAX_IPOPTLEN];
+	struct ipt_osf_finger *kf;
+	struct ipt_osf_user_finger *f;
+	struct ipt_osf_finger_storage *st;
+
+	if (!info)
+		return false;
+
+	ip = ip_hdr(skb);
+	if (!ip)
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
+	st = &ipt_osf_fingers[df];
+	
+	rcu_read_lock();
+	list_for_each_entry_rcu(kf, &st->finger_list, finger_entry) {
+		f = &kf->finger;
+
+		if (!(info->flags & IPT_OSF_LOG) && strcmp(info->genre, f->genre))
+			continue;
+
+		optp = _optp;
+		fmatch = FMATCH_WRONG;
+
+		if (totlen == f->ss && ipt_osf_ttl(skb, info, f->ttl)) {
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
+					__u8 *optend = optp + len;
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
+			if (info->flags & IPT_OSF_LOG)
+				printk(KERN_INFO "%s [%s:%s] : "
+					"%pi4:%d -> %pi4:%d hops=%d\n",
+					f->genre, f->version, f->subtype, 
+					&ip->saddr, ntohs(tcp->source), 
+					&ip->daddr, ntohs(tcp->dest), 
+					f->ttl - ip->ttl);
+
+			if (info->flags & IPT_OSF_CONNECTOR)
+				ipt_osf_send_connector(f, skb);
+
+			if ((info->flags & IPT_OSF_LOG) &&
+			    info->loglevel == IPT_OSF_LOGLEVEL_FIRST)
+				break;
+		}
+	}
+	rcu_read_unlock();
+
+	if (!fcount && (info->flags & (IPT_OSF_LOG | IPT_OSF_CONNECTOR))) {
+		unsigned int i;
+		struct ipt_osf_user_finger fg;
+
+		memset(&fg, 0, sizeof(fg));
+#if 1
+		if (info->flags & IPT_OSF_LOG) {
+			if (info->loglevel != IPT_OSF_LOGLEVEL_ALL_KNOWN)
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
+		if (info->flags & IPT_OSF_CONNECTOR) {
+			fg.wss.val = window;
+			fg.ttl = ip->ttl;
+			fg.df = df;
+			fg.ss = totlen;
+			fg.mss = mss;
+			strncpy(fg.genre, "Unknown", MAXGENRELEN);
+
+			ipt_osf_send_connector(&fg, skb);
+		}
+	}
+
+	if (fcount)
+		fmatch = FMATCH_OK;
+
+	return fmatch == FMATCH_OK;
+}
+
+static struct xt_match ipt_osf_match = {
+	.name 		= "osf",
+	.revision	= 0,
+	.family		= NFPROTO_IPV4,
+	.proto		= IPPROTO_TCP,
+	.hooks      	= (1 << NF_INET_LOCAL_IN) | (1 << NF_INET_PRE_ROUTING),
+	.match 		= ipt_osf_match_packet,
+	.matchsize	= sizeof(struct ipt_osf_info),
+	.me		= THIS_MODULE,
+};
+
+static void ipt_osf_finger_free_rcu(struct rcu_head *rcu_head)
+{
+	struct ipt_osf_finger *f = container_of(rcu_head, struct ipt_osf_finger, rcu_head);
+
+	kfree(f);
+}
+
+static void osf_cn_callback(void *data)
+{
+	struct cn_msg *msg = data;
+	struct ipt_osf_user_finger *f = (struct ipt_osf_user_finger *)(msg + 1);
+	struct ipt_osf_finger *kf = NULL, *sf;
+	struct ipt_osf_finger_storage *st = &ipt_osf_fingers[!!f->df];
+
+	/*
+	 * If msg->ack is set to 0 then we add attached fingerprint,
+	 * otherwise remove, and in this case we do not need to allocate data.
+	 */
+	if (!msg->ack) {
+		kf = kmalloc(sizeof(struct ipt_osf_finger), GFP_KERNEL);
+		if (!kf)
+			return;
+
+		memcpy(&kf->finger, f, sizeof(struct ipt_osf_user_finger));
+	}
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(sf, &st->finger_list, finger_entry) {
+		if (memcmp(&sf->finger, f, sizeof(struct ipt_osf_user_finger)))
+			continue;
+
+		if (msg->ack) {
+			spin_lock_bh(&st->finger_lock);
+			list_del_rcu(&sf->finger_entry);
+			spin_unlock_bh(&st->finger_lock);
+			call_rcu(&sf->rcu_head, ipt_osf_finger_free_rcu);
+		} else {
+			kfree(kf);
+			kf = NULL;
+		}
+
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
+}
+
+static int __init ipt_osf_init(void)
+{
+	int err = -EINVAL;
+	int i;
+
+	for (i=0; i<ARRAY_SIZE(ipt_osf_fingers); ++i) {
+		struct ipt_osf_finger_storage *st = &ipt_osf_fingers[i];
+
+		INIT_LIST_HEAD(&st->finger_list);
+		spin_lock_init(&st->finger_lock);
+	}
+
+	err = cn_add_callback(&cn_osf_id, "osf", osf_cn_callback);
+	if (err) {
+		printk(KERN_ERR "Failed (%d) to register OSF connector.\n", err);
+		goto err_out_exit;
+	}
+
+	err = xt_register_match(&ipt_osf_match);
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
+	cn_del_callback(&cn_osf_id);
+err_out_exit:
+	return err;
+}
+
+static void __exit ipt_osf_fini(void)
+{
+	struct ipt_osf_finger *f;
+	int i;
+
+	cn_del_callback(&cn_osf_id);
+	xt_unregister_match(&ipt_osf_match);
+
+	rcu_read_lock();
+	for (i=0; i<ARRAY_SIZE(ipt_osf_fingers); ++i) {
+		struct ipt_osf_finger_storage *st = &ipt_osf_fingers[i];
+
+		list_for_each_entry_rcu(f, &st->finger_list, finger_entry) {
+			list_del_rcu(&f->finger_entry);
+			call_rcu(&f->rcu_head, ipt_osf_finger_free_rcu);
+		}
+	}
+	rcu_read_unlock();
+
+	rcu_barrier();
+
+	printk(KERN_INFO "Passive OS fingerprint matching module finished.\n");
+}
+
+module_init(ipt_osf_init);
+module_exit(ipt_osf_fini);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Evgeniy Polyakov <zbr@ioremap.net>");
+MODULE_DESCRIPTION("Passive OS fingerprint matching.");

-- 
	Evgeniy Polyakov

--Kj7319i9nmIyA2yE
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="libipt_osf.c"

/*
 * Copyright (c) 2003+ Evgeniy Polyakov <zbr@ioremap.net>
 *
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

/*
 * iptables interface for OS fingerprint matching module.
 */

#include <stdio.h>
#include <netdb.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>
#include <ctype.h>

#include <linux/types.h>

#include <xtables.h>

#include <netinet/ip.h>
#include <netinet/tcp.h>

#include <linux/netfilter/xt_osf.h>

static void osf_help(void)
{
	printf("OS fingerprint match options:\n"
		"--genre [!] string         Match a OS genre by passive fingerprinting.\n"
		"--ttl                  Use some TTL check extensions to determine OS:\n"
		"       0                       true ip and fingerprint TTL comparison. Works for LAN.\n"
		"       1                       check if ip TTL is less than fingerprint one. Works for global addresses.\n"
		"       2                       do not compare TTL at all. Allows to detect NMAP, but can produce false results.\n"
		"--log level            Log determined genres into dmesg even if they do not match desired one:\n"
		"       0                       log all matched or unknown signatures.\n"
		"       1                       log only first one.\n"
		"       2                       log all known matched signatures.\n"
		"--connector            Log through kernel connector.\n\n"
		);
}


static const struct option osf_opts[] = {
	{ .name = "genre",	.has_arg = true, .val = '1' },
	{ .name = "ttl",	.has_arg = true, .val = '2' },
	{ .name = "log",	.has_arg = true, .val = '3' },
	{ .name = "connector",	.has_arg = false, .val = '5' },
	{ .name = NULL }
};


static void osf_init(struct xt_entry_match *m)
{
}

static void osf_parse_string(const unsigned char *s, struct ipt_osf_info *info)
{
	if (strlen(s) < MAXGENRELEN) 
		strcpy(info->genre, s);
	else 
		exit_error(PARAMETER_PROBLEM, "Genre string too long `%s' [%d], max=%d", 
				s, strlen(s), MAXGENRELEN);
}

static int osf_parse(int c, char **argv, int invert, unsigned int *flags,
      			const void *entry,
      			struct xt_entry_match **match)
{
	struct ipt_osf_info *info = (struct ipt_osf_info *)(*match)->data;
	
	switch(c) 
	{
		case '1': /* --genre */
			if (*flags & IPT_OSF_GENRE)
				exit_error(PARAMETER_PROBLEM, "Can't specify multiple genre parameter");
			check_inverse(optarg, &invert, &optind, 0);
			osf_parse_string(argv[optind-1], info);
			if (invert)
				info->flags |= IPT_OSF_INVERT;
			info->len=strlen(info->genre);
			*flags |= IPT_OSF_GENRE;
			break;
		case '2': /* --ttl */
			if (*flags & IPT_OSF_TTL)
				exit_error(PARAMETER_PROBLEM, "Can't specify multiple ttl parameter");
			*flags |= IPT_OSF_TTL;
			info->flags |= IPT_OSF_TTL;
			info->ttl = atoi(argv[optind-1]);
			break;
		case '3': /* --log */
			if (*flags & IPT_OSF_LOG)
				exit_error(PARAMETER_PROBLEM, "Can't specify multiple log parameter");
			*flags |= IPT_OSF_LOG;
			info->loglevel = atoi(argv[optind-1]);
			info->flags |= IPT_OSF_LOG;
			break;
		case '5': /* --connector */
			if (*flags & IPT_OSF_CONNECTOR)
				exit_error(PARAMETER_PROBLEM, "Can't specify multiple connector parameter");
			*flags |= IPT_OSF_CONNECTOR;
			info->flags |= IPT_OSF_CONNECTOR;
			break;
		default:
			return 0;
	}

	return 1;
}

static void osf_final_check(unsigned int flags)
{
	if (!flags)
		exit_error(PARAMETER_PROBLEM, "OS fingerprint match: You must specify `--genre'");
}

static void osf_print(const void *ip, const struct xt_entry_match *match, int numeric)
{
	const struct ipt_osf_info *info = (const struct ipt_osf_info*) match->data;

	printf("OS fingerprint match %s%s ", (info->flags & IPT_OSF_INVERT) ? "! " : "", info->genre);
}

static void osf_save(const void *ip, const struct xt_entry_match *match)
{
	const struct ipt_osf_info *info = (const struct ipt_osf_info*) match->data;

	printf("--genre %s%s ", (info->flags & IPT_OSF_INVERT) ? "! ": "", info->genre);
}

static struct xtables_match osf_match = {
	.name		= "osf",
	.version	= XTABLES_VERSION,
	.size		= XT_ALIGN(sizeof(struct ipt_osf_info)),
	.userspacesize	= XT_ALIGN(sizeof(struct ipt_osf_info)),
	.help		= osf_help,
	.init		= osf_init,
	.parse		= osf_parse,
	.print		= osf_print,
	.final_check	= osf_final_check,
	.save		= osf_save,
	.extra_opts	= osf_opts
};

void _init(void)
{
	xtables_register_match(&osf_match);
}

--Kj7319i9nmIyA2yE--
