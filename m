From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 12 Feb 2009 21:57:29 +0300
Message-ID: <20090212185729.GA17896@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan.

Thanks a lot for the review.

On Thu, Feb 12, 2009 at 07:22:25PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
> >diff --git a/include/linux/netfilter_ipv4/ipt_osf.h b/include/linux/netfilter_ipv4/ipt_osf.h
> >new file mode 100644
> >index 0000000..c2d2c7a
> >--- /dev/null
> >+++ b/include/linux/netfilter_ipv4/ipt_osf.h
> 
> Much of this I think should be upgraded to the xt_ prefixing
> already, even if it does not do IPv6 yet.

Maybe, I follow the existing naming conventions.

> >+struct ipt_osf_info {
> >+	char			genre[MAXGENRELEN];
> >+	__u32			len;
> >+	__u32			flags;
> >+	__u32			loglevel;
> >+	__u32			ttl;
> >+};
> 
> I do not think you need an entire u32 for loglevel and ttl.

They are aligned to 8 bytes, although this is not strickly needed in
this case, it does not hurt.
 
> Could there at least be some description as to what the
> following fields are?
>  +/**
> >+ * Wildcard MSS (kind of).
>    * @wc:	wild card what(?)
>    * @val:	some value?
> >+ */
> >+struct ipt_osf_wc {
> >+	__u32			wc;
> >+	__u32			val;
> >+};
> 

This is a weird wildcards implementation for the MSS value.
They can be pure wildcards and several subtypes which form the window
size and MSS state machine.

> >+struct ipt_osf_user_finger {
> >+	struct ipt_osf_wc wss;
> >+
> >+	__u8 ttl, df;
> >+	__u16 ss, mss;
> >+	int opt_num;
> >+
> >+	char genre[MAXGENRELEN];
> >+	char version[MAXGENRELEN];
> >+	char subtype[MAXGENRELEN];
> >+
> >+	/* MAX_IPOPTLEN is maximum if all options are NOPs or EOLs */
> >+	struct ipt_osf_opt opt[MAX_IPOPTLEN];
> >+};
> 
> Are you sure it is safe to use arch-dependent types like 'int'?

I would be very surprised if Linux will ever run on weird arch where int
is not 32 bits.

> >+/* Defines for IANA option kinds */
> >+
> >+#define OSFOPT_EOL		0	/* End of options */
> >+#define OSFOPT_NOP		1	/* NOP */
> >+#define OSFOPT_MSS		2	/* Maximum segment size */
> >+#define OSFOPT_WSO		3	/* Window scale option */
> >+#define OSFOPT_SACKP		4	/* SACK permitted */
> >+#define OSFOPT_SACK		5	/* SACK */
> >+#define OSFOPT_ECHO		6
> >+#define OSFOPT_ECHOREPLY	7
> >+#define OSFOPT_TS		8	/* Timestamp option */
> >+#define OSFOPT_POCP		9	/* Partial Order Connection Permitted */
> >+#define OSFOPT_POSP		10	/* Partial Order Service Profile */
> >+#define OSFOPT_EMPTY		255
> >+/* Others are not used in current OSF */
> 
> Wrapping this into an enum seems to look nicer.
> 
> >+#ifdef __KERNEL__
> >+
> >+#include <linux/list.h>
> >+#include <net/tcp.h>
> >+
> >+struct ipt_osf_finger {
> >+	struct rcu_head			rcu_head;
> >+	struct list_head		finger_entry;
> >+	struct ipt_osf_user_finger	finger;
> >+};
> >+
> >+#endif				/* __KERNEL__ */
> >+
> >+#endif				/* _IPT_OSF_H */
> 
> Move this section to the .c file.

Ok.

> >+config IP_NF_MATCH_OSF
> >+	tristate '"osf" match support'
> >+	depends on NETFILTER_ADVANCED && CONNECTOR
> >+	help
> >+	  Passive OS fingerprint matching module.
> >+	  You should download and install rule loading software from
> >+	  http://www.ioremap.net/projects/osf
> >+
> >+	  To compile it as a module, choose M here.  If unsure, say N.
> >+
> 
> Please do use NETFILTER_XT_ and its section.

What's this? It does not exist in the net/ipv4/netfilter/Kconfig

