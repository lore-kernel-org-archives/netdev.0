From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH] atm: br2684: Fix excessive queue bloat
Date: Sun, 25 Nov 2012 22:43:33 +0100
Message-ID: <20121125214332.GA2722@shrek.podlesie.net>
References: <1353715292.26346.237.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, John Crispin <blogic@openwrt.org>,
	Dave =?iso-8859-1?Q?T=E4ht?= <dave.taht@gmail.com>,
	"Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [93.179.225.50] ([93.179.225.50]:44353 "EHLO shrek.podlesie.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753474Ab2KYVne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2012 16:43:34 -0500
Content-Disposition: inline
In-Reply-To: <1353715292.26346.237.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 24, 2012 at 12:01:32AM +0000, David Woodhouse wrote:
> There's really no excuse for an additional wmem_default of buffering
> between the netdev queue and the ATM device. Two packets (one in-flight,
> and one ready to send) ought to be fine. It's not as if it should take
> long to get another from the netdev queue when we need it.
> 
> If necessary we can make the queue space configurable later, but I don't
> think it's likely to be necessary.

Maybe some high-speed devices will require larger queue, especially for
smaller packets, but 2 packet queue should be sufficient in almost all cases.

>  static inline struct br2684_vcc *pick_outgoing_vcc(const struct sk_buff *skb,
> @@ -504,6 +505,11 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
>  	brvcc = kzalloc(sizeof(struct br2684_vcc), GFP_KERNEL);
>  	if (!brvcc)
>  		return -ENOMEM;
> +	/* Allow two packets in the ATM queue. One actually being sent, and one
> +	   for the ATM 'TX done' handler to send. It shouldn't take long to get
> +	   the next one from the netdev queue, when we need it. More than that
> +	   would be bufferbloat. */
> +	atomic_set(&brvcc->qspace, 2);

Maybe this magic "2" and the comment should be moved to some #define.

>  	write_lock_irq(&devs_lock);
>  	net_dev = br2684_find_dev(&be.ifspec);
>  	if (net_dev == NULL) {

Looks good,

Reviewed-by: Krzysztof Mazur <krzysiek@podlesie.net>

Krzysiek
