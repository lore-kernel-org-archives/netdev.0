From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New commands to configure IOV features
Date: Fri, 21 Sep 2012 18:35:58 +0100
Message-ID: <1348248958.2521.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <5003DC9B.8000706@broadcom.com> <5005BD00.4090106@redhat.com>
	 <5005D45D.1040302@genband.com>
	 <20120717.141153.46613285253481776.davem@davemloft.net>
	 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>
	 <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
	 <5009B186.6000806@genband.com>
	 <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
	 <5009ECDF.4090305@genband.com> <500D59BF.9040006@redhat.com>
	 <500D6932.8090306@genband.com>
	 <20120723113607.56ce7aaf@nehalam.linuxnetplumber.net>
	 <C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com>
	 <5059A767.2090307@broadcom.com> <20120919085306.00006af9@unknown>
	 <1348083847.2636.37.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAE9FiQXQj_KdWT-mVVsptxiEgGjScgDy_Lp-aXioZ4YAQh1wWQ@mail.gmail.com>
	 <1348094773.2636.85.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAE9FiQVk-uXgLK6dM8q5-Xsh8LO+c-Dd_cEpu2WzJ6Uzt6ztnA@mail.gmail.com>
	 <1348104190.4836.61.camel@deadeye.wl.decadent.org.uk>
	 <C5551D9AAB213A418B7FD5E4A6F30A07152FA5F6@ORSMSX106.amr.corp.intel.com>
	 <CAE9FiQXqFnrXT8ibD2zsmeTj-VzXb8sAOjUtryBOxEXj216pQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-pci <linux-pci@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAE9FiQXqFnrXT8ibD2zsmeTj-VzXb8sAOjUtryBOxEXj216pQQ@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-09-20 at 22:50 -0700, Yinghai Lu wrote:
[...]
> Index: linux-2.6/include/linux/pci.h
> ===================================================================
> --- linux-2.6.orig/include/linux/pci.h
> +++ linux-2.6/include/linux/pci.h
> @@ -663,6 +663,7 @@ struct pci_driver {
>         const struct pci_device_id *id_table;   /* must be non-NULL for probe to be called */
>         int  (*probe)  (struct pci_dev *dev, const struct pci_device_id *id);   /* New device inserted */
>         void (*remove) (struct pci_dev *dev);   /* Device removed (NULL if not a hot-plug capable driver) */
> +       void (*set_max_vfs) (struct pci_dev *dev); /* enable sriov */
>         int  (*suspend) (struct pci_dev *dev, pm_message_t state);      /* Device suspended */
>         int  (*suspend_late) (struct pci_dev *dev, pm_message_t state);
>         int  (*resume_early) (struct pci_dev *dev);

Not sure about this; the driver may fail to enable those VFs and it
would be nice to be able to report that failure directly.

That said, this is 'max_vfs' (a limit) and if the driver fails to set up
all the VFs then the *limit* may still be changed.

> Subject: [PATCH] PCI: Add max_vfs in sysfs per pci device where supports
> 
> driver later need to check dev->max_vfs in /sys
> 
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
[...]
> +static ssize_t
> +max_vfs_store(struct device *dev, struct device_attribute *attr,
> +                const char *buf, size_t count)
> +{
> +       unsigned long val;
> +       struct pci_dev *pdev = to_pci_dev(dev);
> +
> +       if (strict_strtoul(buf, 0, &val) < 0)
> +               return -EINVAL;
> +
> +       pdev->max_vfs = val;
> +
> +       if (pdev->is_added) {

No locking required here?

> +               int err;
> +               err = device_schedule_callback(dev, max_vfs_callback);

Any particular reason this should be a callback?

[...]
> Index: linux-2.6/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ linux-2.6/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -129,13 +129,6 @@ static struct notifier_block dca_notifie
>  };
>  #endif
>  
> -#ifdef CONFIG_PCI_IOV
> -static unsigned int max_vfs;
> -module_param(max_vfs, uint, 0);
> -MODULE_PARM_DESC(max_vfs,
> -                "Maximum number of virtual functions to allocate per
> physical function - default is zero and maximum value is 63");
> -#endif /* CONFIG_PCI_IOV */
> -
>  static unsigned int allow_unsupported_sfp;
>  module_param(allow_unsupported_sfp, uint, 0);
>  MODULE_PARM_DESC(allow_unsupported_sfp,
> @@ -4528,7 +4521,7 @@ static int __devinit ixgbe_sw_init(struc
>  #ifdef CONFIG_PCI_IOV
>         /* assign number of SR-IOV VFs */
>         if (hw->mac.type != ixgbe_mac_82598EB)
> -               adapter->num_vfs = (max_vfs > 63) ? 0 : max_vfs;
> +               adapter->num_vfs = (pdev->max_vfs > 63) ? 0 : pdev->max_vfs;

We are trying to make all SR-IOV capable drivers work the same, so this
weird limiting behaviour should not be retained.

So I think the correct assignment is:
		adapter->num_vfs = min(pdev->max_vfs, 63);

>  #endif
>         /* enable itr by default in dynamic mode */
> @@ -7249,8 +7242,9 @@ static int __devinit ixgbe_probe(struct
>  
>  #ifdef CONFIG_PCI_IOV
>         ixgbe_enable_sriov(adapter, ii);
> -
>  #endif
> +       adapter->ixgbe_info = ii;
> +
>         netdev->features = NETIF_F_SG |
>                            NETIF_F_IP_CSUM |
>                            NETIF_F_IPV6_CSUM |
> @@ -7720,11 +7714,42 @@ static const struct pci_error_handlers i
>         .resume = ixgbe_io_resume,
>  };
>  
> +static void ixgbe_set_max_vfs(struct pci_dev *pdev)
> +{
> +#ifdef CONFIG_PCI_IOV
> +       struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
> +       struct net_device *netdev = adapter->netdev;
> +       struct ixgbe_hw *hw = &adapter->hw;
> +       int num_vfs = 0;
> +
> +       /* assign number of SR-IOV VFs */
> +       if (hw->mac.type != ixgbe_mac_82598EB)
> +               num_vfs = (pdev->max_vfs > 63) ? 0 : pdev->max_vfs;
> +
> +       /* no change */
> +       if (adapter->num_vfs == num_vfs)
> +               return;
> +
> +       if (!num_vfs) {
> +               /* disable sriov */
> +               ixgbe_disable_sriov(adapter);
> +               adapter->num_vfs = 0;
> +       } else if (!adapter->num_vfs && num_vfs) {
> +               /* enable sriov */
> +               adapter->num_vfs = num_vfs;
> +               ixgbe_enable_sriov(adapter, adapter->ixgbe_info);
> +       } else {
> +               /* increase or decrease */

Indeed, increase or decrease is not supported either in our PCI API or
in the SR-IOV spec.  I think I would prefer the PCI core to filter out
unsupported changes (i.e. not call set_max_vfs and maybe report an
error), but I'm not sure about that.

Ben.

> +       }
> +#endif
> +}
> +
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
