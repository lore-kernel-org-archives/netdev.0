From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH -v2] ipvs: Remove unused variable ret from
 sync_thread_master()
Date: Thu, 19 Dec 2013 09:23:51 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1312190919160.2940@ja.home.ssi.bg>
References: <1384266864-564-1-git-send-email-geert@linux-m68k.org> <alpine.LFD.2.03.1311130934390.1647@ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Peter Zijlstra <peterz@infradead.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Simon Horman <horms@verge.net.au>,
	Fabio Estevam <festevam@gmail.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35090 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750807Ab3LSHZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 02:25:29 -0500
In-Reply-To: <alpine.LFD.2.03.1311130934390.1647@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 13 Nov 2013, Julian Anastasov wrote:

> On Tue, 12 Nov 2013, Geert Uytterhoeven wrote:
> 
> > net/netfilter/ipvs/ip_vs_sync.c: In function 'sync_thread_master':
> > net/netfilter/ipvs/ip_vs_sync.c:1640:8: warning: unused variable 'ret' [-Wunused-variable]
> > 
> > Commit 35a2af94c7ce7130ca292c68b1d27fcfdb648f6b ("sched/wait: Make the
> > __wait_event*() interface more friendly") changed how the interruption
> > state is returned. However, sync_thread_master() ignores this state,
> > now causing a compile warning.
> > 
> > According to Julian Anastasov <ja@ssi.bg>, this behavior is OK:
> > 
> >     "Yes, your patch looks ok to me. In the past we used ssleep() but IPVS
> >      users were confused why IPVS threads increase the load average. So, we
> >      switched to _interruptible calls and later the socket polling was
> >      added."
> > 
> > Document this, as requested by Peter Zijlstra, to avoid precious developers
> > disappearing in this pitfall in the future.
> > 
> > Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > ---
> > v2: Document that sync_thread_master() ignores the interruption state,
> > 
> >  net/netfilter/ipvs/ip_vs_sync.c |    5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> > index f63c2388f38d..db801263ee9f 100644
> > --- a/net/netfilter/ipvs/ip_vs_sync.c
> > +++ b/net/netfilter/ipvs/ip_vs_sync.c
> > @@ -1637,7 +1637,10 @@ static int sync_thread_master(void *data)
> >  			continue;
> >  		}
> >  		while (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
> > -			int ret = __wait_event_interruptible(*sk_sleep(sk),
> > +			/* (Ab)use interruptible sleep to avoid increasing
> > +			 * the load avg.
> > +			 */
> > +			__wait_event_interruptible(*sk_sleep(sk),
> >  						   sock_writeable(sk) ||
> >  						   kthread_should_stop());
> >  			if (unlikely(kthread_should_stop()))
> 
> 	Fabio Estevam posted similar change too early but
> we are better with such comment.
> 
> Acked-by: Julian Anastasov <ja@ssi.bg>
> 
> 	Also, the TASK_UNINTERRUPTIBLE | TASK_IDLE idea looks good
> to me. If such change is planned may be the above patch
> better not to go via the ipvs-next tree to avoid conflicts?
> As we don't have any changes in this area let us know if
> someone takes the above patch for another tree.

	Simon, lets apply this patch to ipvs-next tree...

Regards

--
Julian Anastasov <ja@ssi.bg>
