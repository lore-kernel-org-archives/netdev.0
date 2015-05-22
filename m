From: Yijing Wang <wangyijing@huawei.com>
Subject: Re: e1000e pci_disable_link_state_locked() issues
Date: Fri, 22 May 2015 15:14:14 +0800
Message-ID: <555ED746.8030406@huawei.com>
References: <20150520194749.GA10210@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <intel-wired-lan@lists.osuosl.org>
To: Bjorn Helgaas <bhelgaas@google.com>,
	Yinghai Lu <yinghai@kernel.org>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150520194749.GA10210@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/5/21 3:47, Bjorn Helgaas wrote:
> I think we have some issues with the e1000e usage of
> pci_disable_link_state_locked(), which Yinghai added with 9f728f53dd70
> ("PCI/e1000e: Add and use pci_disable_link_state_locked()").
> 
> That fixed an AER deadlock in the following path, where pci_bus_sem is held
> by pci_walk_bus(), and we deadlocked when we tried to re-acquire it in
> pci_disable_link_state():
> 
>   do_recovery
>     broadcast_error_message(..., report_slot_reset)
>       pci_walk_bus
>         down_read(&pci_bus_sem)
>           cb(...)                                       # report_slot_reset
>             report_slot_reset
>               dev->driver->err_handler->slot_reset      # e1000_io_slot_reset
>                 e1000_io_slot_reset
>                   e1000e_disable_aspm
>                     pci_disable_link_state
>                       down_read(&pci_bus_sem)
> 
> 9f728f53dd70 fixed that by changing e1000e_disable_aspm() to use
> pci_disable_link_state_locked() instead, which assumes pci_bus_sem is
> already held.
> 
> That's fine for the e1000_io_slot_reset() path, where pci_bus_sem really
> *is* held.  But e1000e_disable_aspm() is also called from e1000_probe() and
> __e1000_resume(), and in those paths, we *don't* hold pci_bus_sem.
> 
> In effect, the caller of pci_disable_link_state_locked() is promising that
> pci_bus_sem is held, and __pci_disable_link_state() relies on that promise
> for its locking.  But e1000e isn't upholding its end of the bargain.
> 
> I'm not 100% sure __pci_disable_link_state() actually *needs* that locking:
> it is only called from a driver, and it should be impossible for a device

pci_disable_link_state()/pci_disable_link_state_locked() almost always be called in drivers,
one exception is a quirk function quirk_disable_aspm_l0s(). Since the final fixup is called
in pci_bus_add_device(), and we have big lock pci_rescan_remove_lock to protect the add/remove,
so I think it's still safe to call pci_disable_link_state() in quirk_disable_aspm_l0s() without
the pci_bus_sem lock.

/*
 * The 82575 and 82598 may experience data corruption issues when transitioning
 * out of L0S.  To prevent this we need to disable L0S on the pci-e link
 */
static void quirk_disable_aspm_l0s(struct pci_dev *dev)
{
	dev_info(&dev->dev, "Disabling L0s\n");
	pci_disable_link_state(dev, PCIE_LINK_STATE_L0S);
}
DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, 0x10a7, quirk_disable_aspm_l0s);
...


> or any upstream bridge to go away while a driver is bound to it.  If
> somebody wanted to analyze this further and propose a patch to remove the
> locking (if it seems safe), that would be great.
> 
> But in any case, __pci_disable_link_state() should be able to rely on its
> callers following the rules, so I'd like to see an e1000e change to use
> pci_disable_link_state() from the paths where pci_bus_sem is not held.
> 
> Bjorn
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


-- 
Thanks!
Yijing
