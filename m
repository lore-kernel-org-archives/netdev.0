From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 1/4] xen/netback: implements persistent grant with one
 page pool.
Date: Thu, 15 Nov 2012 09:10:12 +0000
Message-ID: <1352970612.3499.43.camel@zakaz.uk.xensource.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
	 <1352963066-570-1-git-send-email-annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Annie Li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:55755 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754528Ab2KOJKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 04:10:16 -0500
In-Reply-To: <1352963066-570-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 07:04 +0000, Annie Li wrote:
> This patch implements persistent grant in netback driver. Tx and rx
> share the same page pool, this pool will be split into two parts
> in next patch.
> 
> Signed-off-by: Annie Li <annie.li@oracle.com>
> ---
>  drivers/net/xen-netback/common.h    |   18 +++-
>  drivers/net/xen-netback/interface.c |   22 ++++
>  drivers/net/xen-netback/netback.c   |  212 +++++++++++++++++++++++++++++++----
>  drivers/net/xen-netback/xenbus.c    |   14 ++-
>  4 files changed, 239 insertions(+), 27 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 94b79c3..a85cac6 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -45,8 +45,19 @@
>  #include <xen/grant_table.h>
>  #include <xen/xenbus.h>
> 
> +#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
> +#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
> +#define MAXIMUM_OUTSTANDING_BLOCK_REQS \

BLOCK?

> +                       (XEN_NETIF_TX_RING_SIZE + XEN_NETIF_RX_RING_SIZE)
> +
>  struct xen_netbk;
> 
> +struct persistent_entry {
> +       grant_ref_t forgranted;
> +       struct page *fpage;
> +       struct gnttab_map_grant_ref map;
> +};

Isn't this duplicating a bunch of infrastructure which is also in
blkback? Can we put it into some common helpers please?

> +
>  struct xenvif {
>         /* Unique identifier for this interface. */
>         domid_t          domid;
> @@ -75,6 +86,7 @@ struct xenvif {
> 
>         /* Internal feature information. */
>         u8 can_queue:1;     /* can queue packets for receiver? */
> +       u8 persistent_grant:1;
> 
>         /*
>          * Allow xenvif_start_xmit() to peek ahead in the rx request
> @@ -98,6 +110,9 @@ struct xenvif {
>         struct net_device *dev;
> 
>         wait_queue_head_t waiting_to_free;
> +
> +       struct persistent_entry *persistent_gnt[MAXIMUM_OUTSTANDING_BLOCK_REQS];

What is the per-vif memory overhead of this array?

> +static struct persistent_entry*
> +get_per_gnt(struct persistent_entry **pers_entry,
> +           unsigned int count, grant_ref_t gref)
> +{
> +       int i;
> +
> +       for (i = 0; i < count; i++)
> +               if (gref == pers_entry[i]->forgranted)
> +                       return pers_entry[i];

Isn't this linear scan rather expensive? I think Roger implemented some
sort of hash lookup for blkback which I think is required here too (and
should be easy if you make that code common).

> +
> +       return NULL;
> +}
> +

> @@ -1338,7 +1497,11 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
>                 gop->source.domid = vif->domid;
>                 gop->source.offset = txreq.offset;
> 
> -               gop->dest.u.gmfn = virt_to_mfn(page_address(page));
> +               if (!vif->persistent_grant)
> +                       gop->dest.u.gmfn = virt_to_mfn(page_address(page));
> +               else
> +                       gop->dest.u.gmfn = (unsigned long)page_address(page);

page_address doesn't return any sort of frame number, does it? This is
rather confusing...

> @@ -453,7 +460,12 @@ static int connect_rings(struct backend_info *be)
>                 val = 0;
>         vif->csum = !val;
> 
> -       /* Map the shared frame, irq etc. */
> +       if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-persistent-grants",
> +                        "%u", &val) < 0)
> +               val = 0;
> +       vif->persistent_grant = !!val;
> +
> +/* Map the shared frame, irq etc. */

Please run the patches through checkpatch.pl

>         err = xenvif_connect(vif, tx_ring_ref, rx_ring_ref, evtchn);
>         if (err) {
>                 xenbus_dev_fatal(dev, err,
> --
> 1.7.3.4
> 
