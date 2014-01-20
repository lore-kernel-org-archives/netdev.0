From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v4 8/9] xen-netback: Timeout packets in RX path
Date: Mon, 20 Jan 2014 16:53:56 +0000
Message-ID: <20140120165356.GF11681@zion.uk.xensource.com>
References: <1389731995-9887-1-git-send-email-zoltan.kiss@citrix.com>
 <1389731995-9887-9-git-send-email-zoltan.kiss@citrix.com>
 <20140116000334.GE5331@zion.uk.xensource.com>
 <52D98427.1060103@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52D98427.1060103@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 17, 2014 at 07:27:35PM +0000, Zoltan Kiss wrote:
> On 16/01/14 00:03, Wei Liu wrote:
> >On Tue, Jan 14, 2014 at 08:39:54PM +0000, Zoltan Kiss wrote:
> >[...]
> >>diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> >>index 109c29f..d1cd8ce 100644
> >>--- a/drivers/net/xen-netback/common.h
> >>+++ b/drivers/net/xen-netback/common.h
> >>@@ -129,6 +129,9 @@ struct xenvif {
> >>  	struct xen_netif_rx_back_ring rx;
> >>  	struct sk_buff_head rx_queue;
> >>  	RING_IDX rx_last_skb_slots;
> >
> >Hmm... You seemed to mix your other patch with this series. :-)
> Yep, this series doesn't work without that patch (actually that is a
> bug in netback even without my series), so at the moment it is based
> on it.
> 
> >
> >>+	bool rx_queue_purge;
> >>+
> >>+	struct timer_list wake_queue;
> >>
> >>  	/* This array is allocated seperately as it is large */
> >>  	struct gnttab_copy *grant_copy_op;
> >>@@ -225,4 +228,7 @@ void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx);
> >>
> >>  extern bool separate_tx_rx_irq;
> >>
> >[...]
> >>@@ -559,7 +579,7 @@ void xenvif_free(struct xenvif *vif)
> >>  		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
> >>  			unmap_timeout++;
> >>  			schedule_timeout(msecs_to_jiffies(1000));
> >>-			if (unmap_timeout > 9 &&
> >>+			if (unmap_timeout > ((rx_drain_timeout_msecs/1000) * DIV_ROUND_UP(XENVIF_QUEUE_LENGTH, (XEN_NETIF_RX_RING_SIZE / MAX_SKB_FRAGS))) &&
> >
> >This line is really too long. And what's the rationale behind this long
> >expression?
> It calculates how many times you should ditch the internal queue of
> an another (maybe stucked) vif before Qdisc empties it's actual
> content. After that there shouldn't be any mapped handle left, so we
> should start printing these messages. Actually it should use
> vif->dev->tx_queue_len, and yes, it is probably better to move it to
> the beginning of the function into a new variable, and use that
> here.
> 

Why is relative to tx queue length?

What's the meaning of drain_timeout multipled by the last part
(DIV_ROUND_UP)?

If you proposed to use vif->dev->tx_queue_len to replace DIV_ROUND_UP
then ignore the above question. But I still don't understand the
rationale behind this. Could you elaborate a bit more? Wouldn't
rx_drain_timeout_msecs/1000 along suffice?

Wei.

> Zoli
