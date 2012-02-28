From: Thadeu Lima de Souza Cascardo <cascardo-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] mlx4: prevent the device from being removed concurrently
Date: Tue, 28 Feb 2012 17:34:38 -0300
Message-ID: <20120228203438.GA12028@oc1711230544.ibm.com>
References: <1330454176-17768-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <20120228.143051.352474620462899753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120228.143051.352474620462899753.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2012 at 02:30:51PM -0500, David Miller wrote:
> From: Thadeu Lima de Souza Cascardo <cascardo-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Tue, 28 Feb 2012 15:36:16 -0300
> 
> > When a EEH happens, the catas poll code will try to restart the device,
> > removing it and adding it back again. The EEH code will try to do the
> > same. One of the threads ends up accessing memory that was freed by the
> > other thread and we get a crash.
> 
> Stop adding bandaids to the locking.
> 
> If the EEH infrastructure doesn't synchronize parallel operations
> on the same device, that is the real bug, and that's where the real
> fix belongs.
> 
> I refuse to apply this patch.
> 

It's not EEH that does not synchronize removal. The problem is that the
driver itself calls the driver remove function through mlx4_restart_one.

>From catas.c:

 88 static void catas_reset(struct work_struct *work)
...
103                 ret = mlx4_restart_one(priv->dev.pdev);


>From main.c:

2013 int mlx4_restart_one(struct pci_dev *pdev)
...
2015         mlx4_remove_one(pdev);

2067 static struct pci_driver mlx4_driver = {
...
2071         .remove         = __devexit_p(mlx4_remove_one)


Real EEH support in this driver will have to do something similar to
reset the device. And this either requires that we remove or rewrite the
catas code, or that we implement some kind of locking.

Probably, what we should do here is rewrite catas code so that is
resilient to races with any code removing the device, be it EEH or
anything else. It's just that EEH will trigger the catas code and makes
it a lot easier to test this problem.

Regards.
Cascardo.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
