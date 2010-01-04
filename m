From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: Fix oops in sky2_xmit_frame() after TX timeout
Date: Mon, 4 Jan 2010 10:26:37 -0800
Message-ID: <20100104102637.16734638@nehalam>
References: <4B3C8323.1080301@ring3k.org>
	<4B3CF2C4.5070203@gmail.com>
	<4B3D38FB.40105@ring3k.org>
	<20100101183155.GA8519@del.dom.local>
	<4B41560C.4040500@gmail.com>
	<20100104134904.GA18583@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Berck E. Nash" <flyboy@gmail.com>,
	Mike McCormack <mikem@ring3k.org>, netdev@vger.kernel.org,
	dhazelton@enter.net, mbreuer@majjas.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43086 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752983Ab0ADS07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 13:26:59 -0500
In-Reply-To: <20100104134904.GA18583@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 4 Jan 2010 13:49:04 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On Sun, Jan 03, 2010 at 07:44:28PM -0700, Berck E. Nash wrote:
> > Jarek Poplawski wrote:
> > > Yes, it seems this lock might be needed around this place, but I'd
> > > like to check another idea: if it's not about awakening too early.
> > > Berck, could you try this patch?
> > 
> > Okay, after running with that for several days I have not gotten the
> > oops.  That doesn't mean that I won't tomorrow, but I've gotten several
> > of these:
> > 
> > [45621.704025] sky2 eth0: hung mac 124:21 fifo 195 (127:122)
> > [45621.704027] sky2 eth0: receiver hang detected
> > [45621.708524] sky2 eth0: disabling interface
> > [45621.715229] sky2 eth0: enabling interface
> > [45624.862111] sky2 eth0: Link is up at 1000 Mbps, full duplex, flow
> > control both
> > [61024.704036] sky2 eth0: hung mac 124:75 fifo 195 (133:128)
> > [61024.704039] sky2 eth0: receiver hang detected
> > [61024.708487] sky2 eth0: disabling interface
> > [61024.714791] sky2 eth0: enabling interface
> > [61027.864288] sky2 eth0: Link is up at 1000 Mbps, full duplex, flow
> > control both
> > 
> > And it hasn't crashed.  The "receiver hang detected" would often (but
> > not always) be followed by the oops before.
> > 
> > Berck
> 
> OK, here it is with some cosmetics; let David decide if it needs more
> testing.
> 
> Thanks everybody,
> Jarek P.
> ------------->
> 
> During TX timeout procedure dev could be awaken too early, e.g. by
> sky2_complete_tx() called from sky2_down(). Then sky2_xmit_frame()
> can run while buffers are freed causing an oops. This patch fixes it
> by adding netif_device_present() test in sky2_tx_complete().
> 
> Fixes: http://bugzilla.kernel.org/show_bug.cgi?id=14925
> 
> With debugging by: Mike McCormack <mikem@ring3k.org>
> 
> Reported-by: Berck E. Nash <flyboy@gmail.com>
> Tested-by: Berck E. Nash <flyboy@gmail.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> ---
> 
>  drivers/net/sky2.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 1c01b96..2f32fab 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -1844,7 +1844,9 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
>  	sky2->tx_cons = idx;
>  	smp_mb();
>  
> -	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
> +	/* Wake unless it's detached, and called e.g. from sky2_down() */
> +	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4 &&
> +	    likely(netif_device_present(dev)))
>  		netif_wake_queue(dev);
>  }
>

The likely() seems unnecessary noise here. It can't possibly matter that
much.


-- 
