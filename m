From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] bpf: BPF for lightweight tunnel
 infrastructure
Date: Tue, 29 Nov 2016 23:01:52 -0800
Message-ID: <20161130070150.GA33397@ast-mbp.thefacebook.com>
References: <cover.1480424542.git.tgraf@suug.ch>
 <7cc79a82e49996a9ebbff861af471018fdf118fb.1480424542.git.tgraf@suug.ch>
 <20161130001504.GA28238@ast-mbp.thefacebook.com>
 <20161130064850.GB16856@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        hannes@stressinduktion.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36401 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750810AbcK3HCC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 02:02:02 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so449416pgx.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 23:02:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161130064850.GB16856@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 07:48:51AM +0100, Thomas Graf wrote:
> On 11/29/16 at 04:15pm, Alexei Starovoitov wrote:
> > On Tue, Nov 29, 2016 at 02:21:22PM +0100, Thomas Graf wrote:
> > ...
> > > +#define LWT_BPF_MAX_HEADROOM 128
> > 
> > why 128?
> > btw I'm thinking for XDP to use 256, so metadata can be stored in there.
> 
> It's an arbitrary limit to catch obvious misconfiguration. I'm absolutely
> fine with bumping it to 256.
> 
> > > +static int run_lwt_bpf(struct sk_buff *skb, struct bpf_lwt_prog *lwt,
> > > +		       struct dst_entry *dst, bool can_redirect)
> > > +{
> > > +	int ret;
> > > +
> > > +	/* Preempt disable is needed to protect per-cpu redirect_info between
> > > +	 * BPF prog and skb_do_redirect(). The call_rcu in bpf_prog_put() and
> > > +	 * access to maps strictly require a rcu_read_lock() for protection,
> > > +	 * mixing with BH RCU lock doesn't work.
> > > +	 */
> > > +	preempt_disable();
> > > +	rcu_read_lock();
> > > +	bpf_compute_data_end(skb);
> > > +	ret = BPF_PROG_RUN(lwt->prog, skb);
> > > +	rcu_read_unlock();
> > > +
> > > +	switch (ret) {
> > > +	case BPF_OK:
> > > +		break;
> > > +
> > > +	case BPF_REDIRECT:
> > > +		if (!can_redirect) {
> > > +			WARN_ONCE(1, "Illegal redirect return code in prog %s\n",
> > > +				  lwt->name ? : "<unknown>");
> > > +			ret = BPF_OK;
> > > +		} else {
> > > +			ret = skb_do_redirect(skb);
> > 
> > I think this assumes that program did bpf_skb_push and L2 header is present.
> > Would it make sense to check that mac_header < network_header here to make
> > sure that it actually happened? I think the cost of single 'if' isn't much.
> > Also skb_do_redirect() can redirect to l3 tunnels like ipip ;)
> > so program shouldn't be doing bpf_skb_push in such case...
> 
> We are currently guaranteeing mac_header <= network_header given that
> bpf_skb_push() is calling skb_reset_mac_header() unconditionally.
> 
> Even if a program were to push an L2 header and then redirect to an l3
> tunnel, __bpf_redirect_no_mac will pull it off again and correct the
> mac_header offset.

yes. that part is fine.

> Should we check in __bpf_redirect_common() whether mac_header <
> nework_header then or add it to lwt-bpf conditional on
> dev_is_mac_header_xmit()?

may be only extra 'if' in lwt-bpf is all we need?
I'm still missing what will happen if we 'forget' to do
bpf_skb_push() inside the lwt-bpf program, but still do redirect
in lwt_xmit stage to l2 netdev...
