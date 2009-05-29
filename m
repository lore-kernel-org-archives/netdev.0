From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [resend] Passive OS fingerprint xtables match.
Date: Fri, 29 May 2009 12:59:18 +0400
Message-ID: <20090529085918.GA11887@ioremap.net>
References: <20090511095343.GA30778@ioremap.net> <4A1D6A20.8050404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A1D6A20.8050404@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick.

Thanks for your comments.

On Wed, May 27, 2009 at 06:28:16PM +0200, Patrick McHardy (kaber@trash.net) wrote:
> >You will find something like this in the syslog:
> >Windows [2000:SP3:Windows XP Pro SP1, 2000 SP3]: 11.22.33.55:4024 -> 
> >11.22.33.44:139 hops=4
> >Linux [2.5:]: 1.2.3.4:44448 -> 11.22.33.44:22 hops=4
> 
> Please convert this to use nf_log_packet().

Ok, will use.

> >--- /dev/null
> >+++ b/include/linux/netfilter/xt_osf.h
> >+#ifndef _XT_OSF_H
> >+#define _XT_OSF_H
> >+
> >+#define MAXGENRELEN		32
> >+#define MAXDETLEN		64
> 
> ^ Unused
> 
> >+
> >+#define XT_OSF_GENRE		(1<<0)
> >+#define	XT_OSF_TTL		(1<<1)
> >+#define XT_OSF_LOG		(1<<2)
> >+#define XT_OSF_UNUSED		(1<<3)
> 
> ^ Unused? :)

I will drop those constants.

> >+#define XT_OSF_CONNECTOR	(1<<4)
> >+#define XT_OSF_INVERT		(1<<5)
> >+
> >+#define XT_OSF_LOGLEVEL_ALL	0
> >+#define XT_OSF_LOGLEVEL_FIRST	1
> >+#define XT_OSF_LOGLEVEL_ALL_KNOWN	2
> 
> What does this do?

There are 3 log levels - dump all matched entries, only the first
matched and dump unknown packet data if needed.

> >+#define XT_OSF_TTL_TRUE		0	/* True ip and fingerprint 
> >TTL comparison */
> >+#define XT_OSF_TTL_LESS		1	/* Check if ip TTL is less 
> >than fingerprint one */
> >+#define XT_OSF_TTL_NOCHECK	2	/* Do not compare ip and fingerprint 
> >TTL at all */
> 
> These seem redundant - having neither of TRUE or LESS seems
> equivalent to NOCHECK. Perhaps thats the reason why its not
> used at all :) Looking at the code, "TRUE" would be better
> named as "EQUAL".

There are only three types of TTL check - equal (for true), less than
fingerprint one and when no check is performed at all. NOCHECK is
actually used, but LESS one does not have a special check, but a default
clause when neither TRUE or NOCHECK is specified.

> >+struct xt_osf_info {
> >+	char			genre[MAXGENRELEN];
> >+	__u32			len;
> >+	__u32			flags;
> >+	__u32			loglevel;
> >+	__u32			ttl;
> >+};
> 
> Unless you're really really sure that this is not going to
> change, please use netlink attributes. Similar for the other
> ABI structures.

It was not changed for the last 5 years, maybe even more.
There are no other fields in the tcp header to match against :)

