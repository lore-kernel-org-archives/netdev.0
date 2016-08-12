From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V2 08/18] liquidio: CN23XX queue manipulation
Date: Fri, 12 Aug 2016 12:30:22 -0700
Message-ID: <1471030222.18251.13.camel@perches.com>
References: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
	 <1471026035-15323-9-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0107.hostedemail.com ([216.40.44.107]:58629 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751031AbcHLTa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 15:30:29 -0400
In-Reply-To: <1471026035-15323-9-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-08-12 at 11:20 -0700, Raghu Vatsavayi wrote:
> This patch adds support for cn23xx queue manipulation.

trivia:

> diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
[]
> @@ -315,6 +315,52 @@ static void cn23xx_setup_global_mac_regs(struct octeon_device *oct)
>  		(oct, CN23XX_SLI_PKT_MAC_RINFO64(mac_no, pf_num)));
>  }
>  
> +static int cn23xx_reset_io_queues(struct octeon_device *oct)
> +{
> +	int ret_val = 0;
> +	u64 d64 = 0ULL, q_no = 0ULL, srn = 0ULL, ern = 0ULL;

none of these initializations are necessary.

> +
> +	srn = oct->sriov_info.pf_srn;
> +	ern = srn + oct->sriov_info.num_pf_rings;
> +
> +	/*As per HRM reg description, s/w cant write 0 to ENB. */
> +	/*to make the queue off, need to set the RST bit. */
> +
> +	/* Reset the Enable bit for all the 64 IQs.  */
> +	for (q_no = srn; q_no < ern; q_no++) {
> +		/* set RST bit to 1. This bit applies to both IQ and OQ */
> +		d64 = octeon_read_csr64(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no));
> +		d64 = d64 | CN23XX_PKT_INPUT_CTL_RST;
> +		octeon_write_csr64(oct, CN23XX_SLI_IQ_PKT_CONTROL64(q_no), d64);
> +	}

[]

> +static void cn23xx_enable_io_queues(struct octeon_device *oct)
> +{
> +	u64 q_no = 0, reg_val = 0ULL;
> +	s32 srn = 0, ern = 0;

Mixing s32 and u64 types for srn and ern seems odd
and likely wrong.

> +
> +	srn = oct->sriov_info.pf_srn;
> +	ern = srn + oct->num_iqs;
