From: "Lubetkin, YanirX" <yanirx.lubetkin@intel.com>
Subject: RE: [Intel-wired-lan] e1000e pci_disable_link_state_locked() issues
Date: Thu, 21 May 2015 15:56:11 +0000
Message-ID: <4D1FB504F643AC4BA12C9F34A1763FA419CB34F7@HASMSX106.ger.corp.intel.com>
References: <20150520194749.GA10210@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bjorn Helgaas <bhelgaas@google.com>,
	Yinghai Lu <yinghai@kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150520194749.GA10210@google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

I'm going to check this and will get back to you with input/questions/resolution.

Thanks,
Yanir


> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Bjorn Helgaas
> Sent: Wednesday, May 20, 2015 22:48
> To: Yinghai Lu; Kirsher, Jeffrey T
> Cc: linux-pci@vger.kernel.org; intel-wired-lan@lists.osuosl.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: [Intel-wired-lan] e1000e pci_disable_link_state_locked() issues
> 
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
> it is only called from a driver, and it should be impossible for a device or any
> upstream bridge to go away while a driver is bound to it.  If somebody
> wanted to analyze this further and propose a patch to remove the locking (if
> it seems safe), that would be great.
> 
> But in any case, __pci_disable_link_state() should be able to rely on its callers
> following the rules, so I'd like to see an e1000e change to use
> pci_disable_link_state() from the paths where pci_bus_sem is not held.
> 
> Bjorn
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@lists.osuosl.org
> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
