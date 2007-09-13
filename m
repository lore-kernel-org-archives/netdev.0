From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Distributed storage. Security attributes and ducumentation update.
Date: Thu, 13 Sep 2007 08:03:52 -0700
Message-ID: <20070913150352.GA12806@linux.vnet.ibm.com>
References: <20070831160611.GA21660@2ka.mipt.ru> <20070910221445.GL11801@linux.vnet.ibm.com> <20070913122259.GA20714@2ka.mipt.ru>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759953AbXIMPEO@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070913122259.GA20714@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 13, 2007 at 04:22:59PM +0400, Evgeniy Polyakov wrote:
> Hi Paul.
> 
> On Mon, Sep 10, 2007 at 03:14:45PM -0700, Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > > Further TODO list includes:
> > > * implement optional saving of mirroring/linear information on the remote
> > > 	nodes (simple)
> > > * implement netlink based setup (simple)
> > > * new redundancy algorithm (complex)
> > > 
> > > Homepage:
> > > http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst
> > 
> > A couple questions below, but otherwise looks good from an RCU viewpoint.
> > 
> > 							Thanx, Paul
> 
> Thanks for your comments, and sorry for late reply I was at KS/London
> trip.
> > > +	if (--num) {
> > > +		list_for_each_entry_rcu(n, &node->shared, shared) {
> > 
> > This function is called under rcu_read_lock() or similar, right?
> > (Can't tell from this patch.)  It is also OK to call it from under the
> > update-side mutex, of course.
> 
> Actually not, but it does not require it, since entry can not be removed
> during this operations since appropriate reference counter for given node is
> being held. It should not be RCU at all.

Ah!  Yes, it is OK to use _rcu in this case, but should be avoided
unless doing so eliminates duplicate code or some such.  So, agree
with dropping _rcu in this case.

> > > +static int dst_mirror_read(struct dst_request *req)
> > > +{
> > > +	struct dst_node *node = req->node, *n, *min_dist_node;
> > > +	struct dst_mirror_priv *priv = node->priv;
> > > +	u64 dist, d;
> > > +	int err;
> > > +
> > > +	req->bio_endio = &dst_mirror_read_endio;
> > > +
> > > +	do {
> > > +		err = -ENODEV;
> > > +		min_dist_node = NULL;
> > > +		dist = -1ULL;
> > > + 
> > > +		/*
> > > +		 * Reading is never performed from the node under resync.
> > > +		 * If this will cause any troubles (like all nodes must be
> > > +		 * resynced between each other), this check can be removed
> > > +		 * and per-chunk dirty bit can be tested instead.
> > > +		 */
> > > +
> > > +		if (!test_bit(DST_NODE_NOTSYNC, &node->flags)) {
> > > +			priv = node->priv;
> > > +			if (req->start > priv->last_start)
> > > +				dist = req->start - priv->last_start;
> > > +			else
> > > +				dist = priv->last_start - req->start;
> > > +			min_dist_node = req->node;
> > > +		}
> > > +
> > > +		list_for_each_entry_rcu(n, &node->shared, shared) {
> > 
> > I see one call to this function that appears to be under the update-side
> > mutex, but I cannot tell if the other calls are safe.  (Safe as in either
> > under the update-side mutex or under rcu_read_lock() and friends.)
> 
> The same here - those processing function are called from
> generic_make_request() from any lock on top of them. Each node is linked
> into the list of the first added node, which reference counter is
> increased in higher layer. Right now there is no way to add or remove
> nodes after array was started, such functionality requires storage tree
> lock to be taken and RCU can not be used (since it requires sleeping and
> I did not investigate sleepable RCU for this purpose).
> 
> So, essentially RCU is not used in DST :)

Works for me!  "Use the right tool for the job!"

> Thanks for review, Paul.

							Thanx, Paul
