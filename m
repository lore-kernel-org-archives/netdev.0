From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv4 net-next 05/32] cxgb4: use
 spinlock_irqsave/spinlock_irqrestore for db lock
Date: Sat, 08 Mar 2014 00:43:12 -0500 (EST)
Message-ID: <20140308.004312.1333337731427216882.davem@davemloft.net>
References: <1394188409-9739-1-git-send-email-hariprasad@chelsio.com>
	<1394188409-9739-6-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394188409-9739-6-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Fri,  7 Mar 2014 16:03:02 +0530

> @@ -3585,9 +3585,11 @@ static void disable_txq_db(struct sge_txq *q)
>  
>  static void enable_txq_db(struct sge_txq *q)
>  {
> -	spin_lock_irq(&q->db_lock);
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&q->db_lock, flags);
>  	q->db_disabled = 0;
> -	spin_unlock_irq(&q->db_lock);
> +	spin_unlock_irqrestore(&q->db_lock, flags);
>  }
>  
>  static void disable_dbs(struct adapter *adap)
> @@ -3617,9 +3619,10 @@ static void enable_dbs(struct adapter *adap)

At least be consistent when making changes like this.

You are changing from spin_{un,}lock_irq() to
spin_{un,}lock_irq{save,restore}() here in enable_txq_db()
but not in disable_txq_db().

But both of those functions are invoked, via one level of
indirection, from the same exact function: process_db_drop()

Futhermore, this function process_db_drop() runs via a workqueue, and
therefore always runs with interrupts enabled.  So you shouldn't need
to use the save/restore spinlock variants at all.  Plain
spin_lock_irq() and spin_unlock_irq(), as is currently coded, is
perfectly fine.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
