From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCH net-next 8/9] openvswitch: Allow matching on conntrack label
Date: Fri, 31 Jul 2015 16:07:04 -0700
Message-ID: <CANr6G5zFzZC7PgB37KWRCQh84U2SEhan26wqs9zW3KXcC_t=TQ@mail.gmail.com>
References: <1438279963-29563-1-git-send-email-joestringer@nicira.com>
 <1438279963-29563-9-git-send-email-joestringer@nicira.com> <20150731132004.GA20471@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Justin Pettit <jpettit@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Florian Westphal <fwestpha@redhat.com>,
	Hannes Sowa <hannes@redhat.com>,
	Thomas Graf <tgraf@noironetworks.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150731132004.GA20471@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31 July 2015 at 06:20, Florian Westphal <fw@strlen.de> wrote:
> Joe Stringer <joestringer@nicira.com> wrote:
>> +/* Load connlabel and ensure it supports 128-bit labels */
>> +static struct xt_match *load_connlabel(struct net *net)
>> +{
>> +#ifdef CONFIG_NF_CONNTRACK_LABELS
>> +     struct xt_match *match;
>> +     struct xt_mtchk_param mtpar;
>> +     struct xt_connlabel_mtinfo info;
>> +     int err = -EINVAL;
>> +
>> +     match = xt_request_find_match(NFPROTO_UNSPEC, "connlabel", 0);
>> +     if (IS_ERR(match)) {
>> +             match = NULL;
>> +             goto exit;
>> +     }
>> +
>> +     info.bit = sizeof(struct ovs_key_ct_label) * 8 - 1;
>> +     info.options = 0;
>> +
>> +     mtpar.net       = net;
>> +     mtpar.table     = match->table;
>> +     mtpar.entryinfo = NULL;
>> +     mtpar.match     = match;
>> +     mtpar.matchinfo = &info;
>> +     mtpar.hook_mask = BIT(NF_INET_PRE_ROUTING);
>> +     mtpar.family    = NFPROTO_IPV4;
>> +
>> +     err = xt_check_match(&mtpar, XT_ALIGN(match->matchsize), match->proto,
>> +                          0);
>
> Yummy :-)

You're very graceful :-)

> Rather than adding a dependency on xtables I think a better option would
> be to move the
>
> par->net->ct.labels_used++;
> words = BITS_TO_LONGS(info->bit+1);
> if (words > par->net->ct.label_words)
>         par->net->ct.label_words = words;
>
> parts from the checkentry/destroy hooks of xt_connlabel into
> nf_conntrack_labels.c so that you don't need this mtpar stunt above
> anymore (and I'd like to add ctlabel set support for nft at one point
> so I'd also need to move that out of xt_label).
>
> You can move that out of this series and submit that to nf-devel as
> separate patch if you want.

Thanks for the suggestion, I'll send a patch and adjust this code in
v2 accordingly.

>> +         ovs_ct_verify(OVS_KEY_ATTR_CT_LABEL)) {
>> +             const struct ovs_key_ct_label *cl;
>> +
>> +             cl = nla_data(a[OVS_KEY_ATTR_CT_LABEL]);
>> +             SW_FLOW_KEY_MEMCPY(match, ct.label, cl->ct_label,
>> +                                sizeof(*cl), is_mask);
>> +             *attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABEL);
>> +     }
>
> So you're using labels as arbitrary 128 bit identifier, right?
>
> Nothing wrong with that, just asking.

Right, it's exposed as an arbitrarily maskable/settable field of 128
bits in length, as that's the maximum today. So it's effectively up to
userspace to use it as a bunch of 1-bit flags or N-bit fields within
the range of the 128 bits.
