From: Jon Mason <jon.mason@intel.com>
Subject: Re: [1/2] PCI-Express Non-Transparent Bridge Support
Date: Wed, 10 Oct 2012 10:06:32 -0700
Message-ID: <20121010170631.GE22838@jonmason-lab>
References: <1349213177-9985-2-git-send-email-jon.mason@intel.com>
 <20121007141344.6624e873@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@risingtidesystems.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121007141344.6624e873@wp.pl>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 07, 2012 at 02:13:44PM +0200, Jakub Kicinski wrote:
> Hi,
> 
> it's good to see some NTB code getting into mainline! I have a few comments
> though.
> 
> On Tue, 02 Oct 2012 21:26:16 -0000, Jon Mason <jon.mason@intel.com>
> wrote:
> 
> [...]
> >+/**
> >+ * ntb_write_local_spad() - write to the secondary scratchpad register
> >+ * @ndev: pointer to ntb_device instance
> >+ * @idx: index to the scratchpad register, 0 based
> >+ * @val: the data value to put into the register
> >+ *
> >+ * This function allows writing of a 32bit value to the indexed scratchpad
> >+ * register. The register resides on the secondary (external) side.
> >+ *
> >+ * RETURNS: An appropriate -ERRNO error value on error, or zero for success.
> >+ */
> [...]
> >+/**
> >+ * ntb_write_remote_spad() - write to the secondary scratchpad register
> >+ * @ndev: pointer to ntb_device instance
> >+ * @idx: index to the scratchpad register, 0 based
> >+ * @val: the data value to put into the register
> >+ *
> >+ * This function allows writing of a 32bit value to the indexed scratchpad
> >+ * register. The register resides on the secondary (external) side.
> >+ *
> >+ * RETURNS: An appropriate -ERRNO error value on error, or zero for success.
> >+ */
> 
> Those comments look suspiciously similar. I think one of the functions
> does write to primary scratchpad?

Yes, the comments can be improved.

> 
> [...]
> >+/**
> >+ * ntb_read_local_spad() - read from the primary scratchpad register
> >+ * @ndev: pointer to ntb_device instance
> >+ * @idx: index to scratchpad register, 0 based
> >+ * @val: pointer to 32bit integer for storing the register value
> >+ *
> >+ * This function allows reading of the 32bit scratchpad register on
> >+ * the primary (internal) side.
> >+ *
> >+ * RETURNS: An appropriate -ERRNO error value on error, or zero for success.
> >+ */
> [...]
> >+/**
> >+ * ntb_read_remote_spad() - read from the primary scratchpad register
> >+ * @ndev: pointer to ntb_device instance
> >+ * @idx: index to scratchpad register, 0 based
> >+ * @val: pointer to 32bit integer for storing the register value
> >+ *
> >+ * This function allows reading of the 32bit scratchpad register on
> >+ * the primary (internal) side.
> >+ *
> >+ * RETURNS: An appropriate -ERRNO error value on error, or zero for success.
> >+ */
> 
> Same here.
> 
> [...]
> >+static int ntb_setup_msix(struct ntb_device *ndev)
> >+{
> >+	struct pci_dev *pdev = ndev->pdev;
> >+	struct msix_entry *msix;
> >+	int msix_entries;
> >+	int rc, i, pos;
> >+	u16 val;
> >+
> >+	pos = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
> >+	if (!pos) {
> >+		rc = -EIO;
> >+		goto err;
> >+	}
> >+
> >+	rc = pci_read_config_word(pdev, pos + PCI_MSIX_FLAGS, &val);
> >+	if (rc)
> >+		goto err;
> >+
> >+	msix_entries = msix_table_size(val);
> >+	if (msix_entries > ndev->limits.msix_cnt) {
> >+		rc = -EINVAL;
> >+		goto err;
> >+	}
> >+
> >+	ndev->msix_entries = kmalloc(sizeof(struct msix_entry) * msix_entries,
> >+				     GFP_KERNEL);
> >+	if (!ndev->msix_entries) {
> >+		rc = -ENOMEM;
> >+		goto err;
> >+	}
> >+
> >+	for (i = 0; i < msix_entries; i++)
> >+		ndev->msix_entries[i].entry = i;
> >+
> >+	rc = pci_enable_msix(pdev, ndev->msix_entries, msix_entries);
> >+	if (rc < 0)
> >+		goto err1;
> >+	if (rc > 0) {
> 
> rc > 0 doesn't mean that vectors were allocated. Have a look at the
> example in Documentation/PCI/MSI-HOWTO.txt.

Thank you, I will correct this.

> 
> >+		/* On SNB, the link interrupt is always tied to 4th vector.  If
> >+		 * we can't get all 4, then we can't use MSI-X.
> >+		 */
> >+		if (ndev->hw_type != BWD_HW) {
> >+			rc = -EIO;
> >+			goto err1;
> >+		}
> 
> This looks fragile, what if msix_table_size(val) was < 4? 

If there are not at least 4 vectors, then we shouldn't use MSI-X.

> 
> >+
> >+		dev_warn(&pdev->dev,
> >+			 "Only %d MSI-X vectors.  Limiting the number of queues to that number.\n",
> >+			 rc);
> >+		msix_entries = rc;
> >+	}
> >+
> >+	for (i = 0; i < msix_entries; i++) {
> >+		msix = &ndev->msix_entries[i];
> >+		WARN_ON(!msix->vector);
> >+
> >+		/* Use the last MSI-X vector for Link status */
> >+		if (ndev->hw_type == BWD_HW) {
> >+			rc = request_irq(msix->vector, bwd_callback_msix_irq, 0,
> >+					 "ntb-callback-msix", &ndev->db_cb[i]);
> >+			if (rc)
> >+				goto err2;
> >+		} else {
> >+			if (i == msix_entries - 1) {
> >+				rc = request_irq(msix->vector,
> >+						 xeon_event_msix_irq, 0,
> >+						 "ntb-event-msix", ndev);
> >+				if (rc)
> >+					goto err2;
> >+			} else {
> >+				rc = request_irq(msix->vector,
> >+						 xeon_callback_msix_irq, 0,
> >+						 "ntb-callback-msix",
> >+						 &ndev->db_cb[i]);
> >+				if (rc)
> >+					goto err2;
> >+			}
> >+		}
> >+	}
> >+
> >+	ndev->num_msix = msix_entries;
> >+	if (ndev->hw_type == BWD_HW)
> >+		ndev->max_cbs = msix_entries;
> >+	else
> >+		ndev->max_cbs = msix_entries - 1;
> >+
> >+	return 0;
> >+
> >+err2:
> >+	while (--i >= 0) {
> >+		msix = &ndev->msix_entries[i];
> >+		if (ndev->hw_type != BWD_HW && i == ndev->num_msix - 1)
> >+			free_irq(msix->vector, ndev);
> >+		else
> >+			free_irq(msix->vector, &ndev->db_cb[i]);
> >+	}
> >+	pci_disable_msix(pdev);
> >+err1:
> >+	kfree(ndev->msix_entries);
> >+	dev_err(&pdev->dev, "Error allocating MSI-X interrupt\n");
> >+err:
> >+	ndev->num_msix = 0;
> >+	return rc;
> >+}
> 
> Thanks for your work,

Thanks for the review.

> 
>   -- Kuba
