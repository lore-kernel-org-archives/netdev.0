From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] pci, e1000e: Add and use __pci_disable_link_state
Date: Thu, 12 May 2011 16:32:10 -0700
Message-ID: <20110512163210.132a2954@jbarnes-desktop>
References: <4DC6E6E8.9040306@kernel.org>
	<20110509143536.08bd0297@jbarnes-desktop>
	<4DCAF039.4030207@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	Matthew Garrett <mjg@redhat.com>,
	Naga Chumbalkar <nagananda.chumbalkar@hp.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4DCAF039.4030207@kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 May 2011 13:23:21 -0700
Yinghai Lu <yinghai@kernel.org> wrote:

> On 05/09/2011 02:35 PM, Jesse Barnes wrote:
> > On Sun, 08 May 2011 11:54:32 -0700
> > Yinghai Lu <yinghai@kernel.org> wrote:
> > 
> >>
> >> Need to use it in _e1000e_disable_aspm.
> >> when aer happens,
> >> pci_walk_bus already have down_read(&pci_bus_sem)...
> >> then report_slot_reset
> >>         ==> e1000_io_slot_reset
> >>                 ==> e1000e_disable_aspm
> >>                         ==> pci_disable_link_state...
> >>
> >> We can not use pci_disable_link_state, and it will try to hold pci_bus_sem again.
> >>
> >> Try to have __pci_disable_link_state that will not need to hold pci_bus_sem.
> > 
> > What about the other callers of e1000e_disable_aspm?  Do they already
> > have the lock held or is it just reset that needs the already locked
> > version?
> 
> yes. 
> 
> there is another version when aspm is not defined. and it does not use any lock. 
> 
> #ifdef CONFIG_PCIEASPM
> static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
> {
>         pci_disable_link_state(pdev, state);
> }
> #else
> static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
> {
>         int pos;
>         u16 reg16;
> 
>         /*
>          * Both device and parent should have the same ASPM setting.
>          * Disable ASPM in downstream component first and then upstream.
>          */
>         pos = pci_pcie_cap(pdev);
>         pci_read_config_word(pdev, pos + PCI_EXP_LNKCTL, &reg16);
>         reg16 &= ~state;
>         pci_write_config_word(pdev, pos + PCI_EXP_LNKCTL, reg16);
> 
>         if (!pdev->bus->self)
>                 return;
> 
>         pos = pci_pcie_cap(pdev->bus->self);
>         pci_read_config_word(pdev->bus->self, pos + PCI_EXP_LNKCTL, &reg16);
>         reg16 &= ~state;
>         pci_write_config_word(pdev->bus->self, pos + PCI_EXP_LNKCTL, reg16);
> }
> #endif

No, I mean __e1000e_disable_aspm is called from several spots:

*** drivers/net/e1000e/82571.c:
e1000_get_variants_82571[435]  e1000e_disable_aspm(adapter->pdev, PCIE_LINK_STATE_L0S);

*** drivers/net/e1000e/netdev.c:
e1000_change_mtu[5027]         e1000e_disable_aspm(adapter->pdev, PCIE_LINK_STATE_L1);
__e1000_resume[5402]           e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
e1000_io_slot_reset[5650]      e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
e1000_probe[5797]              e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);

Are all of them safe for the unlocked version of ASPM disable?

-- 
Jesse Barnes, Intel Open Source Technology Center
