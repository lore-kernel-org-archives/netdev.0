From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 for-next 05/12] IB/cm: Share listening CM IDs
Date: Tue, 19 May 2015 16:35:02 -0600
Message-ID: <20150519223502.GA26324@obsidianresearch.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1431841868-28063-6-git-send-email-haggaie@mellanox.com>
 <20150519183545.GH18675@obsidianresearch.com>
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
In-Reply-To: <20150519183545.GH18675-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 19, 2015 at 12:35:45PM -0600, Jason Gunthorpe wrote:
> On Sun, May 17, 2015 at 08:51:01AM +0300, Haggai Eran wrote:
> > @@ -212,6 +212,8 @@ struct cm_id_private {
> >  	spinlock_t lock;	/* Do not acquire inside cm.lock */
> >  	struct completion comp;
> >  	atomic_t refcount;
> > +	/* Number of clients sharing this ib_cm_id. Only valid for listeners. */
> > +	atomic_t sharecount;
> 
> No need for this atomic, hold the lock
> 
> The use of the atomic looks racy:
> 
> > +	if (!atomic_dec_and_test(&cm_id_priv->sharecount)) {
> > +		/* The id is still shared. */
> > +		return;
> > +	}
> 
> Might race with this:
> 
> > +		if (atomic_inc_return(&cm_id_priv->sharecount) == 1) {
> > +			/* This ID is already being destroyed */
> > +			atomic_dec(&cm_id_priv->sharecount);
> > +			goto new_id;
> > +		}
> > +
> 
> Resulting in use-after-free of cm_id_priv->sharecount

Actually, there is something else odd here.. I mentioned the above
because there wasn't obvious ref'ing on the cm_id_priv. Looking closer
the cm.lock should prevent use-after-free, but there is still no ref.

The more I look at this, the more I think it is sketchy. Don't try and
merge sharecount and refcount together, after cm_find_listen is called
you have to increment the refcount before dropping cm.lock.

Decrement the refcount when destroying a shared listen.

I also don't see how the 'goto new_id' can work, if cm_find_listen
succeeds then __ib_cm_listen is guarenteed to fail.

Fix the locking to make that impossible, associate sharecount with the
cm.lock and, rework how cm_destroy_id grabs the cm_id_priv->lock spinlock:

	case IB_CM_LISTEN:
		spin_lock_irq(&cm.lock);
		if (cm_id_priv->sharecount != 0) {
		     cm_id_prv->sharecount--;
		     // paired with in in ib_cm_id_create_and_listen
		     atomic_dec(&cm_id_priv->refcount);
		     spin_unlock_irq(&cm.lock);
		     return;
		}
		rb_erase(&cm_id_priv->service_node, &cm.listen_service_table);
		spin_unlock_irq(&cm.lock);
	
		spin_lock_irq(&cm_id_priv->lock);
		cm_id->state = IB_CM_IDLE;
		spin_unlock_irq(&cm_id_priv->lock);
		break;

Now that condition is eliminated, the unneeded atomic is gone, and
refcount still acts like a proper kref should.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
