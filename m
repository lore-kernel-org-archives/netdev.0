From: Tejun Heo <htejun@gmail.com>
Subject: Re: 2.6.21-rc3-git4 ata1.00: qc timeout (cmd 0xef) (crashdump kernel)
Date: Tue, 13 Mar 2007 04:40:10 +0900
Message-ID: <45F5AC9A.9030601@gmail.com>
References: <6bffcb0e0703090857r14eda34bj92f3fd1d0008edb8@mail.gmail.com>	<45F51218.9030907@gmail.com>	<45F5805A.5080509@googlemail.com>	<1173718012.13341.95.camel@localhost.localdomain>	<45F58644.1070905@gmail.com>	<20070312115037.0b39b751@dxpl.pdx.osdl.net>	<45F5A3E4.4010503@gmail.com> <20070312123029.6ad619b0@freekitty>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080706020506070005040806"
Cc: tglx@linutronix.de,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Jeff Garzik <jeff@garzik.org>, linux-ide@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20070312123029.6ad619b0@freekitty>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080706020506070005040806
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> On Tue, 13 Mar 2007 04:03:00 +0900
> Tejun Heo <htejun@gmail.com> wrote:
> 
>> Stephen Hemminger wrote:
>>>> 1. the controller has IRQ stuck high (infrequent but possible)
>>>> 2. the IRQ is already requested by another device
>>>> 3. the IRQ gets disabled due to screaming interrupts at the moment
>>>> ata_piix does pci_enable_device().
>>>>
>>>> I think we can be much more resilient to screaming interrupts if we
>>>> enable device with IRQ disabled and enable it after the device is
>>>> initialized to some level, possibly when requesting IRQ.
>>> The first thing the skge driver does is do a chip reset, and that should
>>> cause IRQ to be disabled and cleared. The driver has no chance to
>>> fix it if the BIOS left the IRQ screaming...
>> What if we do something like...
>>
>> 	pci_intx(pdev, 0);
>> 	pci_enable_device(pdev);
>> 	/* initialize */
>> 	request_irq(blah blah...);
>> 	pci_intx(pdev, 1);
>>
>> Would this work for skge?
>>
> 
> Okay for testing, but any change like this should be done in the base
> PCI layer, not one off in a particular driver.

Yeap, it was a proof-of-concept pseudo code.  I attached a patch to do
above in skge.  Please point out if it is broken (e.g. intx needs to be
enabled earlier).

Michal, can you apply the attached patch and see whether it fixes the
problem.

Thanks.

-- 
tejun

--------------080706020506070005040806
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index eea75a4..2c990f2 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3585,6 +3585,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	struct skge_hw *hw;
 	int err, using_dac = 0;
 
+	pci_intx(pdev, 0);
 	err = pci_enable_device(pdev);
 	if (err) {
 		dev_err(&pdev->dev, "cannot enable PCI device\n");
@@ -3669,6 +3670,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 		       dev->name, pdev->irq);
 		goto err_out_unregister;
 	}
+	pci_intx(pdev, 1);
 	skge_show_addr(dev);
 
 	if (hw->ports > 1 && (dev1 = skge_devinit(hw, 1, using_dac))) {

--------------080706020506070005040806--
