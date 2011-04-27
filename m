From: David Decotigny <decot@google.com>
Subject: [PATCHv2 0/4] ethtool: generalize use of ethtool_cmd_speed API
Date: Wed, 27 Apr 2011 11:34:45 -0700
Message-ID: <1303929290-21037-1-git-send-email-decot__12072.3843960606$1303929373$gmane$org@google.com>
References: <1303001651-4074-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	mirq-linux@rere.qmqm.pl, Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyc
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:61045 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759096Ab1D0SfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 14:35:18 -0400
In-Reply-To: <1303001651-4074-1-git-send-email-decot@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This is the second version of a patch series aimed at making sure the
speed field of struct ethtool_cmd is accessed as a 32b integer
throughout the kernel.

Thanks to Ben for his careful review!
Below are a few comments before sending the series.

On 04/16/11 19:06, Ben Hutchings wrote:
> Don't encourage use of the SPEED_* macros.  The speed is just a value in
> units of Mbit/s.

Updated. Thanks!

>> This makes sure that when a driver calls the ethtool's
>> get/set_settings() callback of another driver,
> 
> Many of them are calling themselves, and they can ignore speed_hi
> because they will never set it.

Right. Here is what I replied to Ben in private: I think it makes
sense to have a uniform & consistent use of the API without exception
nor assumption, even though it borrows additional useless CPU cycles
(+ cache lines probably). This comes down to trade-off between code
management and performance, for which I privileged the former because
I don't think the ethtool api is supposed to be heavily used
throughout normal kernel operation.

I left the initial changes in place.

>> the data passed to it
>> is clean. This guarantees that speed_hi will be zeroed correctly if
>> the called callback doesn't explicitely set it: we are sure we don't
>> get a corrupted speed from the underlying driver. We also take care of
>> setting the cmd field appropriately (ETHTOOL_GSET/SSET).
> 
> I think this initialisation ought to be done in
> dev_ethtool_get_settings(), and that function moved into net/core/dev.c,
> to avoid code bloat.  (Yes it's minimal in this case, but these things
> add up.)

Done. This is in the 2nd patch of the series. Any feedback welcome, I
am not entirely convinced that my additions are pertinent.

> Maybe also in mii_ethtool_gset().

I don't think this is equivalent to dev_ethtool_get_settings(). My
understanding is that mii_ethtool_gset() (and likewise for mdio45_) is
meant to be wrapped almost transparently inside a driver's
get_settings(), so it should make the same assumptions as a normal
get_settings(). However, dev_ethtool_get_settings() is meant to be
used to _call_ some driver's get_settings(), so it should make sure
that it enforces the assumptions this driver is making.

In the end, I didn't change mii_ethtool_gset() the same way I did for
dev_ethtool_get_settings (no memset).

>> --- a/arch/mips/txx9/generic/setup_tx4939.c
>> +++ b/arch/mips/txx9/generic/setup_tx4939.c
[...]
> If you're going to rewrite the whole function then at least get rid of
> this stupid conditional and return ethtool_cmd_speed(&cmd).

Updated. Thanks!

[...]
> e100 is just getting its own settings and doesn't need to be changed.

Right. I still did change it for the sake of consistency (see remark
above).

