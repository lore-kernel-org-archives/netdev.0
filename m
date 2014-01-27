From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH 1/3] net: ethoc: don't advertise gigabit speed on attached
 PHY
Date: Mon, 27 Jan 2014 20:17:16 +0400
Message-ID: <52E6868C.3070401@gmail.com>
References: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com> <1390795167-6677-2-git-send-email-jcmvbkbc@gmail.com> <1390817904.2735.127.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Chris Zankel <chris@zankel.net>,
	Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390817904.2735.127.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ben,

On Mon, Jan 27, 2014 at 2:18 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Mon, 2014-01-27 at 07:59 +0400, Max Filippov wrote:
>> OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps, but does
>> not disable advertisement when PHY supports them. This results in
>> non-functioning network when the MAC is connected to a gigabit PHY connected
>> to a gigabit switch.
>>
>> The fix is to disable gigabit speed advertisement on attached PHY
>> unconditionally.
>>
>> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
>> ---
>>  drivers/net/ethernet/ethoc.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
>> index 4de8cfd..0aa1a05 100644
>> --- a/drivers/net/ethernet/ethoc.c
>> +++ b/drivers/net/ethernet/ethoc.c
>> @@ -712,6 +712,8 @@ static int ethoc_open(struct net_device *dev)
>>               netif_start_queue(dev);
>>       }
>>
>> +     priv->phy->advertising &= ~(ADVERTISED_1000baseT_Full |
>> +                                 ADVERTISED_1000baseT_Half);
>>       phy_start(priv->phy);
>>       napi_enable(&priv->napi);
>>
>
> This is not sufficient to disable gigabit speeds; the supported mask
> should also be limited.  And it should be done even before the net

I tried that, but when I also limit supported mask the phy driver doesn't
touch gigabit advertising register int the genphy_config_advert at all.
That's probably right for ethtool interface, but ethoc doesn't support
ethtool.

> device is registered.
>
> Rather than poking into the phy_device structure directly from this
> driver, I think you should add a function in phylib for this purpose.

Like below?

---8<---
>From 347331f399626ecaa9a8e54252f55e0b6788772f Mon Sep 17 00:00:00 2001
From: Max Filippov <jcmvbkbc@gmail.com>
Date: Mon, 27 Jan 2014 04:01:40 +0400
Subject: [PATCH 1/3] net: ethoc: don't advertise gigabit speed on attached PHY

OpenCores 10/100 Mbps MAC does not support speeds above 100 Mbps, but does
not disable advertisement when PHY supports them. This results in
non-functioning network when the MAC is connected to a gigabit PHY connected
to a gigabit switch.

The fix is to disable gigabit speed advertisement on attached PHY
unconditionally.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 3 +++
 include/linux/phy.h          | 5 +++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 4de8cfd..e817d58 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -688,6 +688,9 @@ static int ethoc_mdio_probe(struct net_device *dev)
 	}

 	priv->phy = phy;
+	phy_update_adv(phy,
+		       ~(ADVERTISED_1000baseT_Full |
+			 ADVERTISED_1000baseT_Half), 0);
 	return 0;
 }

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 48a4dc3..0282a8d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -559,6 +559,11 @@ static inline int phy_read_status(struct phy_device *phydev) {
 	return phydev->drv->read_status(phydev);
 }

+static inline void phy_update_adv(struct phy_device *phydev, u32 mask, u32 set)
+{
+	phydev->advertising = (phydev->advertising & mask) | set;
+}
+
 int genphy_setup_forced(struct phy_device *phydev);
 int genphy_restart_aneg(struct phy_device *phydev);
 int genphy_config_aneg(struct phy_device *phydev);
-- 
1.8.1.4


-- 
Thanks.
-- Max
