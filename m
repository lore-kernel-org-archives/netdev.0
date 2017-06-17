From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Sat, 17 Jun 2017 11:54:00 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2CD1@FRAEML521-MBS.china.huawei.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-8-salil.mehta@huawei.com>
 <20170614023228.GA16215@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614023228.GA16215@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, June 14, 2017 3:32 AM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next 7/8] net: hns3: Add Ethtool support to
> HNS3 driver
> 
> > +static const struct hns3_link_mode_mapping hns3_lm_map[] = {
> > +	{HNS3_LM_FIBRE_BIT, ETHTOOL_LINK_MODE_FIBRE_BIT},
> > +	{HNS3_LM_AUTONEG_BIT, ETHTOOL_LINK_MODE_Autoneg_BIT},
> > +	{HNS3_LM_TP_BIT, ETHTOOL_LINK_MODE_TP_BIT},
> > +	{HNS3_LM_PAUSE_BIT, ETHTOOL_LINK_MODE_Pause_BIT},
> > +	{HNS3_LM_BACKPLANE_BIT, ETHTOOL_LINK_MODE_Backplane_BIT},
> > +	{HNS3_LM_10BASET_HALF_BIT, ETHTOOL_LINK_MODE_10baseT_Half_BIT},
> > +	{HNS3_LM_10BASET_FULL_BIT, ETHTOOL_LINK_MODE_10baseT_Full_BIT},
> > +	{HNS3_LM_100BASET_HALF_BIT, ETHTOOL_LINK_MODE_100baseT_Half_BIT},
> > +	{HNS3_LM_100BASET_FULL_BIT, ETHTOOL_LINK_MODE_100baseT_Full_BIT},
> > +	{HNS3_LM_1000BASET_FULL_BIT,
> ETHTOOL_LINK_MODE_1000baseT_Full_BIT},
> > +	{HNS3_LM_10000BASEKR_FULL_BIT,
> ETHTOOL_LINK_MODE_10000baseKR_Full_BIT},
> > +	{HNS3_LM_25000BASEKR_FULL_BIT,
> ETHTOOL_LINK_MODE_25000baseKR_Full_BIT},
> > +	{HNS3_LM_40000BASELR4_FULL_BIT,
> > +	 ETHTOOL_LINK_MODE_40000baseLR4_Full_BIT},
> > +	{HNS3_LM_50000BASEKR2_FULL_BIT,
> > +	 ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT},
> > +	{HNS3_LM_100000BASEKR4_FULL_BIT,
> > +	 ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT},
> > +};
> 
> I don't see anywhere your HNS3_LM_ enum's get used by the hardware. So
> it would be better to just use the Linux values and avoid this
> translation macro:
Actually, the whole idea is to set bits in "supported" & " advertising"
bitmap fields part of the " struct ethtool_link_ksettings *cmd".

Mapping structure "hns3_link_mode_mapping hns3_lm_map" and its corresponding
Bit set macro HNS3_DRV_TO_ETHTOOL_CAPS() is exactly being used to
Map and populate these bits in the above 2 bitmaps.

Without above we would end up using below macros for each of the bits being
Set separately and will clog the hns3_get_link_ksettings() function something
similar to below:

static int hns3_get_link_ksettings(struct net_device *net_dev,
				   struct ethtool_link_ksettings *cmd)
{
    [....]
      <........un-necessary repetition of the macros.........>

      /* setting bit ETHTOOL_LINK_MODE_100baseT_Full_BIT */
	ethtool_link_ksettings_add_link_mode(lk_ksettings, name,  
						     100baseT_Full);
      /* setting bit ETHTOOL_LINK_MODE_1000baseT_Full_BIT */
	ethtool_link_ksettings_add_link_mode(lk_ksettings, name,
						     1000baseT_Full);
      /* setting bit ETHTOOL_LINK_MODE_1000baseT_Full_BIT */
	ethtool_link_ksettings_add_link_mode(lk_ksettings, name,
						     10000baseT_Full);
    [....]
}

OR another solution could be just include all of above repetition
of macros as one single macros, for example Broadcom driver has
done the same:


static void bnxt_fw_to_ethtool_advertised_spds(struct bnxt_link_info *link_info,
				struct ethtool_link_ksettings *lk_ksettings)
{
    [....]

	if (link_info->autoneg & BNXT_AUTONEG_FLOW_CTRL)
		fw_pause = link_info->auto_pause_setting;

	BNXT_FW_TO_ETHTOOL_SPDS(fw_speeds, fw_pause, lk_ksettings, advertising);
}


#define BNXT_FW_TO_ETHTOOL_SPDS(fw_speeds, fw_pause, lk_ksettings, name)\
{									\
	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_100MB)			\
		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
						     100baseT_Full);	\
	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_1GB)			\
		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
						     1000baseT_Full);	\
	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_10GB)			\
		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
						     10000baseT_Full);	\
	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_25GB)			\
		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
						     25000baseCR_Full);	\
	if ((fw_speeds) & BNXT_LINK_SPEED_MSK_40GB)			\
		ethtool_link_ksettings_add_link_mode(lk_ksettings, name,\
						     40000baseCR4_Full);\
    [....]								\
}

We thought mapping macros like ETHTOOL_LINK_MODE_*_BIT 
to our own internal macros like HNS3_LM_* using 

struct hns3_link_mode_mapping {
	u32 hns3_link_mode;
	u32 ethtool_link_mode;
};

1. Gives us control to set all these bits using the iterative loop.
   in macro HNS3_DRV_TO_ETHTOOL_CAPS()
2. Specifying the speed bit to be set becomes more cleaner and easier using
   below syntax. It is just an OR operation:

		supported_caps = HNS3_LM_BACKPLANE_BIT |
				     HNS3_LM_PAUSE_BIT |
			           HNS3_LM_AUTONEG_BIT |
                             HNS3_LM_40000BASELR4_FULL_BIT |
			           HNS3_LM_10000BASEKR_FULL_BIT | 
			           HNS3_LM_1000BASET_FULL_BIT |
                             HNS3_LM_100BASET_FULL_BIT |
			           HNS3_LM_100BASET_HALF_BIT |
                             HNS3_LM_10BASET_FULL_BIT |
			           HNS3_LM_10BASET_HALF_BIT;


We would like to retain this format. Hope this explanation is fine?

Best regards
Salil

> 
> > +
> > +#define HNS3_DRV_TO_ETHTOOL_CAPS(caps, lk_ksettings, name)	\
> > +{								\
> > +	int i;							\
> > +								\
> > +	for (i = 0; i < ARRAY_SIZE(hns3_lm_map); i++) {		\
> > +		if ((caps) & hns3_lm_map[i].hns3_link_mode)	\
> > +			__set_bit(hns3_lm_map[i].ethtool_link_mode,\
> > +				  (lk_ksettings)->link_modes.name); \
> > +	}							\
> > +}
> 
> 	Andrew
