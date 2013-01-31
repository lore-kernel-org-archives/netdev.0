From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 2/2] drivers: net:ethernet: cpsw: add support for VLAN
Date: Thu, 31 Jan 2013 16:39:26 +0530
Message-ID: <510A50E6.8090504@ti.com>
References: <1359572855-12344-1-git-send-email-mugunthanvnm@ti.com> <1359572855-12344-3-git-send-email-mugunthanvnm@ti.com> <20130130220243.GB22847@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20130130220243.GB22847@electric-eye.fr.zoreil.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/31/2013 3:32 AM, Francois Romieu wrote:
> Mugunthan V N <mugunthanvnm@ti.com> :
> [...]
>> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
>> index 6ddd028..99696bf 100644
>> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>> @@ -24,6 +24,8 @@ Required properties:
>>   Optional properties:
>>   - ti,hwmods		: Must be "cpgmac0"
>>   - no_bd_ram		: Must be 0 or 1
>> +- default_vlan		: Specifies Default VLAN for non tagged packets
>> +			  ALE processing
> Isn't it a device-tree hack for what should belong to a common API ?
Its a hardware feature which stack will not be aware of. It is used in 
the ALE filtering
process with a non-tagged packet arrives.
>
> [...]
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index a40750e..6c66f01 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
> [...]
>> @@ -607,14 +611,41 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
>>   	}
>>   }
>>   
>> +static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
>> +{
>> +	writel(priv->data.default_vlan, &priv->host_port_regs->port_vlan);
>> +	if (priv->version == CPSW_VERSION_1) {
>> +		slave_write(&priv->slaves[0], priv->data.default_vlan,
>> +			    CPSW1_PORT_VLAN);
>> +		slave_write(&priv->slaves[1], priv->data.default_vlan,
>> +			    CPSW1_PORT_VLAN);
>> +	} else {
>> +		slave_write(&priv->slaves[0], priv->data.default_vlan,
>> +			    CPSW2_PORT_VLAN);
>> +		slave_write(&priv->slaves[1], priv->data.default_vlan,
>> +			    CPSW2_PORT_VLAN);
>> +	}
>> +	cpsw_ale_add_vlan(priv->ale, priv->data.default_vlan,
>> +			ALE_ALL_PORTS << priv->host_port,
>> +			ALE_ALL_PORTS << priv->host_port,
>> +			ALE_ALL_PORTS << priv->host_port,
>> +			(BIT(1) | BIT(2)) << priv->host_port);
>> +}
> static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
> {
> 	const int vlan = priv->data.default_vlan;
> 	const int port = priv->host_port;
> 	u32 reg;
> 	int i;
>
> 	reg = (priv->version == CPSW_VERSION_1) ? CPSW1_PORT_VLAN :
> 	      CPSW2_PORT_VLAN;
>
> 	writel(vlan, &priv->host_port_regs->port_vlan);
>
> 	for (int i = 0; i < 2; i++)
> 		slave_write(priv->slaves + i, vlan, reg);
>
> 	cpsw_ale_add_vlan(priv->ale, vlan, ALE_ALL_PORTS << port,
> 			  ALE_ALL_PORTS << port, ALE_ALL_PORTS << port,
> 			  (BIT(1) | BIT(2)) << port);
> }
>
> ... or somewhere between both. Your call.
Will modify the code as this looks simpler
>
> [...]
>> @@ -933,6 +967,55 @@ static void cpsw_ndo_poll_controller(struct net_device *ndev)
>>   }
>>   #endif
>>   
>> +static inline void cpsw_add_vlan_ale_entry(struct cpsw_priv *priv,
>> +				unsigned short vid)
>> +{
>> +	cpsw_ale_add_vlan(priv->ale, vid, ALE_ALL_PORTS << priv->host_port,
>> +			0, ALE_ALL_PORTS << priv->host_port,
>> +			(BIT(1) | BIT(2)) << priv->host_port);
> "(BIT(1) | BIT(2))" is repeated a couple of times.
Will replace with port number defines.
>
> [...]
>> +static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
>> +		unsigned short vid)
>> +{
>> +	struct cpsw_priv *priv = netdev_priv(ndev);
>> +
>> +	if (vid == priv->data.default_vlan)
>> +		return 0;
>> +
>> +	spin_lock(&priv->lock);
>> +
>> +	dev_info(priv->dev, "Adding vlanid %d to vlan filter\n", vid);
>> +	cpsw_add_vlan_ale_entry(priv, vid);
>> +
>> +	spin_unlock(&priv->lock);
>> +	return 0;
>> +}
>> +
>> +static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
>> +		unsigned short vid)
>> +{
>> +	struct cpsw_priv *priv = netdev_priv(ndev);
>> +
>> +	if (vid == priv->data.default_vlan)
>> +		return 0;
>> +
>> +	spin_lock(&priv->lock);
>> +
>> +	dev_info(priv->dev, "removing vlanid %d from vlan filter\n", vid);
>> +	cpsw_ale_del_vlan(priv->ale, vid, 0);
>> +	cpsw_ale_del_ucast(priv->ale, priv->mac_addr,
>> +			   priv->host_port, ALE_VLAN, vid);
>> +	cpsw_ale_del_mcast(priv->ale, priv->ndev->broadcast, 0, ALE_VLAN, vid);
>> +
>> +	spin_unlock(&priv->lock);
> What are you trying to achieve with the lock ?
>
> It is not used anywhere else and both cpsw_ndo_vlan_rx_{add, kill}_vid are
> called under RTNL.
Will remove the lock from both apis

Regards
Mugunthan V N
