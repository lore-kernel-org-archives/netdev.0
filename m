From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH net v2 1/3] drivers: net: cpsw: fix parsing of phy-handle
 DT property in dual_emac config
Date: Mon, 25 Apr 2016 22:14:07 +0300
Message-ID: <571E6C7F.10704@ti.com>
References: <1461261035-5578-1-git-send-email-drivshin.allworx@gmail.com>
 <1461262794-9562-1-git-send-email-drivshin.allworx@gmail.com>
 <571A210E.2020607@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
	Andrew Goodbody <andrew.goodbody-nYQdZkeIoGZN8Ch2cx6nig@public.gmane.org>,
	Markus Brunner <systemprogrammierung.brunner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nicolas Chauvet <kwizart-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "David Rivshin (Allworx)" <drivshin.allworx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <571A210E.2020607-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/22/2016 04:03 PM, Grygorii Strashko wrote:
> On 04/21/2016 09:19 PM, David Rivshin (Allworx) wrote:
>> From: David Rivshin <drivshin-5fOYsn7Fw8lBDgjK7y7TUQ@public.gmane.org>
>>
>> Commit 9e42f715264ff158478fa30eaed847f6e131366b ("drivers: net: cpsw: add
>> phy-handle parsing") saved the "phy-handle" phandle into a new cpsw_priv
>> field. However, phy connections are per-slave, so the phy_node field 
>> should
>> be in cpsw_slave_data rather than cpsw_priv.
>>
>> This would go unnoticed in a single emac configuration. But in dual_emac
>> mode, the last "phy-handle" property parsed for either slave would be 
>> used
>> by both of them, causing them both to refer to the same phy_device.
>>
>> Fixes: 9e42f715264f ("drivers: net: cpsw: add phy-handle parsing")
>> Signed-off-by: David Rivshin <drivshin-5fOYsn7Fw8lBDgjK7y7TUQ@public.gmane.org>
>> Tested-by: Nicolas Chauvet <kwizart-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>> I would suggest this for -stable. It should apply cleanly as far back
>> as 4.4.
>>
>> Changes since v1 [1]:
>> - Rebased (no conflicts)
>> - Added Tested-by from Nicolas Chauvet
>>
>> [1] https://patchwork.ozlabs.org/patch/560326/
> 
> Reviewed-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>

In my opinion, it will be good to have this patch merged as part of -rc cycle, since
it will fix "NULL pointer dereference" issue with current LKML as reported by Andrew Goodbody.


> 
>>
>>   drivers/net/ethernet/ti/cpsw.c | 13 ++++++-------
>>   drivers/net/ethernet/ti/cpsw.h |  1 +
>>   2 files changed, 7 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c 
>> b/drivers/net/ethernet/ti/cpsw.c
>> index 42fdfd4..d69cb3f 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -363,15 +363,14 @@ static inline void slave_write(struct cpsw_slave 
>> *slave, u32 val, u32 offset)
>>       __raw_writel(val, slave->regs + offset);
>>   }
>>
>>   struct cpsw_priv {
>>       spinlock_t            lock;
>>       struct platform_device        *pdev;
>>       struct net_device        *ndev;
>> -    struct device_node        *phy_node;
>>       struct napi_struct        napi_rx;
>>       struct napi_struct        napi_tx;
>>       struct device            *dev;
>>       struct cpsw_platform_data    data;
>>       struct cpsw_ss_regs __iomem    *regs;
>>       struct cpsw_wr_regs __iomem    *wr_regs;
>>       u8 __iomem            *hw_stats;
>> @@ -1144,16 +1143,16 @@ static void cpsw_slave_open(struct cpsw_slave 
>> *slave, struct cpsw_priv *priv)
>>
>>       if (priv->data.dual_emac)
>>           cpsw_add_dual_emac_def_ale_entries(priv, slave, slave_port);
>>       else
>>           cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
>>                      1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
>>
>> -    if (priv->phy_node)
>> -        slave->phy = of_phy_connect(priv->ndev, priv->phy_node,
>> +    if (slave->data->phy_node)
>> +        slave->phy = of_phy_connect(priv->ndev, slave->data->phy_node,
>>                    &cpsw_adjust_link, 0, slave->data->phy_if);
>>       else
>>           slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
>>                    &cpsw_adjust_link, slave->data->phy_if);
>>       if (IS_ERR(slave->phy)) {
>>           dev_err(priv->dev, "phy %s not found on slave %d\n",
>>               slave->data->phy_id, slave->slave_num);
>> @@ -1936,20 +1935,19 @@ static void cpsw_slave_init(struct cpsw_slave 
>> *slave, struct cpsw_priv *priv,
>>
>>       slave->data    = data;
>>       slave->regs    = regs + slave_reg_ofs;
>>       slave->sliver    = regs + sliver_reg_ofs;
>>       slave->port_vlan = data->dual_emac_res_vlan;
>>   }
>>

[..]

-- 
regards,
-grygorii
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
