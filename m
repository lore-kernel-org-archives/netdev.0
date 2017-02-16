From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v7 1/2] qed: Add infrastructure for PTP support
Date: Thu, 16 Feb 2017 04:41:59 -0800
Message-ID: <1487248919.1311.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1487147051-14350-1-git-send-email-Yuval.Mintz@cavium.com>
         <1487147051-14350-2-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        richardcochran@gmail.com, Sudarsana.Kalluru@cavium.com
To: Yuval Mintz <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33914 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754277AbdBPMmB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 07:42:01 -0500
Received: by mail-pg0-f65.google.com with SMTP id v184so1937852pgv.1
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 04:42:01 -0800 (PST)
In-Reply-To: <1487147051-14350-2-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-15 at 10:24 +0200, Yuval Mintz wrote:
> From: Sudarsana Reddy Kalluru <sudarsana.Kalluru@cavium.com>
> 
> The patch adds the required qed interfaces for configuring/reading
> the PTP clock on the adapter.


> +/* Read Phy Hardware Clock */
> +static int qed_ptp_hw_read_cc(struct qed_dev *cdev, u64 *phc_cycles)
> +{
> +	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
> +	struct qed_ptt *p_ptt = p_hwfn->p_ptp_ptt;
> +	u32 temp = 0;
> +
> +	temp = qed_rd(p_hwfn, p_ptt, NIG_REG_TSGEN_SYNC_TIME_LSB);
> +	*phc_cycles = qed_rd(p_hwfn, p_ptt, NIG_REG_TSGEN_SYNC_TIME_MSB);
> +	*phc_cycles <<= 32;
> +	*phc_cycles |= temp;
> +
> +	return 0;
> +}

LSB and MSB being read non atomically, it looks like you could have an
error of (1<<32) cycles here.

(You read LSB value close to 0xFFFFFFFF right before it changes to 0,
while MSB got incremented.)
