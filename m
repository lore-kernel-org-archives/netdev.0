From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] bnx2: Add support for CNIC driver.
Date: Thu, 22 May 2008 20:45:22 -0700
Message-ID: <20080523034522.GA8612@linux.vnet.ibm.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com> <1211418386-18203-2-git-send-email-mchan@broadcom.com> <20080522064541.GA11933@linux.vnet.ibm.com> <1211484208.18326.25.camel@dell>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, michaelc@cs.wisc.edu,
	anilgv@broadcom.com, netdev <netdev@vger.kernel.org>,
	linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1211484208.18326.25.camel@dell>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 22, 2008 at 12:23:28PM -0700, Michael Chan wrote:
> On Wed, 2008-05-21 at 23:45 -0700, Paul E. McKenney wrote:
> 
> > Some RCU-related questions interspersed below, for example, how are
> > updates protected?
> 
> Only one CNIC driver will ever register with the BNX2 driver.  The main
> purpose of using RCU is so that the fast path can avoid locking when
> handling interrupt events from the hardware.

So if a second CNIC driver attempts to register, it gets -EBUSY or
something, right?

> > > +
> > > +static void bnx2_setup_cnic_irq_info(struct bnx2 *bp)
> > > +{
> > > +	struct cnic_ops *c_ops;
> > > +	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
> > > +	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
> > > +	int sb_id;
> > > +
> > > +	rcu_read_lock();
> > > +	c_ops = rcu_dereference(bp->cnic_ops);
> > > +	if (!c_ops)
> > > +		goto done;
> > 
> > Given that c_ops is unused below, what is happening here?  What prevents
> > bp->cnic_ops from becoming NULL immediately after we test it?  And if
> > it is OK for bp->cnic_ops to become NULL immediately after we test it,
> > why are we bothering to test it?
> 
> You are right.  We should just unconditionally set up the IRQ
> information without checking for c_ops.  The data structures we set up
> below are owned by us.

OK.  Hmmm....  You cannot even get away with sarcasm these days!  ;-)

> > > +
> > > +	if (bp->flags & BNX2_FLAG_USING_MSIX) {
> > > +		cp->drv_state |= CNIC_DRV_STATE_USING_MSIX;
> > > +		bnapi->cnic_present = 0;
> > > +		sb_id = BNX2_CNIC_VEC;
> > > +		cp->irq_arr[0].irq_flags |= CNIC_IRQ_FL_MSIX;
> > > +	} else {
> > > +		cp->drv_state &= ~CNIC_DRV_STATE_USING_MSIX;
> > > +		bnapi->cnic_tag = bnapi->last_status_idx;
> > > +		bnapi->cnic_present = 1;
> > > +		sb_id = 0;
> > > +		cp->irq_arr[0].irq_flags &= !CNIC_IRQ_FL_MSIX;
> > > +	}
> > > +
> > > +	cp->irq_arr[0].vector = bp->irq_tbl[sb_id].vector;
> > > +	cp->irq_arr[0].status_blk = (void *) ((unsigned long) bp->status_blk +
> > > +		(BNX2_SBLK_MSIX_ALIGN_SIZE * sb_id));
> > > +	cp->irq_arr[0].status_blk_num = sb_id;
> > > +	cp->num_irq = 1;
> > > +
> > > +done:
> > > +	rcu_read_unlock();
> > > +}
> > > +
> > > +static int bnx2_register_cnic(struct net_device *dev, struct cnic_ops *ops,
> > > +			      void *data)
> > > +{
> > > +	struct bnx2 *bp = netdev_priv(dev);
> > > +	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
> > > +
> > > +	if (ops == NULL)
> > > +		return -EINVAL;
> > > +
> > > +	if (!try_module_get(ops->cnic_owner))
> > > +		return -EBUSY;
> > > +
> > > +	bp->cnic_data = data;
> > > +	rcu_assign_pointer(bp->cnic_ops, ops);
> > 
> > What prevents multiple tasks from doing this assignment concurrently?
> 
> As I said above, only one CNIC driver will ever register.

OK.

> > > +
> > > +	cp->num_irq = 0;
> > > +	cp->drv_state = CNIC_DRV_STATE_REGD;
> > > +
> > > +	bnx2_setup_cnic_irq_info(bp);
> > > +
> > > +	return 0;
> > > +}
> > > +
> > > +static int bnx2_unregister_cnic(struct net_device *dev)
> > > +{
> > > +	struct bnx2 *bp = netdev_priv(dev);
> > > +	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
> > > +	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
> > > +
> > > +	cp->drv_state = 0;
> > > +	module_put(bp->cnic_ops->cnic_owner);
> > > +	bnapi->cnic_present = 0;
> > > +	rcu_assign_pointer(bp->cnic_ops, NULL);
> > 
> > What prevents this from running concurrently with bnx2_register_cnic()?
> 
> We expect the CNIC driver to be well behaved and will only unregister
> after successfully registered.

Trusting, but fair enough.  ;-)

> > > +	synchronize_rcu();
> > 
> > The caller is responsible for freeing up the old bp->cnic_ops structure?
> > Or is this structure statically allocated?
> > 
> > If so, is the idea to delay return until all prior calls through the
> > old ops structure have completed?
> 
> The cnic_ops contain call back function pointers to the CNIC driver.  We
> want to make sure that those calls have completed (in the fast path)
> before continuing.

Very good.  Could you please add a comment to that effect?  Otherwise
people search for what data structure is being freed up.

							Thanx, Paul

> > > +	return 0;
> > > +}
> > > +
> 
> 
