From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC net-next 1/5] net: dsa: Add infrastructure to support LAG
Date: Mon, 2 Oct 2017 11:19:13 -0700
Message-ID: <0232d130-9ee7-c1b5-a532-7656f5e3534b@gmail.com>
References: <20171001194639.8647-1-f.fainelli@gmail.com>
 <20171001194639.8647-2-f.fainelli@gmail.com> <20171002020327.GA21593@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        jiri@resnulli.us, idosch@mellanox.com, Woojung.Huh@microchip.com,
        john@phrozen.org, sean.wang@mediatek.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36547 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdJBSTS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 14:19:18 -0400
Received: by mail-qk0-f196.google.com with SMTP id z14so4395846qkg.3
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 11:19:18 -0700 (PDT)
In-Reply-To: <20171002020327.GA21593@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2017 07:03 PM, Andrew Lunn wrote:
> On Sun, Oct 01, 2017 at 12:46:35PM -0700, Florian Fainelli wrote:
>> Add the necessary logic to support network device events targetting LAG events,
>> this is loosely inspired from mlxsw/spectrum.c.
>>
>> In the process we change dsa_slave_changeupper() to be more generic and be called
>> from both LAG events as well as normal bridge enslaving events paths.
>>
>> The DSA layer takes care of managing the LAG group identifiers, how many LAGs
>> may be supported by a switch, and how many members per LAG are supported by a
>> switch device. When a LAG group is identified, the port is then configured to
>> be a part of that group. When a LAG group no longer has any users, we remove it
>> and we tell the drivers whether it is safe to disable trunking altogether.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  include/net/dsa.h  |  25 +++++++++
>>  net/dsa/dsa2.c     |  12 ++++
>>  net/dsa/dsa_priv.h |   7 +++
>>  net/dsa/port.c     |  92 +++++++++++++++++++++++++++++++
>>  net/dsa/slave.c    | 157 +++++++++++++++++++++++++++++++++++++++++++++++++----
>>  net/dsa/switch.c   |  30 ++++++++++
>>  6 files changed, 312 insertions(+), 11 deletions(-)
>>
>> diff --git a/include/net/dsa.h b/include/net/dsa.h
>> index 10dceccd9ce8..247ea58add68 100644
>> --- a/include/net/dsa.h
>> +++ b/include/net/dsa.h
>> @@ -182,12 +182,20 @@ struct dsa_port {
>>  	u8			stp_state;
>>  	struct net_device	*bridge_dev;
>>  	struct devlink_port	devlink_port;
>> +	u8			lag_id;
>> +	bool			lagged;
>>  	/*
>>  	 * Original copy of the master netdev ethtool_ops
>>  	 */
>>  	const struct ethtool_ops *orig_ethtool_ops;
>>  };
>>  
>> +struct dsa_lag_group {
>> +	/* Used to know when we can disable lag on the switch */
>> +	unsigned int		ref_count;
> 
> Hi Florian
> 
> In what contexts is ref_count manipulated. Normally you use would
> refcounf_t and the operations in linux/refcount.h. But if you know
> there is some other protection, e.g. rtnl, an unsigned int is O.K.
> Maybe scatter some assert_RTNL() in the code?

Hi Andrew,

This is called with rtnl held, but this is a good point. In fact, I
don't think we need the reference count at all, what I am going to
propose now is that we just maintain a bitmask of port members per lag
group (along with the reference to the lag device) and when the hamming
weight of that bitmask is 1, that means we were removing the lat port of
the LAG group and we can stop using that LAG group. This also allow us
to remove the port_lag_member operation, since we would be maintaining
that at the DSA layer now.

> 
>> +static bool dsa_slave_lag_check(struct net_device *dev, struct net_device *lag_dev,
>> +				struct netdev_lag_upper_info *lag_upper_info)
>> +{
>> +	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	u8 lag_id;
>> +
>> +	/* No more lag identifiers available or already in use */
>> +	if (dsa_switch_lag_get_index(p->dp->ds, lag_dev, &lag_id) != 0)
>> +		return false;
>> +
>> +	if (lag_upper_info->tx_type != NETDEV_LAG_TX_TYPE_HASH)
>> +		return false;
> 
> I wounder if the driver needs to decide this? Can different hardware
> support different tx_types?

That is a valid point. For instance, the b53/bcm_sf2 switches can only
do MAC DA and SA, SA only, DA only hashing, but you can't do hashing at
a higher level than L2 addresses, this does appear to be something that
the driver should indeed decide.
-- 
Florian
