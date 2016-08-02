From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Tue, 2 Aug 2016 12:59:09 -0500
Message-ID: <57A0DF6D.6040207@codeaurora.org>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <577999EC.1010104@gmx.de> <579A5929.4010908@codeaurora.org>
 <d41488bf-ef79-ab11-f5fd-5ab15195c932@gmx.de>
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
Received: from smtp.codeaurora.org ([198.145.29.96]:37482 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756257AbcHBSIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 14:08:47 -0400
In-Reply-To: <d41488bf-ef79-ab11-f5fd-5ab15195c932@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lino Sanfilippo wrote:

> By looking closer to the code, the lock seems to serve the protection of a list of skbs that
> are queued to be timestamped. However there is nothing that ever enqueues those skbs, is it?
> I assume that this is a leftover of a previous version of that driver. Code to be merged into
> mailine has to be completely cleaned up and must not contains any functions which are never
> called. So either you implement the timestamping feature completely or you remove the concerning
> code altogether for the initial mainline driver version. You can add that feature any time later.

I will remove it.  It's not enabled by default on my platform anyway.  I 
didn't realize it wasn't properly implemented.

>> So you're saying that if NETIF_F_RXCSUM is not set, then
>> napi_gro_receive() should not be called?
>
> This requirement seems indeed to be obsolete now so you can ignore my former complaint and
> leave it as it is.

Ok.

> No, how should it? There still is nothing that wakes up the queue once it is stopped. Stopping and
> restarting/waking up a queue is up to the driver, since the network stack cant know if the hw is
> ready to queue another transmission or not. Usually the queue is stopped in the xmit function
> as soon as there are not enough descs left. Stopping the queue tells the network stack not to
> call the xmit function any more. When there are enough descs available again the driver
> has to wake up the queue. This is normally done in the tx completion handler (emac_mac_tx_process()
> in your case) as soon as enough free list elements are available again. Take a look at other
> drivers and when they call netif_wake_queue (or one of its variants).

Something must have gotten deleted by accident.  The internal version of 
the driver has this:

if (netif_queue_stopped(adpt->netdev) &&
     netif_carrier_ok(adpt->netdev) &&
     (emac_get_num_free_tpdescs(txque) >= (txque->tpd.count / 8)))
	netif_wake_queue(adpt->netdev);

My version replaces this with:

	netdev_completed_queue(adpt->netdev, pkts_compl, bytes_compl);

I don't know why this change was made.  However, if I comment out this 
line, the transmit queue times out, so obviously it's necessary.

I notice that *some* drivers, follow that with some variant of:

	if (netif_queue_stopped(bgmac->net_dev))
		netif_wake_queue(bgmac->net_dev);

Is there a good way to test my code? ping and iperf appear to send no 
more than 3 packets at a time, which comes nowhere close to filling the 
queue (which holds 512 normally).  netif_queue_stopped() never returns 
true, no matter what I do.

>> Should I just move the "netdev->mtu = new_mtu" line outside of the
>> if-statement?
>
> You can do that, but take care to ajdust dpt->rxbuf_size to the correct
> value as soon as the interface is brought up. (The same applies to the
> initialization of the mac with the new mtu value of course).

Is there any reason this doesn't work:

	netdev->mtu = new_mtu;
	adpt->rxbuf_size = new_mtu > EMAC_DEF_RX_BUF_SIZE ?
		ALIGN(max_frame, 8) : EMAC_DEF_RX_BUF_SIZE;

	if (netif_running(netdev))
		return emac_reinit_locked(adpt);

I set rxbuf_size regardless.  If the interface is up, it will 
reinitialize and load the new value.  If the interface is down, 
rxbuf_size will be ignored until emac_mac_up() is called.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
