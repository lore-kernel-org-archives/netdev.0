From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] stmmac: call stmmac_init_phy from
 stmmac_dvr_probe
Date: Mon, 20 Mar 2017 10:43:48 -0700
Message-ID: <257f3b05-805d-fd59-5435-89ede6b0fe4b@gmail.com>
References: <20170320172915.8313-1-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Niklas Cassel <niklass@axis.com>
To: Niklas Cassel <niklas.cassel@axis.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, Joao.Pinto@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320172915.8313-1-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/20/2017 10:29 AM, Niklas Cassel wrote:
> From: Niklas Cassel <niklas.cassel@axis.com>
> 
> It is usually possible to do
> ethtool -s autoneg on
> so that you trigger an autoneg before calling
> ip link set dev eth0 up

This is completely driver specific and there is no guarantee for this to
work universally across all device drivers because when your interface
is brought down, the most sensible thing to expect in return is that
your PHY is powered down (unless your interface participates in
Wake-on-LAN).

> 
> However, stmmac returns -EBUSY if !netif_running.
> The only reason for this appears to be that stmmac_init_phy
> is called from stmmac_open instead of from stmmac_dvr_probe.
> 
> Move stmmac_init_phy to stmmac_dvr_probe so that ethool
> works as soon as register_netdev has been called.
> stmmac_check_ether_addr was also moved to probe,
> so that the ordering doesn't change.

Are you sure this is a good idea? There are many drivers that moved the
PHY probe into ndo_open() for mainly two things:

- phy_connect() starts the PHY state machine and starting the state
machine without a network device running is kind of wasting cycles

- if the interface is probed, but not used, you are keeping the Ethernet
link running without being able to service packets, which is at best a
waste of power
--
Florian
