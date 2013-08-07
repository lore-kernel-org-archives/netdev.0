From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] netfilter: add SYNPROXY core/target
Date: Wed, 7 Aug 2013 22:56:03 +0200
Message-ID: <20130807205602.GA21463@macbook.localnet>
References: <1375897371-18430-1-git-send-email-kaber@trash.net>
 <1375897371-18430-4-git-send-email-kaber@trash.net>
 <20130807222600.51eeca09@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, as@one.com
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130807222600.51eeca09@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 07, 2013 at 10:26:00PM +0200, Jesper Dangaard Brouer wrote:
> On Wed,  7 Aug 2013 19:42:49 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > +	nth = (struct tcphdr *)skb_put(nskb, tcp_hdr_size);
> > +	nth->source	= th->source;
> > +	nth->dest	= th->dest;
> > +	nth->seq	= htonl(ntohl(th->seq) - 1);
> > +	nth->ack_seq	= htonl(ntohl(th->ack_seq) - 1);;
> 
> Strange double ";;"

Thanks, fixed.

> Besides shouldn't nth->ack_seq be zero, in a SYN packet? This is the
> SYN "replayed" towards the server right?
> 
> I also pointed to this in an earlier patch Martin showed me, but he
> reported that changing this resulted in bad behavior.  So, I would
> request Martin to re-test this part.

Right, it should be zero, but it doesn't matter since the ACK flag isn't
set. This is used to propagate the sequence number to the hook function
to initialize the sequence adjustment data. While in the target function,
we don't have any connection tracking state to store this in. We could
set it to zero after that, but it shouldn't matter.

> > +static unsigned int
> > +synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
> > +{
> > +	const struct xt_synproxy_info *info = par->targinfo;
> > +	struct synproxy_net *snet = synproxy_pernet(dev_net(par->in));
> > +	struct synproxy_options opts = {};
> > +	struct tcphdr *th, _th;
> > +
> > +	if (nf_ip_checksum(skb, par->hooknum, par->thoff, IPPROTO_TCP))
> > +		return NF_DROP;
> > +
> > +	th = skb_header_pointer(skb, par->thoff, sizeof(_th), &_th);
> > +	if (th == NULL)
> > +		return NF_DROP;
> > +
> > +	synproxy_parse_options(skb, par->thoff, th, &opts);
> > +
> > +	if (th->syn) {
> > +		/* Initial SYN from client */
> > +		this_cpu_inc(snet->stats->syn_received);
> > +
> > +		if (th->ece && th->cwr)
> > +			opts.options |= XT_SYNPROXY_OPT_ECN;
> > +
> > +		opts.options &= info->options;
> > +		if (opts.options & XT_SYNPROXY_OPT_TIMESTAMP)
> > +			synproxy_init_timestamp_cookie(info, &opts);
> > +		else
> > +			opts.options &= ~(XT_SYNPROXY_OPT_WSCALE |
> > +					  XT_SYNPROXY_OPT_SACK_PERM |
> > +					  XT_SYNPROXY_OPT_ECN);
> > +
> > +		synproxy_send_client_synack(skb, th, &opts);
> > +	} else if (th->ack && !(th->fin || th->rst)) {
> 
> This could also match SYN+ACK... we are only interested in the ACK
> (from the 3WHS) here, right?

Right, we shouldn't see a SYN/ACK here, but I'll add an explicit check.

> > +			switch (opcode) {
> > +			case TCPOPT_MSS:
> > +				if (opsize == TCPOLEN_MSS) {
> > +					 opts->mss = get_unaligned_be16(ptr);
> 
> Strange indention, extra space before "opts->mss".
> 
> > +					 opts->options |= XT_SYNPROXY_OPT_MSS;
> 
> Strange indention, extra space before "opts->options".

Thanks, fixed.

> > +static int synproxy_cpu_seq_show(struct seq_file *seq, void *v)
> > +{
> > +	struct synproxy_stats *stats = v;
> > +
> > +	if (v == SEQ_START_TOKEN) {
> > +		seq_printf(seq, "syn_received\tcookie_invalid\tcookie_valid\n");
> > +		return 0;
> > +	}
> > +
> > +	seq_printf(seq, "%08u\t%08x\t%08x\n",
> 
> Shouldn't all numbers be printed in hex? (%08u -> %08x)

Right, fixed.

> Besides when using net->proc_net_stat, then the first entry is usually
> "entries" which is not percpu, this will likely confusing the tool:
>   lnstat -f synproxy -c 42

I'll look into that.

Thanks Jesper.
