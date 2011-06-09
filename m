From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bnx2i: fix bnx2i driver to test for physical device
 support of iscsi early
Date: Wed, 8 Jun 2011 20:19:48 -0400
Message-ID: <20110609001948.GA8203@neilslaptop.think-freely.org>
References: <1307561363-11677-1-git-send-email-nhorman@tuxdriver.com>
 <1307563443.8532.42.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mike Christie <michaelc@cs.wisc.edu>,
	"David S. Miller" <davem@davemloft.net>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37031 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880Ab1FIAT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 20:19:58 -0400
Content-Disposition: inline
In-Reply-To: <1307563443.8532.42.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 08, 2011 at 01:04:03PM -0700, Michael Chan wrote:
> 
> On Wed, 2011-06-08 at 12:29 -0700, Neil Horman wrote:
> > Recently reported error message indicating the following error:
> > bnx2 0003:01:00.1: eth1: Failed waiting for ULP up call to complete
> > 
> > The card in question is:
> > eth0: Broadcom NetXtreme II BCM5709 1000Base-SX (C0)
> > 
> > Which doesn't appear to support isci.  The undrlying cause of the error above is
> > the fact that bnx2i assumes that every bnx2 card supports iscsi, and doesn't
> > actually test for support until the iscsi virtual adapter is being brought up in
> > bnx2i_start (pointed to by cnic_start).  bnx2i_start tests for
> > cnic->max_iscsi_conn, and if that value is zero, attempts to unregister the
> > device from the cnic framework.  Unfortunately, cnic_unregister_device (pointed
> > to by cnic->unregister_device), waits for the ULP_F_CALL_PENDING to be cleared
> > before completing, and if that doesn't occur within a few tenths of a second, we
> > issue the above warning.  Since that flag gets set prior to the call to
> > bnx2i_start and cleared on its return, we're guaranteed to get this error for
> > any bnx2 adapter not supporting iscsi.
> > 
> > It seems the correct fix is to detect earlier if an adapter supports iscsi and
> > not even try to register the device with cnic if it doesn't.  This is already
> > what bnx2x does, so this patch clones the functionality of that driver for bnx2.
> 
> Thanks Neil.  We have a similar patch almost ready to be posted.  The
> main difference is that cp->max_iscsi_conn is read ahead of time during
> bnx2_init_one().  We cannot read registers in bnx2_cnic_probe() because
> it may be called when the device is already down.  I'll send out that
How do you figure?  bnx2_cnic_probe is only called from is_cnic_dev (which still
makes me shake my head a bit).  is_cnic_dev is only called from
cnic_netdev_event, which holds the rtnl_lock.  Since the event we trigger on is
called from NETDEV_REGISTER or NETDEV_UP, I don't see how we can wind up
suspending the device prior to caling bnx2_cnic_probe.  And it seems to me to be
a better solution to do the read in bnx2_cnic_probe than to distribute the
initalization of cnic_eth_dev throughout the bnx2 driver.

Neil

