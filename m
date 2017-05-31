From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH V3] neigh: Really delete an arp/neigh entry on "ip neigh
 delete" or "arp -d"
Date: Thu, 1 Jun 2017 01:41:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1706010059370.10214@ja.home.ssi.bg>
References: <1496188346-83229-1-git-send-email-sowmini.varadhan@oracle.com> <alpine.LFD.2.20.1705312337280.5775@ja.home.ssi.bg> <20170531214639.GH9362@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56854 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751570AbdEaWmA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 18:42:00 -0400
In-Reply-To: <20170531214639.GH9362@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 31 May 2017, Sowmini Varadhan wrote:

> On (06/01/17 00:41), Julian Anastasov wrote:
> > 
> > 	So, we do not hold reference to neigh while accessing
> > its fields. I suspect we need to move the table lock from
> > neigh_remove_one here, for example:
> 
> good point, let me think over your suggestion carefully (it sounds
> right, I want to make sure I dont miss any other race-windows)
> and post patch v4 tomorrow..

	Another problem is that neigh_update() changes the
state but before we go and unlink the entry another CPU
can reactivate the entry, i.e. NUD_INCOMPLETE entered
in __neigh_event_send(). So, there will be always some
small window where surprises can happen and the entry is
not really deleted.

	Checking for NUD_FAILED may not be needed, the
atomic_read(&n->refcnt) == 1 check under lock ensures
that we are in some state without timer, i.e. not in
NUD_INCOMPLETE, so it is ok to remove the entry.

> > 	Another solution to cause faster removal would be
> > to cancel the gc_work and to schedule it after 1 jiffie.
> > It helps when many entries are deleted at once but the
> > work prefers to just sleep when gc_thresh1 is not reached,
> > so such solution is not good enough.
> 
> Right the other drawback of relying on gc for cleanup is
> that it doesn't give higher preference to cleaning up FAILED
> entries first- so it can end up cleaning up other useful entries
> (as I was pointing out to David Ahern)

	I see, ok.

Regards
