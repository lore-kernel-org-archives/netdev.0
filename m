From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] net: adding memory barrier to the poll and receive
	callbacks
Date: Mon, 29 Jun 2009 19:32:17 +0200
Message-ID: <20090629173217.GC2742@ami.dom.local>
References: <20090629140434.GE3845@jolsa.lab.eng.brq.redhat.com> <20090629141445.GF3845@jolsa.lab.eng.brq.redhat.com> <alpine.DEB.1.10.0906290826300.29966@makko.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, oleg@redhat.com, eric.dumazet@gmail.com
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:58375 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbZF2Rc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 13:32:26 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906290826300.29966@makko.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 08:34:55AM -0700, Davide Libenzi wrote:
> On Mon, 29 Jun 2009, Jiri Olsa wrote:
> 
> > -static inline void poll_wait(struct file * filp, wait_queue_head_t * wait_address, poll_table *p)
> > +static inline void __poll_wait(struct file *filp,
> > +				wait_queue_head_t *wait_address, poll_table *p)
> > +{
> > +	p->qproc(filp, wait_address, p);
> > +}
> > +
> > +static inline void poll_wait(struct file *filp,
> > +				wait_queue_head_t *wait_address, poll_table *p)
> >  {
> >  	if (p && wait_address)
> > -		p->qproc(filp, wait_address, p);
> > +		__poll_wait(filp, wait_address, p);
> >  }
> 
> > +static inline void sock_poll_wait(struct file *filp, struct sock *sk,
> > +		poll_table *p)
> > +{
> > +	if (p && sk->sk_sleep) {
> > +		__poll_wait(filp, sk->sk_sleep, p);
> > +		/*
> > +		 * We need to be sure we are in sync with the
> > +		 * socket flags modification.
> > +		 *
> > +		 * This memory barrier is paired in the sk_has_sleeper.
> > +		*/
> > +		smp_mb();
> > +	}
> > +}
> 
> I think Oleg already said this, but you can use directly poll_wait() 
> without adding another abstraction, and the compiler will drop the double 
> check for you:

I think Oleg told about cosmetics and let Jiri to choose. I'd only
add it's not mainly about optimization, but easy showing the main
difference, of course depending on taste.

Jarek P. 
