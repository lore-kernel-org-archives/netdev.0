From: jamal <hadi@cyberus.ca>
Subject: Re: [RFR] gianfar ethernet driver
Date: 05 Jul 2004 22:38:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089081499.1068.66.camel@jzny.localdomain>
References: <8F52CF1D-C916-11D8-BB6A-000393DBC2E8@freescale.com>
	 <40E98FB8.4070900@pobox.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>,
        David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40E98FB8.4070900@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-07-05 at 13:28, Jeff Garzik wrote:
> (CC to netdev added)
> 
> Kumar,
> 
> I've merged the gianfar driver into my netdev-2.6 queue.  This will get 
> it automatically propagated into the -mm tree, and once some of these 
> comments are resolved/discussed, pushed upstream as well.
> 
> Follow-up patches should be incremental to this (your) patch.
> 
> 
> Others,
> 
> I've attached the patch as Kumar submitted it.  Please review.
> 
> 
> 
> Comments:

Some pretty good comments there Jeff.

> 1) Share the knowledge.  Please CC comments (and criticisms!) to netdev.
> 
> 2) I'm strongly pondering vetoing try_fastroute() code in this driver. 
> Surely this should be in core net stack code... if it isn't already?  Jamal?

I hardly know anybody still using this interface - i believe it is not
useful after NAPI; maybe this comment would bring out some of the
believers out of the woodwork to comment.
Otherwise i would say kill it.


> 8) I recommend enabling _both_ hardware interrupt coalescing and NAPI, 
> at the same time.  Several other Linux net drivers need to be changed to 
> do this, as well

Under low rates having both helps (by reducing the amount of PCI
operations - at the expense of some added latency)

> 18) As Jamal recently noted, no need to test netif_queue_stopped()
> 

Since it is a new driver why dont we have him do more work? <evil grin
here, should that be followed by a loud eerie muhahahaha?> ;->

1) The check (in gfar_start_xmit()):

Should happen much sooner - i.e before the skb is touched.

if (txbdp == priv->dirty_tx) {
	netif_stop_queue(dev)
	unlock
	return 1;
}
The rest of your code goes here ..

Do this before the skb is touched. Note the return 1. This means dont
add it to your priv->tx_skbuff[priv->skb_curtx] = skb before you do
this.
Dont understand why you have your own proivate list btw.

2) Also its pretty scary if you are doing:
txbdp->status |= TXBD_INTERRUPT for every packet.
Look at other drivers, they try to do this every few packets;
or enable tx mitigation to slow the rate  of those interupts.

cheers,
jamal
