From: "Salvatore De Astis" <dev.rinux@gmail.com>
Subject: (unknown)
Date: Tue, 4 Mar 2008 10:11:13 +0100
Message-ID: <c73373920803040111n46467b2qeb11723167747ddf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:30419 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbYCDJLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 04:11:13 -0500
Received: by wf-out-1314.google.com with SMTP id 28so840396wff.4
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2008 01:11:13 -0800 (PST)
Subject: 
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I'm a junior developer and I need some informations about the octal
UART chip  Exar xr17d158.
I have two pci cards (PSCC-1028 - Actis-Computer cards) with octal
UART chip  Exar xr17d158. Linux finds the hardware and sets up the
ports (from ttyS4 to ttyS19). I read the code of 8250_pci.c and this
chip seems to be supported by linux.
 But I can't transmit and receive because the chip needs specific
values  to be written in some registers. These ones are: mpiolvl,
mpiosel and  mpio3t. I have wrote this simple module and when I load
it the board work in 232 mode.

#include <linux/module.h>
#include <linux/init.h>
#include <linux/pci.h>
#include <asm/io.h>

#define CONF_REG_START     0x80
#define CONF_REG_SIZE     0x90

typedef struct _xr17d168_conf_regs {
     u8 int0;      /* Read-only Interrupt              - value 0x00 */
    u8 int1;      /* Read-only                    - value 0x00 */
    u8 int2;      /* Read-only                    - value 0x00 */
    u8 int3;      /* Read-only                    - value 0x00 */

    u8 timercntl; /* Read-write Timer control              - value 0x00 */
    u8 timer;      /* Reserved                      - value 0x00 */
    u8 timerlsb;  /* Read/Write Timer LSB              - value 0x00 */
     u8 timermsb;  /* Read/Write Timer MSB              - value 0x00 */

    u8 mode8x;    /* Read-write                   - value 0x00 */
    u8 rega;      /* Reserved                      - value 0x00 */
    u8 reset;      /* Write only Self clear bits after reset      -
value 0x00 */
     u8 sleep;      /* Read/Write Sleep mode              - value 0x00 */

    u8 drev;      /* Read-only Device Revision            - value 0x09 */
    u8 dvid;      /* Read-only Device Identification          - value 0x28 */
     u8 regb;      /* Write-only                   - value 0x00 */
    u8 mpioint;   /* Read/Write MPIO interrupt mask          - value 0x00 */

    u8 mpiolvl;   /* Read/Write MPIO level control          - value 0x00 */
     u8 mpio3t;    /* Read/Write MPIO output control          - value 0x00 */
    u8 mpioinv;   /* Read/Write MPIO input polarity select      - value 0x00 */
    u8 mpiosel;   /* Read/Write MPIO select              - value 0xFF */
 } xr17d168_conf_regs;

xr17d168_conf_regs *xr17d168_conf_regs_ptr;

int xr17d168_init(void) {

    struct pci_dev *dev;
    int ret;
    u8 mode;
    unsigned long start_addr, end_addr, size;


    dev = pci_get_device(PCI_VENDOR_ID_EXAR, PCI_DEVICE_ID_EXAR_XR17C158, NULL);
    if(dev) {
        printk(KERN_ALERT "EXAR XR17D168 Octal PCI UART Driver init.\n");

    ret = pci_enable_device(dev);

    start_addr = pci_resource_start(dev, 0);
    end_addr = pci_resource_end(dev, 0);
    size = end_addr - start_addr;

    xr17d168_conf_regs_ptr = (xr17d168_conf_regs
*)ioremap(start_addr+CONF_REG_START,CONF_REG_SIZE);

     mode = 0xec;
    iowrite8(mode, &xr17d168_conf_regs_ptr->mpiolvl);
        iowrite8(0, &xr17d168_conf_regs_ptr->mpiosel);
        iowrite8(0, &xr17d168_conf_regs_ptr->mpio3t);

    pci_dev_put(dev);
    }
    return 0;
}

void xr17d168_exit(void) {

    printk(KERN_ALERT "EXAR XR17D168 Octal PCI UART Driver exit.\n");
    iowrite8(0, &xr17d168_conf_regs_ptr->mpiolvl);
     iowrite8(0xff, &xr17d168_conf_regs_ptr->reset);
    iounmap((void *)xr17d168_conf_regs_ptr);
}

static struct pci_driver
module_init(xr17d168_init);
module_exit(xr17d168_exit);
MODULE_LICENSE("Dual BSD/GPL");

This is my first linux driver so excuse me if it isn't perfect! I'm
working to improve myself.
My questions are:
1) Is the driver necessary to set properly the configuration registers?
2) Does exist a method (like ioctl, sysfs or proc) to configure my boards?
3) What is the better way for manage this chip that has the capability
to work in 232, 422 or half ports in 232 and others in 422 modes?

Excuse me for my bad  english!!

Yours sincerly,
-- 
Salvatore De Astis
