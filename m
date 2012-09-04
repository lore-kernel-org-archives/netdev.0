From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] usbnet: drop unneeded check for NULL
Date: Tue, 04 Sep 2012 18:13:18 +0200
Message-ID: <20747715.9FmHp7X6VE@linux-lqwf.site>
References: <1346768514-19823-1-git-send-email-oliver@neukum.org> <20120904155343.GA2170@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39776 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756848Ab2IDQOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 12:14:38 -0400
In-Reply-To: <20120904155343.GA2170@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 04 September 2012 17:53:43 Richard Cochran wrote:
> On Tue, Sep 04, 2012 at 04:21:54PM +0200, Oliver Neukum wrote:
> > usbnet_start_xmit() is always called with a valid skb
> 
> So, has the problem that this test worked around been fixed?

netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
                                     struct net_device *net)
{
        struct usbnet           *dev = netdev_priv(net);
        int                     length;
        struct urb              *urb = NULL;
        struct skb_data         *entry;
        struct driver_info      *info = dev->driver_info;
        unsigned long           flags;
        int retval;

        if (skb)
                skb_tx_timestamp(skb);

        // some devices want funky USB-level framing, for
        // win32 driver (usually) and/or hardware quirks
        if (info->tx_fixup) {
                skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
                if (!skb) {
                        if (netif_msg_tx_err(dev)) {
                                netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
                                goto drop;
                        } else {
                                /* cdc_ncm collected packet; waits for more */
                                goto not_drop;
                        }
                }
        }
        length = skb->len;

If that check is ever needed and tx_fixup not needed, the driver will oops here.
The check is wrong in any case.

	Regards
		Oliver
 
