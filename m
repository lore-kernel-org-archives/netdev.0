From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [RFC PATCH V3 12/16] netback: multi-page ring support
Date: Tue, 31 Jan 2012 09:48:20 -0500
Message-ID: <20120131144820.GE3244@phenom.dumpdata.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
 <1327934734-8908-13-git-send-email-wei.liu2@citrix.com>
 <4F26D4E5020000780006FF41@nat28.tlf.novell.com>
 <1327943436.5553.39.camel@leeds.uk.xensource.com>
 <4F27BC1002000078000700D3@nat28.tlf.novell.com>
 <1328008145.5553.74.camel@leeds.uk.xensource.com>
 <4F27F9960200007800070228@nat28.tlf.novell.com>
 <1328016770.5553.87.camel@leeds.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Beulich <JBeulich@suse.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:26303 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061Ab2AaOvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 09:51:09 -0500
Content-Disposition: inline
In-Reply-To: <1328016770.5553.87.camel@leeds.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2012 at 01:32:50PM +0000, Wei Liu wrote:
> On Tue, 2012-01-31 at 13:24 +0000, Jan Beulich wrote:
> > >>> On 31.01.12 at 12:09, Wei Liu <wei.liu2@citrix.com> wrote:
> > > On Tue, 2012-01-31 at 09:01 +0000, Jan Beulich wrote:
> > >> >>> On 30.01.12 at 18:10, Wei Liu <wei.liu2@citrix.com> wrote:
> > >> > On Mon, 2012-01-30 at 16:35 +0000, Jan Beulich wrote:
> > >> >> >>> On 30.01.12 at 15:45, Wei Liu <wei.liu2@citrix.com> wrote:
> > >> >> > -int xenvif_map_frontend_rings(struct xenvif *vif,
> > >> >> > -			      grant_ref_t tx_ring_ref,
> > >> >> > -			      grant_ref_t rx_ring_ref)
> > >> >> > +int xenvif_map_frontend_rings(struct xen_comms *comms,
> > >> >> > +			      int domid,
> > >> >> > +			      unsigned long ring_ref[],
> > >> >> > +			      unsigned int  ring_ref_count)
> > >> >> >  {
> > >> >> > -	void *addr;
> > >> >> > -	struct xen_netif_tx_sring *txs;
> > >> >> > -	struct xen_netif_rx_sring *rxs;
> > >> >> > -
> > >> >> > -	int err = -ENOMEM;
> > >> >> > +	struct gnttab_map_grant_ref op[NETBK_MAX_RING_PAGES];
> > >> >> > +	unsigned int i;
> > >> >> > +	int err = 0;
> > >> >> >  
> > >> >> > -	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
> > >> >> > -				     tx_ring_ref, &addr);
> > >> >> 
> > >> >> Any reason why you don't just extend this function (in a prerequisite
> > >> >> patch) rather than open coding a common utility function (twice) here,
> > >> >> so that other backends (blkback!) can benefit later as well.
> > >> >> 
> > >> >> Jan
> > >> >> 
> > >> > 
> > >> > I'm mainly focusing on netback stuffs, so the code is slightly coupled
> > >> > with netback -- NETBK_MAX_RING_PAGES.
> > >> > 
> > >> > To extend xenbus_map_ring_valloc and make more generic, it requires
> > >> > setting a global maximum page number limits on rings, I think it will
> > >> > require further investigation and code refactor -- which I have no time
> > >> > to attend to at the moment. :-/
> > >> 
> > >> Why? You can simply pass in the number of pages, there's no need
> > >> for a global maximum.
> > >> 
> > > 
> > > I mean the gnttab_map_gran_ref array, it is statically allocated at the
> > > moment. Of course we can make it dynamically allocated, but why bother
> > > taking the risk of allocation failure.
> > 
> > There's so many other allocations, why would you worry about this
> > one.
> > 
> 
> IMHO, this is not a critical part of the code, so failing this one thus
> making all other pieces not workable is very strange.
> 
> > But of course you can undo what a recent change did, and then
> > subsequently someone else will have to clean up again after you.
> > I'm just asking to follow good programming practices and write
> > re-usable code where potential for re-use is obvious (after all,
> > multi-page block interface patches have been floating around for
> > much longer than yours for the net interface).
> > 
> 
> I understand your concern. If the changes required will not make this
> series longer and involves major changes in block interface, I'm happy
> to refactor the xenbus interface.

Please do. Patches are more than welcome to make it be more versatile.
