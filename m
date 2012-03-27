From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [STRAW MAN PATCH] sch_teql doesn't load-balance ppp(oatm)
 slaves
Date: Tue, 27 Mar 2012 21:55:38 +0200
Message-ID: <1332878138.3547.41.camel@edumazet-glaptop>
References: <1332450218.32446.79.camel@shinybook.infradead.org>
	 <20120322.230331.1623101647193498167.davem@davemloft.net>
	 <1332672230.32446.160.camel@shinybook.infradead.org>
	 <20120325.173635.1909319488008466320.davem@davemloft.net>
	 <1332875447.2058.48.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, paulus@samba.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57243 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755511Ab2C0Tzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 15:55:42 -0400
Received: by eekc41 with SMTP id c41so87130eek.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 12:55:41 -0700 (PDT)
In-Reply-To: <1332875447.2058.48.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-03-27 at 20:10 +0100, David Woodhouse wrote:
> On Sun, 2012-03-25 at 17:36 -0400, David Miller wrote:
> > Yes, the ATM devices deep transmit queue is quite undesirable.
> 
> This should fix that, and while I'm at it should fix the gratuitous
> running of ppp_output_wakeup() from a tasklet on *every* packet, when
> it's almost never necessary. Some careful eyes over the locking issues
> on that would be much appreciated. I've documented how I *think* it
> works...
> 
> I'm tempted to rip out the atm_may_send() bit; there's not a lot of
> point in checking against sk_sndbuf when we're limiting to two packets
> anyway, is there? There's always been a problem here if sk_sndbuf was
> set lower than the MTU of the interface; it would block for ever.
> 
> I'm running this now on my ADSL router. I can watch it working, keeping
> precisely two packets in the queue at a time (one really in-flight and
> one ready for the ATM driver). My leftover debugging in sch_teql is
> triggering when the xmit returns NETDEV_TX_BUSY, and all seems to be
> well.
> 
> --- net/atm/pppoatm.c~	2012-03-27 19:59:54.379565896 +0100
> +++ net/atm/pppoatm.c	2012-03-27 20:03:02.676561017 +0100
> @@ -62,10 +62,13 @@ struct pppoatm_vcc {
>  	void (*old_pop)(struct atm_vcc *, struct sk_buff *);
>  					/* keep old push/pop for detaching */
>  	enum pppoatm_encaps encaps;
> +	atomic_t inflight;
> +	unsigned long blocked;
>  	int flags;			/* SC_COMP_PROT - compress protocol */
>  	struct ppp_channel chan;	/* interface to generic ppp layer */
>  	struct tasklet_struct wakeup_tasklet;
>  };
> +#define BLOCKED 0
>  
>  /*
>   * Header used for LLC Encapsulated PPP (4 bytes) followed by the LCP protocol
> @@ -102,16 +105,31 @@ static void pppoatm_wakeup_sender(unsign
>  static void pppoatm_pop(struct atm_vcc *atmvcc, struct sk_buff *skb)
>  {
>  	struct pppoatm_vcc *pvcc = atmvcc_to_pvcc(atmvcc);
> +
>  	pvcc->old_pop(atmvcc, skb);
> +	smp_mb__before_atomic_dec();

I have no idea why you added all these barriers...

> +	atomic_dec(&pvcc->inflight);
> +
>  	/*
