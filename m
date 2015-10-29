From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 1/6] net: dsa: Use delayed work instead of timer+work
 for polling
Date: Thu, 29 Oct 2015 14:51:56 +0100
Message-ID: <20151029135156.GQ2307@lunn.ch>
References: <56321DA1.4060304@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58113 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743AbbJ2NwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 09:52:10 -0400
Content-Disposition: inline
In-Reply-To: <56321DA1.4060304@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2015 at 02:22:41PM +0100, Neil Armstrong wrote:
> Simplifies the code and avoids a crash when removing the
> module:
>  dsa dsa ethmv2 (unregistering): Link is Down
>  device eth1 left promiscuous mode
>  Unable to handle kernel paging request at virtual address bacc5cf6
>  ...
>  (run_timer_softirq) from [<c003e810>] (__do_softirq+0xcc/0x320)
>  (__do_softirq) from [<c003ed40>] (irq_exit+0xac/0x10c)
>  (irq_exit) from [<c007ec20>] (__handle_domain_irq+0x50/0xa8)
> 
> Signed-off-by: Frode Isaksen <fisaksen@baylibre.com>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  include/net/dsa.h |  3 +--
>  net/dsa/dsa.c     | 28 ++++++++--------------------
>  2 files changed, 9 insertions(+), 22 deletions(-)
> 
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index 98ccbde..d4d13f7 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -112,8 +112,7 @@ struct dsa_switch_tree {
>  	 * Link state polling.
>  	 */
>  	int			link_poll_needed;
> -	struct work_struct	link_poll_work;
> -	struct timer_list	link_poll_timer;
> +	struct delayed_work	link_poll_work;
> 
>  	/*
>  	 * Data for the individual switch chips.
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 1eba07f..aeb6a7c 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -513,7 +513,7 @@ static void dsa_link_poll_work(struct work_struct *ugly)
>  	struct dsa_switch_tree *dst;
>  	int i;
> 
> -	dst = container_of(ugly, struct dsa_switch_tree, link_poll_work);
> +	dst = container_of(ugly, struct dsa_switch_tree, link_poll_work.work);
> 
>  	for (i = 0; i < dst->pd->nr_chips; i++) {
>  		struct dsa_switch *ds = dst->ds[i];
> @@ -522,17 +522,9 @@ static void dsa_link_poll_work(struct work_struct *ugly)
>  			ds->drv->poll_link(ds);

Hi Neil, Frode

I assume you have see:

http://permalink.gmane.org/gmane.linux.network/380777

which is now in net-next.

The only driver making use of poll_link is mv88e6060.c. The argument
from removing it from the other mv88e6xxx drivers is that it is not
needed. The phylib will be polling the phys and looking for state
changes. mv88e6060.c implements phy_read() and phy_write() so it
should also allow the use of phylib.

Could you try 6060 without .poll_link. If that works, we should be
able to remove all this code, rather than fix it up.

     Andrew
