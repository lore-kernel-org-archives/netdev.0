From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 12 Feb 2009 19:22:25 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr>
References: <20090212171245.GA15025@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:43998 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755237AbZBLSW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 13:22:27 -0500
In-Reply-To: <20090212171245.GA15025@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2009-02-12 18:12, Evgeniy Polyakov wrote:
>
>You will find something like this in the syslog:
>ipt_osf: Windows [2000:SP3:Windows XP Pro SP1, 2000 SP3]: 11.22.33.55:4024 -> 11.22.33.44:139
>
>Passive OS fingerprint homepage (archives, examples):
>http://www.ioremap.net/projects/osf

>diff --git a/include/linux/netfilter_ipv4/ipt_osf.h b/include/linux/netfilter_ipv4/ipt_osf.h
>new file mode 100644
>index 0000000..c2d2c7a
>--- /dev/null
>+++ b/include/linux/netfilter_ipv4/ipt_osf.h

Much of this I think should be upgraded to the xt_ prefixing
already, even if it does not do IPv6 yet.

>+struct ipt_osf_info {
>+	char			genre[MAXGENRELEN];
>+	__u32			len;
>+	__u32			flags;
>+	__u32			loglevel;
>+	__u32			ttl;
>+};

I do not think you need an entire u32 for loglevel and ttl.


Could there at least be some description as to what the
following fields are?
 +/**
>+ * Wildcard MSS (kind of).
   * @wc:	wild card what(?)
   * @val:	some value?
>+ */
>+struct ipt_osf_wc {
>+	__u32			wc;
>+	__u32			val;
>+};

>+struct ipt_osf_user_finger {
>+	struct ipt_osf_wc wss;
>+
>+	__u8 ttl, df;
>+	__u16 ss, mss;
>+	int opt_num;
>+
>+	char genre[MAXGENRELEN];
>+	char version[MAXGENRELEN];
>+	char subtype[MAXGENRELEN];
>+
>+	/* MAX_IPOPTLEN is maximum if all options are NOPs or EOLs */
>+	struct ipt_osf_opt opt[MAX_IPOPTLEN];
>+};

Are you sure it is safe to use arch-dependent types like 'int'?

>+/* Defines for IANA option kinds */
>+
>+#define OSFOPT_EOL		0	/* End of options */
>+#define OSFOPT_NOP		1	/* NOP */
>+#define OSFOPT_MSS		2	/* Maximum segment size */
>+#define OSFOPT_WSO		3	/* Window scale option */
>+#define OSFOPT_SACKP		4	/* SACK permitted */
>+#define OSFOPT_SACK		5	/* SACK */
>+#define OSFOPT_ECHO		6
>+#define OSFOPT_ECHOREPLY	7
>+#define OSFOPT_TS		8	/* Timestamp option */
>+#define OSFOPT_POCP		9	/* Partial Order Connection Permitted */
>+#define OSFOPT_POSP		10	/* Partial Order Service Profile */
>+#define OSFOPT_EMPTY		255
>+/* Others are not used in current OSF */

Wrapping this into an enum seems to look nicer.

>+#ifdef __KERNEL__
>+
>+#include <linux/list.h>
>+#include <net/tcp.h>
>+
>+struct ipt_osf_finger {
>+	struct rcu_head			rcu_head;
>+	struct list_head		finger_entry;
>+	struct ipt_osf_user_finger	finger;
>+};
>+
>+#endif				/* __KERNEL__ */
>+
>+#endif				/* _IPT_OSF_H */

Move this section to the .c file.

>+config IP_NF_MATCH_OSF
>+	tristate '"osf" match support'
>+	depends on NETFILTER_ADVANCED && CONNECTOR
>+	help
>+	  Passive OS fingerprint matching module.
>+	  You should download and install rule loading software from
>+	  http://www.ioremap.net/projects/osf
>+
>+	  To compile it as a module, choose M here.  If unsure, say N.
>+

Please do use NETFILTER_XT_ and its section.

