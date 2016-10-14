From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net 2/2] conntrack: enable to tune gc parameters
Date: Fri, 14 Oct 2016 12:37:26 +0200
Message-ID: <20161014103726.GA10404@breakpoint.cc>
References: <1476094704-17452-1-git-send-email-nicolas.dichtel@6wind.com>
 <1476094704-17452-3-git-send-email-nicolas.dichtel@6wind.com>
 <20161010140424.GB21057@breakpoint.cc>
 <cdda5290-c49c-e841-6ba5-10b30fd04fc0@6wind.com>
 <20161013204338.GA32449@breakpoint.cc>
 <f1df137d-7278-f6fb-3237-1bd20afadb48@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Cc: Florian Westphal <fw@strlen.de>, davem@davemloft.net,
        pablo@netfilter.org, netdev@vger.kernel.org,
        netfilter-devel@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41866 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751939AbcJNKiW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 06:38:22 -0400
Content-Disposition: inline
In-Reply-To: <f1df137d-7278-f6fb-3237-1bd20afadb48@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> Le 13/10/2016 à 22:43, Florian Westphal a écrit :
> > Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> >> Le 10/10/2016 à 16:04, Florian Westphal a écrit :
> >>> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> >>>> After commit b87a2f9199ea ("netfilter: conntrack: add gc worker to remove
> >>>> timed-out entries"), netlink conntrack deletion events may be sent with a
> >>>> huge delay. It could be interesting to let the user tweak gc parameters
> >>>> depending on its use case.
> >>>
> >>> Hmm, care to elaborate?
> >>>
> >>> I am not against doing this but I'd like to hear/read your use case.
> >>>
> >>> The expectation is that in almot all cases eviction will happen from
> >>> packet path.  The gc worker is jusdt there for case where a busy system
> >>> goes idle.
> >> It was precisely that case. After a period of activity, the event is sent a long
> >> time after the timeout. If the router does not manage a lot of flows, why not
> >> trying to parse more entries instead of the default 1/64 of the table?
> >> In fact, I don't understand why using GC_MAX_BUCKETS_DIV instead of using always
> >> GC_MAX_BUCKETS whatever the size of the table is.
> > 
> > I wanted to make sure that we have a known upper bound on the number of
> > buckets we process so that we do not block other pending kworker items
> > for too long.
> I don't understand. GC_MAX_BUCKETS is the upper bound and I agree that it is
> needed. But why GC_MAX_BUCKETS_DIV (ie 1/64)?
> In other words, why this line:
> goal = min(nf_conntrack_htable_size / GC_MAX_BUCKETS_DIV, GC_MAX_BUCKETS);
> instead of:
> goal = GC_MAX_BUCKETS;

Sure, we can do that.  But why is a fixed size better than a fraction?

E.g. with 8k buckets and simple goal = GC_MAX_BUCKETS we scan entire
table on every run, currently we only scan 128.

I wanted to keep too many destroy notifications from firing at once
but maybe i was too paranoid...

> > (Or cause too many useless scans)
> > 
> > Another idea worth trying might be to get rid of the max cap and
> > instead break early in case too many jiffies expired.
> > 
> > I don't want to add sysctl knobs for this unless absolutely needed; its already
> > possible to 'force' eviction cycle by running 'conntrack -L'.
> > 
> Sure, but this is not a "real" solution, just a workaround.
> We need to find a way to deliver conntrack deletion events in a reasonable
> delay, whatever the traffic on the machine is.

Agree, but that depends on what 'reasonable' means and what kind of
uneeded cpu churn we're willing to add.

We can add a sysctl for this but we should use a low default to not do
too much unneeded work.

So what about your original patch, but only add

nf_conntrack_gc_interval

(and also add instant-resched in case entire budget was consumed)?
