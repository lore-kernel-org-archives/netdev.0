From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Tue, 12 May 2015 12:54:47 -0600
Message-ID: <20150512185447.GA3503@obsidianresearch.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com>
 <5551A2CB.1010407@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5551A2CB.1010407-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 12, 2015 at 09:50:51AM +0300, Haggai Eran wrote:
> >> -void ib_destroy_cm_id(struct ib_cm_id *cm_id)
> >> +static void __ib_destroy_cm_id(struct kref *ref)
> >>  {
> >> +	struct ib_cm_id *cm_id = container_of(ref, struct ib_cm_id, ref);
> >> +
> >>  	cm_destroy_id(cm_id, 0);
> >>  }
> > 
> > Hum, this is quite a heavy free function. Did you check that this is
> > safe to do asynchronously, that there are no implicit kref's being
> > held by the caller?
> 
> I'm not sure what you mean. The function is called by the last kref_put,
> and destroys the ID synchronously.

Sorry, I was thinking about kobjects and CONFIG_DEBUG_KOBJECT_RELEASE
when I wrote that.


> Looking at the code though, I now notice that the other call site to
> cm_destroy_id, from within the error path of cm_process_work could now
> theoretically destroy an ID with existing references. Is that what you
> meant?

No, but that is certainly a problem.
 
> Since only listening CM IDs are now shared in RDMA CM, this should not
> happen in this patch-set, but perhaps the code can be changed to
> make

I think you need to enforce those semantics..

Firstly, it looks to me like we, again, have two krefs, the one you
added and the 'ref_count'  in the priv structure which is 99% of a
kref. So, again, don't do that.

If you want to share listening CM IDs, then do exactly and only
that. Use the existing ref count scheme for keeping track of the
kfree/etc, and add some kind of sharable listen ref count. Early exit
from cm_destroy_id when the there are still people listening.

That sounds like it keeps the basic rule of cm_destroy_id being
properly paired with the alloc, and allows listen sharing without the
confusion of what does multiple destroy mean.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
