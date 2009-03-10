From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Passive OS fingerprint xtables match.
Date: Tue, 10 Mar 2009 17:07:27 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0903101618270.19523@fbirervta.pbzchgretzou.qr>
References: <20090310151357.GA10658@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090310151357.GA10658@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tuesday 2009-03-10 16:13, Evgeniy Polyakov wrote:
>
>[xt_osf]

This starts to get its shape. I'm in favor of it.


>--- /dev/null
>+++ b/include/linux/netfilter/xt_osf.h
>@@ -0,0 +1,110 @@
>+/*
>+ * xt_osf.h
>+ *

Common-sense policy wants that filenames like these not be part of the file.

>+#ifndef _IPT_OSF_H
>+#define _IPT_OSF_H
>+
>+#define MAXGENRELEN		32
>+#define MAXDETLEN		64
>+
>+#define IPT_OSF_GENRE		(1<<0)
>+#define	IPT_OSF_TTL		(1<<1)
>+#define IPT_OSF_LOG		(1<<2)
>+#define IPT_OSF_UNUSED		(1<<3)
>+#define IPT_OSF_CONNECTOR	(1<<4)
>+#define IPT_OSF_INVERT		(1<<5)
>+
>+#define IPT_OSF_LOGLEVEL_ALL	0
>+#define IPT_OSF_LOGLEVEL_FIRST	1
>+#define IPT_OSF_LOGLEVEL_ALL_KNOWN	2
>+
>+#define IPT_OSF_TTL_TRUE	0	/* True ip and fingerprint TTL comparison */
>+#define IPT_OSF_TTL_LESS	1	/* Check if ip TTL is less than fingerprint one */
>+#define IPT_OSF_TTL_NOCHECK	2	/* Do not compare ip and fingerprint TTL at all */
>+
>+struct ipt_osf_info {
>+	char			genre[MAXGENRELEN];
>+	__u32			len;
>+	__u32			flags;
>+	__u32			loglevel;
>+	__u32			ttl;
>+};
>[more struct ipt_osf...]

Since the module's name is xt_osf now, it would make sense to follow
this in the struct names too.

>diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
>index c2bac9c..34aafec 100644
>--- a/net/netfilter/Kconfig
>+++ b/net/netfilter/Kconfig
>@@ -853,6 +853,19 @@ config NETFILTER_XT_MATCH_U32
> 
> 	  Details and examples are in the kernel module source.
> 
>+config NETFILTER_XT_MATCH_OSF
>+	tristate 'Passive OS fingerprint match support'

Just a minor thing, could you add "osf" somewhere in the short-text
so that people instantly know the name of the module (without having
to consult the help text), like the other entries. For example

	tristate '"osf" Passive OS fingerprint match'

>+	depends on NETFILTER_ADVANCED
>+	help
>+	  Passive OS fingerprint matching module. Allows to passively match
>+	  remote operation system analyzing incoming TCP packets with SYN
>+	  bit set.

A bit of rewording I suggest.

	This option selects the Passive OS Fingerprinting match module
	that allows to passively match the
	remote operating system by analyzing incoming TCP SYN packets.

>+
>+	  You should download and install rule loading software from
>+	  http://www.ioremap.net/projects/osf

should -> can

	Rules and loading software can be downloaded from
	http://ioremap.net/projects/osf/

>diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
>index da3d909..ec3a6e0 100644
>--- a/net/netfilter/Makefile
>+++ b/net/netfilter/Makefile
>@@ -89,6 +89,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_STRING) += xt_string.o
> obj-$(CONFIG_NETFILTER_XT_MATCH_TCPMSS) += xt_tcpmss.o
> obj-$(CONFIG_NETFILTER_XT_MATCH_TIME) += xt_time.o
> obj-$(CONFIG_NETFILTER_XT_MATCH_U32) += xt_u32.o
>+obj-$(CONFIG_NETFILTER_XT_MATCH_OSF) += xt_osf.o

Please have the list sorted alphabetically. (This keeps merge conflicts
down because everybody does not try to append at the end.)

>diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
>new file mode 100644
>index 0000000..f8b5a16
>--- /dev/null
>+++ b/net/netfilter/xt_osf.c
>+
>+static void ipt_osf_send_connector(struct ipt_osf_user_finger *f,
>+				   const struct sk_buff *skb)
>+{
>+	struct ipt_osf_message *msg = &per_cpu(ipt_osf_mbuf, smp_processor_id());
>+	struct ipt_osf_nlmsg *data = &msg->nlmsg;
>+	struct iphdr *iph = ip_hdr(skb);
>+	struct tcphdr *tcph = tcp_hdr(skb);

iph and tcph are only used in memcpy and could be directly substituted:

	memcpy(&data->ip, ip_hdr(skb), ...)
	memcpy(&data->tcp, tcp_hdr(skb), ...)

>+	memcpy(&msg->cmsg.id, &cn_osf_id, sizeof(struct cn_msg));
>+	msg->cmsg.seq = osf_seq++;
>+	msg->cmsg.ack = 0;
>+	msg->cmsg.len = sizeof(struct ipt_osf_nlmsg);
>+
>+	memcpy(&data->f, f, sizeof(struct ipt_osf_user_finger));
>+	memcpy(&data->ip, iph, sizeof(struct iphdr));

xt_osf does not look at IP options, is that so?

>+	memcpy(&data->tcp, tcph, sizeof(struct tcphdr));

xt_osf does not look at TCP options, is not it?

Note that you cannot directly use tcp_hdr(skb) as the
skb->transport_header has not yet been initialized (it still points
at skb->network_header) because the packet has not yet been seen by
the next handler. This affects PREROUTING, and INPUT chains (and
BROUTING, for ebtables people, but irrelevant here).

The packet may also be fragmented or non-linear.

You actually do the right thing in ipt_osf_match_packet.

>+static inline int ipt_osf_ttl(const struct sk_buff *skb, struct ipt_osf_info *info,

const struct ipt_osf_info *

>+			    unsigned char f_ttl)
>+{
>+	struct iphdr *ip = ip_hdr(skb);
const struct iphdr *iph

>+	if (info->flags & IPT_OSF_TTL) {
>+		if (info->ttl == IPT_OSF_TTL_TRUE)
>+			return (ip->ttl == f_ttl);

redundant pair of ()

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

redundant pair of ()

>+}
>+
>+static bool ipt_osf_match_packet(const struct sk_buff *skb,
>+		const struct xt_match_param *p)
>+{
>+	struct ipt_osf_info *info = (struct ipt_osf_info *)p->matchinfo;

no cast needed. const advised.

>+	struct iphdr *ip;
>+	struct tcphdr _tcph, *tcp;
const

>+	int fmatch = FMATCH_WRONG, fcount = 0;
>+	unsigned int optsize = 0, check_WSS = 0;
>+	u16 window, totlen, mss = 0;
>+	bool df;
>+	unsigned char *optp = NULL, *_optp = NULL;
const

>+	unsigned char opts[MAX_IPOPTLEN];

>+	struct ipt_osf_finger *kf;
>+	struct ipt_osf_user_finger *f;
>+	struct ipt_osf_finger_storage *st;
three const, as far as possible

>+
>+	if (!info)
>+		return false;
>+
>+	ip = ip_hdr(skb);
>+	if (!ip)
>+		return false;

ip_hdr is always returning non-NULL anyway.

>+
>+			for (optnum = 0; optnum < f->opt_num; ++optnum) {
>+				if (f->opt[optnum].kind == (*optp)) {
>+					__u32 len = f->opt[optnum].length;
>+					__u8 *optend = optp + len;
const

>[...]
>+	}
>+
>+	if (fcount)
>+		fmatch = FMATCH_OK;
>+
>+	return fmatch == FMATCH_OK;
>+}
>+
>+static struct xt_match ipt_osf_match = {
>+	.name 		= "osf",
>+	.revision	= 0,
>+	.family		= NFPROTO_IPV4,
>+	.proto		= IPPROTO_TCP,
>+	.hooks      	= (1 << NF_INET_LOCAL_IN) | (1 << NF_INET_PRE_ROUTING),

Would allow FORWARD work?

>+	.match 		= ipt_osf_match_packet,
>+	.matchsize	= sizeof(struct ipt_osf_info),
>+	.me		= THIS_MODULE,
>+};
>+


-Jan
