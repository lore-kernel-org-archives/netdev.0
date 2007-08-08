From: "Indan Zupancic" <indan@nul.nu>
Subject: 2.6.23-rc2: WARNING at kernel/irq/resend.c:70 check_irq_resend()
Date: Wed, 8 Aug 2007 20:09:07 +0200 (CEST)
Message-ID: <38436.81.207.0.53.1186596547.squirrel@secure.samage.net>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
To: "Thomas Gleixner" <tglx@linutronix.de>,
	"lkml" <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965215AbXHHSJg@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Just added an old network card, RTL-8029(AS), ne2k-pci driver, and tried to
expand the network (failed because I didn't use a cross-over cable).

The code snippet that spat the thing:

/*
 * IRQ resend
 *
 * Is called with interrupts disabled and desc->lock held.
 */
void check_irq_resend(struct irq_desc *desc, unsigned int irq)
{
	unsigned int status = desc->status;

	/*
	 * Make sure the interrupt is enabled, before resending it:
	 */
	desc->chip->enable(irq);

	/*
	 * Temporary hack to figure out more about the problem, which
	 * is causing the ancient network cards to die.
	 */
	if (desc->handle_irq != handle_edge_irq) {
		WARN_ON_ONCE(1);
		return;
	}

and relevant dmesg snippet:

[  446.836399] eth1: RealTek RTL-8029 found at 0x9000, IRQ 16, 00:00:B4:BB:BF:E5.
[  855.458468] r8169: eth0: link up
[  857.500667] r8169: eth0: link up
[  902.294283] r8169: eth0: link up
[ 4126.348427] r8169: eth0: link up
[ 5598.446233] r8169: eth0: link down
[ 5618.904846] r8169: eth0: link up
[ 5623.133090] r8169: eth0: link down
[ 5624.708071] r8169: eth0: link up
[ 6328.267872] WARNING: at /home/indan/src/git/linux-2.6/kernel/irq/resend.c:70 check_irq_resend()
[ 6328.267896]  [<b0135d8f>] check_irq_resend+0x4f/0x8c
[ 6328.267912]  [<b0135888>] enable_irq+0x84/0xaa
[ 6328.267918]  [<c08e37cc>] ne2k_pci_block_output+0x0/0x138 [ne2k_pci]
[ 6328.267931]  [<c08e37cc>] ne2k_pci_block_output+0x0/0x138 [ne2k_pci]
[ 6328.267939]  [<c08e37cc>] ne2k_pci_block_output+0x0/0x138 [ne2k_pci]
[ 6328.267947]  [<c08e0f8a>] ei_start_xmit+0x29f/0x2b9 [8390]
[ 6328.267966]  [<b022a53e>] dev_hard_start_xmit+0x19e/0x1fd
[ 6328.267976]  [<b023620a>] __qdisc_run+0x6c/0x151
[ 6328.267986]  [<b022c459>] dev_queue_xmit+0x12a/0x271
[ 6328.267991]  [<b0260ec9>] arp_send+0x4c/0x64
[ 6328.268002]  [<b0260524>] arp_xmit+0x4d/0x51
[ 6328.268009]  [<b026117c>] arp_process+0x29b/0x50a
[ 6328.268018]  [<b0244f0a>] ip_forward+0x22c/0x23a
[ 6328.268026]  [<b02434a8>] ip_rcv_finish+0x0/0x282
[ 6328.268032]  [<b0243db9>] ip_rcv+0x479/0x4a8
[ 6328.268037]  [<b02434a8>] ip_rcv_finish+0x0/0x282
[ 6328.268044]  [<b02614db>] arp_rcv+0xf0/0x104
[ 6328.268049]  [<b012ae17>] hrtimer_run_queues+0x12/0x1a1
[ 6328.268055]  [<b02613eb>] arp_rcv+0x0/0x104
[ 6328.268061]  [<b022a07d>] netif_receive_skb+0x2d9/0x317
[ 6328.268068]  [<b022baa0>] process_backlog+0x6d/0xd2
[ 6328.268075]  [<b022c1c2>] net_rx_action+0x81/0x14d
[ 6328.268082]  [<b011dd84>] __do_softirq+0x35/0x75
[ 6328.268088]  [<b0106030>] do_softirq+0x3e/0x8d
[ 6328.268098]  [<b0136530>] handle_fasteoi_irq+0x0/0xbe
[ 6328.268103]  [<b011dd44>] irq_exit+0x25/0x30
[ 6328.268107]  [<b010630f>] do_IRQ+0x94/0xad
[ 6328.268114]  [<b0104763>] common_interrupt+0x23/0x28
[ 6328.268123]  [<b0102a0c>] default_idle+0x27/0x39
[ 6328.268128]  [<b0102347>] cpu_idle+0x41/0x55
[ 6328.268133]  [<b032f99b>] start_kernel+0x20e/0x213
[ 6328.268140]  [<b032f317>] unknown_bootoption+0x0/0x196
[ 6328.268146]  =======================

# cat /proc/interrupts
           CPU0
  0:    9804926   IO-APIC-edge      timer
  1:       8270   IO-APIC-edge      i8042
  9:          0   IO-APIC-fasteoi   acpi
 12:     181281   IO-APIC-edge      i8042
 16:      40410   IO-APIC-fasteoi   sata_sil, eth1
 17:          0   IO-APIC-fasteoi   ohci_hcd:usb1, NVidia nForce2
 18:     499428   IO-APIC-fasteoi   ohci_hcd:usb2
 19:          2   IO-APIC-fasteoi   ehci_hcd:usb3
 20:     689588   IO-APIC-fasteoi   eth0
NMI:          0
LOC:    9805098
ERR:          0
MIS:          0

So the card is sharing an IRQ with the disk controller.

No idea if the network card died after this warning, for all
practical purposes it didn't work before, so couldn't check.

I can provide more information and run some tests if anyone
wants that, just keep in mind that the card isn't connected to
anything.

Greetings,

Indan
