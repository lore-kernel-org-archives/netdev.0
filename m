From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] e1000: fix IRQx nobody cared for shared irq with INTx
Date: Sat, 29 Mar 2008 16:50:58 -0700
Message-ID: <86802c440803291650v5cec6e95sb71ed10664e2799a@mail.gmail.com>
References: <200803291403.23479.yhlu.kernel@gmail.com>
	 <47EEB154.9060605@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, "Greg KH" <greg@kroah.com>,
	"Ingo Molnar" <mingo@elte.hu>,
	"kernel list" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:9962 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbYC2Xu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 19:50:59 -0400
Received: by rv-out-0910.google.com with SMTP id k20so509893rvb.1
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2008 16:50:58 -0700 (PDT)
In-Reply-To: <47EEB154.9060605@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 29, 2008 at 2:15 PM, Jeff Garzik <jeff@garzik.org> wrote:
>
> Yinghai Lu wrote:
>  > when try to kexec one latest kernel from kernel.org from RHEL 5.1 got
>  >
>  > ACPI: PCI Interrupt 0000:02:00.0[A] -> Link [LNKA] -> GSI 19 (level, low) -> IRQ 19
>  > acpi->mptable 2 : Int: type 0, pol 1, trig 1, bus 02, IRQ 00, APIC ID 0, APIC INT 13
>  > PCI: Setting latency timer of device 0000:02:00.0 to 64
>  > PCI: Enabling Mem-Wr-Inval for device 0000:02:00.0
>  > scsi0 :  on PCI bus 02 device 00 irq 19
>  > irq 19: nobody cared (try booting with the "irqpoll" option)
>  > Pid: 1, comm: swapper Not tainted 2.6.24-smp-07682-g551e4fb-dirty #19
>  >
>  > Call Trace:
>  >  <IRQ>  [<ffffffff8026a3eb>] __report_bad_irq+0x30/0x72
>  >  [<ffffffff8026a651>] note_interrupt+0x224/0x26f
>  >  [<ffffffff8026ae78>] handle_fasteoi_irq+0xa5/0xc8
>  >  [<ffffffff8021ffdc>] call_softirq+0x1c/0x28
>  >  [<ffffffff802218e2>] do_IRQ+0xf1/0x15f
>  >  [<ffffffff8021f361>] ret_from_intr+0x0/0xa
>  >  <EOI>  [<ffffffff80785bd6>] pci_mmcfg_write+0x0/0xb0
>  >  [<ffffffff80224dd9>] native_read_tsc+0xd/0x1d
>  >  [<ffffffff804681e7>] __delay+0x17/0x22
>  >  [<ffffffff805cb1a9>] lpfc_sli_brdrestart+0x14c/0x16b
>  >  [<ffffffff805cb264>] lpfc_do_config_port+0x9c/0x3e4
>  >  [<ffffffff802d77a9>] sysfs_link_sibling+0x17/0x31
>  >  [<ffffffff805cb674>] lpfc_sli_hba_setup+0xc8/0x4a2
>  >  [<ffffffff80825397>] lpfc_pci_probe_one+0x750/0x914
>  >  [<ffffffff804728f3>] pci_device_probe+0xb3/0xfb
>  >  [<ffffffff804d958c>] driver_probe_device+0xb5/0x132
>  >  [<ffffffff804d96ab>] __driver_attach+0x0/0x93
>  >  [<ffffffff804d9705>] __driver_attach+0x5a/0x93
>  >  [<ffffffff804d89bc>] bus_for_each_dev+0x44/0x6f
>  >  [<ffffffff804d91b9>] bus_add_driver+0xae/0x1f5
>  >  [<ffffffff804d990e>] driver_register+0x59/0xce
>  >  [<ffffffff80472b56>] __pci_register_driver+0x4a/0x7c
>  >  [<ffffffff80c2d78a>] lpfc_init+0x98/0xba
>  >  [<ffffffff80c0d6e7>] kernel_init+0x175/0x2e1
>  >  [<ffffffff8021fc68>] child_rip+0xa/0x12
>  >  [<ffffffff80c0d572>] kernel_init+0x0/0x2e1
>  >  [<ffffffff8021fc5e>] child_rip+0x0/0x12
>  >
>  > handlers:
>  > [<ffffffff805cdbce>] (lpfc_intr_handler+0x0/0x4c6)
>  > Disabling IRQ #19
>  >
>  > root caused that there is one Intel card that shared io apic pin and irq with
>  >  lpfc
>  >
>  > e1000_probe path only use pci_enable_device to setup irq entry but masked, and
>  > will use e1000_open to use request_irq/setup_irq to install action and
>  > enable/unmask that io apic entry.
>  >
>  > but lpfc driver will call it's probe and request_irq/setup_irq. so it
>  > enable/umask that io apic entry. and only lpfc's action the lpfc_intr_handler
>  > is installed.
>  >
>  > and some case, the e1000 sent out irq (hw bug or first kernel doesn't call
>  > e1000_irq_disable?)
>  > that irq will confuse the hanlder ... it is not for lpfc_intr_handler...
>  >
>  > So try to call pci_intx(dev, 0) in e1000_probe,
>  > and later call pci_intx(dev, 1) after request_irq in e1000_open patch, if the
>  > irq is using INTx
>  >
>  > even e1000 is using MSI, still need this patch. Because even pci_enable_msi in
>  > e1000_open path will call pci_intx(dev, 0), that is too late. when we have lpfc
>  > driver loaded before use ifconfig to set network connection.
>  >
>  > othe drivers may need to be updated in the same way, if they have same problem
>  > like nobody cared irq with shared INTx irq.
>  >
>  > Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>
>  >
>  > Index: linux-2.6/drivers/net/e1000/e1000_main.c
>  > ===================================================================
>  > --- linux-2.6.orig/drivers/net/e1000/e1000_main.c
>  > +++ linux-2.6/drivers/net/e1000/e1000_main.c
>  > @@ -324,6 +324,9 @@ static int e1000_request_irq(struct e100
>  >                       pci_disable_msi(adapter->pdev);
>  >               DPRINTK(PROBE, ERR,
>  >                       "Unable to allocate interrupt Error: %d\n", err);
>  > +     } else if (!adapter->have_msi) {
>  > +             /* enable INTx before if not using MSI */
>  > +             pci_intx(adapter->pdev, 1);
>  >       }
>  >
>  >       return err;
>  > @@ -934,6 +937,8 @@ e1000_probe(struct pci_dev *pdev,
>  >       uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
>  >       DECLARE_MAC_BUF(mac);
>  >
>  > +     /* disable INTx at first */
>  > +     pci_intx(pdev, 0);
>  >       if ((err = pci_enable_device(pdev)))
>  >               return err;
>  >
>  > Index: linux-2.6/drivers/net/e1000e/netdev.c
>  > ===================================================================
>  > --- linux-2.6.orig/drivers/net/e1000e/netdev.c
>  > +++ linux-2.6/drivers/net/e1000e/netdev.c
>  > @@ -960,6 +960,9 @@ static int e1000_request_irq(struct e100
>  >                       err);
>  >               if (adapter->flags & FLAG_MSI_ENABLED)
>  >                       pci_disable_msi(adapter->pdev);
>  > +     } else if (!(adapter->flags & FLAG_MSI_ENABLED)) {
>  > +             /* enable INTx before if not using MSI */
>  > +             pci_intx(adapter->pdev, 1);
>  >       }
>  >
>  >       return err;
>
>  These seem sane.
>
>
>
>  > @@ -3726,6 +3729,8 @@ static int __devinit e1000_probe(struct
>  >       u16 eeprom_apme_mask = E1000_EEPROM_APME;
>  >
>  >       e1000e_disable_l1aspm(pdev);
>  > +     /* disable INTx at first */
>  > +     pci_intx(pdev, 0);
>  >       err = pci_enable_device(pdev);
>  >       if (err)
>  >               return err;
>
>  Any pci_* call before pci_enable_device() is questionable.  I would put
>  it after pci_enable_device(), unless there is a _strong_ reason.

pci_intx should be safe.

void
pci_intx(struct pci_dev *pdev, int enable)
{
        u16 pci_command, new;

        pci_read_config_word(pdev, PCI_COMMAND, &pci_command);

        if (enable) {
                new = pci_command & ~PCI_COMMAND_INTX_DISABLE;
        } else {
                new = pci_command | PCI_COMMAND_INTX_DISABLE;
        }

        if (new != pci_command) {
                struct pci_devres *dr;

                pci_write_config_word(pdev, PCI_COMMAND, new);

                dr = find_pci_dr(pdev);
                if (dr && !dr->restore_intx) {
                        dr->restore_intx = 1;
                        dr->orig_intx = !enable;
                }
        }
}

static struct pci_devres * find_pci_dr(struct pci_dev *pdev)
{
        if (pci_is_managed(pdev))
                return devres_find(&pdev->dev, pcim_release, NULL, NULL);
        return NULL;
}


YH
