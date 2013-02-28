From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 6/8] netfront: multi-page ring support
Date: Thu, 28 Feb 2013 11:02:37 +0000
Message-ID: <20130228110237.GA23777@zion.uk.xensource.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
 <1360944010-15336-7-git-send-email-wei.liu2@citrix.com>
 <512C5B96.10204@oracle.com>
 <1361882139.2109.52.camel@zion.uk.xensource.com>
 <512DB83A.6050503@oracle.com>
 <1361980154.2109.67.camel@zion.uk.xensource.com>
 <512EE8EF.30200@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: ANNIE LI <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:15517 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916Ab3B1LDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 06:03:01 -0500
Content-Disposition: inline
In-Reply-To: <512EE8EF.30200@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 28, 2013 at 05:19:43AM +0000, ANNIE LI wrote:
> 
> 
> On 2013-2-27 23:49, Wei Liu wrote:
> > On Wed, 2013-02-27 at 07:39 +0000, ANNIE LI wrote:
> >> On 2013-2-26 20:35, Wei Liu wrote:
> >>> On Tue, 2013-02-26 at 06:52 +0000, ANNIE LI wrote:
> >>>> On 2013-2-16 0:00, Wei Liu wrote:
> >>>>> Signed-off-by: Wei Liu<wei.liu2@citrix.com>
> >>>>> ---
> >>>>>     drivers/net/xen-netfront.c |  246 +++++++++++++++++++++++++++++++-------------
> >>>>>     1 file changed, 174 insertions(+), 72 deletions(-)
> >>>>>
> >>>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> >>>>> index 8bd75a1..de73a71 100644
> >>>>> --- a/drivers/net/xen-netfront.c
> >>>>> +++ b/drivers/net/xen-netfront.c
> >>>>> @@ -67,9 +67,19 @@ struct netfront_cb {
> >>>>>
> >>>>>     #define GRANT_INVALID_REF   0
> >>>>>
> >>>>> -#define NET_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
> >>>>> -#define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
> >>>>> -#define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE, 256)
> >>>>> +#define XENNET_MAX_RING_PAGE_ORDER XENBUS_MAX_RING_PAGE_ORDER
> >>>>> +#define XENNET_MAX_RING_PAGES      (1U<<    XENNET_MAX_RING_PAGE_ORDER)
> >>>>> +
> >>>>> +
> >>>>> +#define NET_TX_RING_SIZE(_nr_pages)                  \
> >>>>> +     __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE * (_nr_pages))
> >>>>> +#define NET_RX_RING_SIZE(_nr_pages)                  \
> >>>>> +     __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE * (_nr_pages))
> >>>>> +
> >>>>> +#define XENNET_MAX_TX_RING_SIZE NET_TX_RING_SIZE(XENNET_MAX_RING_PAGES)
> >>>>> +#define XENNET_MAX_RX_RING_SIZE NET_RX_RING_SIZE(XENNET_MAX_RING_PAGES)
> >>>>> +
> >>>>> +#define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE(1), 256)
> >>>> Not using multi-page ring here?
> >>>> In xennet_create_dev, gnttab_alloc_grant_references allocates
> >>>> TX_MAX_TARGET number of grant reference for tx. In
> >>>> xennet_release_tx_bufs, NET_TX_RING_SIZE(np->tx_ring_pages) numbers of
> >>>> grants are processed. And NET_RX_RING_SIZE(np->tx_ring_pages) is totally
> >>>> different from TX_MAX_TARGET if np->rx_ring_pages is not 1. Although
> >>>> skb_entry_is_link helps to not release invalid grants, lots of null loop
> >>>> seems unnecessary. I think TX_MAX_TARGET should be changed into some
> >>>> variableconnected with np->tx_ring_pages. Or you intended to use one
> >>>> page ring here?
> >>>>
> >>> Looking back my history, this limitation was introduced because if we
> >>> have a multi-page backend and single page frontend, the backend skb
> >>> processing could overlap.
> >> I did not see the overlap you mentioned here in netback. Although
> >> netback supports multi-page, netback->vif still uses single page if the
> >> frontend only supports single page. Netfront and netback negotiate this
> >> through xenstore in your 5/8 patch. The requests and response should not
> >> have any overlap between netback and netfront. Am I missing something?
> >>
> > I tried to dig up mail archive just now and realized that the bug report
> > was in private mail exchange with Konrad.
> >
> > I don't really remember the details now since it is more than one year
> > old, but you can find trace in Konrad's tree, CS 5b4c3dd5b255. All I can
> > remember is that this bug was triggered by mixed old/new
> > frontend/backend.
> 
> I checked the code in Konrad's tree and am thinking this overlap issue 
> you mentioned existing in original netback(without multi-ring) and newer 
> netfront. Original netback does not support multi-ring, and your newer 
> netfront before this bug fix used "#define TX_MAX_TARGET 
> XENNET_MAX_TX_RING_SIZE" directly. So that would cause overlap when 
> netfront allocating rx skbs.
> "#define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE(1), 256)" limits the 
> netfront to single ring, it fixed the overlap issue, but not enough.
> 

Yes. I just saw a bug report from Xen-user list yesterday for the same
issue in original netback (1 page ring), so the overlap issue is not
introduced by multi-page ring implementation. If your team also sees that
issue, do you have patch to fix that?


Wei.
