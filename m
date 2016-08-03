From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 3 Aug 2016 15:00:34 -0500
Message-ID: <57A24D62.5080207@codeaurora.org>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <577999EC.1010104@gmx.de> <579A5929.4010908@codeaurora.org>
 <d41488bf-ef79-ab11-f5fd-5ab15195c932@gmx.de>
 <57A0DF6D.6040207@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, shankerd@codeaurora.org,
	vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
	robh+dt@kernel.org, andrew@lunn.ch, bjorn.andersson@linaro.org,
	mlangsdo@redhat.com, jcm@redhat.com, agross@codeaurora.org,
	davem@davemloft.net, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:60557 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758214AbcHCUAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 16:00:39 -0400
In-Reply-To: <57A0DF6D.6040207@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timur Tabi wrote:
>
> Is there a good way to test my code? ping and iperf appear to send no
> more than 3 packets at a time, which comes nowhere close to filling the
> queue (which holds 512 normally).  netif_queue_stopped() never returns
> true, no matter what I do.

Never mind, I fixed this problem.  I had a race condition between

	/* update produce idx */
	prod_idx = (tx_q->tpd.produce_idx << tx_q->produce_shift) &
		    tx_q->produce_mask;
	emac_reg_update32(adpt->base + tx_q->produce_reg,
			  tx_q->produce_mask, prod_idx);

and the call to netif_stop_queue().  The emac_reg_update32() signalled 
to the hardware that data is available, and it immediately called the 
ISR, before I had a chance to call netif_stop_queue().  So now I call 
emac_reg_update32() after netif_stop_queue(), and everything works.

I'll post a v7 soon.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
