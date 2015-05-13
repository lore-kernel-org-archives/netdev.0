From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v3 for-next 05/13] IB/cm: Reference count ib_cm_ids
Date: Wed, 13 May 2015 10:58:23 -0600
Message-ID: <20150513165823.GA20343@obsidianresearch.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
 <1431253604-9214-6-git-send-email-haggaie@mellanox.com>
 <20150511183459.GB25405@obsidianresearch.com>
 <5551A2CB.1010407@mellanox.com>
 <20150512185447.GA3503@obsidianresearch.com>
 <55532566.9040105@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:54439 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934009AbbEMQ61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 12:58:27 -0400
Content-Disposition: inline
In-Reply-To: <55532566.9040105@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 01:20:22PM +0300, Haggai Eran wrote:

> > If you want to share listening CM IDs, then do exactly and only
> > that. Use the existing ref count scheme for keeping track of the
> > kfree/etc,

> The existing reference count scheme is for synchronization in
> cm_destroy_id. The function waits for active handlers to complete
> before

Pedantically, this is true

> destroying the id. Decrementing ref_count to zero doesn't cause the id
> to be freed.

Think it through. cm_destroy_id does this:

	cm_deref_id(cm_id_priv);
	wait_for_completion(&cm_id_priv->comp);

The cm_create_cm_id/cm_destroy_id pair holds a value in refcount.

The only way refcount can go zero is if cm_destroy_id is waiting in
wait_for_completion. So setting the refcount to zero always triggers a
(possibly async) kfree.

> > and add some kind of sharable listen ref count.
> That's basically what the patch does. I can change it from a kref to a
> direct reference count if you prefer.

As I've said, idiomatically I prefer to see kref used to manage object
life time exclusively, not as a general purpose counter.

In this case the share count should be protected by the existing spin
lock.

> > Early exit
> > from cm_destroy_id when the there are still people listening.
> > 
> > That sounds like it keeps the basic rule of cm_destroy_id being
> > properly paired with the alloc, and allows listen sharing without the
> > confusion of what does multiple destroy mean.
> 
> Won't you find it confusing if a call to ib_destroy_cm_id is successful
> but the id actually continues to live?

No.. As the caller, I don't care what the cm layer is doing behind the scenes.

The lifetime if each cm_id is clearly defined:

cm_create_cm_id()
cm_ref_id() / cm_deref_id()
cm_destroy_id()

The fact the CM might share a listen (and only a listen) ID behind the
scenes is not the caller's problem. That is an implementation choice,
each caller stands alone and uses the API properly, assuming it is the
only user of the returned cm_id.

The caller relies on cm_destroy_id being synchronous.

> I prefer the API to explicitly show that you are only decreasing the
> reference count and that the id might not be destroyed immediately.

No, that is fuzzy thinking, and lead to this patch that tried to have
both a ib_cm_id_put and cm_destroy_id being used at once. That is broken.

As discussed, we can't easily convert all call sites of cm_destroy_id
to ib_cm_id_put because 1) We loose the error code and 2) The put_X
idiom is async while cm_destory_id users expect sync.

So the best choice is to retain the cm_create_cm_id()/cm_destroy_id()
pairing, and have cm_destroy_id 'do the right thing' when presented
with a shared listen to destroy -> decrease the share count and free
the underlying listen when no more shares are left.

That said: Are you sure this is going to work? Are all the listen
specific cases of cm_destroy_id OK with not doing the
wait_for_completion and cm_dqueue_work *for stuff related to that
client* ?

If not you'll have to change the patch to create multiple cm_id's for
the same listen and iterate over all of them.

Jason
