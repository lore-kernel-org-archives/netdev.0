From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] cnic: Add CNIC driver.
Date: Thu, 22 May 2008 20:47:13 -0700
Message-ID: <20080523034713.GB8612@linux.vnet.ibm.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com> <1211418386-18203-3-git-send-email-mchan@broadcom.com> <20080522074422.GB11933@linux.vnet.ibm.com> <1211485571.18326.41.camel@dell>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, michaelc@cs.wisc.edu,
	anilgv@broadcom.com, netdev <netdev@vger.kernel.org>,
	linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1211485571.18326.41.camel@dell>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 22, 2008 at 12:46:11PM -0700, Michael Chan wrote:
> On Thu, 2008-05-22 at 00:44 -0700, Paul E. McKenney wrote:
> 
> > > +
> > > +int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
> > > +{
> > > +	struct cnic_dev *dev;
> > > +
> > > +	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> > > +		printk(KERN_ERR PFX "cnic_register_driver: Bad type %d\n",
> > > +		       ulp_type);
> > > +		return -EINVAL;
> > > +	}
> > > +	mutex_lock(&cnic_lock);
> > > +	if (cnic_ulp_tbl[ulp_type]) {
> > > +		printk(KERN_ERR PFX "cnic_register_driver: Type %d has already "
> > > +				    "been registered\n", ulp_type);
> > > +		mutex_unlock(&cnic_lock);
> > > +		return -EBUSY;
> > > +	}
> > > +
> > > +	read_lock(&cnic_dev_lock);
> > > +	list_for_each_entry(dev, &cnic_dev_list, list) {
> > > +		struct cnic_local *cp = dev->cnic_priv;
> > > +
> > > +		clear_bit(ULP_F_INIT, &cp->ulp_flags[ulp_type]);
> > > +	}
> > > +	read_unlock(&cnic_dev_lock);
> > > +
> > > +	rcu_assign_pointer(cnic_ulp_tbl[ulp_type], ulp_ops);
> > 
> > OK, protected by cnic_lock.
> > 
> > > +	mutex_unlock(&cnic_lock);
> > > +
> > > +	/* Prevent race conditions with netdev_event */
> > > +	rtnl_lock();
> > > +	read_lock(&cnic_dev_lock);
> > > +	list_for_each_entry(dev, &cnic_dev_list, list) {
> > > +		struct cnic_local *cp = dev->cnic_priv;
> > > +
> > > +		if (!test_and_set_bit(ULP_F_INIT, &cp->ulp_flags[ulp_type]))
> > > +			ulp_ops->cnic_init(dev);
> > > +	}
> > > +	read_unlock(&cnic_dev_lock);
> > > +	rtnl_unlock();
> > > +
> > > +	return 0;
> > > +}
> > > +
> > > +int cnic_unregister_driver(int ulp_type)
> > > +{
> > > +	struct cnic_dev *dev;
> > > +
> > > +	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> > > +		printk(KERN_ERR PFX "cnic_unregister_driver: Bad type %d\n",
> > > +		       ulp_type);
> > > +		return -EINVAL;
> > > +	}
> > > +	mutex_lock(&cnic_lock);
> > > +	if (!cnic_ulp_tbl[ulp_type]) {
> > > +		printk(KERN_ERR PFX "cnic_unregister_driver: Type %d has not "
> > > +				    "been registered\n", ulp_type);
> > > +		goto out_unlock;
> > > +	}
> > > +	read_lock(&cnic_dev_lock);
> > > +	list_for_each_entry(dev, &cnic_dev_list, list) {
> > > +		struct cnic_local *cp = dev->cnic_priv;
> > > +		
> > > +		if (rcu_dereference(cp->ulp_ops[ulp_type])) {
> > 
> > The rcu_dereference() is redundant because we hold cnic_lock.
> > (Which is OK, just wanting to make sure I understand the code.)
> 
> Yes, I wanted to access these RCU protected pointers in a uniform way.

Very good.

> > 
> > > +			printk(KERN_ERR PFX "cnic_unregister_driver: Type %d "
> > > +			       "still has devices registered\n", ulp_type);
> > > +			read_unlock(&cnic_dev_lock);
> > > +			goto out_unlock;
> > > +		}
> > > +	}
> > > +	read_unlock(&cnic_dev_lock);
> > > +
> > > +	rcu_assign_pointer(cnic_ulp_tbl[ulp_type], NULL);
> > 
> > OK, protected by cnic_lock.
> > 
> > > +
> > > +	mutex_unlock(&cnic_lock);
> > > +	synchronize_rcu();
> > 
> > The caller is responsible for freeing up cnic_ulp_tbl[ulp_type]?  If so,
> > the caller had better have kept a pointer to it...
> > 
> > But the caller would need to snapshot the pointer before the cnic_lock
> > was acquired, which means that some other pointer might in fact be
> > in place by the time this function returns.
> > 
> > So, is this data element statically allocated?  Or is there some other
> > trick being used?
> > 
> > Or is the whole point of this code simply to ensure that any calls to
> > the old cnic_ulp_tbl[ulp_type] functions have completed before this
> > function returns?  If so, please add a comment to this effect.
> 
> Yes, once again to ensure that any calls have completed before
> continuing.  I will document the use of RCU more in the next version.

