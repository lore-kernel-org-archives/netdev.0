From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH net-next] stmmac: call stmmac_init_phy from
 stmmac_dvr_probe
Date: Mon, 20 Mar 2017 19:34:07 +0100
Message-ID: <82fbc595-5269-bcd9-d75f-778fbd8d2bdb@axis.com>
References: <20170320172915.8313-1-niklass@axis.com>
 <257f3b05-805d-fd59-5435-89ede6b0fe4b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>, <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <257f3b05-805d-fd59-5435-89ede6b0fe4b@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/20/2017 06:43 PM, Florian Fainelli wrote:
> On 03/20/2017 10:29 AM, Niklas Cassel wrote:
>> From: Niklas Cassel <niklas.cassel@axis.com>
>>
>> It is usually possible to do
>> ethtool -s autoneg on
>> so that you trigger an autoneg before calling
>> ip link set dev eth0 up
> This is completely driver specific and there is no guarantee for this to
> work universally across all device drivers because when your interface
> is brought down, the most sensible thing to expect in return is that
> your PHY is powered down (unless your interface participates in
> Wake-on-LAN).
>
>> However, stmmac returns -EBUSY if !netif_running.
>> The only reason for this appears to be that stmmac_init_phy
>> is called from stmmac_open instead of from stmmac_dvr_probe.
>>
>> Move stmmac_init_phy to stmmac_dvr_probe so that ethool
>> works as soon as register_netdev has been called.
>> stmmac_check_ether_addr was also moved to probe,
>> so that the ordering doesn't change.
> Are you sure this is a good idea? There are many drivers that moved the
> PHY probe into ndo_open() for mainly two things:
>
> - phy_connect() starts the PHY state machine and starting the state
> machine without a network device running is kind of wasting cycles
>
> - if the interface is probed, but not used, you are keeping the Ethernet
> link running without being able to service packets, which is at best a
> waste of power

Hello Florian

Thank you for your input.
I can see the point in keeping phy_connect in ndo_open.

What I dislike is the -EBUSY from stmmac_ethtool_get_link_ksettings,
since this will create warnings in user space by our favorite monolith.
(Please don't flame me, I dislike it as much as you guys.)

[ WARNING ] systemd-udevd[236]: link_config: could not get ethtool features for eth0
[ WARNING ] systemd-udevd[236]: Could not set offload features of eth0: Device or resource busy


However, it is kind of sad that drivers are so inconsistent of what goes
in probe and what goes in ndo_open...which is tied together with the
whole mess of when certain ethtool commands work or do not work.

Do you know of a good way to avoid the -EBUSY in stmmac_ethtool_get_link_ksettings,
but still keep phy_connect in ndo_open?
The current code checks netif_running(), which checks __LINK_STATE_START,
which gets set by __dev_open().
stmmac_ethtool_get_link_ksettings also returns -ENODEV if ndev->phydev == NULL.
