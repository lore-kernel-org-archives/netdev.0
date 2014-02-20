From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v5 1/9] xen-netback: Introduce TX grant map
 definitions
Date: Thu, 20 Feb 2014 09:33:28 +0000
Message-ID: <1392888808.22494.21.camel@kazak.uk.xensource.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>
			 <1390253069-25507-2-git-send-email-zoltan.kiss@citrix.com>
		 <1392743214.23084.38.camel@kazak.uk.xensource.com>
		 <5303C44D.4070500@citrix.com>
	 <1392804319.23084.109.camel@kazak.uk.xensource.com>
	 <53050BF5.1060009@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53050BF5.1060009@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-02-19 at 19:54 +0000, Zoltan Kiss wrote:
> On 19/02/14 10:05, Ian Campbell wrote:
> > On Tue, 2014-02-18 at 20:36 +0000, Zoltan Kiss wrote:
> >> On 18/02/14 17:06, Ian Campbell wrote:
> >>> On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
> >>>> This patch contains the new definitions necessary for grant mapping.
> >>>
> >>> Is this just adding a bunch of (currently) unused functions? That's a
> >>> slightly odd way to structure a series. They don't seem to be "generic
> >>> helpers" or anything so it would be more normal to introduce these as
> >>> they get used -- it's a bit hard to review them out of context.
> >> I've created two patches because they are quite huge even now,
> >> separately. Together they would be a ~500 line change. That was the best
> >> I could figure out keeping in mind that bisect should work. But as I
> >> wrote in the first email, I welcome other suggestions. If you and Wei
> >> prefer this two patch in one big one, I merge them in the next version.
> >
> > I suppose it is hard to split a change like this up in a sensible way,
> > but it is rather hard to review something which is split in two parts
> > sensibly.
> >
> > If the combined patch too large to fit on the lists?
> Well, it's ca. 30 kb, ~500 lines changed. I guess it's possible. It's up 
> to you and Wei, if you would like them to be merged, I can do that.

30kb doesn't sound too bad to me.

Patches #1 and #2 are, respectively:

 drivers/net/xen-netback/common.h    |   30 ++++++-
 drivers/net/xen-netback/interface.c |    1 +
 drivers/net/xen-netback/netback.c   |  161 +++++++++++++++++++++++++++++++++++
 3 files changed, 191 insertions(+), 1 deletion(-)

 drivers/net/xen-netback/interface.c |   63 ++++++++-
 drivers/net/xen-netback/netback.c   |  254 ++++++++++++++---------------------
 2 files changed, 160 insertions(+), 157 deletions(-)

I don't think combining those would be terrible, although I'm willing to
be proven wrong ;-)

> >>>
> >>>> +		vif->dealloc_prod++;
> >>>
> >>> What happens if the dealloc ring becomes full, will this wrap and cause
> >>> havoc?
> >> Nope, if the dealloc ring is full, the value of the last increment won't
> >> be used to index the dealloc ring again until some space made available.
> >
> > I don't follow -- what makes this the case?
> The dealloc ring has the same size as the pending ring, and you can only 
> add slots to it which are already on the pending ring (the pending_idx 
> comes from ubuf->desc), as you are essentially free up slots here on the 
> pending ring.
> So if the dealloc ring becomes full, vif->dealloc_prod - 
> vif->dealloc_cons will be 256, which would be bad. But the while loop 
> should exit here, as we shouldn't have any more pending slots. And if we 
> dealloc and create free pending slots in dealloc_action, dealloc_cons 
> will also advance.

OK, so this is limited by the size of the pending array, makes sense,
assuming that array is itself correctly guarded...

> >> Of course if something broke and we have more pending slots than tx ring
> >> or dealloc slots then it can happen. Do you suggest a
> >> BUG_ON(vif->dealloc_prod - vif->dealloc_cons >= MAX_PENDING_REQS)?
> >
> > A
> >           BUG_ON(space in dealloc ring < number of slots needed to dealloc this skb)
> > would seem to be the right thing, if that really is the invariant the
> > code is supposed to be implementing.
> Not exactly, it means BUG_ON(number of slots to dealloc > 
> MAX_PENDING_REQS), and it should be at the end of the loop, without '='.

OK.

> >
> >>>
> >>>> +		}
> >>>> +
> >>>> +	} while (dp != vif->dealloc_prod);
> >>>> +
> >>>> +	vif->dealloc_cons = dc;
> >>>
> >>> No barrier here?
> >> dealloc_cons only used in the dealloc_thread. dealloc_prod is used by
> >> the callback and the thread as well, that's why we need mb() in
> >> previous. Btw. this function comes from classic's net_tx_action_dealloc
> >
> > Is this code close enough to that code architecturally that you can
> > infer correctness due to that though?
> Nope, I've just mentioned it because knowing that old code can help to 
> understand this new, as their logic is very similar some places, like here.
> 
> > So long as you have considered the barrier semantics in the context of
> > the current code and you think it is correct to not have one here then
> > I'm ok. But if you have just assumed it is OK because some older code
> > didn't have it then I'll have to ask you to consider it again...
> Nope, as I mentioned above, dealloc_cons only accessed in that funcion, 
> from the same thread. Dealloc_prod is written in the callback and read 
> out here, that's why we need the barrier there.

OK.

Although this may no longer be true if you added some BUG_ONs as
discussed above?

> 
> >
> >>>> +				netdev_err(vif->dev,
> >>>> +					   " host_addr: %llx handle: %x status: %d\n",
> >>>> +					   gop[i].host_addr,
> >>>> +					   gop[i].handle,
> >>>> +					   gop[i].status);
> >>>> +			}
> >>>> +			BUG();
> >>>> +		}
> >>>> +	}
> >>>> +
> >>>> +	for (i = 0; i < gop - vif->tx_unmap_ops; ++i)
> >>>> +		xenvif_idx_release(vif, pending_idx_release[i],
> >>>> +				   XEN_NETIF_RSP_OKAY);
> >>>> +}
> >>>> +
> >>>> +
> >>>>    /* Called after netfront has transmitted */
> >>>>    int xenvif_tx_action(struct xenvif *vif, int budget)
> >>>>    {
> >>>> @@ -1678,6 +1793,25 @@ static void xenvif_idx_release(struct xenvif *vif, u16 pending_idx,
> >>>>    	vif->mmap_pages[pending_idx] = NULL;
> >>>>    }
> >>>>
> >>>> +void xenvif_idx_unmap(struct xenvif *vif, u16 pending_idx)
> >>>
> >>> This is a single shot version of the batched xenvif_tx_dealloc_action
> >>> version? Why not just enqueue the idx to be unmapped later?
> >> This is called only from the NAPI instance. Using the dealloc ring
> >> require synchronization with the callback which can increase lock
> >> contention. On the other hand, if the guest sends small packets
> >> (<PAGE_SIZE), the TLB flushing can cause performance penalty.
> >
> > Right. When/How often is this called from the NAPI instance?
> When grant mapping error detected in xenvif_tx_check_gop, and if a 
> packet smaller than PKT_PROT_LEN is sent. The latter would be removed if 
> we will grant copy such packets entirely.
> 
> > Is the locking contention from this case so severe that it out weighs
> > the benefits of batching the unmaps? That would surprise me. After all
> > the locking contention is there for the zerocopy_callback case too
> >
> >>   The above
> >> mentioned upcoming patch which gntcopy the header can prevent that
> >
> > So this is only called when doing the pull-up to the linear area?
> Yes, as mentioned above.

I'm not sure why you don't just enqueue the dealloc with the other
normal ones though.

Ian.
