From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Fri, 05 Jun 2009 13:54:15 +0200
Message-ID: <4A290767.6080202@trash.net>
References: <20090604162212.GA24661@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090604162212.GA24661@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> 
> This version switches from printk to nf_log_packet() interface,
> introduces separate add/remove commands for fingerprint processing,
> drops unused variables and includes, adds more comments and contains
> other misc cleanups.

Thanks, this looks much better already. A few final requests:

> +++ b/net/netfilter/xt_osf.c
> +
> +struct xt_osf_finger_storage {
> +	struct list_head		finger_list;
> +};

Without the lock the struct doesn't seem useful anymore. Any reason
for not removing it?

> +static int xt_osf_add_callback(struct sock *ctnl, struct sk_buff *skb,
> +			struct nlmsghdr *nlh, struct nlattr *osf_attrs[])
> +{
> +	struct xt_osf_user_finger *f;
> +	struct xt_osf_finger *kf = NULL, *sf;
> +	struct xt_osf_finger_storage *st;
> +	int err = 0;
> +
> +	if (!osf_attrs[OSF_ATTR_FINGER])
> +		return -EINVAL;
> +
> +	f = nla_data(osf_attrs[OSF_ATTR_FINGER]);
> +	st = &xt_osf_fingers[!!f->df];
> +
> +	kf = kmalloc(sizeof(struct xt_osf_finger), GFP_KERNEL);
> +	if (!kf)
> +		return -ENOMEM;
> +
> +	memcpy(&kf->finger, f, sizeof(struct xt_osf_user_finger));
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(sf, &st->finger_list, finger_entry) {
> +		if (memcmp(&sf->finger, f, sizeof(struct xt_osf_user_finger)))
> +			continue;
> +
> +		/*
> +		 * We are protected by nfnl mutex.

Which means we don't need RCU here (and for removal), right?

> +		 */
> +		kfree(kf);
> +		kf = NULL;
> +
> +		err = -EEXIST;
> +		break;

Please verify that the correct netlink flags are set to avoid
problems in case someone wants to add replacements later on.
This means addition always requires NLM_F_CREATE. NLM_F_REPLACE
is currently not supported, but EEXIST should only be returned
when NLM_F_EXCL is set.

> +static inline int xt_osf_ttl(const struct sk_buff *skb, const struct xt_osf_info *info,
> +			    unsigned char f_ttl)
> +{
> +	const struct iphdr *ip = ip_hdr(skb);
> +
> +	if (info->flags & XT_OSF_TTL) {
> +		if (info->ttl == XT_OSF_TTL_TRUE)
> +			return ip->ttl == f_ttl;
> +		if (info->ttl == XT_OSF_TTL_NOCHECK)
> +			return 1;
> +		else if (ip->ttl <= f_ttl)
> +			return 1;
> +		else {
> +			struct in_device *in_dev = in_dev_get(skb->dev);

This code is only running inside RCU read side section.
You could use the non-refcounted variant.

> +			int ret = 0;
> +
> +			for_ifa(in_dev) {
> +				if (inet_ifa_match(ip->saddr, ifa)) {
> +					ret = (ip->ttl == f_ttl);
> +					break;
> +				}
> +			}
> +			endfor_ifa(in_dev);
> +
> +			in_dev_put(in_dev);
> +			return ret;
> +		}
> +	}
> +
> +	return ip->ttl == f_ttl;
> +}
> +
> +static bool xt_osf_match_packet(const struct sk_buff *skb,
> +		const struct xt_match_param *p)
> +{
> +	const struct xt_osf_info *info = p->matchinfo;
> +	const struct iphdr *ip = ip_hdr(skb);
> +	const struct tcphdr *tcp;
> +	struct tcphdr _tcph;
> +	int fmatch = FMATCH_WRONG, fcount = 0;
> +	unsigned int optsize = 0, check_WSS = 0;
> +	u16 window, totlen, mss = 0;
> +	bool df;
> +	const unsigned char *optp = NULL, *_optp = NULL;
> +	unsigned char opts[MAX_IPOPTLEN];
> +	const struct xt_osf_finger *kf;
> +	const struct xt_osf_user_finger *f;
> +	const struct xt_osf_finger_storage *st;
> +
> +	if (!info)
> +		return false;
> +
> +	tcp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(struct tcphdr), &_tcph);
> +	if (!tcp)
> +		return false;
> +
> +	if (!tcp->syn)
> +		return false;
> +
> +	totlen = ntohs(ip->tot_len);
> +	df = ntohs(ip->frag_off) & IP_DF;
> +	window = ntohs(tcp->window);
> +
> +	if (tcp->doff * 4 > sizeof(struct tcphdr)) {
> +		optsize = tcp->doff * 4 - sizeof(struct tcphdr);

tcp_optlen()?

> +
> +		if (optsize > sizeof(opts))
> +			optsize = sizeof(opts);

How can this happen? The doff field can only represent up to 40
bytes of option length.

> +
> +		_optp = optp = skb_header_pointer(skb, ip_hdrlen(skb) +
> +				sizeof(struct tcphdr), optsize, opts);
> +	}
> +
> +	st = &xt_osf_fingers[df];
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(kf, &st->finger_list, finger_entry) {
> +		f = &kf->finger;
> +
> +		if (!(info->flags & XT_OSF_LOG) && strcmp(info->genre, f->genre))
> +			continue;
> +
> +		optp = _optp;
> +		fmatch = FMATCH_WRONG;
> +
> +		if (totlen == f->ss && xt_osf_ttl(skb, info, f->ttl)) {
> +			int foptsize, optnum;
> +
> +			/*
> +			 * Should not happen if userspace parser was written correctly.
> +			 */
> +			if (f->wss.wc >= OSF_WSS_MAX)
> +				continue;
> +
> +			/* Check options */
> +
> +			foptsize = 0;
> +			for (optnum = 0; optnum < f->opt_num; ++optnum)
> +				foptsize += f->opt[optnum].length;
> +
> +			if (foptsize > MAX_IPOPTLEN ||
> +				optsize > MAX_IPOPTLEN ||
> +				optsize != foptsize)
> +				continue;
> +
> +			check_WSS = f->wss.wc;
> +
> +			for (optnum = 0; optnum < f->opt_num; ++optnum) {
> +				if (f->opt[optnum].kind == (*optp)) {
> +					__u32 len = f->opt[optnum].length;
> +					const __u8 *optend = optp + len;
> +					int loop_cont = 0;
> +
> +					fmatch = FMATCH_OK;
> +
> +					switch (*optp) {
> +					case OSFOPT_MSS:
> +						mss = optp[3];
> +						mss <<= 8;
> +						mss |= optp[2];
> +
> +						mss = ntohs(mss);
> +						break;
> +					case OSFOPT_TS:
> +						loop_cont = 1;
> +						break;
> +					}
> +
> +					optp = optend;
> +				} else
> +					fmatch = FMATCH_OPT_WRONG;
> +
> +				if (fmatch != FMATCH_OK)
> +					break;
> +			}
> +
> +			if (fmatch != FMATCH_OPT_WRONG) {
> +				fmatch = FMATCH_WRONG;
> +
> +				switch (check_WSS) {
> +				case OSF_WSS_PLAIN:
> +					if (f->wss.val == 0 || window == f->wss.val)
> +						fmatch = FMATCH_OK;
> +					break;
> +				case OSF_WSS_MSS:
> +					/*
> +					 * Some smart modems decrease mangle MSS to 
> +					 * SMART_MSS_2, so we check standard, decreased
> +					 * and the one provided in the fingerprint MSS
> +					 * values.
> +					 */
> +#define SMART_MSS_1	1460
> +#define SMART_MSS_2	1448
> +					if (window == f->wss.val * mss ||
> +					    window == f->wss.val * SMART_MSS_1 ||
> +					    window == f->wss.val * SMART_MSS_2)
> +						fmatch = FMATCH_OK;
> +					break;
> +				case OSF_WSS_MTU:
> +					if (window == f->wss.val * (mss + 40) ||
> +					    window == f->wss.val * (SMART_MSS_1 + 40) ||
> +					    window == f->wss.val * (SMART_MSS_2 + 40))
> +						fmatch = FMATCH_OK;
> +					break;
> +				case OSF_WSS_MODULO:
> +					if ((window % f->wss.val) == 0)
> +						fmatch = FMATCH_OK;
> +					break;
> +				}
> +			}
> +
> +			if (fmatch != FMATCH_OK)
> +				continue;
> +
> +			fcount++;
> +			/*
> +			 * Everyone uses NULL loginfo (well, everyone uses
> +			 * NULL for all but format and message fields), so
> +			 * I did not set it up either.
> +			 */

That comment doesn't provide much value IMO. A loginfo field is only
passed in by the various LOG targets.

> +			if (info->flags & XT_OSF_LOG)
> +				nf_log_packet(p->hooknum, 0, skb, p->in, p->out, NULL,
> +					"%s [%s:%s] : %pi4:%d -> %pi4:%d hops=%d\n",
> +					f->genre, f->version, f->subtype,
> +					&ip->saddr, ntohs(tcp->source),
> +					&ip->daddr, ntohs(tcp->dest),
> +					f->ttl - ip->ttl);
> +
> +			if ((info->flags & XT_OSF_LOG) &&
> +			    info->loglevel == XT_OSF_LOGLEVEL_FIRST)
> +				break;
> +		}
> +	}
> +	rcu_read_unlock();
> +
> +	if (!fcount && (info->flags & XT_OSF_LOG)) {
> +		unsigned int i;
> +		struct xt_osf_user_finger fg;
> +
> +		memset(&fg, 0, sizeof(fg));
> +
> +		if (info->flags & XT_OSF_LOG) {
> +			if (info->loglevel != XT_OSF_LOGLEVEL_ALL_KNOWN)
> +				nf_log_packet(p->hooknum, 0, skb, p->in, p->out, NULL,
> +					"window: %u, mss: %u, totlen: %u, df: %d, ttl: %u : ",
> +					window, mss, totlen, df, ip->ttl);

nf_log_packet() can pass the entire packet to userspace. Header-field
extraction should be done by whatever is logging in userspace. This
looks very much like debugging anyways, where is the actual message?

> +			if (_optp) {
> +				optp = _optp;
> +				for (i = 0; i < optsize; i++)
> +					nf_log_packet(p->hooknum, 0, skb, p->in, p->out, NULL,
> +						"%02X ", optp[i]);

Same here and other logging calls.

> +			}
> +
> +			nf_log_packet(p->hooknum, 0, skb, p->in, p->out, NULL,
> +					"%pi4:%u -> %pi4:%u\n",
> +			     &ip->saddr, ntohs(tcp->source),
> +			     &ip->daddr, ntohs(tcp->dest));
> +		}
> +	}
> +
> +	if (fcount)
> +		fmatch = FMATCH_OK;
> +
> +	return fmatch == FMATCH_OK;
> +}
> +
> +static struct xt_match xt_osf_match = {
> +	.name 		= "osf",
> +	.revision	= 0,
> +	.family		= NFPROTO_IPV4,
> +	.proto		= IPPROTO_TCP,
> +	.hooks      	= (1 << NF_INET_LOCAL_IN) |
> +				(1 << NF_INET_PRE_ROUTING) |
> +				(1 << NF_INET_FORWARD),
> +	.match 		= xt_osf_match_packet,
> +	.matchsize	= sizeof(struct xt_osf_info),
> +	.me		= THIS_MODULE,
> +};
> +
> +static int __init xt_osf_init(void)
> +{
> +	int err = -EINVAL;
> +	int i;
> +
> +	for (i=0; i<ARRAY_SIZE(xt_osf_fingers); ++i) {
> +		struct xt_osf_finger_storage *st = &xt_osf_fingers[i];
> +
> +		INIT_LIST_HEAD(&st->finger_list);
> +	}
> +
> +	err = nfnetlink_subsys_register(&xt_osf_nfnetlink);
> +	if (err < 0) {
> +		printk(KERN_ERR "Failed (%d) to register OSF nsfnetlink helper.\n", err);
> +		goto err_out_exit;
> +	}
> +
> +	err = xt_register_match(&xt_osf_match);
> +	if (err) {
> +		printk(KERN_ERR "Failed (%d) to register OS fingerprint "
> +				"matching module.\n", err);
> +		goto err_out_remove;
> +	}
> +
> +	printk(KERN_INFO "Started passive OS fingerprint matching module.\n");

Please no messages on successful module load. Or at least
not when statically built, but preferrably not at all.

> +
> +	return 0;
> +
> +err_out_remove:
> +	nfnetlink_subsys_unregister(&xt_osf_nfnetlink);
> +err_out_exit:
> +	return err;
> +}
> +
> +static void __exit xt_osf_fini(void)
> +{
> +	struct xt_osf_finger *f;
> +	int i;
> +
> +	nfnetlink_subsys_unregister(&xt_osf_nfnetlink);
> +	xt_unregister_match(&xt_osf_match);
> +
> +	rcu_read_lock();
> +	for (i=0; i<ARRAY_SIZE(xt_osf_fingers); ++i) {
> +		struct xt_osf_finger_storage *st = &xt_osf_fingers[i];
> +
> +		list_for_each_entry_rcu(f, &st->finger_list, finger_entry) {
> +			list_del_rcu(&f->finger_entry);
> +			call_rcu(&f->rcu_head, xt_osf_finger_free_rcu);
> +		}
> +	}
> +	rcu_read_unlock();
> +
> +	rcu_barrier();
> +
> +	printk(KERN_INFO "Passive OS fingerprint matching module finished.\n");

Even less on unload :)

> +}
> +
> +module_init(xt_osf_init);
> +module_exit(xt_osf_fini);
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Evgeniy Polyakov <zbr@ioremap.net>");
> +MODULE_DESCRIPTION("Passive OS fingerprint matching.");
> +MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_OSF);
> 
> 

