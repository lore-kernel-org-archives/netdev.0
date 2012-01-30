From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V3 04/16] netback: switch to per-cpu scratch space.
Date: Mon, 30 Jan 2012 17:05:00 +0000
Message-ID: <1327943100.5553.33.camel@leeds.uk.xensource.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	 <1327934734-8908-5-git-send-email-wei.liu2@citrix.com>
	 <CANX6Dak_1VQ1J8hRK+yd1-FmGOnd75BkNm2uUVKd_TNTiNLtxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Viral Mehta <viral.vkm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:34333 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab2A3REu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 12:04:50 -0500
In-Reply-To: <CANX6Dak_1VQ1J8hRK+yd1-FmGOnd75BkNm2uUVKd_TNTiNLtxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-30 at 16:49 +0000, Viral Mehta wrote:
> Hi,
> 
> On Mon, Jan 30, 2012 at 9:45 AM, Wei Liu <wei.liu2@citrix.com> wrote:
> >
> >        skb_queue_head_init(&rxq);
> > @@ -534,13 +527,16 @@ void xen_netbk_rx_action(struct xen_netbk *netbk)
> >                        break;
> >        }
> >
> > -       BUG_ON(npo.meta_prod > ARRAY_SIZE(netbk->meta));
> > +       BUG_ON(npo.meta_prod > MAX_PENDING_REQS);
> 
> While you are already here,
> how about having WARN_ON() ?
> 
> >
> > -       if (!npo.copy_prod)
> > +       if (!npo.copy_prod) {
> > +               put_cpu_ptr(gco);
> > +               put_cpu_ptr(m);
> >                return;
> > +       }
> >
> > -       BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op));
> > -       ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, &netbk->grant_copy_op,
> > +       BUG_ON(npo.copy_prod > (2 * XEN_NETIF_RX_RING_SIZE));
> 
> And may be here, too...
> 
> If there is serious bug, may be system will crash at a later point
> But, IMHO, WARN_ON() is the correct function for drivers at least.
> 

I don't agree. Here BUG_ON means code logic has defects that we haven't
discovered. I won't take the risk of any undefined behavior.

Further more, there are a bunch of drivers use BUG_ON. A simple grep
will show you hundreds (even thousands?) of results.


Wei.