> patchset very soon.  Thanks again.
> 
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > CC: Michael Chan <mchan@broadcom.com>
> > CC: Mike Christie <michaelc@cs.wisc.edu>
> > CC: "David S. Miller" <davem@davemloft.net>
> > ---
> >  drivers/net/bnx2.c              |    2 +-
> >  drivers/net/cnic.c              |   15 +++------------
> >  drivers/scsi/bnx2i/bnx2i_init.c |   29 +++++++++++++++--------------
> >  3 files changed, 19 insertions(+), 27 deletions(-)
> > 
> > diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> > index 57d3293..927e3e6 100644
> > --- a/drivers/net/bnx2.c
> > +++ b/drivers/net/bnx2.c
> > @@ -423,7 +423,7 @@ struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev)
> >  	cp->drv_ctl = bnx2_drv_ctl;
> >  	cp->drv_register_cnic = bnx2_register_cnic;
> >  	cp->drv_unregister_cnic = bnx2_unregister_cnic;
> > -
> > +	cp->max_iscsi_conn = bnx2_reg_rd_ind(bp, BNX2_FW_MAX_ISCSI_CONN);
> >  	return cp;
> >  }
> >  EXPORT_SYMBOL(bnx2_cnic_probe);
> > diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
> > index 11a92af..b6f6211 100644
> > --- a/drivers/net/cnic.c
> > +++ b/drivers/net/cnic.c
> > @@ -2420,13 +2420,11 @@ static int cnic_bnx2x_fcoe_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
> >  
> >  static int cnic_bnx2x_fcoe_fw_destroy(struct cnic_dev *dev, struct kwqe *kwqe)
> >  {
> > -	struct fcoe_kwqe_destroy *req;
> >  	union l5cm_specific_data l5_data;
> >  	struct cnic_local *cp = dev->cnic_priv;
> >  	int ret;
> >  	u32 cid;
> >  
> > -	req = (struct fcoe_kwqe_destroy *) kwqe;
> >  	cid = BNX2X_HW_CID(cp, cp->fcoe_init_cid);
> >  
> >  	memset(&l5_data, 0, sizeof(l5_data));
> > @@ -4218,14 +4216,6 @@ static void cnic_enable_bnx2_int(struct cnic_dev *dev)
> >  		BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID | cp->last_status_idx);
> >  }
> >  
> > -static void cnic_get_bnx2_iscsi_info(struct cnic_dev *dev)
> > -{
> > -	u32 max_conn;
> > -
> > -	max_conn = cnic_reg_rd_ind(dev, BNX2_FW_MAX_ISCSI_CONN);
> > -	dev->max_iscsi_conn = max_conn;
> > -}
> > -
> >  static void cnic_disable_bnx2_int_sync(struct cnic_dev *dev)
> >  {
> >  	struct cnic_local *cp = dev->cnic_priv;
> > @@ -4550,8 +4540,6 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
> >  		return err;
> >  	}
> >  
> > -	cnic_get_bnx2_iscsi_info(dev);
> > -
> >  	return 0;
> >  }
> >  
> > @@ -5230,6 +5218,9 @@ static struct cnic_dev *init_bnx2_cnic(struct net_device *dev)
> >  	cp->close_conn = cnic_close_bnx2_conn;
> >  	cp->next_idx = cnic_bnx2_next_idx;
> >  	cp->hw_idx = cnic_bnx2_hw_idx;
> > +
> > +	cdev->max_iscsi_conn = ethdev->max_iscsi_conn;
> > +
> >  	return cdev;
> >  
> >  cnic_err:
> > diff --git a/drivers/scsi/bnx2i/bnx2i_init.c b/drivers/scsi/bnx2i/bnx2i_init.c
> > index 1d24a28..263bc60 100644
> > --- a/drivers/scsi/bnx2i/bnx2i_init.c
> > +++ b/drivers/scsi/bnx2i/bnx2i_init.c
> > @@ -163,21 +163,14 @@ void bnx2i_start(void *handle)
> >  	struct bnx2i_hba *hba = handle;
> >  	int i = HZ;
> >  
> > -	if (!hba->cnic->max_iscsi_conn) {
> > -		printk(KERN_ALERT "bnx2i: dev %s does not support "
> > -			"iSCSI\n", hba->netdev->name);
> > +	/**
> > +	 * We should never register devices that don't support iscsi
> > +	 * (see bnx2i_init_one), so something is wrong if we try to
> > +	 * to start an iscsi adapter on hardware wtih 0 supported
> > +	 * iscsi connections
> > +	 */
> > +	BUG_ON(!hba->cnic->max_iscsi_conn);
> >  
> > -		if (test_bit(BNX2I_CNIC_REGISTERED, &hba->reg_with_cnic)) {
> > -			mutex_lock(&bnx2i_dev_lock);
> > -			list_del_init(&hba->link);
> > -			adapter_count--;
> > -			hba->cnic->unregister_device(hba->cnic, CNIC_ULP_ISCSI);
> > -			clear_bit(BNX2I_CNIC_REGISTERED, &hba->reg_with_cnic);
> > -			mutex_unlock(&bnx2i_dev_lock);
> > -			bnx2i_free_hba(hba);
> > -		}
> > -		return;
> > -	}
> >  	bnx2i_send_fw_iscsi_init_msg(hba);
> >  	while (!test_bit(ADAPTER_STATE_UP, &hba->adapter_state) && i--)
> >  		msleep(BNX2I_INIT_POLL_TIME);
> > @@ -281,6 +274,13 @@ static int bnx2i_init_one(struct bnx2i_hba *hba, struct cnic_dev *cnic)
> >  	int rc;
> >  
> >  	mutex_lock(&bnx2i_dev_lock);
> > +	if (!cnic->max_iscsi_conn) {
> > +		printk(KERN_ALERT "bnx2i: dev %s does not support "
> > +			"iSCSI\n", hba->netdev->name);
> > +		rc = -EOPNOTSUPP;
> > +		goto out;
> > +	}
> > +
> >  	hba->cnic = cnic;
> >  	rc = cnic->register_device(cnic, CNIC_ULP_ISCSI, hba);
> >  	if (!rc) {
> > @@ -298,6 +298,7 @@ static int bnx2i_init_one(struct bnx2i_hba *hba, struct cnic_dev *cnic)
> >  	else
> >  		printk(KERN_ERR "bnx2i dev reg, unknown error, %d\n", rc);
> >  
> > +out:
> >  	mutex_unlock(&bnx2i_dev_lock);
> >  
> >  	return rc;
> 
> 
> 