>--- /dev/null
>+++ b/net/ipv4/netfilter/ipt_osf.c
>+
>+static inline int ipt_osf_ttl(const struct sk_buff *skb, struct ipt_osf_info *info,
>+			    unsigned char f_ttl)
>+{
>+	struct iphdr *ip = ip_hdr(skb);
>+
>+	if (info->flags & IPT_OSF_TTL) {
>+		if (info->ttl == IPT_OSF_TTL_TRUE)
>+			return (ip->ttl == f_ttl);
>+		if (info->ttl == IPT_OSF_TTL_NOCHECK)
>+			return 1;
>+		else if (ip->ttl <= f_ttl)
>+			return 1;
>+		else {
>+			struct in_device *in_dev = in_dev_get(skb->dev);
>+			int ret = 0;
>+
>+			for_ifa(in_dev) {
>+				if (inet_ifa_match(ip->saddr, ifa)) {
>+					ret = (ip->ttl == f_ttl);
>+					break;
>+				}
>+			}
>+			endfor_ifa(in_dev);
>+
>+			in_dev_put(in_dev);
>+			return ret;
>+		}
>+	}
>+	
>+	return (ip->ttl == f_ttl);
>+}
>+
>+static bool ipt_osf_match_packet(const struct sk_buff *skb,
>+		const struct xt_match_param *p)
>+{
>+	struct ipt_osf_info *info = (struct ipt_osf_info *)p->matchinfo;
>+	struct iphdr *ip;
>+	struct tcphdr _tcph, *tcp;
>+	int fmatch = FMATCH_WRONG, fcount = 0;
>+	unsigned int optsize = 0, check_WSS = 0;
>+	u16 window, totlen, mss = 0;
>+	unsigned char df, *optp = NULL, *_optp = NULL;

Maybe this should be 'bool df'?

>+	unsigned char opts[MAX_IPOPTLEN];
>+	struct ipt_osf_finger *kf;
>+	struct ipt_osf_user_finger *f;
>+	struct ipt_osf_finger_storage *st;
>+
>+	if (!info)
>+		return 0;

Use 'false' - the function returns bool.

>+
>+	ip = ip_hdr(skb);
>+	if (!ip)
>+		return 0;
>+
>+	tcp = skb_header_pointer(skb, ip->ihl * 4, sizeof(struct tcphdr), &_tcph);

Use ip_hdrlen(skb) instead of ihl*4.

>+	df = ((ntohs(ip->frag_off) & IP_DF) ? 1 : 0);

Together with bool df, it's just  df = ntohs(ip_frag_off) & IP_DF;

>+	st = &ipt_osf_fingers[!!df];

And the !! becomes redundant.

>+			for (optnum = 0; optnum < f->opt_num; ++optnum) {
>+				if (f->opt[optnum].kind == (*optp)) {
>+					__u32 len = f->opt[optnum].length;
>+					__u8 *optend = optp + len;
>+					int loop_cont = 0;
>+					
>+					fmatch = FMATCH_OK;
>+
>+					switch (*optp) {
>+					case OSFOPT_MSS:
>+						mss = ntohs(*(u16 *)(optp + 2));

This needs get_unaligned(), in case someone sends a malicious packet.

>+			if (info->flags & IPT_OSF_LOG)
>+				printk(KERN_INFO "%s [%s:%s] : "
>+					"%u.%u.%u.%u:%u -> %u.%u.%u.%u:%u hops=%d\n",
>+					f->genre, f->version, f->subtype, 
>+					NIPQUAD(ip->saddr), ntohs(tcp->source), 
>+					NIPQUAD(ip->daddr), ntohs(tcp->dest), 
>+					f->ttl - ip->ttl);

Dave told me NIPQUAD is slated for ripout. Though, I have not
looked if there is already a new format specifier for v4 addresses.

>+	return (fmatch == FMATCH_OK) ? 1 : 0;

Just fmatch == FMATCH_OK is sufficient for bool-returning functions.

>+static bool
>+ipt_osf_checkentry(const struct xt_mtchk_param *m)
>+{
>+	struct ipt_ip *ip = (struct ipt_ip *)m->entryinfo;
>+
>+	if (ip->proto != IPPROTO_TCP)
>+		return false;
>+
>+	return true;
>+}

Do this function via
	.proto = IPPROTO_TCP,
in the osf_match struct instead:

>+static struct xt_match ipt_osf_match = {
>+	.name 		= "osf",
>+	.revision	= 0,
>+	.family		= AF_INET,

	.family = NFPROTO_IPV4

>+	.hooks      	= (1 << NF_INET_LOCAL_IN) | (1 << NF_INET_PRE_ROUTING),
>+	.match 		= ipt_osf_match_packet,
>+	.checkentry	= ipt_osf_checkentry,
>+	.matchsize	= sizeof(struct ipt_osf_info),
>+	.me		= THIS_MODULE,
>+};

>+	if (kf) {
>+		spin_lock_bh(&st->finger_lock);
>+		list_add_tail_rcu(&kf->finger_entry, &st->finger_list);
>+		spin_unlock_bh(&st->finger_lock);
>+
>+		printk("%s: added rule for %s:%s:%s.\n", __func__, kf->finger.genre, kf->finger.version, kf->finger.subtype);

Missing verbosity level.

>+static void __devexit ipt_osf_fini(void)

Why __devinit and __devexit, should not this be __init/__exit?

