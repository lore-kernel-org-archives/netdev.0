From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v3 2/9] xen-netback: Change TX path
 from grant copy to mapping
Date: Fri, 10 Jan 2014 16:08:31 +0000
Message-ID: <20140110160830.GG30581@zion.uk.xensource.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
 <1389139818-24458-3-git-send-email-zoltan.kiss@citrix.com>
 <20140109153015.GF12164@zion.uk.xensource.com>
 <52CFDAEC.5080708@citrix.com>
 <20140110114534.GE29180@zion.uk.xensource.com>
 <52D01094.5060102@citrix.com>
 <52D0198C.6000600@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <jonathan.davies@citrix.com>,
	<ian.campbell@citrix.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52D0198C.6000600@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 10, 2014 at 04:02:20PM +0000, David Vrabel wrote:
> On 10/01/14 15:24, Zoltan Kiss wrote:
> > On 10/01/14 11:45, Wei Liu wrote:
> >> On Fri, Jan 10, 2014 at 11:35:08AM +0000, Zoltan Kiss wrote:
> >> [...]
> >>>
> >>>>> @@ -920,6 +852,18 @@ static int xenvif_tx_check_gop(struct xenvif
> >>>>> *vif,
> >>>>>       err = gop->status;
> >>>>>       if (unlikely(err))
> >>>>>           xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
> >>>>> +    else {
> >>>>> +        if (vif->grant_tx_handle[pending_idx] !=
> >>>>> +            NETBACK_INVALID_HANDLE) {
> >>>>> +            netdev_err(vif->dev,
> >>>>> +                "Stale mapped handle! pending_idx %x handle %x\n",
> >>>>> +                pending_idx, vif->grant_tx_handle[pending_idx]);
> >>>>> +            BUG();
> >>>>> +        }
> >>>>> +        set_phys_to_machine(idx_to_pfn(vif, pending_idx),
> >>>>> +            FOREIGN_FRAME(gop->dev_bus_addr >> PAGE_SHIFT));
> >>>>
> >>>> What happens when you don't have this?
> >>> Your frags will be filled with garbage. I don't understand exactly
> >>> what this function does, someone might want to enlighten us? I've
> >>> took it's usage from classic kernel.
> >>> Also, it might be worthwhile to check the return value and BUG if
> >>> it's false, but I don't know what exactly that return value means.
> >>>
> >>
> >> This is actually part of gnttab_map_refs. As you're using hypercall
> >> directly this becomes very fragile.
> >>
> >> So the right thing to do is to fix gnttab_map_refs.
> > I agree, as I mentioned in other email in this thread, I think that
> > should be the topic of an another patchseries. In the meantime, I will
> > use gnttab_batch_map instead of the direct hypercall, it handles the
> > GNTST_eagain scenario, and I will use set_phys_to_machine the same way
> > as m2p_override does:
> 
> If the grant table code doesn't provide the API calls you need you can
> either:
> 
> a) add the new API as a prerequisite patch.
> b) use the existing API calls and live with the performance problem,
> until you can refactor the API later on.
> 
> Adding a netback-specific hack isn't a valid option.
> 

Agreed.

Wei.

> David
