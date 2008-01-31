From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH retry] bluetooth : add conn add/del workqueues to avoid  connection fail
Date: Thu, 31 Jan 2008 14:09:30 +0100
Message-ID: <20080131130930.GW15220@kernel.dk>
References: <20080130022354.GA3132@darkstar.te-china.tietoenator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcel@holtmann.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, bluez-devel@lists.sf.net,
	netdev@vger.kernel.org
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:3556 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764850AbYAaNJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 08:09:34 -0500
Content-Disposition: inline
In-Reply-To: <20080130022354.GA3132@darkstar.te-china.tietoenator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30 2008, Dave Young wrote:
> 
> The bluetooth hci_conn sysfs add/del executed in the default workqueue.
> If the del_conn is executed after the new add_conn with same target,
> add_conn will failed with warning of "same kobject name".
> 
> Here add btaddconn & btdelconn workqueues,
> flush the btdelconn workqueue in the add_conn function to avoid the issue.
> 
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 
> 
> ---
> diff -upr a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
> --- a/net/bluetooth/hci_sysfs.c	2008-01-30 10:14:27.000000000 +0800
> +++ b/net/bluetooth/hci_sysfs.c	2008-01-30 10:14:14.000000000 +0800
> @@ -12,6 +12,8 @@
>  #undef  BT_DBG
>  #define BT_DBG(D...)
>  #endif
> +static struct workqueue_struct *btaddconn;
> +static struct workqueue_struct *btdelconn;
>  
>  static inline char *typetostr(int type)
>  {
> @@ -279,6 +281,7 @@ static void add_conn(struct work_struct 
>  	struct hci_conn *conn = container_of(work, struct hci_conn, work);
>  	int i;
>  
> +	flush_workqueue(btdelconn);
>  	if (device_add(&conn->dev) < 0) {
>  		BT_ERR("Failed to register connection device");
>  		return;
> @@ -313,6 +316,7 @@ void hci_conn_add_sysfs(struct hci_conn 
>  
>  	INIT_WORK(&conn->work, add_conn);
>  
> +	queue_work(btaddconn, &conn->work);
>  	schedule_work(&conn->work);
>  }

So you queue &conn->work on both btaddconn and keventd_wq?

-- 
Jens Axboe

