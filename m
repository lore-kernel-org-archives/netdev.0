From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next V2 1/1] tcp: Prevent needless syn-ack rexmt
 during TWHS
Date: Sat, 27 Oct 2012 16:23:05 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1210271556250.1628@ja.ssi.bg>
References: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com> <1351339032.30380.222.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34635 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754910Ab2J0NQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Oct 2012 09:16:52 -0400
In-Reply-To: <1351339032.30380.222.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 27 Oct 2012, Eric Dumazet wrote:

> > @@ -598,9 +598,8 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
> >  					       &expire, &resend);
> >  				req->rsk_ops->syn_ack_timeout(parent, req);
> >  				if (!expire &&
> > -				    (!resend ||
> > -				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL) ||
> > -				     inet_rsk(req)->acked)) {
> > +				    (!resend || inet_rsk(req)->acked ||
> > +				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL))) {
> >  					unsigned long timeo;
> >  
> >  					if (req->retrans++ == 0)
> 
> 
> Part of the complexity of this is that req->retrans is the number of
> timeouts, serving as the exponential backoff base.
> 
> Unfortunately we have a side effect because number of retransmits is
> wrong for defer accept.
> 
> Here is what I suggest : upstream to net-next this patch we use at
> Google :
> 
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Tue Oct 2 02:21:12 2012 -0700
> 
> net-tcp: better retrans tracking for defer-accept
> 
> For passive TCP connections using TCP_DEFER_ACCEPT facility,
> we incorrectly increment req->retrans each time timeout triggers
> while no SYNACK is sent.
> 
> Decouple req->retrans field into two fields :
> 
> num_retrans : number of retransmit
> num_timeout : number of timeouts
> 
> (retrans was renamed to make sure we didnt miss an occurrence)
> 
> introduce inet_rtx_syn_ack() helper to increment num_retrans
> only if ->rtx_syn_ack() succeeded.

	This is dangerous, the first of the cases is route
failure, what if we just added reject route for some attacker?
We will get error forever. May be it is difficult to decide
which error should change the counter. IMHO, such reliability
is not needed, we can be short of memory too.

> Use inet_rtx_syn_ack() from tcp_check_req() to increment num_retrans
> when we re-send a SYNACK in answer to a SYN. Prior to this patch,
> we were not counting these retransmits.

	Such change looks correct. Of course, it has
side effect on current TCP_DEFER_ACCEPT calculations but
it is a TCP_DEFER_ACCEPT implementation problem.

> Change tcp_v[46]_rtx_synack() to increment TCP_MIB_RETRANSSEGS
> only if a synack packet was successfuly queued.

Regards

--
Julian Anastasov <ja@ssi.bg>
