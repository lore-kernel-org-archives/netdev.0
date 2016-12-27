From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: stmmac: synchronize stmmac_open and stmmac_dvr_probe
Date: Mon, 26 Dec 2016 21:10:09 -0800
Message-ID: <461cd45a-70a5-1f08-816d-3c210d694083@gmail.com>
References: <1482839100-20612-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, pavel@ucw.cz,
        Ong Boon Leong <boon.leong.ong@intel.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, weifeng.voon@intel.com,
        Lars Persson <lars.persson@axis.com>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        seraphin.bonnaffe@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36680 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbcL0FKL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 00:10:11 -0500
In-Reply-To: <1482839100-20612-1-git-send-email-hock.leong.kweh@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/27/2016 03:44 AM, Kweh, Hock Leong wrote:
> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
> 
> If kernel module stmmac driver being loaded after OS booted, there is a
> race condition between stmmac_open() and stmmac_mdio_register(), which is
> invoked inside stmmac_dvr_probe(), and the error is showed in dmesg log as
> PHY not found and stmmac_open() failed:
> [  473.919358] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized):
> 		stmmac_dvr_probe: warning: cannot get CSR clock
> [  473.919382] stmmaceth 0000:01:00.0: no reset control found
> [  473.919412] stmmac - user ID: 0x10, Synopsys ID: 0x42
> [  473.919429] stmmaceth 0000:01:00.0: DMA HW capability register supported
> [  473.919436] stmmaceth 0000:01:00.0: RX Checksum Offload Engine supported
> [  473.919443] stmmaceth 0000:01:00.0: TX Checksum insertion supported
> [  473.919451] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized):
> 		Enable RX Mitigation via HW Watchdog Timer
> [  473.921395] libphy: PHY stmmac-1:00 not found
> [  473.921417] stmmaceth 0000:01:00.0 eth0: Could not attach to PHY
> [  473.921427] stmmaceth 0000:01:00.0 eth0: stmmac_open: Cannot attach to
> 		PHY (error: -19)
> [  473.959710] libphy: stmmac: probed
> [  473.959724] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 0 IRQ POLL
> 		(stmmac-1:00) active
> [  473.959728] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 1 IRQ POLL
> 		(stmmac-1:01)
> [  473.959731] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 2 IRQ POLL
> 		(stmmac-1:02)
> [  473.959734] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 3 IRQ POLL
> 		(stmmac-1:03)
> 
> The resolution used wait_for_completion_interruptible() to synchronize
> stmmac_open() and stmmac_dvr_probe() to prevent the race condition
> happening.

The proper fix for this would be to have register_netdev() be the last
thing done in stmmac_drv_probe(), whereas right now, the last thing done
is stmmac_mdio_register(), leading the window you are seeing here, where
the network interface can be open prior to all resources being set up,
including, but not limited to MDIO devices.
-- 
Florian
