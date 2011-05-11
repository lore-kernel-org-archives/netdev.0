From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH] pci,
	e1000e: Add and use __pci_disable_link_state
Date: Wed, 11 May 2011 13:23:21 -0700
Message-ID: <4DCAF039.4030207@kernel.org>
References: <4DC6E6E8.9040306@kernel.org>
	<20110509143536.08bd0297@jbarnes-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Naga Chumbalkar <nagananda.chumbalkar@hp.com>,
	e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, John Ronciak <john.ronciak@intel.com>,
	Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	netdev@vger.kernel.org, Matthew Garrett <mjg@redhat.com>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20110509143536.08bd0297@jbarnes-desktop>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 05/09/2011 02:35 PM, Jesse Barnes wrote:
> On Sun, 08 May 2011 11:54:32 -0700
> Yinghai Lu <yinghai@kernel.org> wrote:
> 
>>
>> Need to use it in _e1000e_disable_aspm.
>> when aer happens,
>> pci_walk_bus already have down_read(&pci_bus_sem)...
>> then report_slot_reset
>>         ==> e1000_io_slot_reset
>>                 ==> e1000e_disable_aspm
>>                         ==> pci_disable_link_state...
>>
>> We can not use pci_disable_link_state, and it will try to hold pci_bus_sem again.
>>
>> Try to have __pci_disable_link_state that will not need to hold pci_bus_sem.
> 
> What about the other callers of e1000e_disable_aspm?  Do they already
> have the lock held or is it just reset that needs the already locked
> version?

yes. 

there is another version when aspm is not defined. and it does not use any lock. 

#ifdef CONFIG_PCIEASPM
static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
{
        pci_disable_link_state(pdev, state);
}
#else
static void __e1000e_disable_aspm(struct pci_dev *pdev, u16 state)
{
        int pos;
        u16 reg16;

        /*
         * Both device and parent should have the same ASPM setting.
         * Disable ASPM in downstream component first and then upstream.
         */
        pos = pci_pcie_cap(pdev);
        pci_read_config_word(pdev, pos + PCI_EXP_LNKCTL, &reg16);
        reg16 &= ~state;
        pci_write_config_word(pdev, pos + PCI_EXP_LNKCTL, reg16);

        if (!pdev->bus->self)
                return;

        pos = pci_pcie_cap(pdev->bus->self);
        pci_read_config_word(pdev->bus->self, pos + PCI_EXP_LNKCTL, &reg16);
        reg16 &= ~state;
        pci_write_config_word(pdev->bus->self, pos + PCI_EXP_LNKCTL, reg16);
}
#endif



> 
>> +extern void __pci_disable_link_state(struct pci_dev *pdev, int state);
>>  extern void pcie_clear_aspm(void);
>>  extern void pcie_no_aspm(void);
>>  #else
> 
> pci_disable_link_state_locked would be more descriptive and would match
> other usage in the kernel.

ok.

Thanks

Yinghai

------------------------------------------------------------------------------
Achieve unprecedented app performance and reliability
What every C/C++ and Fortran developer should know.
Learn how Intel has extended the reach of its next-generation tools
to help boost performance applications - inlcuding clusters.
http://p.sf.net/sfu/intel-dev2devmay
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
