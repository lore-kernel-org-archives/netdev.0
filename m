From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net-next V2 1/2] xen-netback: split
 event channels support for Xen backend driver
Date: Wed, 22 May 2013 09:05:55 +0100
Message-ID: <519C988302000078000D8018@nat28.tlf.novell.com>
References: <1369161310-9529-1-git-send-email-wei.liu2@citrix.com>
 <1369161310-9529-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xen.org>, <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:34065 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232Ab3EVIGB convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Wed, 22 May 2013 04:06:01 -0400
In-Reply-To: <1369161310-9529-2-git-send-email-wei.liu2@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 21.05.13 at 20:35, Wei Liu <wei.liu2@citrix.com> wrote:
> @@ -158,4 +163,6 @@ void xenvif_carrier_off(struct xenvif *vif);
>  /* Returns number of ring slots required to send an skb to the frontend */
>  unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb);
>  
> +extern unsigned int feature_split_event_channels;

This gets used exclusively as a boolean, so ought to be bool.

> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -114,6 +114,15 @@ static int netback_probe(struct xenbus_device *dev,
>  			goto abort_transaction;
>  		}
>  
> +		/* Split event channels support */
> +		err = xenbus_printf(xbt, dev->nodename,
> +				"feature-split-event-channels",
> +				"%u", feature_split_event_channels);
> +		if (err) {
> +			message = "writing feature-split-event-channels";
> +			goto abort_transaction;

We had this discussion elsewhere quite recently: Failure to write
extension nodes should not be fatal - this needs to even be moved
out of the containing loop afaict.

> +	/* Try split event channels first, then single event channel. */
> +	err = xenbus_gather(XBT_NIL, dev->otherend,
> +			    "event-channel-tx", "%u", &tx_evtchn,
> +			    "event-channel-rx", "%u", &rx_evtchn, NULL);
> +	if (err) {
> +		err = xenbus_gather(XBT_NIL, dev->otherend,
> +				    "event-channel", "%u", &tx_evtchn, NULL);

And this got discussed quite recently too: Single item reads should
use xenbus_scanf() as being the simpler interface doing better type
checking.

Jan
