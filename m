From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: log: protect nf_log_register against double
 registering
Date: Wed, 22 Oct 2014 18:44:39 +0200
Message-ID: <20141022164439.GA3698@salvia>
References: <c7fcb46fa24c1a64f00c9322bb5cddbde977da0a.1413842217.git.mleitner@redhat.com>
 <20141022120255.GA21821@salvia>
 <5447A429.3030608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5447A429.3030608@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 22, 2014 at 10:33:45AM -0200, Marcelo Ricardo Leitner wrote:
> On 22-10-2014 10:02, Pablo Neira Ayuso wrote:
> >On Mon, Oct 20, 2014 at 07:58:03PM -0200, Marcelo Ricardo Leitner wrote:
> >>Currently, despite the comment right before the function,
> >>nf_log_register allows registering two loggers on with the same type and
> >>end up overwriting the previous register.
> >>
> >>Not a real issue today as current tree doesn't have two loggers for the
> >>same type but it's better to get this protected.
> >>
> >>Also make sure that all of its callers do error checking.
> >
> >No major objetions to this sanity check. Some comment below.
> >
> >>Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> >>---
> >>
> >>Notes:
> >>     Please let me know if you have any issues with the identation on
> >>     nf_log_register. I just couldn't find a better one.
> >
> >You can split nf_log_register() in two functions to avoid this.
> 
> Sorry but I don't follow this one. You mean having the check on
> nf_log_register() and then calling a __nf_log_register() to actually
> register it?
> 
> Now I'm thinking on wrapping
>             rcu_dereference_protected(loggers[i][logger->type],
> +					lockdep_is_held(&nf_log_mutex))
> into a macro or something like that, because that's the issue in
> there and this construction is called several times. Something like:
> 
> #define logger_deref_protected(pf, type) \
>         rcu_dereference_protected(loggers[pf][type], \
>                                   lockdep_is_held(&nf_log_mutex));
> 
> WDYT?

Seems OK, I think this can be:

#define nft_log_dereference(logger)

So you can use this both from net->nf.nf_loggers[x] and
loggers[x][y] and we have one single macro and we avoid the indent
issues.

Thanks.
