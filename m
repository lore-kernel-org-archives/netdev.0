From: jamal <hadi@cyberus.ca>
Subject: Re: [RFR] gianfar ethernet driver
Date: 07 Jul 2004 14:29:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089224952.1027.340.camel@jzny.localdomain>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com>
	 <89563A5C-CFAE-11D8-BA44-000393C30512@freescale.com>
	 <1089170282.1038.80.camel@jzny.localdomain>
	 <20040707032913.GA1822@havoc.gtf.org>
	 <1089171693.1037.87.camel@jzny.localdomain>  <40EB8B84.7040301@pobox.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
        Kumar Gala <kumar.gala@freescale.com>, netdev@oss.sgi.com,
        dwmw2@infradead.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40EB8B84.7040301@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-07-07 at 01:35, Jeff Garzik wrote:

> > 
> > True returning 0 this is not wrong; it
> > results in an extra call in the layer above the driver.
> > (I was trying to point that out in earlier email)
> 
> er, I'm confused now?
> 
> Every single ethernet driver returns zero, when it has queued a packet 
> to hardware :)  That's the common case, I would hope it doesn't result 
> in additional work.

Its a small optimization. In either case, the xmit() will not be invoked
again until device wakes up - so both models are fine from that
perspective. In the case of returning a zero there will be a few more
lines of code executed trying to see if qdisc has a packet before
realizing the device is stopped and requeueing that packet.
Not something to sweat over to be honest. If i had 1000 hours available
and nothing fun to work on (theres always something fun to do) then i
will start changing things. I think you should encourage new drivers to
use the return 1 scheme though.

> > 
> > Ok, I overlooked fragments. I think it would be useful to capture this
> > in the doc you were preping. BTW, why can you figure out the fragment
> > count? If you can then the check for number of descriptors availabel
> > could account for that.
> 
> In one design, you can say
> 
> 	queue packet
> 	if (free descriptors < MAX_SKB_FRAGS)
> 		netif_stop_queue()
> 	return 0
> 
> That design wastes descriptors, but ensures you always have enough room 
> when ->hard_start_xmit is called, and thus ensures you never have to 
> return 1.
> 
> Another design, that attempts to use more descriptors, is
> 
> 	if (free descriptors < skb->frags)
> 		netif_stop_queue()
> 		return 1
> 
> 	queue packet
> 
> 	if (free descriptors == 0)
> 		netif_stop_queue()
> 	return 0
> 

Looking good.

cheers,
jamal
