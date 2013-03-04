From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH 2/2] benet: Wait I/O while resuming device
Date: Mon, 4 Mar 2013 09:17:22 +0000
Message-ID: <1433171e-68da-4ebb-924f-e18b3f43858c@CMEXHTCAS2.ad.emulex.com>
References: <1362383327-32362-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1362383327-32362-2-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Seetharaman, Subramanian" <subbu.seetharaman@emulex.com>,
	"Khaparde, Ajit" <Ajit.Khaparde@Emulex.Com>
To: Gavin Shan <shangw@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:57194 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755894Ab3CDJR0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 04:17:26 -0500
In-Reply-To: <1362383327-32362-2-git-send-email-shangw@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Gavin Shan [mailto:shangw@linux.vnet.ibm.com]
> 
> After resetting the adapter, the config space register (0x7c) might give fake
> information to indicate the f/w is ready. In turn, 0xFF's is always returned while
> accessing on I/O space registers. The patch adds more check to make sure the
> I/O space is ready for access before accessing that region.
> 
...
> 
> +int be_cmd_fw_wait_io(struct be_adapter *adapter) {
> +	void __iomem *db = adapter->db + MPU_MAILBOX_DB_OFFSET;
> +	int timeout = 0;
> +	u32 val;
> +
> +	if (lancer_chip(adapter))
> +		return 0;
> +
> +	do {
> +		val = ioread32(db);
> +		if (val != 0xffffffff)
> +			return 0;
Wouldn't reading 0xffffffff from a register cause a new EEH flow to be triggered? 

Anyway, the SLIPORT_SEMAPHORE register that returns a valid POST
state *always* is available in the CSR BAR space. This will be for BE2 and BE3
chips. For Skyhawk-R chips config-space/0x7c will work fine.
I can give a patch with these changes in a few days if that works for you....

> +
> +		dev_info(&adapter->pdev->dev,
> +			"Wating for I/O (0x%08x), %ds elapsed\n",
> +			val, timeout);
> +		if (msleep_interruptible(2000)) {
> +			dev_err(&adapter->pdev->dev,
> +				"Waiting for I/O aborted\n");
> +			return -EIO;
> +		}
> +		timeout += 2;
> +	} while (timeout < 60);
> +
> +	dev_err(&adapter->pdev->dev, "Timeout waiting for I/O (%d)\n",
> timeout);
> +	return -1;
> +}
> +
