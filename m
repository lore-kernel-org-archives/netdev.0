From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv2 2.6.24] fib: fix route replacement, fib_info is shared
Date: Tue, 29 Jan 2008 09:49:15 +0100
Message-ID: <20080129084915.GA1624@ff.dom.local>
References: <20080127232018.GA2856@ami.dom.local> <Pine.LNX.4.58.0801290139450.3181@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joonwoo Park <joonwpark81@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:13459 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbYA2Im0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 03:42:26 -0500
Received: by ug-out-1314.google.com with SMTP id z38so152470ugc.16
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 00:42:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0801290139450.3181@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 29, 2008 at 02:30:47AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Mon, 28 Jan 2008, Jarek Poplawski wrote:
> 
> > BTW, the way "add" works wasn't questioned now, but it seems could be,
> > or man ip should call it e.g. "ip route add - add new destination",
> > and append "ip route append" (unless I have old man).
> 
> 	"add" is similar to "prepend", only that checks NLM_F_EXCL
> to avoid many alternative routes, only one route for tos+priority is
> allowed for "add". As for the sorting by tos/priority and the
> insertion position I remember for thread on this issue:

Yes but I've meant this man (8) ip description could be confusing:

"  ip route add - add new route
   ip route change - change route
   ip route replace - change or add new one"

One can wonder why there is an error while adding two new routes with
"add", but OK to do the same with "replace". But, it's "man" problem
of course.

> 
> http://marc.info/?t=109614290600002&r=1&w=2
> 
> > > +		fa = list_entry(fa->fa_list.prev, struct fib_alias, fa_list);
> > > +		list_for_each_entry_continue(fa, &f->fn_alias, fa_list) {
> > > +			if (fa->fa_tos != tos)
> > > +				break;
> > > +			if (fa->fa_info->fib_priority != fi->fib_priority)
> > > +				break;
> > > +			if (fa->fa_type == cfg->fc_type &&
> > > +			    fa->fa_scope == cfg->fc_scope &&
> > > +			    fa->fa_info == fi) {
> > > +				fa_match = fa;
> > > +				break;
> > 
> > Why can't we try goto out from here? (less reading...)
> 
> 	The case with NLM_F_REPLACE needs to check more things, one
> day one can combine NLM_F_APPEND+NLM_F_REPLACE to replace last
> alternative route, not only the first one as currently implemented.

I'm not sure I can understand your point: do you mean there could be
something to do for these options is fa_match exists? But, maybe it
relates to my question below...

> 
> > > +			fa = fa_first;
> > > +			if (fa_match) {
> > > +				if (fa == fa_match)
> > > +					err = 0;
> > 
> > Could you comment more why returning an error seems to depend on the
> > order of aliases here? But, IMHO there is no reason to change the old
> > behavior WRT this error, so probably this err = 0 should be always if
> > NLM_F_REPLACE is set.
> 
> 	fa_match is some existing alias that matches all new parameters.
> As NLM_F_REPLACE changes the first alternative route for 
> tos+priority if fa_match == fa_first (we are replacing alias that
> matches all parameters) we return 0, only that routing cache is not 
> flushed - nothing is replaced/changed. So, "fa == fa_match" means
> "replace will not change existing parameters", return 0 as this is
> not an error.

Probably I miss something, but what parameters do we change if
(fa_match) && (fa != fa_match)? Isn't this "goto out" in any case?

> 
> > PS: I think, this FIB info you sent earlier is just fine for
> > Documentation/networking without any changes! (Maybe one more patch?)
> 
> 	This is so small part of the picture, such 15-minute listing
> is not enough to explain everything. May be such and other information
> can be added as part of some known documentation.

This is small but condensed, and IMHO it fits very well what is now
in this directory.

Thanks,
Jarek P.