> >+struct xt_osf_user_finger {
> >+	struct xt_osf_wc	wss;
> >+
> >+	__u8			ttl, df;
> >+	__u16			ss, mss;
> >+	__u16			opt_num;
> >+
> >+	char			genre[MAXGENRELEN];
> >+	char			version[MAXGENRELEN];
> >+	char			subtype[MAXGENRELEN];
> >+
> >+	/* MAX_IPOPTLEN is maximum if all options are NOPs or EOLs */
> >+	struct xt_osf_opt	opt[MAX_IPOPTLEN];
> 
> This really looks like you should use nested attributes.

This will be an unneded complication - we should provide an option
sequence, and maximum number of options is strickly determined by
the protocol specification. How does having separate attributes for each
option simplify the process?

> >+/* Defines for IANA option kinds */
> >+
> >+enum iana_options {
> >+	OSFOPT_EOL = 0,		/* End of options */
> >+	OSFOPT_NOP, 		/* NOP */
> >+	OSFOPT_MSS, 		/* Maximum segment size */
> >+	OSFOPT_WSO, 		/* Window scale option */
> >+	OSFOPT_SACKP,		/* SACK permitted */
> >+	OSFOPT_SACK,		/* SACK */
> >+	OSFOPT_ECHO,
> >+	OSFOPT_ECHOREPLY,
> >+	OSFOPT_TS,		/* Timestamp option */
> >+	OSFOPT_POCP,		/* Partial Order Connection Permitted */
> >+	OSFOPT_POSP,		/* Partial Order Service Profile */
> >+
> >+	/* Others are not used in the current OSF */
> >+	OSFOPT_EMPTY = 255,
> >+};
> 
> Why do we need to duplicate these?

Why duplicate? It is the only place of the constants describing used
option numbers. include/net/tcp.h does not have 'partial order' options
in particular.

> >+config NETFILTER_XT_MATCH_OSF
> >+	tristate '"osf" Passive OS fingerprint match'
> >+	depends on NETFILTER_ADVANCED
> 
> && NFNETLINK

Will add.

> >--- /dev/null
> >+++ b/net/netfilter/xt_osf.c
> >@@ -0,0 +1,469 @@
> >+/*
> >+ * Copyright (c) 2003+ Evgeniy Polyakov <zbr@ioremap.net>
> >+ *
> >+ *
> >+ * This program is free software; you can redistribute it and/or modify
> >+ * it under the terms of the GNU General Public License as published by
> >+ * the Free Software Foundation; either version 2 of the License, or
> >+ * (at your option) any later version.
> >+ *
> >+ * This program is distributed in the hope that it will be useful,
> >+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
> >+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> >+ * GNU General Public License for more details.
> >+ *
> >+ * You should have received a copy of the GNU General Public License
> >+ * along with this program; if not, write to the Free Software
> >+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
> >+ */
> >+
> >+#include <linux/module.h>
> >+#include <linux/kernel.h>
> >+
> >+#include <linux/connector.h>
> 
> Not needed. The remaining ones look like some (percpu?) could be
> removed as well.

Yup.

> >+struct xt_osf_finger_storage
> >+{
> 
> Please place the opening bracket consistently with the other
> structure definitions.

I.e. always on the new line? :)

> >+	struct list_head		finger_list;
> >+	spinlock_t			finger_lock;
> >+};
> >+
> >+/*
> >+ * Indexed by dont-fragment bit.
> >+ * It is the only constant value in the fingerprint.
> >+ */
> >+struct xt_osf_finger_storage xt_osf_fingers[2];
> 
> static

Ok.

> >+
> >+struct xt_osf_message {
> >+	struct cn_msg		cmsg;
> >+	struct xt_osf_nlmsg	nlmsg;
> >+};
> 
> Unused.

Yes.

