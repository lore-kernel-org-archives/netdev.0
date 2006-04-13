From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: via_rhine modules error on 2.6.16 with mii-tool
Date: Thu, 13 Apr 2006 11:40:18 -0700
Message-ID: <20060413114018.65fba555@localhost.localdomain>
References: <BAY103-F401F96F0B06D75E70AF0BFB2DF0@phx.gbl>
	<20060327203946.GA11824@k3.hellgate.ch>
	<20060413182638.GC25854@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roger Luethi <rl@hellgate.ch>, Marco Berizzi <pupilla@hotmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37809 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964950AbWDMSkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 14:40:31 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060413182638.GC25854@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 14:26:43 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> On Mon, Mar 27, 2006 at 10:39:46PM +0200, Roger Luethi wrote:
> > On Fri, 24 Mar 2006 16:49:10 +0100, Marco Berizzi wrote:
> > > Hello evebody.
> > > I get this error on linux vanilla 2.6.16
> > > with via_rhine module loaded  when
> > > I run mii-tool:
> > 
> > That was caused by a recent change that replaced an mdelay with msleep.
> > 
> > netdev_ioctl and friends (ethtool calls, too) are known to grab a spin lock
> > before they do much of anything, and they hang onto it until they're done.
> > They also call mdio_read/write, which requires millisecond delays on Rhine-I.
> > 
> > So on Rhine-I with a 2.6.15+ kernel, the driver ends up calling msleep
> > while holding a spin lock -- hence the stack dump.
> > 
> > I wonder if low latency for ancient Rhine-I chips is worth the trouble.
> 
> IIRC, the point was that mdelay was getting called in interrupt
> context and causing ugly messages to show-up in dmesg.
> 
> Would the patch below be sufficient?  Or does the whole patch need
> to be reverted?
> 
> John
> 
> diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
> index 2418715..e7b4bc3 100644
> --- a/drivers/net/via-rhine.c
> +++ b/drivers/net/via-rhine.c
> @@ -1145,8 +1130,8 @@ static void rhine_disable_linkmon(void _
>  	if (quirks & rqRhineI) {
>  		iowrite8(0x01, ioaddr + MIIRegAddr);	// MII_BMSR
>  
> -		/* Do not call from ISR! */
> -		msleep(1);
> +		/* Can be called from ISR. Evil. */
> +		mdelay(1);
>  
>  		/* 0x80 must be set immediately before turning it off */
>  		iowrite8(0x80, ioaddr + MIICmd);

The right thing to do is get rid of the locking in via_rhine:netdev_ioctl and push
the locking down into mdio_read, mdio_write.
