From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] mlx4: prevent the device from being removed concurrently
Date: Wed, 29 Feb 2012 17:19:50 +0200
Message-ID: <201202291719.50764.jackm@dev.mellanox.co.il>
References: <1330454176-17768-1-git-send-email-cascardo@linux.vnet.ibm.com> <20120228.154657.1817512578346429850.davem@davemloft.net> <201202291647.53161.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, cascardo-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201202291647.53161.jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 29 February 2012 16:47, Jack Morgenstein wrote:
> Some comments.
> 
> 1. Mr Cascardo's solution is only partial, and does not cover all the problem cases. He
>    simply uncovered one of several examples of what lack-of-sync will do when removing a device.
>    Mr. Cascardo found the kernel Oops that happens when a catastrophic error occurs during device
>    removal. What if we receive a catas error while doing "init_one"?  What if we are in the middle
>    of catas error recovery (in the init_one stage), and we get a remove_one request from higher up?
> 
>    There is a solution for this precise problem in the mthca driver (infiniband/hw/mthca/mthca_main.c
>    infiniband/hw/mthca/mthca_catas.c). In the mthca driver, we DO in fact use an "mthca_device_mutex"
>    for precisely the reason given in a. above.  I see no reason not to do the same thing here.
> 
>    This requires:
> 	1. mlx4_init_one(), mlx4_remove_one() and mlx4_restart_one all grab an mlx4_device_mutex.
>         2. new procedure __mlx4_remove_one(), which does not grab the mutex.
> 
>    Note that it is NOT enough to simply protect the removal operation.  The protection must wrap the
>    ENTIRE restart operation (both removal and init), because allowing a remove in the middle of init_one
>    or restart_one would probably also cause a kernel Oops.
> 
> 2. The intf_mutex is used with mlx4_un/register_device and mlx4_un/register_interface. unregister_device is
>    used both in remove_one and in mlx4_change_port_types.  I would hesitate to grab that mutex for a more
>    global use.  I think it is cleaner to add a device mutex (mlx4_device_mutex) for initializing/removing/
>    restarting the device.
> 
> -Jack
> 
Another thing -- what about the desired final state of the device?  Say we do a remove one, and in the middle
of this, we get a catas restart.  The catas restart will wait until the remove-in-progress completes, and
then will do its remove/init -- with the net result that the device is UP rather than DOWN.

This implies that we need some sort of state machine here.

-Jack
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
