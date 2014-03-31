From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_core: Handle null return by pci_match_id()
Date: Mon, 31 Mar 2014 07:52:20 +0300
Message-ID: <CAJZOPZKOPHDoBDSd7=ytbC8MfPPD_ZKBh6qrc0iA+mRF+FD6DQ@mail.gmail.com>
References: <1396193215-6863-1-git-send-email-amirv@mellanox.com>
	<CAJZOPZ+je04BC8BAoL1i1jAGrMFbHkFSAjypFSd3Kxc6_PC-cw@mail.gmail.com>
	<20140331035439.GA11288@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:34779 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbaCaEwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 00:52:21 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so7672770pbc.13
        for <netdev@vger.kernel.org>; Sun, 30 Mar 2014 21:52:21 -0700 (PDT)
In-Reply-To: <20140331035439.GA11288@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 6:54 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>
> On Sun, Mar 30, 2014 at 09:08:06PM +0300, Or Gerlitz wrote:
> >On Sun, Mar 30, 2014 at 6:26 PM, Amir Vadai <amirv@mellanox.com> wrote:
> >> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
> >> pci_device_id.driver_data to __mlx4_init_one during reset".
> >>
> >> pci_match_id() might return NULL if someone binds the driver to a device
> >> manually using /sys/bus/pci/drivers/.../new_id. Need to check 'id'
> >> before using it.
> >>
> >> Thanks to Bjorn who raised the problem.
> >
> >Well, that commit was applied to net and is now present in Linus
> >tree... so assuming it's too late for 3.14, need to queue this for
> >-stable
> >
> >Or.
>
> Sorry for this bothering, hope this will not block someone.
>
> Here is my suggestion for fixing this, not sure this is a good way to export
> pci_match_device() to modules. This is my current solution to this problem. If
> you have any comments, please let me know.
>
> ------------------------------------------------------------------------------
> From 9361e1edd6776202c6e11dd44d3d4d72c990b111 Mon Sep 17 00:00:00 2001
> From: Wei Yang <weiyang@linux.vnet.ibm.com>
> Date: Mon, 31 Mar 2014 11:34:57 +0800
> Subject: [PATCH net-next] net/mlx4_core: match pci_device_id including dynids



Your original commit went to net and same needs to be done for the fix



>
>
> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
> pci_device_id.driver_data to __mlx4_init_one during reset".
>
> pci_match_id() just match the static pci_device_id, which may return NULL if
> someone binds the driver to a device manually using
> /sys/bus/pci/drivers/.../new_id.
>
> This patch match pci_device_id with pci_match_device() to cover both dynids
> and static id_table.
>
> Thanks to Bjorn finding this issue.
>
> CC: Bjorn Helgaas <bhelgaas@google.com>
> CC: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c |    4 +++-
>  drivers/pci/pci-driver.c                  |    3 ++-
>  include/linux/pci.h                       |    2 ++
>  3 files changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index aa54ef7..b0edb5c 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2673,7 +2673,9 @@ static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
>         const struct pci_device_id *id;
>         int ret;
>
> -       id = pci_match_id(mlx4_pci_table, pdev);
> +       id = pci_match_device(pci_dev_driver(pdev), pdev);
> +       BUG_ON(!id);
> +
>         ret = __mlx4_init_one(pdev, id->driver_data);
>
>         return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
> diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
> index 25f0bc6..1ee26a1 100644
> --- a/drivers/pci/pci-driver.c
> +++ b/drivers/pci/pci-driver.c
> @@ -225,7 +225,7 @@ const struct pci_device_id *pci_match_id(const struct pci_device_id *ids,
>   * system is in its list of supported devices.  Returns the matching
>   * pci_device_id structure or %NULL if there is no match.
>   */
> -static const struct pci_device_id *pci_match_device(struct pci_driver *drv,
> +const struct pci_device_id *pci_match_device(struct pci_driver *drv,
>                                                     struct pci_dev *dev)
>  {
>         struct pci_dynid *dynid;
> @@ -1355,6 +1355,7 @@ postcore_initcall(pci_driver_init);
>
>  EXPORT_SYMBOL_GPL(pci_add_dynid);
>  EXPORT_SYMBOL(pci_match_id);
> +EXPORT_SYMBOL(pci_match_device);
>  EXPORT_SYMBOL(__pci_register_driver);
>  EXPORT_SYMBOL(pci_unregister_driver);
>  EXPORT_SYMBOL(pci_dev_driver);
> diff --git a/include/linux/pci.h b/include/linux/pci.h
> index 6d1cc9e..d7a7d05 100644
> --- a/include/linux/pci.h
> +++ b/include/linux/pci.h
> @@ -1135,6 +1135,8 @@ int pci_add_dynid(struct pci_driver *drv,
>                   unsigned long driver_data);
>  const struct pci_device_id *pci_match_id(const struct pci_device_id *ids,
>                                          struct pci_dev *dev);
> +const struct pci_device_id *pci_match_device(struct pci_driver *drv,
> +                                                   struct pci_dev *dev);
>  int pci_scan_bridge(struct pci_bus *bus, struct pci_dev *dev, int max,
>                     int pass);
>
> --
> 1.7.9.5
>
>
> --
> Richard Yang
> Help you, Help me
>
