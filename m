From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next V2 1/2] xen-netback: split event channels
 support for Xen backend driver
Date: Wed, 22 May 2013 16:50:55 +0100
Message-ID: <20130522155055.GB4543@zion.uk.xensource.com>
References: <1369161310-9529-1-git-send-email-wei.liu2@citrix.com>
 <1369161310-9529-2-git-send-email-wei.liu2@citrix.com>
 <519CE6F9.8080307@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>,
	<konrad.wilk@oracle.com>, <david.vrabel@citrix.com>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:1761 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397Ab3EVPu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 11:50:57 -0400
Content-Disposition: inline
In-Reply-To: <519CE6F9.8080307@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 11:40:41AM -0400, annie li wrote:
> 
> On 2013-5-21 14:35, Wei Liu wrote:
> >[....]
> >+
> >  static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  {
> >  	struct xenvif *vif = netdev_priv(dev);
> >@@ -125,13 +143,15 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
> >  static void xenvif_up(struct xenvif *vif)
> >  {
> >  	xen_netbk_add_xenvif(vif);
> >-	enable_irq(vif->irq);
> >+	enable_irq(vif->tx_irq);
> >+	enable_irq(vif->rx_irq);
> 
> enable_irq are called twice in one event channel situation. How
> about adding if condition here to differ one event channel and split
> event channel?
> 

Sure, if this makes code better comprehensible.

> >+	/* Try split event channels first, then single event channel. */
> >+	err = xenbus_gather(XBT_NIL, dev->otherend,
> >+			    "event-channel-tx", "%u", &tx_evtchn,
> >+			    "event-channel-rx", "%u", &rx_evtchn, NULL);
> >+	if (err) {
> >+		err = xenbus_gather(XBT_NIL, dev->otherend,
> >+				    "event-channel", "%u", &tx_evtchn, NULL);
> >+		if (err) {
> >+			xenbus_dev_fatal(dev, err,
> >+					 "reading %s/event-channel(-tx/rx)",
> >+					 dev->otherend);
> 
> This err really comes from reading original implementation(one event
> channel), right? So it is better to not use (-tx/rx) here?
> Or using two xenbus_dev_fatal to print log: one for reading tx/rx
> failure, the other for one event channel failure.
> 

The failure of reading split event channels doesn't imply a fatal error.
Here the fatal error is trying to read both split event channels and
single event channel and fail.

If people really want to debug this problem, they should look at
xenstore entries instead of relying on this log message.


Wei.

> Thanks
> Annie
