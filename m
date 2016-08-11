From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Thu, 11 Aug 2016 09:22:53 -0500
Message-ID: <57AC8A3D.3010208@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
 <57AA2001.2010904@codeaurora.org>
 <214dcbb7-0c3b-1e00-3e50-db513d77b10b@gmail.com>
 <57AA7ED0.9000707@codeaurora.org>
 <85b76eca-5473-6724-0c9d-7b6fa7677f50@gmail.com>
 <57AB589D.3010509@codeaurora.org>
 <0da01875-b55a-c0fd-bd5f-05bb41fbd7fc@gmail.com>
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
Received: from smtp.codeaurora.org ([198.145.29.96]:33517 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708AbcHKOW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 10:22:57 -0400
In-Reply-To: <0da01875-b55a-c0fd-bd5f-05bb41fbd7fc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
>>      netif_stop_queue(netdev);
>> >     napi_disable(&adpt->rx_q.napi);
>> >
>> >I cannot call just napi_disable() in emac_change_mtu(), because when I
>> >then call emac_mac_down(), the first thing it does is call
>> >netif_stop_queue(), and that's when I timeout/hang.
> Whatever emac_mac_down() does you can unroll it in the change_mtu
> callback anyway, so if this a problematic sequence you can work around it.

I'm having difficulty coming up with an actual sequence that works. This 
odd interaction between netif_stop_queue() and napi_disable() is giving 
me inconsistent results.

The hang occurs with this loop in napi_disable():

	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
		msleep(1);

This loop never exits.  Can you give me a clue as to what could be the 
reason?

>> >Unfortunately, I cannot even do this:
>> >
>> >     netif_stop_queue(netdev);
>> >     napi_disable(&adpt->rx_q.napi);
>> >     netif_stop_queue(netdev);
>> >     napi_disable(&adpt->rx_q.napi);
>> >
>> >Even though I've already called netif_stop_queue(), calling it again
>> >causes the timeout/hang.

> Buf if this is really what you copy/pasted here, why do this twice anyway?

Sorry, what I meant was that I was hoping that *both* emac_change_mtu() 
and emac_mac_down() could do

	netif_stop_queue(netdev);
	napi_disable(&adpt->rx_q.napi);

Which would have the effect of what I wrote above.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
