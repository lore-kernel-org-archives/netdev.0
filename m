From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next V3 09/18] liquidio: MSIX support for CN23XX
Date: Mon, 22 Aug 2016 17:36:07 +0000
Message-ID: <CO2PR11MB0088969E015C67811BC64E0197E80@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <1471824765-26473-10-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0119.outbound.protection.outlook.com ([104.47.41.119]:59460
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754256AbcHVRgM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 13:36:12 -0400
In-Reply-To: <1471824765-26473-10-git-send-email-rvatsavayi@caviumnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	u64 time_threshold;
> +	u64 cnt_threshold;
...
> +		octeon_write_csr64(
> +		    oct, CN23XX_SLI_OQ_PKT_INT_LEVELS(oq_no),
> +		    ((u64)(time_threshold << 32 | cnt_threshold)));
No need for the cast.

> +	if (!droq) {
> +		dev_err(&oct->pci_dev->dev, "23XX bringup FIXME: oct
> pfnum:%d ioq_vector->ioq_num :%d droq is NULL\n",
> +			oct->pf_num, ioq_vector->ioq_num);
> +		return 0;
> +	}

> +	if (oct->msix_on !=3D 1) {
> +		if (intr64 & CN23XX_INTR_PKT_DATA)
> +			oct->int_status |=3D OCT_DEV_INTR_PKT_DATA;
> +	}
What's the significance of 1? Is it actually a Boolean?
=20
> +static int msix_enable =3D 1;
What's the purpose of this static variable? Is there any way to change it?

> +	if (OCTEON_CN23XX_PF(oct) && msix_enable) {
> +		if (!oct->msix_entries) {
> +			/* dev_err(&oct->pci_dev->dev,
> +			* "Memory Alloc failed...\n");
> +			 * This is commenting due WARNING: Possible
> unnecessary
> +			 * out of memory' message
> +			 */
> +			return 1;
> +		}
Don't submit commented prints.

> +		irqret =3D request_irq(msix_entries[num_ioq_vectors].vector,
> +				     liquidio_legacy_intr_handler, 0, "octeon",
> +				     oct);
> +		if (irqret) {
> +			dev_err(&oct->pci_dev->dev,
> +				"OCTEON: Request_irq failed for MSIX interrupt
> Error: %d\n",
> +				irqret);
> +			kfree(oct->msix_entries);
> +			return 1;
Shouldn't you also call pci_disable_msix() on error flow?

> +		}
> +		for (i =3D 0; i < num_ioq_vectors; i++) {
> +			irqret =3D request_irq(msix_entries[i].vector,
> +					     liquidio_msix_intr_handler, 0,
> +					     "octeon", &oct->ioq_vector[i]);
> +			if (irqret) {
> +				dev_err(&oct->pci_dev->dev,
> +					"OCTEON: Request_irq failed for MSIX
...
> +				kfree(oct->msix_entries);
> +				return 1;
Likewise
