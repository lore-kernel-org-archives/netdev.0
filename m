From: Neil Horman <nhorman@redhat.com>
Subject: Re: [PATCH net] cxgb4: Fix possible race condition in cleanup
Date: Tue, 19 Aug 2014 09:05:51 -0400
Message-ID: <20140819130551.GA6850@hmsreliant.think-freely.org>
References: <1408394819-31073-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	hariprasad@chelsio.com, svemuri@chelsio.com
To: Anish Bhatt <anish@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385AbaHSNF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2014 09:05:59 -0400
Content-Disposition: inline
In-Reply-To: <1408394819-31073-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2014 at 01:46:59PM -0700, Anish Bhatt wrote:
> There is a possible race condition when we unregister the PCI Driver and then
> flush/destroy the global workq. This could lead to situations where there
> are tasks on the work queue with references to now deleted adapter data
> structures. Instead, have per-adapter work queues which were instantiated and
> torn down in init_one() and remove_one(), respectively.
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 33 ++++++++++++++-----------
>  2 files changed, 20 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> index d572821..c067b78 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
> @@ -652,6 +652,7 @@ struct adapter {
>  	struct tid_info tids;
>  	void **tid_release_head;
>  	spinlock_t tid_release_lock;
> +	struct workqueue_struct *workq;
>  	struct work_struct tid_release_task;
>  	struct work_struct db_full_task;
>  	struct work_struct db_drop_task;
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> index 1afee70..e92aba8 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> @@ -643,8 +643,6 @@ static int set_rxmode(struct net_device *dev, int mtu, bool sleep_ok)
>  	return ret;
>  }
>  
> -static struct workqueue_struct *workq;
> -
>  /**
>   *	link_start - enable a port
>   *	@dev: the port to enable
> @@ -3340,7 +3338,7 @@ static void cxgb4_queue_tid_release(struct tid_info *t, unsigned int chan,
>  	adap->tid_release_head = (void **)((uintptr_t)p | chan);
>  	if (!adap->tid_release_task_busy) {
>  		adap->tid_release_task_busy = true;
> -		queue_work(workq, &adap->tid_release_task);
> +		queue_work(adap->workq, &adap->tid_release_task);
>  	}
>  	spin_unlock_bh(&adap->tid_release_lock);
>  }
> @@ -4140,7 +4138,7 @@ void t4_db_full(struct adapter *adap)
>  		notify_rdma_uld(adap, CXGB4_CONTROL_DB_FULL);
>  		t4_set_reg_field(adap, SGE_INT_ENABLE3,
>  				 DBFIFO_HP_INT | DBFIFO_LP_INT, 0);
> -		queue_work(workq, &adap->db_full_task);
> +		queue_work(adap->workq, &adap->db_full_task);
>  	}
>  }
>  
> @@ -4150,7 +4148,7 @@ void t4_db_dropped(struct adapter *adap)
>  		disable_dbs(adap);
>  		notify_rdma_uld(adap, CXGB4_CONTROL_DB_FULL);
>  	}
> -	queue_work(workq, &adap->db_drop_task);
> +	queue_work(adap->workq, &adap->db_drop_task);
>  }
>  
>  static void uld_attach(struct adapter *adap, unsigned int uld)
> @@ -6517,6 +6515,12 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		goto out_disable_device;
>  	}
>  
> +	adapter->workq = create_singlethread_workqueue("cxgb4");
> +	if (!adapter->workq) {
> +		err = -ENOMEM;
> +		goto out_free_adapter;
> +	}
> +
>  	/* PCI device has been enabled */
>  	adapter->flags |= DEV_ENABLED;
>  
> @@ -6715,6 +6719,9 @@ sriov:
>   out_unmap_bar0:
>  	iounmap(adapter->regs);
>   out_free_adapter:
> +	if (adapter->workq)
> +		destroy_workqueue(adapter->workq);
> +
>  	kfree(adapter);
>   out_disable_device:
>  	pci_disable_pcie_error_reporting(pdev);
> @@ -6736,6 +6743,12 @@ static void remove_one(struct pci_dev *pdev)
>  	if (adapter) {
>  		int i;
>  
> +		/* Tear down per-adapter Work Queue first since it can contain
> +		 * references to our adapter data structure.
> +		 */
> +		flush_workqueue(adapter->workq);
> +		destroy_workqueue(adapter->workq);
> +
nit: flush_workqueue is implied by destroy_workqueue.  It doesn't change any
functionality but you don't need to do both here.  destroy_workqueue is
sufficient.

Neil
