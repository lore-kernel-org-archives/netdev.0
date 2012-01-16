From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: RE: [Xen-devel] [RFC PATCH 3/6] netback: switch to NAPI + kthread
 model
Date: Mon, 16 Jan 2012 10:31:55 +0000
Message-ID: <1326709915.17210.410.camel@zakaz.uk.xensource.com>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com>
	 <1326473949-22389-4-git-send-email-wei.liu2@citrix.com>
	 <291EDFCB1E9E224A99088639C4762022B5991BEC49@LONPMAILBOX01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:41890 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab2APKcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 05:32:17 -0500
In-Reply-To: <291EDFCB1E9E224A99088639C4762022B5991BEC49@LONPMAILBOX01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-16 at 10:14 +0000, Paul Durrant wrote:
> > -----Original Message-----
> > From: xen-devel-bounces@lists.xensource.com [mailto:xen-devel-
> > bounces@lists.xensource.com] On Behalf Of Wei Liu
> > Sent: 13 January 2012 16:59
> > To: Ian Campbell; konrad.wilk@oracle.com; xen-
> > devel@lists.xensource.com; netdev@vger.kernel.org
> > Cc: Wei Liu (Intern)
> > Subject: [Xen-devel] [RFC PATCH 3/6] netback: switch to NAPI + kthread
> > model
> > 
> > This patch implements 1:1 model netback. We utilizes NAPI and kthread to
> > do the weight-lifting job:
> > 
> >   - NAPI is used for guest side TX (host side RX)
> >   - kthread is used for guest side RX (host side TX)
> > 
> > This model provides better scheduling fairness among vifs. It also lays the
> > foundation for future work.
> > 
> > The major defect for the current implementation is that in the NAPI poll
> > handler we don't actually disable interrupt. Xen stuff is different from real
> > hardware, it requires some other tuning of ring macros.
> > 
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > ---
> [snip]
> > 
> >  	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
> >  	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS]; @@ -100,42
> > +91,14 @@ struct xen_netbk {
> >  	struct netbk_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];  };
> > 
> 
> Keeping these big inline arrays might cause scalability issues.
> pending_tx_info should arguably me more closely tied in and possibly
> implemented within your page pool code.

For pending_tx_info that probably makes sense since there is a 1:1
mapping between page pool entries and pending_tx_info.

For some of the others the arrays are the runtime scratch space used by
the netback during each processing pass. Since, regardless of the number
of VIFs, there can only ever be nr_online_cpus netback's active at once
perhaps per-CPU scratch space (with appropriate locking etc) is the way
to go.

Ian.
