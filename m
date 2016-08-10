From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Wed, 10 Aug 2016 11:38:53 -0500
Message-ID: <57AB589D.3010509@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
 <57AA2001.2010904@codeaurora.org>
 <214dcbb7-0c3b-1e00-3e50-db513d77b10b@gmail.com>
 <57AA7ED0.9000707@codeaurora.org>
 <85b76eca-5473-6724-0c9d-7b6fa7677f50@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56030 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934826AbcHJTGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 15:06:18 -0400
In-Reply-To: <85b76eca-5473-6724-0c9d-7b6fa7677f50@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
>> >Is there an easy way for me to stop the RX path before I set rxbuf_size?
>> >  Some netif_xxx function I can call?
> napi_disable() should take care of that.

It appears that if I call netif_stop_queue() *afer* calling 
napi_disable(), I get a hang and/or TX timeout.  Since emac_mac_down() 
does this:

	netif_stop_queue(netdev);
	napi_disable(&adpt->rx_q.napi);

I cannot call just napi_disable() in emac_change_mtu(), because when I 
then call emac_mac_down(), the first thing it does is call 
netif_stop_queue(), and that's when I timeout/hang.

Unfortunately, I cannot even do this:

	netif_stop_queue(netdev);
	napi_disable(&adpt->rx_q.napi);
	netif_stop_queue(netdev);
	napi_disable(&adpt->rx_q.napi);

Even though I've already called netif_stop_queue(), calling it again 
causes the timeout/hang.

Is this expected?  I never understood why I needed to call 
netif_stop_queue() before napi_disable().  I do see some drivers do not 
call netif_stop_queue().  I even saw a driver that calls them in reverse 
order, so I don't understand why that sequence breaks for me but not him.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
