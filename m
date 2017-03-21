From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: [PATCH net-next] stmmac: call stmmac_init_phy from
 stmmac_dvr_probe
Date: Tue, 21 Mar 2017 10:04:20 +0100
Message-ID: <fb001e95-5660-4d08-73f0-14ab1c52d648@axis.com>
References: <20170320172915.8313-1-niklass@axis.com>
 <257f3b05-805d-fd59-5435-89ede6b0fe4b@gmail.com>
 <82fbc595-5269-bcd9-d75f-778fbd8d2bdb@axis.com>
 <285d0fe6-9257-5e44-1272-be22dc271094@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>, <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <285d0fe6-9257-5e44-1272-be22dc271094@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/20/2017 11:07 PM, Florian Fainelli wrote:
>
> (snip)
>>
>> However, it is kind of sad that drivers are so inconsistent of what goes
>> in probe and what goes in ndo_open...which is tied together with the
>> whole mess of when certain ethtool commands work or do not work.
> Well, inconsistent here is kind of big statement, what I meant to say is
> that your proposed change actually makes thing inconsistent.

What I mean is that it is about 50/50 if something e.g. phy_connect
is called from probe or from ndo_open.
This is what I think is inconsistent.

git grep -p -E "phy_connect\(|phy_connect_direct\(" drivers/net/ethernet/ | grep open | wc -l
12

git grep -p -E "phy_connect\(|phy_connect_direct\(" drivers/net/ethernet/ | grep probe | wc -l
27
even if we exclude *_mii_probe/*_mdio_probe which are done
git grep -p mii_probe drivers/net/ethernet/ | grep open | wc -l
6
git grep -p mdio_probe drivers/net/ethernet/ | grep open | wc -l
2

phy_connect done from probe:
27-6-2=19

phy_connect done from ndo_open:
12+6+2=20


>
>> Do you know of a good way to avoid the -EBUSY in stmmac_ethtool_get_link_ksettings,
>> but still keep phy_connect in ndo_open?
> Let me rephrase this: doing an ethtool operation on an interface that is
> not open is not a defined behavior which adheres to a contract with the
> kernel. ethtool operations on interfaces that are DOWN, may succeed if
> they do not involve a piece of hardware that needs to be active (e.g:
> the PHY) but there is no guarantee that a) the change is immediately
> applied, or b) that the results are consistent.
>
> The best thing to do IMHO is just silence the warning, return an error
> coed, and come back configuring the interface at a later time when it is
> guaranteed to be operational.

Thank you for your feedback. I agree with you,
silencing the warning would be the best way forward.
David, please ignore this patch.



However, since ethtool is a user interface, I think that it would
have been nice if it wasn't so driver specific regarding to if a
command works before the interface is open or not.

If the user does some ethtool operation that affects e.g. the PHY
before the interface is open, perhaps there is a way to save this
setting so it could be applied when the resource is available.

For the PHY case, net_device has a pointer to a phy_device,
register_netdev could create a dummy phy_device if
ndev->phy_device is NULL, that way changes could be saved
and applied when phy_connect replaces the dummy device
(or perhaps when phy_start() is called).
(If it isn't a dummy phy_device, changes could be applied immediately.)
This way it would not matter if phy_connect is done from probe
or from ndo_open.