> >+static bool ipt_osf_match_packet(const struct sk_buff *skb,
> >+		const struct xt_match_param *p)
> >+{
> >+	struct ipt_osf_info *info = (struct ipt_osf_info *)p->matchinfo;
> >+	struct iphdr *ip;
> >+	struct tcphdr _tcph, *tcp;
> >+	int fmatch = FMATCH_WRONG, fcount = 0;
> >+	unsigned int optsize = 0, check_WSS = 0;
> >+	u16 window, totlen, mss = 0;
> >+	unsigned char df, *optp = NULL, *_optp = NULL;
> 
> Maybe this should be 'bool df'?

Although it is a bit, it is not really a boolean type.

> >+	unsigned char opts[MAX_IPOPTLEN];
> >+	struct ipt_osf_finger *kf;
> >+	struct ipt_osf_user_finger *f;
> >+	struct ipt_osf_finger_storage *st;
> >+
> >+	if (!info)
> >+		return 0;
> 
> Use 'false' - the function returns bool.

Yup.

> >+
> >+	ip = ip_hdr(skb);
> >+	if (!ip)
> >+		return 0;
> >+
> >+	tcp = skb_header_pointer(skb, ip->ihl * 4, sizeof(struct tcphdr), &_tcph);
> 
> Use ip_hdrlen(skb) instead of ihl*4.
> 
> >+	df = ((ntohs(ip->frag_off) & IP_DF) ? 1 : 0);
> 
> Together with bool df, it's just  df = ntohs(ip_frag_off) & IP_DF;
> 
> >+	st = &ipt_osf_fingers[!!df];
> 
> And the !! becomes redundant.

I have no strong opinion if this should be bool or int, but logically it
is not boolean type.

> >+			for (optnum = 0; optnum < f->opt_num; ++optnum) {
> >+				if (f->opt[optnum].kind == (*optp)) {
> >+					__u32 len = f->opt[optnum].length;
> >+					__u8 *optend = optp + len;
> >+					int loop_cont = 0;
> >+					
> >+					fmatch = FMATCH_OK;
> >+
> >+					switch (*optp) {
> >+					case OSFOPT_MSS:
> >+						mss = ntohs(*(u16 *)(optp + 2));
> 
> This needs get_unaligned(), in case someone sends a malicious packet.

Hmmm, why is this needed? We dereference linear kernel pointer at
proper offset (modulo of the option size).

> >+			if (info->flags & IPT_OSF_LOG)
> >+				printk(KERN_INFO "%s [%s:%s] : "
> >+					"%u.%u.%u.%u:%u -> %u.%u.%u.%u:%u hops=%d\n",
> >+					f->genre, f->version, f->subtype, 
> >+					NIPQUAD(ip->saddr), ntohs(tcp->source), 
> >+					NIPQUAD(ip->daddr), ntohs(tcp->dest), 
> >+					f->ttl - ip->ttl);
> 
> Dave told me NIPQUAD is slated for ripout. Though, I have not
> looked if there is already a new format specifier for v4 addresses.

Its from days when it did not exist. I will update the format.

> >+	return (fmatch == FMATCH_OK) ? 1 : 0;
> 
> Just fmatch == FMATCH_OK is sufficient for bool-returning functions.

Yes.

> >+static bool
> >+ipt_osf_checkentry(const struct xt_mtchk_param *m)
> >+{
> >+	struct ipt_ip *ip = (struct ipt_ip *)m->entryinfo;
> >+
> >+	if (ip->proto != IPPROTO_TCP)
> >+		return false;
> >+
> >+	return true;
> >+}
> 
> Do this function via
> 	.proto = IPPROTO_TCP,
> in the osf_match struct instead:

Hmm, it is not used in the existing net/ipv4/netfilter modules.

> >+static struct xt_match ipt_osf_match = {
> >+	.name 		= "osf",
> >+	.revision	= 0,
> >+	.family		= AF_INET,
> 
> 	.family = NFPROTO_IPV4
> 

Will add.

> >+	.hooks      	= (1 << NF_INET_LOCAL_IN) | (1 << NF_INET_PRE_ROUTING),
> >+	.match 		= ipt_osf_match_packet,
> >+	.checkentry	= ipt_osf_checkentry,
> >+	.matchsize	= sizeof(struct ipt_osf_info),
> >+	.me		= THIS_MODULE,
> >+};
> 
> >+	if (kf) {
> >+		spin_lock_bh(&st->finger_lock);
> >+		list_add_tail_rcu(&kf->finger_entry, &st->finger_list);
> >+		spin_unlock_bh(&st->finger_lock);
> >+
> >+		printk("%s: added rule for %s:%s:%s.\n", __func__, kf->finger.genre, kf->finger.version, kf->finger.subtype);
> 
> Missing verbosity level.

Yup.

> >+static void __devexit ipt_osf_fini(void)
> 
> Why __devinit and __devexit, should not this be __init/__exit?

It can be __init/__exit, I will replace.

-- 
	Evgeniy Polyakov