Very good!

> > > +	return 0;
> > > +
> > > +out_unlock:
> > > +	mutex_unlock(&cnic_lock);
> > > +	return -EINVAL;
> > > +}
> > > +
> > > +EXPORT_SYMBOL(cnic_register_driver);
> > > +EXPORT_SYMBOL(cnic_unregister_driver);
> > > +
> > > +static int cnic_start_hw(struct cnic_dev *);
> > > +static void cnic_stop_hw(struct cnic_dev *);
> > > +
> > > +static int cnic_register_device(struct cnic_dev *dev, int ulp_type,
> > > +				void *ulp_ctx)
> > > +{
> > > +	struct cnic_local *cp = dev->cnic_priv;
> > > +	struct cnic_ulp_ops *ulp_ops;
> > > +
> > > +	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> > > +		printk(KERN_ERR PFX "cnic_register_device: Bad type %d\n",
> > > +		       ulp_type);
> > > +		return -EINVAL;
> > > +	}
> > > +	mutex_lock(&cnic_lock);
> > > +	if (cnic_ulp_tbl[ulp_type] == NULL) {
> > > +		printk(KERN_ERR PFX "cnic_register_device: Driver with type %d "
> > > +				    "has not been registered\n", ulp_type);
> > > +		mutex_unlock(&cnic_lock);
> > > +		return -EAGAIN;
> > > +	}
> > > +	if (rcu_dereference(cp->ulp_ops[ulp_type])) {
> > 
> > Again, the rcu_dereference() is redundant due to the cnic_lock being
> > held, and again, this is OK, just checking to make sure I understand it.
> > 
> > > +		printk(KERN_ERR PFX "cnic_register_device: Type %d has already "
> > > +		       "been registered to this device\n", ulp_type);
> > > +		mutex_unlock(&cnic_lock);
> > > +		return -EBUSY;
> > > +	}
> > > +	if (!try_module_get(cnic_ulp_tbl[ulp_type]->owner)) {
> > > +		mutex_unlock(&cnic_lock);
> > > +		return -EBUSY;
> > > +	}
> > > +
> > > +	clear_bit(ULP_F_START, &cp->ulp_flags[ulp_type]);
> > > +	cp->ulp_handle[ulp_type] = ulp_ctx;
> > > +	ulp_ops = cnic_ulp_tbl[ulp_type];
> > > +	rcu_assign_pointer(cp->ulp_ops[ulp_type], ulp_ops);
> > 
> > Good, protected by cnic_lock.
> > 
> > > +	cnic_hold(dev);
> > > +	if (!dev->use_count) {
> > > +		if (!test_bit(CNIC_F_IF_GOING_DOWN, &dev->flags)) {
> > > +			if (dev->netdev->flags & IFF_UP)
> > > +				set_bit(CNIC_F_IF_UP, &dev->flags);
> > > +		}
> > > +	}
> > > +	dev->use_count++;
> > > +
> > > +	if (dev->use_count == 1) {
> > > +		if (test_bit(CNIC_F_IF_UP, &dev->flags))
> > > +			cnic_start_hw(dev);
> > > +	}
> > > +
> > > +	if (test_bit(CNIC_F_CNIC_UP, &dev->flags))
> > > +		if (!test_and_set_bit(ULP_F_START, &cp->ulp_flags[ulp_type]))
> > > +			ulp_ops->cnic_start(cp->ulp_handle[ulp_type]);
> > > +
> > > +	mutex_unlock(&cnic_lock);
> > > +
> > > +	return 0;
> > > +
> > > +}
> > > +
> > > +static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
> > > +{
> > > +	struct cnic_local *cp = dev->cnic_priv;
> > > +
> > > +	if (ulp_type >= MAX_CNIC_ULP_TYPE) {
> > > +		printk(KERN_ERR PFX "cnic_unregister_device: Bad type %d\n",
> > > +		       ulp_type);
> > > +		return -EINVAL;
> > > +	}
> > > +	mutex_lock(&cnic_lock);
> > > +	if (rcu_dereference(cp->ulp_ops[ulp_type])) {
> > 
> > Ditto...
> > 
> > > +		dev->use_count--;
> > > +		module_put(cp->ulp_ops[ulp_type]->owner);
> > > +		rcu_assign_pointer(cp->ulp_ops[ulp_type], NULL);
> > 
> > OK, cnic_lock held...
> > 
> > > +		if (dev->use_count == 0)
> > > +			cnic_stop_hw(dev);
> > > +		cnic_put(dev);
> > > +	} else {
> > > +		printk(KERN_ERR PFX "cnic_unregister_device: device not "
> > > +		       "registered to this ulp type %d\n", ulp_type);
> > > +		mutex_unlock(&cnic_lock);
> > > +		return -EINVAL;
> > > +	}
> > > +	mutex_unlock(&cnic_lock);
> > > +
> > > +	synchronize_rcu();
> > 
> > Caller is again responsible for freeing up cp->ulp_ops[ulp_type]?
> > If so, the caller had better have obtained a reference to it beforehand.
> > But it might have changed in the meantime.  So, how is this freed?
> > 
> > Or is this statically allocated with the only purpose of the
> > synchronize_rcu() being to ensure that calls though the old ops vector
> > have completed before this function returns?  If so, please add a
> > comment to this effect.
> 
> Yes same as above.

Good!

> > > +
> > > +static int cnic_cm_open(struct cnic_dev *dev)
> > > +{
> > > +	struct cnic_local *cp = dev->cnic_priv;
> > > +	int err;
> > > +
> > > +	err = cnic_cm_alloc_mem(dev);
> > > +	if (err)
> > > +		return err;
> > > +
> > > +	err = cp->start_cm(dev);
> > > +
> > > +	if (err)
> > > +		goto err_out;
> > > +
> > > +	spin_lock_init(&cp->wr_lock);
> > > +
> > > +	tasklet_init(&cp->cnic_task, &cnic_task, (unsigned long) cp);
> > > +
> > > +	cp->cm_nb.notifier_call = cnic_net_callback;
> > > +	register_netevent_notifier(&cp->cm_nb);
> > > +
> > > +	dev->cm_create = cnic_cm_create;
> > > +	dev->cm_destroy = cnic_cm_destroy;
> > > +	dev->cm_connect = cnic_cm_connect;
> > > +	dev->cm_abort = cnic_cm_abort;
> > > +	dev->cm_close = cnic_cm_close;
> > > +	dev->cm_select_dev = cnic_cm_select_dev;
> > > +
> > > +	cp->ulp_handle[CNIC_ULP_L4] = dev;
> > > +	rcu_assign_pointer(cp->ulp_ops[CNIC_ULP_L4], &cm_ulp_ops);
> > 
> > The cnic_lock is not held due to this being initialization time, and
> > that no one else can be messing with this until initialization is
> > complete?
> 
> Yes, this is actually the CNIC driver registering with itself.  Only the
> CNIC driver will be using the CNIC_ULP_L4 ID.

Very good!  I will leave it to you as to whether you should add a comment
to this effect.

> > 
> > > +	return 0;
> > > +
> > > +err_out:
> > > +	cnic_cm_free_mem(dev);
> > > +	return err;
> > > +}
> > > +
> 
> > > +static void cnic_stop_bnx2_hw(struct cnic_dev *dev)
> > > +{
> > > +	struct cnic_local *cp = dev->cnic_priv;
> > > +	struct cnic_eth_dev *ethdev = cp->ethdev;
> > > +
> > > +	cnic_disable_bnx2_int_sync(dev);
> > > +
> > > +	cnic_bnx2_reg_wr_ind(dev, BNX2_CP_SCRATCH + 0x20, 0);
> > > +	cnic_bnx2_reg_wr_ind(dev, BNX2_COM_SCRATCH + 0x20, 0);
> > > +
> > > +	cnic_init_context(dev, KWQ_CID);
> > > +	cnic_init_context(dev, KCQ_CID);
> > > +
> > > +	cnic_setup_5709_context(dev, 0);
> > > +	cnic_free_irq(dev);
> > > +
> > > +	ethdev->drv_unregister_cnic(dev->netdev);
> > > +
> > > +	cnic_free_resc(dev);
> > > +}
> > > +
> > > +static void cnic_stop_hw(struct cnic_dev *dev)
> > > +{
> > > +	if (test_bit(CNIC_F_CNIC_UP, &dev->flags)) {
> > > +		struct cnic_local *cp = dev->cnic_priv;
> > > +
> > > +		clear_bit(CNIC_F_CNIC_UP, &dev->flags);
> > > +		rcu_assign_pointer(cp->ulp_ops[CNIC_ULP_L4], NULL);
> > 
> > Given that the cnic_lock does not appear to be held, what prevents
> > other CPUs from manipulating cp->ulp_ops[CNIC_ULP_L4] concurrently
> > with this function?
> > 
> 
> This is again the CNIC driver unregistering with itself.  Only the CNIC
> driver will be using the CNIC_ULP_L4 ID.

Very good -- could you please add a comment to this effect?

							Thanx, Paul

> > > +		synchronize_rcu();
> > > +		cnic_cm_shutdown(dev);
> > > +		cp->stop_hw(dev);
> > > +		pci_dev_put(dev->pcidev);
> > > +	}
> > > +}
> > > +
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
