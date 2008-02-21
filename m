From: Joe Perches <joe@perches.com>
Subject: Re: printk_ratelimit and net_ratelimit conflict and tunable
	behavior
Date: Wed, 20 Feb 2008 23:00:46 -0800
Message-ID: <1203577246.7181.241.camel@localhost>
References: <7BFDACCD6948EF4D8FE8F4888A91596A016371E8@tx14exm60.ds.mot.com>
	 <20080220.223219.165157596.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Steve.Hawkes@motorola.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1852 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752747AbYBUHBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 02:01:11 -0500
In-Reply-To: <20080220.223219.165157596.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-20 at 22:32 -0800, David Miller wrote:
> > +		if (lost) {
> > +			printk(KERN_WARNING
> > +			       "printk: %d %s%smessage%s suppressed.\n",
> > +			       lost,
> > +			       (state->facility == 0 ? "" :
> > state->facility),
> > +			       (state->facility == 0 ? "" : " "),
> > +			       (lost > 1 ? "s" : ""));
> > +		}
> >  		return 1;
> >  	}

This compares a pointer to 0.

How about something like:

	if (lost)
		pr_warn("printk: %s suppressed message count: %d\n",
			state->facility ? : "ratelimit", lost);

> > -	missed++;
> > +	state->missed++;
> >  	spin_unlock_irqrestore(&ratelimit_lock, flags);
> >  	return 0;
> >  }
> > @@ -1280,8 +1290,18 @@ int printk_ratelimit_burst = 10;
> >  
> >  int printk_ratelimit(void)
> >  {
> > +	static struct printk_ratelimit_state limit_state = {
> > +		.toks          = 10 * 5 * HZ,
> > +		.last_jiffies  = 0,
> > +		.missed        = 0,
> > +		.limit_jiffies = 5 * HZ,
> > +		.limit_burst   = 10,
> > +		.facility      = 0
> > +	};
> > +

.facility = NULL


