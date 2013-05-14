From: Yan Burman <yanb@mellanox.com>
Subject: RE: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Tue, 14 May 2013 08:58:40 +0000
Message-ID: <0EE9A1CDC8D6434DB00095CD7DB873462CFB0E4E@MTLDAG01.mtl.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org>
 <1368498506-25857-7-git-send-email-yinghai@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jack Morgenstein <jackm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Yinghai Lu <yinghai@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1368498506-25857-7-git-send-email-yinghai@kernel.org>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Yinghai Lu
> Sent: Tuesday, May 14, 2013 05:31
> To: Bjorn Helgaas
> Cc: Gu Zheng; linux-pci@vger.kernel.org; linux-kernel@vger.kernel.org; Yinghai
> Lu; netdev@vger.kernel.org
> Subject: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
> 
> Found kernel try to load mlx4 drivers for VFs before PF's is really loaded when
> the drivers are built-in, and kernel command line include probe_vfs=63,
> num_vfs=63.
> 
> It turns that it also happen for hotadd path even drivers are compiled as
> modules and if they loaded. Esp some VF share the same driver with PF.
> 
> calling path:
> 	device driver probe
> 		==> pci_enable_sriov
> 			==> virtfn_add
> 				==> pci_dev_add
> 				==> pci_bus_device_add
> when pci_bus_device_add is called, the VF's driver will be attached.
> and at that time PF's driver does not finish yet.
> 
> Need to move out pci_bus_device_add from virtfn_add and call it later. Fix
> the problem for two path, 1. hotadd path: use device_schedule_callback.
> 2. for booting path, use initcall to call that for all VF's.
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
> Cc: netdev@vger.kernel.org
> 
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c    |    7 +
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |    4 -
>  drivers/net/ethernet/cisco/enic/enic_main.c          |    2
>  drivers/net/ethernet/emulex/benet/be_main.c          |    4 +
>  drivers/net/ethernet/intel/igb/igb_main.c            |   11 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        |    2
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c       |    9 +-
>  drivers/net/ethernet/mellanox/mlx4/main.c            |    2
>  drivers/net/ethernet/neterion/vxge/vxge-main.c       |    3
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c |    5 +
>  drivers/net/ethernet/sfc/efx.c                       |    1
>  drivers/pci/iov.c                                    |   73 +++++++++++++++++--
>  drivers/scsi/lpfc/lpfc_init.c                        |    2
>  include/linux/pci.h                                  |    4 +
>  14 files changed, 115 insertions(+), 14 deletions(-)
> 
> Index: linux-2.6/drivers/net/ethernet/mellanox/mlx4/main.c
> =================================================================
> ==
> --- linux-2.6.orig/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ linux-2.6/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2308,6 +2308,8 @@ slave_start:
>  	priv->pci_dev_data = pci_dev_data;
>  	pci_set_drvdata(pdev, dev);
> 
> +	pci_bus_add_device_vfs(pdev);
> +

This seems wrong, since pci_bus_add_device_vfs() is being called for VF's as well as for PF when SRIOV is not enabled.
I can see that there are sanity checks in pci_bus_add_vf() that would prevent this code from doing damage,
but why schedule a callback that will do nothing if we can prevent scheduling altogether?
It would probably be better to do the following:

+	if (dev->flags & MLX4_FLAG_SRIOV)
+		pci_bus_add_device_vfs(pdev);
+

>  	return 0;
> 
>  err_port:
