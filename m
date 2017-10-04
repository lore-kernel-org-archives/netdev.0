From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 7/7] mlxsw: spectrum: Add extack messages for
 enslave failures
Date: Wed, 4 Oct 2017 08:44:22 -0700
Message-ID: <2db8450f-aa7a-24e5-603c-bb76c009fad7@gmail.com>
References: <1507093134-20406-1-git-send-email-dsahern@gmail.com>
 <1507093134-20406-8-git-send-email-dsahern@gmail.com>
 <20171004132403.GA14864@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, jiri@mellanox.com, idosch@mellanox.com,
        davem@davemloft.net, bridge@lists.linux-foundation.org
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33040 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752409AbdJDPoV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 11:44:21 -0400
Received: by mail-pf0-f196.google.com with SMTP id m28so12502625pfi.0
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 08:44:21 -0700 (PDT)
In-Reply-To: <20171004132403.GA14864@splinter>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/4/17 6:24 AM, Ido Schimmel wrote:
> On Tue, Oct 03, 2017 at 09:58:54PM -0700, David Ahern wrote:
>> mlxsw fails device enslavement for a number of reasons. Use the extack
>> facility to return an error message to the user stating why the enslave
>> is failing.
>>
>> Messages are prefixed with "spectrum" so users know it is a constraint
>> imposed by the hardware driver. For example:
>>     $ ip li add br0.11 link br0 type vlan id 11
>>     $ ip li set swp11 master br0
>>     Error: spectrum: Enslaving a port to a device that already has an upper device is not supported.
>>
>> Signed-off-by: David Ahern <dsahern@gmail.com>
> 
> Great stuff, thanks David!
> 
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Tested-by: Ido Schimmel <idosch@mellanox.com>
> 
> See one small nit below, but I would like to patch
> mlxsw_sp_netdevice_port_vlan_event() as well, so I can take care of it
> then.

ok. Works for me. I was planning to add more error messages to mlxsw;
happy to concede that to you or someone else. For example a bridge
without vlan filtering:

$ ip li add br1 type bridge
$ ip li set swp20 master br1
RTNETLINK answers: Invalid argument


> 
>> ---
>>  drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 46 ++++++++++++++++++++------
>>  1 file changed, 36 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
>> index 3adf237c951a..a6cc00e4e543 100644
>> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
>> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
>> @@ -4019,14 +4019,20 @@ static int mlxsw_sp_lag_index_get(struct mlxsw_sp *mlxsw_sp,
>>  static bool
>>  mlxsw_sp_master_lag_check(struct mlxsw_sp *mlxsw_sp,
>>  			  struct net_device *lag_dev,
>> -			  struct netdev_lag_upper_info *lag_upper_info)
>> +			  struct netdev_lag_upper_info *lag_upper_info,
>> +			  struct netlink_ext_ack *extack)
>>  {
>>  	u16 lag_id;
>>  
>> -	if (mlxsw_sp_lag_index_get(mlxsw_sp, lag_dev, &lag_id) != 0)
>> +	if (mlxsw_sp_lag_index_get(mlxsw_sp, lag_dev, &lag_id) != 0) {
>> +		NL_SET_ERR_MSG(extack, "spectrum: Unknown LAG device");
> 
> A more accurate message would be:
> "spectrum: Exceeded number of supported LAG devices"

Right. will update.


> 
>>  		return false;
>> -	if (lag_upper_info->tx_type != NETDEV_LAG_TX_TYPE_HASH)
>> +	}
>> +	if (lag_upper_info->tx_type != NETDEV_LAG_TX_TYPE_HASH) {
>> +		NL_SET_ERR_MSG(extack,
>> +			       "spectrum: LAG device using unsupported Tx type");
>>  		return false;
>> +	}
>>  	return true;
>>  }