> >+static int xt_osf_setup_callback(struct sock *ctnl, struct sk_buff *skb,
> >+			struct nlmsghdr *nlh, struct nlattr *osf_attrs[])
> >+{
> >+	struct xt_osf_user_finger *f;
> >+	struct nfgenmsg *nfmsg = NLMSG_DATA(nlh);
> >+	u16 delete = ntohs(nfmsg->res_id);
> 
> This looks like abuse, we use message types to distinguish between
> additions and deletions, alternative NLM_F_REPLACE.

Why to introduce the whole new callback function and attribute when the
only difference is to add or remove a processed entry?

> >+	struct xt_osf_finger *kf = NULL, *sf;
> >+	struct xt_osf_finger_storage *st;
> >+	int err;
> >+
> >+	if (!osf_attrs[OSF_ATTR_FINGER])
> >+		return -EINVAL;
> >+
> >+	f = nla_data(osf_attrs[OSF_ATTR_FINGER]);
> >+	st = &xt_osf_fingers[!!f->df];
> >+
> >+	/*
> >+	 * If 'delete' is set to 0 then we add attached fingerprint,
> >+	 * otherwise remove, and in this case we do not need to allocate 
> >data.
> >+	 */
> >+	if (!delete) {
> >+		kf = kmalloc(sizeof(struct xt_osf_finger), GFP_KERNEL);
> >+		if (!kf)
> >+			return -ENOMEM;
> >+
> >+		memcpy(&kf->finger, f, sizeof(struct xt_osf_user_finger));
> >+	}
> >+
> >+	err = -ENOENT;
> >+
> >+	rcu_read_lock();
> >+	list_for_each_entry_rcu(sf, &st->finger_list, finger_entry) {
> >+		if (memcmp(&sf->finger, f, sizeof(struct 
> >xt_osf_user_finger)))
> >+			continue;
> >+
> >+		if (delete) {
> >+			spin_lock_bh(&st->finger_lock);
> 
> This lock looks useless, all changes are done in netlink context under
> the nfnl mutex.

Agree.

> >+			list_del_rcu(&sf->finger_entry);
> >+			spin_unlock_bh(&st->finger_lock);
> >+			call_rcu(&sf->rcu_head, xt_osf_finger_free_rcu);
> >+		} else {
> >+			kfree(kf);
> >+			kf = NULL;
> >+		}
> >+
> >+		err = 0;
> >+		break;
> >+	}
> >+
> >+	if (kf) {
> >+		spin_lock_bh(&st->finger_lock);

Here too.

> >+		list_add_tail_rcu(&kf->finger_entry, &st->finger_list);
> >+		spin_unlock_bh(&st->finger_lock);
> >+#if 0
> >+		printk(KERN_INFO "Added rule for %s:%s:%s.\n",
> >+			kf->finger.genre, kf->finger.version, 
> >kf->finger.subtype);
> >+#endif
> >+	}
> >+	rcu_read_unlock();
> >+
> >+	return 0;
> >+}

...

