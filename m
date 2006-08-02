From: a1 <a1k@mail.ru>
Subject: Re: e1000 speed/duplex error
Date: Wed, 2 Aug 2006 12:39:08 +0400
Message-ID: <1556642230.20060802123908@mail.ru>
References: <1301563340.20060801141827@mail.ru> <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com> <793732866.20060801153230@mail.ru> <9929d2390608010445w4fd81b64g310ae90a423e1a7d@mail.gmail.com> <911206621.20060801162006@mail.ru> <9929d2390608010534x54324569ja70b1fcbdc23c097@mail.gmail.com> <44CF66AD.1030901@intel.com> <168330902.20060802113402@mail.ru> <9929d2390608020043y75b487c4ge5a02e7a6c96cb9b@mail.gmail.com>
Reply-To: a1 <a1k@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx6.mail.ru ([194.67.23.26]:31254 "EHLO mx6.mail.ru")
	by vger.kernel.org with ESMTP id S1751359AbWHBIio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 04:38:44 -0400
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <9929d2390608020043y75b487c4ge5a02e7a6c96cb9b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Jeff.

JK> On 8/2/06, a1 <a1k@mail.ru> wrote:
>> Hi, Auke.
>>
>> Auke Kok wrote:
>> AK> Here's that part of the driver documentation:
>>
>> AK> $ modprobe e1000 AutoNeg=0x08
>> AK> e1000: 0000:00:00.0: e1000_validate_option: AutoNeg advertising 100/FD
>>
>>
>> AK>   99 /* Auto-negotiation Advertisement Override
>> AK> 100  *
>> AK> 101  * Valid Range: 0x01-0x0F, 0x20-0x2F (copper); 0x20 (fiber)
>> AK> 102  *
>> AK> 103  * The AutoNeg value is a bit mask describing which speed and duplex
>> AK> 104  * combinations should be advertised during auto-negotiation.
>> AK> 105  * The supported speed and duplex modes are listed below
>> AK> 106  *
>> AK> 107  * Bit           7     6     5      4      3     2     1      0
>> AK> 108  * Speed (Mbps)  N/A   N/A   1000   N/A    100   100   10     10
>> AK> 109  * Duplex                    Full          Full  Half  Full   Half
>> AK> 110  *
>> AK> 111  * Default Value: 0x2F (copper); 0x20 (fiber)
>> AK> 112  */
>>
>> This is not what I'm thinking of. Say, for example, I have a bunch of
>> e1000 adapters in my box and want to dynamically change one's spd/dplx.
>> For that works in the way you described I need to stop all of them and
>> load with autoneg parameter (can I pass this parameter only to single
>> card?) and loose all connection I had on other adapters.
>> It would be better to handle it in ethtool way, since I discovered
>> it's a common behavior.
>> Thanks.
>>
>>
>> AK> hth,
>>
>> AK> Auke
>>
>>
>> --
>> Best Regards,
>>  Alexandr Kotov                       mailto:a1k@mail.ru
>>
>> -
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>

JK> I agree.  Although ethtool does not have that functionality as of yet.
JK>  Feel free to provide a patch to the ethtool maintainer (Jeff Garzik)
JK> if you would like.  I will put it on my plate of things to do, but I
JK> will admit that it is near the bottom of the list of items to get done
JK> for me.  Feel free to ping me once in awhile to remind me.

Ethtool already have support for that, but e1000 driver doesn't treat
all values passed from ethtool correctly.

For example, if I run ethtool with the following parameters:
ethtool -s eth0 speed 100 duplex full autoneg on

parameters filled by ethtool looks like:

ecmd->autoneg = AUTONEG_ENABLE;
ecmd->advertising = ADVERTISED_100baseT_Full;

but then they passed to the driver, driver fills the structure passed
to the hw layer with all possible advertise values.

static int
e1000_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
{
        struct e1000_adapter *adapter = netdev_priv(netdev);
        struct e1000_hw *hw = &adapter->hw;

        /* When SoL/IDER sessions are active, autoneg/speed/duplex
         * cannot be changed */
        if (e1000_check_phy_reset_block(hw)) {
                DPRINTK(DRV, ERR, "Cannot change link characteristics "
                        "when SoL/IDER is active.\n");
                return -EINVAL;
        }

        if (ecmd->autoneg == AUTONEG_ENABLE) {
                hw->autoneg = 1;
                if (hw->media_type == e1000_media_type_fiber)
                        hw->autoneg_advertised = ADVERTISED_1000baseT_Full |
                                     ADVERTISED_FIBRE |
                                     ADVERTISED_Autoneg;
                else
--->                    hw->autoneg_advertised = ADVERTISED_10baseT_Half |
                                                  ADVERTISED_10baseT_Full |
                                                  ADVERTISED_100baseT_Half |
                                                  ADVERTISED_100baseT_Full |
                                                  ADVERTISED_1000baseT_Full|
                                                  ADVERTISED_Autoneg |
                                                  ADVERTISED_TP;
                ecmd->advertising = hw->autoneg_advertised;
        } else
                if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex))
                        return -EINVAL;

        /* reset the link */

        if (netif_running(adapter->netdev))
                e1000_reinit_locked(adapter);
        else
                e1000_reset(adapter);

        return 0;
}

If you change it that way everything works like I thought

--- e1000_ethtool.c.orig        Mon Jun 26 14:13:26 2006
+++ e1000_ethtool.c     Wed Aug 02 12:35:36 2006
@@ -225,13 +225,7 @@
                                     ADVERTISED_FIBRE |
                                     ADVERTISED_Autoneg;
                else
-                       hw->autoneg_advertised = ADVERTISED_10baseT_Half |
-                                                 ADVERTISED_10baseT_Full |
-                                                 ADVERTISED_100baseT_Half |
-                                                 ADVERTISED_100baseT_Full |
-                                                 ADVERTISED_1000baseT_Full|
-                                                 ADVERTISED_Autoneg |
-                                                 ADVERTISED_TP;
+                       hw->autoneg_advertised = ecmd->advertising;
                ecmd->advertising = hw->autoneg_advertised;
        } else
                if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex))


-- 
Best regards,
 Alexandr Kotov                          mailto:a1k@mail.ru

