From: jamal <hadi@cyberus.ca>
Subject: Re: instead of eaction
Date: 07 Feb 2005 09:18:27 -0500
Message-ID: <1107785906.1054.81.camel@jzny.localdomain>
References: <1107728020.1055.50.camel@jzny.localdomain>
	 <20050206230859.GY31837@postel.suug.ch>
	 <1107784621.1053.66.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-dP9GzXAqk/odGNwnK08+"
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <1107784621.1053.66.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-dP9GzXAqk/odGNwnK08+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


I havent finished this and wont touch it for a few days, but should give
you a general view of the csum action. It is slightly more complex
in that it needs to at least check for the data passed from user space
to avoid doing it in the fast/data path and and so overwrittes the
default ->init().
Only thing ive done so far is to compile this. Still a lot of
validation, cleanup and meat to be added. Theres a lot that could be 
done such as incremental checksums, for now this is simple and should
work albeit a little perfomance squeak here and there.

cheers,
jamal

--=-dP9GzXAqk/odGNwnK08+
Content-Disposition: attachment; filename=p1
Content-Type: text/plain; name=p1; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- /dev/null	2005-01-29 13:33:32.773091056 -0500
+++ 2611-rc3+bk3/include/net/tc_act/tc_csuma.h	2005-02-07 08:39:52.594700248 -0500
@@ -0,0 +1,28 @@
+#ifndef __NET_TCA_CSUMA_H
+#define __NET_TCA_CSUMA_H
+
+#include <net/act_api.h>
+#include <net/checksum.h>
+
+struct tcf_csum {
+	u16 ctype;
+	u16 atype;
+	u32 vldact;
+	u32 invact;
+};
+
+enum
+{
+	CSUMA_INVALID = -1,
+	CSUMA_IPVLD,
+	CSUMA_IPSET,
+	CSUMA_TCPVLD,
+	CSUMA_TCPSET,
+	CSUMA_UDPVLD,
+	CSUMA_UDPSET,
+	__CSUMA_MAX
+};
+#define CSUMA_MAX (__CSUMA_MAX - 1)
+
+
+#endif
--- /dev/null	2005-01-29 13:33:32.773091056 -0500
+++ 2611-rc3+bk3/net/sched/csumact.c	2005-02-07 08:37:33.000000000 -0500
@@ -0,0 +1,208 @@
+/*
+ * net/sched/csumact.c	Checksum validate+recompute action
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Jamal Hadi Salim (2005)
+ *
+ */
+
+#include <asm/uaccess.h>
+#include <asm/system.h>
+#include <asm/bitops.h>
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/mm.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/in.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/proc_fs.h>
+#include <net/sock.h>
+#include <net/pkt_sched.h>
+
+#include <net/ip.h>
+#include <net/protocol.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+#include <net/checksum.h>
+
+#define TCA_ACT_CSUMA 23
+
+#define MY_TAB_SIZE     8
+#define MY_TAB_MASK     (MY_TAB_SIZE - 1)
+#include <linux/tc_act/tc_defact.h>
+#include <net/tc_act/tc_defact.h>
+#include <net/tc_act/tc_csuma.h>
+
+static u32 idx_gen;
+static struct tcf_defact *tcf_csuma_ht[MY_TAB_SIZE]; 
+static DEFINE_RWLOCK(csuma_lock);
+
+/* override the defaults */
+#define tcf_st		tcf_defact
+#define tc_st		tc_defact
+#define tcf_t_lock	csuma_lock
+#define tcf_ht		tcf_csuma_ht
+
+#define CONFIG_NET_ACT_INIT 1
+#include <net/pkt_act.h>
+#include <net/act_generic.h>
+
+/* the diffferent csum computers and validators */
+/* 
+ * XXXX: There is a lot of optimizations that could be
+ * done here. each valid and set could share code and 
+ * all the tcp/udp really should be sharing the same code
+ * base
+*/
+static int ipvalid(struct tcf_csum *p, struct sk_buff *skb)
+{
+	struct iphdr *iph = skb->nh.iph;
+	if (ip_fast_csum((unsigned char *)iph, iph->ihl))
+			return p->invact;
+	return p->vldact;
+}
+
+/* XXXX: the usual rules for trampling on pkts must be followed */
+static int ipset(struct tcf_csum *p, struct sk_buff *skb)
+{
+	struct iphdr *iph = skb->nh.iph;
+	iph->check = 0;
+	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+	return p->vldact;
+}
+
+static int tcpvalid(struct tcf_csum *p, struct sk_buff *skb)
+{
+	struct iphdr *iph = skb->nh.iph;
+	unsigned int tcphoff = skb->nh.iph->ihl * 4;
+	unsigned int tcplen = skb->len - tcphoff;
+
+	skb->csum = skb_checksum(skb, tcphoff, tcplen, 0);
+
+	if (csum_tcpudp_magic(iph->saddr, iph->daddr, tcplen, IPPROTO_TCP, skb->csum))
+		return p->invact;
+
+	return p->vldact;
+}
+
+/* XXXX: the usual rules for trampling on pkts must be followed */
+static int tcpset(struct tcf_csum *p, struct sk_buff *skb)
+{
+	struct tcphdr *tcph = skb->h.th;
+	struct iphdr *iph = skb->nh.iph;
+	unsigned int tcphoff = skb->nh.iph->ihl * 4;
+	unsigned int tcplen = skb->len - tcphoff;
+
+	tcph->check = 0;
+	skb->csum = skb_checksum(skb, tcphoff, tcplen, 0);
+
+	tcph->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
+			tcplen, IPPROTO_TCP, skb->csum);
+
+	return p->vldact;
+}
+
+static int udpvalid(struct tcf_csum *p, struct sk_buff *skb)
+{
+	struct iphdr *iph = skb->nh.iph;
+	unsigned int udphoff = skb->nh.iph->ihl * 4;
+	unsigned int udplen = skb->len - udphoff;
+
+	skb->csum = skb_checksum(skb, udphoff, udplen, 0);
+
+	if (csum_tcpudp_magic(iph->saddr, iph->daddr, udplen, IPPROTO_UDP, skb->csum))
+		return p->invact;
+
+	return p->vldact;
+}
+
+/* XXXX: the usual rules for trampling on pkts must be followed */
+static int udpset(struct tcf_csum *p, struct sk_buff *skb)
+{
+	struct udphdr *udph = skb->h.uh;
+	struct iphdr *iph = skb->nh.iph;
+	unsigned int udphoff = skb->nh.iph->ihl * 4;
+	unsigned int udplen = skb->len - udphoff;
+
+	udph->check = 0;
+	skb->csum = skb_checksum(skb, udphoff, udplen, 0);
+
+	udph->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
+			udplen, IPPROTO_UDP, skb->csum);
+
+	return p->vldact;
+}
+
+typedef int (*f_csum)(struct tcf_csum *p, struct sk_buff *skb);
+static f_csum csumfuncs[CSUMA_MAX + 1] = {ipvalid,ipset,tcpvalid,tcpset,udpvalid,udpset };
+
+static int tcf_csuma(struct sk_buff **pskb, struct tc_action *a)
+{
+	int ret;
+	struct sk_buff *skb = *pskb;
+	struct tcf_defact *p = PRIV(a, defact);
+	struct tcf_csum *c = p->defdata;
+
+	spin_lock(&p->lock);
+	p->tm.lastuse = jiffies;
+	p->bstats.bytes += skb->len;
+	p->bstats.packets++;
+	ret = csumfuncs[c->ctype](c, skb);
+	spin_unlock(&p->lock);
+	return ret;
+}
+
+static inline int
+tcf_csuma_init(struct rtattr *rta, struct rtattr *est,
+	       struct tc_action *a, int ovr, int bind)
+{
+	/* cutnpaste tcf_defact_init and check that
+	 * the ctype passed is valid */
+	       return 0;
+}
+
+static struct tc_action_ops act_csuma_ops = {
+	.kind = "csumact",
+	.type = TCA_ACT_CSUMA,
+	.capab = TCA_CAP_NONE,
+	.owner = THIS_MODULE,
+	.act = tcf_csuma,
+	tca_use_default_ops
+};
+
+MODULE_AUTHOR("Jamal Hadi Salim(2005)");
+MODULE_DESCRIPTION("checksum action");
+MODULE_LICENSE("GPL");
+
+static int __init csuma_init_module(void)
+{
+	int ret = tcf_register_action(&act_csuma_ops);
+	if (!ret) {
+		printk("Simple TC action Loaded\n");
+		/* overwrite the init */
+		act_csuma_ops.init = tcf_csuma_init;
+	}
+	return ret;
+}
+
+static void __exit csuma_cleanup_module(void)
+{
+	tcf_unregister_action(&act_csuma_ops);
+}
+
+module_init(csuma_init_module);
+module_exit(csuma_cleanup_module);

--=-dP9GzXAqk/odGNwnK08+--