> >+static bool xt_osf_match_packet(const struct sk_buff *skb,
> >+		const struct xt_match_param *p)
> >+{
> >+	const struct xt_osf_info *info = p->matchinfo;
> >+	const struct iphdr *ip = ip_hdr(skb);
> >+	const struct tcphdr *tcp;
> >+	struct tcphdr _tcph;
> >+	int fmatch = FMATCH_WRONG, fcount = 0;
> >+	unsigned int optsize = 0, check_WSS = 0;
> >+	u16 window, totlen, mss = 0;
> >+	bool df;
> >+	const unsigned char *optp = NULL, *_optp = NULL;
> >+	unsigned char opts[MAX_IPOPTLEN];
> >+	const struct xt_osf_finger *kf;
> >+	const struct xt_osf_user_finger *f;
> >+	const struct xt_osf_finger_storage *st;
> >+
> >+	if (!info)
> >+		return false;
> >+
> >+	tcp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(struct tcphdr), 
> >&_tcph);
> >+	if (!tcp)
> >+		return false;
> >+
> >+	if (!tcp->syn)
> >+		return false;
> >+
> >+	totlen = ntohs(ip->tot_len);
> >+	df = ntohs(ip->frag_off) & IP_DF;
> >+	window = ntohs(tcp->window);
> >+
> >+	if (tcp->doff * 4 > sizeof(struct tcphdr)) {
> >+		optsize = tcp->doff * 4 - sizeof(struct tcphdr);
> >+
> >+		if (optsize > sizeof(opts))
> >+			optsize = sizeof(opts);
> >+
> >+		_optp = optp = skb_header_pointer(skb, ip_hdrlen(skb) + 
> >sizeof(struct tcphdr),
> 
> Please break the line at 80 characters

Will do.

> >+				optsize, opts);
> >+	}
> >+
> >+	st = &xt_osf_fingers[df];
> >+
> >+	rcu_read_lock();
> >+	list_for_each_entry_rcu(kf, &st->finger_list, finger_entry) {
> >+		f = &kf->finger;
> >+
> >+		if (!(info->flags & XT_OSF_LOG) && strcmp(info->genre, 
> >f->genre))
> >+			continue;
> >+
> >+		optp = _optp;
> >+		fmatch = FMATCH_WRONG;
> >+
> >+		if (totlen == f->ss && xt_osf_ttl(skb, info, f->ttl)) {
> >+			int foptsize, optnum;
> >+
> >+			check_WSS = 0;
> >+
> >+			switch (f->wss.wc) {
> >+			case 0:
> >+				check_WSS = 0;
> >+				break;
> >+			case 'S':
> >+				check_WSS = 1;
> >+				break;
> >+			case 'T':
> >+				check_WSS = 2;
> >+				break;
> >+			case '%':
> >+				check_WSS = 3;
> >+				break;
> >+			default:
> >+				check_WSS = 4;
> >+				break;
> >+			}
> 
> This is really pushing my taste-buds. Whatever this does, please at
> use symbolic constants so the reader at least has a chance to understand
> it.

That's a bit unlcear window size processing state machine.
It links together knowledge about window-size, mss, mtu dependancy on
plain size numbers and modulo operations (like window size is multiple
of x bytes).

> >+			if (check_WSS == 4)
> >+				continue;
> >+
> >+			/* Check options */
> >+
> >+			foptsize = 0;
> >+			for (optnum = 0; optnum < f->opt_num; ++optnum)
> >+				foptsize += f->opt[optnum].length;
> >+
> >+			if (foptsize > MAX_IPOPTLEN || optsize > 
> >MAX_IPOPTLEN || optsize != foptsize)
> >+				continue;
> >+
> >+			for (optnum = 0; optnum < f->opt_num; ++optnum) {
> >+				if (f->opt[optnum].kind == (*optp)) {
> >+					__u32 len = f->opt[optnum].length;
> >+					const __u8 *optend = optp + len;
> >+					int loop_cont = 0;
> >+
> >+					fmatch = FMATCH_OK;
> >+
> >+					switch (*optp) {
> >+					case OSFOPT_MSS:
> >+						mss = optp[3];
> >+						mss <<= 8;
> >+						mss |= optp[2];
> >+
> >+						mss = ntohs(mss);
> >+						break;
> >+					case OSFOPT_TS:
> >+						loop_cont = 1;
> >+						break;
> >+					}
> >+
> >+					optp = optend;
> >+				} else
> >+					fmatch = FMATCH_OPT_WRONG;
> >+
> >+				if (fmatch != FMATCH_OK)
> >+					break;
> >+			}
> >+
> >+			if (fmatch != FMATCH_OPT_WRONG) {
> >+				fmatch = FMATCH_WRONG;
> >+
> >+				switch (check_WSS) {
> >+				case 0:
> >+					if (f->wss.val == 0 || window == 
> >f->wss.val)
> >+						fmatch = FMATCH_OK;
> >+					break;
> >+				case 1:	/* MSS */
> >+#define SMART_MSS_1	1460
> >+#define SMART_MSS_2	1448
> 
> Sigh. This entire function is completely unreadable and full of
> unexplained magic. I'll stop here, please clean this before
> resubmitting.

This is a special hack for special modems, which can decrease mss, and
since there is no common knowledge on how to differentiate them, there
is a check against different types.

This function is a core processing state machine, which checks received
packet parameters and compares them against prebuilt set of rules, which
include not only simple equal/not-equal, but also a bit more complex,
like multiple of (various parameter, mss, window-size, plain number).

-- 
	Evgeniy Polyakov
