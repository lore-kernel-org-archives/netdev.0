From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 8/9] openvswitch: Allow matching on conntrack
 label
Date: Fri, 31 Jul 2015 15:20:04 +0200
Message-ID: <20150731132004.GA20471@breakpoint.cc>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-9-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pablo@netfilter.org, kaber@trash.net, jpettit@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, jesse@nicira.com,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@noironetworks.com
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438279963-29563-9-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Stringer <joestringer@nicira.com> wrote:
> Allow matching and setting the conntrack label field. As with ct_mark,
> this is populated by executing the ct() action, and is a writable field.
> The set_field() action may be used to modify the label, which will take
> effect on the most recent conntrack entry.
> 
> E.g.: actions:ct(zone=1),set_field(1->ct_label)
> 
> This will perform conntrack lookup in zone 1, then modify the label for
> that entry. The conntrack entry itself must be committed using the
> "commit" flag in the conntrack action flags for this change to persist.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

> +/* Load connlabel and ensure it supports 128-bit labels */
> +static struct xt_match *load_connlabel(struct net *net)
> +{
> +#ifdef CONFIG_NF_CONNTRACK_LABELS
> +	struct xt_match *match;
> +	struct xt_mtchk_param mtpar;
> +	struct xt_connlabel_mtinfo info;
> +	int err = -EINVAL;
> +
> +	match = xt_request_find_match(NFPROTO_UNSPEC, "connlabel", 0);
> +	if (IS_ERR(match)) {
> +		match = NULL;
> +		goto exit;
> +	}
> +
> +	info.bit = sizeof(struct ovs_key_ct_label) * 8 - 1;
> +	info.options = 0;
> +
> +	mtpar.net	= net;
> +	mtpar.table	= match->table;
> +	mtpar.entryinfo = NULL;
> +	mtpar.match	= match;
> +	mtpar.matchinfo = &info;
> +	mtpar.hook_mask = BIT(NF_INET_PRE_ROUTING);
> +	mtpar.family	= NFPROTO_IPV4;
> +
> +	err = xt_check_match(&mtpar, XT_ALIGN(match->matchsize), match->proto,
> +			     0);

Yummy :-)

Rather than adding a dependency on xtables I think a better option would
be to move the

par->net->ct.labels_used++;
words = BITS_TO_LONGS(info->bit+1);
if (words > par->net->ct.label_words)
	par->net->ct.label_words = words;

parts from the checkentry/destroy hooks of xt_connlabel into
nf_conntrack_labels.c so that you don't need this mtpar stunt above
anymore (and I'd like to add ctlabel set support for nft at one point
so I'd also need to move that out of xt_label).

You can move that out of this series and submit that to nf-devel as
separate patch if you want.

> +	    ovs_ct_verify(OVS_KEY_ATTR_CT_LABEL)) {
> +		const struct ovs_key_ct_label *cl;
> +
> +		cl = nla_data(a[OVS_KEY_ATTR_CT_LABEL]);
> +		SW_FLOW_KEY_MEMCPY(match, ct.label, cl->ct_label,
> +				   sizeof(*cl), is_mask);
> +		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABEL);
> +	}

So you're using labels as arbitrary 128 bit identifier, right?

Nothing wrong with that, just asking.
