From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH 3/3] net: ethernet: ti: cpsw: split common driver data and
 private net data
Date: Fri, 5 Aug 2016 17:38:47 +0300
Message-ID: <b730a95a-af6e-5d7c-fe46-c2b285baedf2@linaro.org>
References: <1470345272-874-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470345272-874-4-git-send-email-ivan.khoronzhuk@linaro.org>
 <04f2beb0-7b1c-1585-7661-aa12c0d175df@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <04f2beb0-7b1c-1585-7661-aa12c0d175df@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05.08.16 15:14, Grygorii Strashko wrote:
> On 08/05/2016 12:14 AM, Ivan Khoronzhuk wrote:
>> Simplify driver by splitting common driver data and net dev
>> private data. In case of dual_emac mode 2 networks devices
>> are created, each of them contains its own private data.
>> But 2 net devices share a bunch of h/w resources, that shouldn't
>> be duplicated.
>> This patch leads to the following:
>> - no functional changes
>> - reduce code size
>> - reduce memory usage
>> - reduce number of conversion to priv function
>> - reduce number of arguments for some functions
>> - increase code readability
>> - create prerequisites to add multichannel support,
>>   when channels are shared between net devices
>
> Even if it sounds reasonable, I have to NACK this patch -
> main reason below, but there are few more:
> - could you pls split this change as it's too big and I'm pretty sure it's possible;
> - could you pls avoid unrelated changes like variable reordering in structures
Ok. v2 will include it.

>
> and thanks a lot for working on this.
>
>>
>> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>> ---
>>  drivers/net/ethernet/ti/cpsw.c | 775 +++++++++++++++++++----------------------
>>  1 file changed, 364 insertions(+), 411 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index 85ee9f5..7a84515 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -141,8 +141,8 @@ do {								\
>>  #define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
>>
>>  #define cpsw_slave_index(priv)				\
>> -		((priv->data.dual_emac) ? priv->emac_port :	\
>> -		priv->data.active_slave)
>> +		((cpsw->data.dual_emac) ? priv->emac_port :	\
>> +		cpsw->data.active_slave)
>>
>>  static int debug_level;
>>  module_param(debug_level, int, 0);
>> @@ -364,29 +364,34 @@ static inline void slave_write(struct cpsw_slave *slave, u32 val, u32 offset)
>>  }
>>
>>  struct cpsw_priv {
>> -	struct platform_device		*pdev;
>>  	struct net_device		*ndev;
>> -	struct napi_struct		napi_rx;
>> -	struct napi_struct		napi_tx;
>>  	struct device			*dev;
>> +	u8				mac_addr[ETH_ALEN];
>> +	bool				rx_pause;
>> +	bool				tx_pause;
>> +	u32				msg_enable;
>> +	u32				emac_port;
>> +};
>> +
>> +struct cpsw_common {
>> +	struct net_device		*ndev; /* holds base ndev */
>> +	struct platform_device		*pdev;
>>  	struct cpsw_platform_data	data;
>> +	struct napi_struct		napi_rx;
>> +	struct napi_struct		napi_tx;
>> +	struct cpdma_chan		*txch, *rxch;
>> +	struct cpsw_slave		*slaves;
>>  	struct cpsw_ss_regs __iomem	*regs;
>>  	struct cpsw_wr_regs __iomem	*wr_regs;
>>  	u8 __iomem			*hw_stats;
>>  	struct cpsw_host_regs __iomem	*host_port_regs;
>> -	u32				msg_enable;
>> -	u32				version;
>> -	u32				coal_intvl;
>> -	u32				bus_freq_mhz;
>> -	int				rx_packet_max;
>>  	struct clk			*clk;
>> -	u8				mac_addr[ETH_ALEN];
>> -	struct cpsw_slave		*slaves;
>>  	struct cpdma_ctlr		*dma;
>> -	struct cpdma_chan		*txch, *rxch;
>>  	struct cpsw_ale			*ale;
>> -	bool				rx_pause;
>> -	bool				tx_pause;
>> +	int				rx_packet_max;
>> +	u32				bus_freq_mhz;
>> +	u32				version;
>> +	u32				coal_intvl;
>>  	bool				quirk_irq;
>>  	bool				rx_irq_disabled;
>>  	bool				tx_irq_disabled;
>> @@ -394,9 +399,10 @@ struct cpsw_priv {
>>  	u32 irqs_table[4];
>>  	u32 num_irqs;
>>  	struct cpts *cpts;
>> -	u32 emac_port;
>>  };
>
>
>
>>
>> +static struct cpsw_common *cpsw;
>> +
>
> Sry, but NACK - no new static variables pls.
Ok.

>

-- 
Regards,
Ivan Khoronzhuk
