From: "Zhang, Yanmin" <yanmin.zhang@intel.com>
Subject: RE: [PATCH] PCI Error Recovery: e1000 network device driver
Date: Sat, 29 Apr 2006 11:26:50 +0800
Message-ID: <117E3EB5059E4E48ADFF2822933287A4A1EF47@pdsmsx404>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-pci@atrey.karlin.mff.cuni.cz>, <linuxppc-dev@ozlabs.org>,
	"Linux NICS" <linuxnics@mailbox.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56951 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S932482AbWD2D06 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 23:26:58 -0400
Content-class: urn:content-classes:message
To: "Linas Vepstas" <linas@austin.ibm.com>, "Greg KH" <greg@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>-----Original Message-----
>>From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-owner@v=
ger.kernel.org] On Behalf Of Linas Vepstas
>>Sent: 2006=C4=EA3=D4=C225=C8=D5 11:22
>>To: Greg KH
>>Cc: Jeff Garzik; Ronciak, John; Brandeburg, Jesse; Kirsher, Jeffrey T=
; linux-kernel@vger.kernel.org; netdev@vger.kernel.org;
>>linux-pci@atrey.karlin.mff.cuni.cz; linuxppc-dev@ozlabs.org; Linux NI=
CS
>>Subject: Re: [PATCH] PCI Error Recovery: e1000 network device driver
>>
>>On Fri, Mar 24, 2006 at 06:22:06PM -0800, Greg KH wrote:
>>> ... a bit
>>> different from the traditional kernel coding style.
>>
>>Sorry, this is due to inattention on my part; I get cross-eyed
>>after staring at the same code for too long. The patch below should
>>fix things.
>>
>>--linas
>>
>>
>>[PATCH] PCI Error Recovery: e1000 network device driver
>>
>>Various PCI bus errors can be signaled by newer PCI controllers.  Thi=
s
>>patch adds the PCI error recovery callbacks to the intel gigabit
>>ethernet e1000 device driver. The patch has been tested, and appears
>>to work well.
>>
>>Signed-off-by: Linas Vepstas <linas@linas.org>
>>Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>
>>----
>>
>> drivers/net/e1000/e1000_main.c |  114 ++++++++++++++++++++++++++++++=
++++++++++-
>> 1 files changed, 113 insertions(+), 1 deletion(-)
>>
>>Index: linux-2.6.16-git6/drivers/net/e1000/e1000_main.c
>>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>--- linux-2.6.16-git6.orig/drivers/net/e1000/e1000_main.c	2006-03-23 =
15:48:01.000000000 -0600
>>+++ linux-2.6.16-git6/drivers/net/e1000/e1000_main.c	2006-03-24 15:14=
:40.431371705 -0600
>>@@ -226,6 +226,16 @@ static int e1000_resume(struct pci_dev *
>>+/**
>>+ * e1000_io_error_detected - called when PCI error is detected
>>+ * @pdev: Pointer to PCI device
>>+ * @state: The current pci conneection state
>>+ *
>>+ * This function is called after a PCI bus error affecting
>>+ * this device has been detected.
>>+ */
>>+static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev=
, pci_channel_state_t state)
>>+{
>>+	struct net_device *netdev =3D pci_get_drvdata(pdev);
>>+	struct e1000_adapter *adapter =3D netdev->priv;
>>+
>>+	netif_device_detach(netdev);
>>+
>>+	if (netif_running(netdev))
>>+		e1000_down(adapter);
[YM] e1000_down will do device IO. So it's not appropriate to do so her=
e.


>>+
>>+	/* Request a slot slot reset. */
>>+	return PCI_ERS_RESULT_NEED_RESET;
>>+}
>>+
>>+/**
>>+ * e1000_io_slot_reset - called after the pci bus has been reset.
>>+ * @pdev: Pointer to PCI device
>>+ *
>>+ * Restart the card from scratch, as if from a cold-boot. Implementa=
tion
>>+ * resembles the first-half of the e1000_resume routine.
>>+ */
>>+static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
>>+{
>>+	struct net_device *netdev =3D pci_get_drvdata(pdev);
>>+	struct e1000_adapter *adapter =3D netdev->priv;
>>+
>>+	if (pci_enable_device(pdev)) {
>>+		printk(KERN_ERR "e1000: Cannot re-enable PCI device after reset.\n=
");
>>+		return PCI_ERS_RESULT_DISCONNECT;
>>+	}
>>+	pci_set_master(pdev);
>>+
>>+	pci_enable_wake(pdev, 3, 0);
>>+	pci_enable_wake(pdev, 4, 0); /* 4 =3D=3D D3 cold */
[YM] Suggest using PCI_D3hot and PCI_D3cold instead of hard-coded numbe=
rs.