[...]
>> diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
>> @@ -2763,11 +2763,12 @@ static void pcnet32_check_media(struct net_device *dev, int verbose)
>>  		netif_carrier_on(dev);
>>  		if (lp->mii) {
>>  			if (netif_msg_link(lp)) {
>> -				struct ethtool_cmd ecmd;
>> +				struct ethtool_cmd ecmd = {
>> +					.cmd = ETHTOOL_GSET };
>>  				mii_ethtool_gset(&lp->mii_if, &ecmd);
>>  				netdev_info(dev, "link up, %sMbps, %s-duplex\n",
>> -					    (ecmd.speed == SPEED_100)
>> -					    ? "100" : "10",
>> +					    (ethtool_cmd_speed(&ecmd)
>> +					     == SPEED_100) ? "100" : "10",
> 
> Just use ethtool_cmd_speed() and %u rather than this conditional.

Updated. Thanks!

[...]
>> diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
>> index 0e61ac8..33cf0b1 100644
>> --- a/drivers/net/stmmac/stmmac_ethtool.c
>> +++ b/drivers/net/stmmac/stmmac_ethtool.c
>> @@ -237,13 +237,13 @@ stmmac_set_pauseparam(struct net_device *netdev,
>>  
>>  	if (phy->autoneg) {
>>  		if (netif_running(netdev)) {
>> -			struct ethtool_cmd cmd;
>> +			struct ethtool_cmd cmd = { .cmd = ETHTOOL_SSET };
>>  			/* auto-negotiation automatically restarted */
>>  			cmd.cmd = ETHTOOL_NWAY_RST;
> 
> This line immediately changes cmd.cmd.  The original author is clearly
> confused, as the phy_ethtool_sset() ignores cmd.cmd and ETHTOOL_NWAY_RST
> does not take any parameters.

True. I made this a bit more elegant.

> I think this whole block should really just be:
> 
> 			ret = phy_start_aneg(phy);

Right, but I prefer not to do this in this series.

> [...]
>> diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
>> index e2e6475..6df9540 100644
>> --- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
>> +++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
>> @@ -664,22 +664,28 @@ static void bnx2fc_link_speed_update(struct fc_lport *lport)
[...]
> This restructuring looks entirely unnecessary, and obscures the real
> change being made.

That's definitely true. Made my changes more transparent. Thanks!

>> diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
>> index bde6ee5..ba9e84a 100644
>> --- a/drivers/scsi/fcoe/fcoe.c
>> +++ b/drivers/scsi/fcoe/fcoe.c
>> @@ -2026,25 +2026,30 @@ out_nodev:
>>  int fcoe_link_speed_update(struct fc_lport *lport)
>>  {
> [...]
> 
> Ditto here.

Same here.

On 04/16/11 19:02, Ben Hutchings wrote:
> On Sat, 2011-04-16 at 17:54 -0700, David Decotigny wrote:
>> This makes sure the ethtool's set_settings() callback of network
>> drivers don't ignore the 16 most significant bits when ethtool calls
>> their set_settings().
>>
>> All the driver compiled with make allyesconfig on x86_64 have been
>> updated.
> 
> You missed one generic function, mdio45_ethtool_gset_npage() in
> drivers/net/mdio.c.

I am not sure about this one. But I think it falls in the same
category as mii_ethtool_gset() above.

> 
> [...]
>> diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
>> index c05db60..ba6c151 100644
>> --- a/drivers/net/dl2k.c
>> +++ b/drivers/net/dl2k.c
>> @@ -1219,11 +1219,11 @@ static int rio_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>>  	} else {
>>  		np->an_enable = 0;
>>  		if (np->speed == 1000) {
>> -			cmd->speed = SPEED_100;
>> +			ethtool_cmd_speed_set(cmd, SPEED_100);
>>  			cmd->duplex = DUPLEX_FULL;
>>  			printk("Warning!! Can't disable Auto negotiation in 1000Mbps, change to Manual 100Mbps, Full duplex.\n");
>>  		}
>> -		switch(cmd->speed + cmd->duplex) {
>> +		switch (ethtool_cmd_speed(cmd) + cmd->duplex) {
> [...]
> 
> If you're going to stop these drivers ignoring speed_hi, maybe you
> should also stop them ignoring the difference between speed and duplex!
> Currently the user can ask for 99 Mbit/s full-duplex and get 100 Mbit/s
> half-duplex.

Yes, that is completely right. Updated. Thanks!

> 
> There are several others that use this trick.

Yes, I noticed too (e1000(e)) but I think it would deserve another
set of patches.

David Decotigny (4):
  ethtool: cosmetics: enforce const-ness in ethtool_cmd_speed
  ethtool: Call ethtool's get/set_settings callbacks with cleaned data
  ethtool: Use the full 32 bit speed range in ethtool's set_settings
  ethtool: cosmetic: Use ethtool ethtool_cmd_speed API

 arch/mips/txx9/generic/setup_tx4939.c   |   21 ++++++-----------
 drivers/infiniband/hw/nes/nes_nic.c     |    4 +-
 drivers/net/3c509.c                     |    2 +-
 drivers/net/acenic.c                    |   10 ++++----
 drivers/net/arm/etherh.c                |    5 ++-
 drivers/net/arm/ks8695net.c             |    7 +++--
 drivers/net/atl1c/atl1c_ethtool.c       |    9 ++++---
 drivers/net/atl1e/atl1e_ethtool.c       |    4 +-
 drivers/net/atlx/atl1.c                 |    9 ++++---
 drivers/net/atlx/atl2.c                 |    4 +-
 drivers/net/b44.c                       |   13 ++++++-----
 drivers/net/bcm63xx_enet.c              |    3 +-
 drivers/net/benet/be_ethtool.c          |   16 ++++++------
 drivers/net/bna/bnad_ethtool.c          |    7 +++--
 drivers/net/bnx2.c                      |   19 +++++++--------
 drivers/net/cassini.c                   |   37 ++++++++++++++++---------------
 drivers/net/chelsio/cxgb2.c             |   11 +++++----
 drivers/net/cxgb3/cxgb3_main.c          |   14 ++++++-----
 drivers/net/cxgb4/cxgb4_main.c          |   14 ++++++-----
 drivers/net/cxgb4vf/cxgb4vf_main.c      |    3 +-
 drivers/net/dl2k.c                      |   29 ++++++++++--------------
 drivers/net/e100.c                      |   10 +++++---
 drivers/net/e1000/e1000_ethtool.c       |   10 +++++---
 drivers/net/e1000e/ethtool.c            |   15 +++++++-----
 drivers/net/eepro.c                     |    2 +-
 drivers/net/ehea/ehea_ethtool.c         |   23 +++++++++++++++----
 drivers/net/enc28j60.c                  |    5 ++-
 drivers/net/enic/enic_main.c            |    4 +-
 drivers/net/ewrk3.c                     |    2 +-
 drivers/net/forcedeth.c                 |   25 ++++++++++++--------
 drivers/net/ibmveth.c                   |    2 +-
 drivers/net/igb/igb_ethtool.c           |   11 +++++----
 drivers/net/igbvf/ethtool.c             |    8 +++---
 drivers/net/ixgb/ixgb_ethtool.c         |    7 +++--
 drivers/net/ixgbe/ixgbe_ethtool.c       |   11 +++++----
 drivers/net/ixgbevf/ethtool.c           |    8 ++++--
 drivers/net/jme.c                       |    3 +-
 drivers/net/ksz884x.c                   |    9 ++++---
 drivers/net/mdio.c                      |   22 +++++++++++------
 drivers/net/mii.c                       |   31 ++++++++++++++++----------
 drivers/net/mlx4/en_ethtool.c           |    7 +++--
 drivers/net/mv643xx_eth.c               |    6 ++--
 drivers/net/myri10ge/myri10ge.c         |    2 +-
 drivers/net/natsemi.c                   |   11 +++++----
 drivers/net/netxen/netxen_nic_ethtool.c |   15 ++++++------
 drivers/net/niu.c                       |    4 +-
 drivers/net/ns83820.c                   |    8 +++---
 drivers/net/pch_gbe/pch_gbe_ethtool.c   |    9 ++++---
 drivers/net/pch_gbe/pch_gbe_main.c      |    6 ++--
 drivers/net/pch_gbe/pch_gbe_phy.c       |    4 +-
 drivers/net/pcmcia/smc91c92_cs.c        |    6 ++--
 drivers/net/pcnet32.c                   |   16 ++++++------
 drivers/net/phy/phy.c                   |   12 ++++++----
 drivers/net/ps3_gelic_net.c             |    8 +++---
 drivers/net/qla3xxx.c                   |    2 +-
 drivers/net/qlcnic/qlcnic_ethtool.c     |   12 +++++-----
 drivers/net/qlge/qlge_ethtool.c         |    2 +-
 drivers/net/r8169.c                     |    5 ++-
 drivers/net/s2io.c                      |    6 ++--
 drivers/net/sc92031.c                   |    8 ++++--
 drivers/net/sfc/ethtool.c               |    5 ++-
 drivers/net/sfc/mcdi_phy.c              |    6 ++--
 drivers/net/sfc/mdio_10g.c              |    4 +-
 drivers/net/sfc/tenxpress.c             |    2 +-
 drivers/net/skge.c                      |    6 ++--
 drivers/net/sky2.c                      |    8 +++---
 drivers/net/smc911x.c                   |    4 +-
 drivers/net/smc91x.c                    |    4 +-
 drivers/net/spider_net_ethtool.c        |    2 +-
 drivers/net/stmmac/stmmac_ethtool.c     |    5 +--
 drivers/net/sungem.c                    |   15 ++++++------
 drivers/net/sunhme.c                    |   19 +++++++--------
 drivers/net/tehuti.c                    |    2 +-
 drivers/net/tg3.c                       |   13 ++++++-----
 drivers/net/tulip/de2104x.c             |   11 +++++----
 drivers/net/tulip/uli526x.c             |    6 ++--
 drivers/net/tun.c                       |    2 +-
 drivers/net/typhoon.c                   |   19 ++++++++-------
 drivers/net/usb/asix.c                  |   28 ++++++++++++-----------
 drivers/net/usb/catc.c                  |    2 +-
 drivers/net/usb/dm9601.c                |    6 ++--
 drivers/net/usb/rtl8150.c               |   11 +++++----
 drivers/net/usb/smsc75xx.c              |    7 +++--
 drivers/net/usb/smsc95xx.c              |    7 +++--
 drivers/net/veth.c                      |    2 +-
 drivers/net/via-velocity.c              |   21 +++++++++++------
 drivers/net/vmxnet3/vmxnet3_ethtool.c   |    4 +-
 drivers/net/vxge/vxge-ethtool.c         |    7 +++--
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c       |   11 ++++++---
 drivers/scsi/fcoe/fcoe.c                |   11 ++++++---
 include/linux/ethtool.h                 |   18 +++++++++++----
 include/linux/netdevice.h               |    9 +------
 include/rdma/ib_addr.h                  |   13 ++++++-----
 net/batman-adv/soft-interface.c         |    2 +-
 net/bridge/br_if.c                      |    4 +-
 net/core/dev.c                          |   24 ++++++++++++++++++++
 net/core/net-sysfs.c                    |   24 ++++++++-----------
 97 files changed, 522 insertions(+), 420 deletions(-)

-- 
1.7.3.1
