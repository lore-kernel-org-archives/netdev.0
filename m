From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Tue, 10 May 2016 21:24:55 -0500
Message-ID: <573297F7.9020500@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com> <571915F5.5070504@codeaurora.org>
 <571A7F3D.1070609@codeaurora.org> <571A8207.60704@gmail.com>
 <57326C44.8020906@codeaurora.org> <57326E08.40803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org,
	Rob Herring <robh+dt@kernel.org>, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57326E08.40803@gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
> The Ethernet MAC should be started in ndo_open() and stopped in
> ndo_close(), in between, there are link state changes, but you are not
> supposed to stop or start your Ethernet MAC and its DMA for instance
> during link change, if that is a HW requirement, your HW is pretty funky.

I think the problem is that the current driver seems to be too eager to 
start/stop the MAC.

Please take a look at emac_work_thread_link_check() at 
https://lkml.org/lkml/2016/4/13/670.  Every time the PHY link goes up, 
it does this:

if (phy->link_up) {
	if (netif_carrier_ok(netdev))
		goto link_task_done;

	pm_runtime_get_sync(netdev->dev.parent);
	netif_info(adpt, timer, adpt->netdev, "NIC Link is Up %s\n",
		   speed);

	emac_mac_start(adpt);
	netif_carrier_on(netdev);
	netif_wake_queue(netdev);


The call to emac_mac_start seems wrong to me here.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
