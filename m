From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH net-next] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Mon, 20 Jun 2016 18:32:19 +0300
Message-ID: <ff2fbee5-46c1-15a8-d283-4320e122934a@annapurnalabs.com>
References: <1465807573-11293-1-git-send-email-netanel@annapurnalabs.com>
 <20160617211118.GA14822@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aligouri@amazon.com, antoine.tenart@free-electrons.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160617211118.GA14822@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 06/18/2016 12:11 AM, Francois Romieu wrote:
> Netanel Belgazal <netanel@annapurnalabs.com> :
> [...]
>
> More stuff below.
>
>> diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
>> new file mode 100644
>> index 0000000..357e10f
>> --- /dev/null
>> +++ b/drivers/net/ethernet/amazon/ena/ena_com.c
> [...]
>> +static int ena_get_dev_stats(struct ena_com_dev *ena_dev,
>> +			     struct ena_admin_aq_get_stats_cmd *get_cmd,
>> +			     struct ena_admin_acq_get_stats_resp *get_resp,
> At first sight it should be possible avoid one pointer argument with:
>
> struct ena_something {
> 	struct ena_admin_aq_get_stats_cmd cmd;
> 	struct ena_admin_acq_get_stats_resp resp;
> 	
> };
Ack
>
> [...]
>> +int ena_com_get_dev_extended_stats(struct ena_com_dev *ena_dev, char *buff,
>> +				   u32 len)
> Where is it used ?
It is currently unused. I'll remove it from this patch and add it in a separate once we'll support it.
>
>> +{
>> +	int ret = 0;
>> +	struct ena_admin_aq_get_stats_cmd get_cmd;
>> +	struct ena_admin_acq_get_stats_resp get_resp;
>> +	void *virt_addr;
> 	int rc = -ENOMEM;
> 	char *str;
>
>> +	dma_addr_t phys_addr;
>> +
>> +	virt_addr = dma_alloc_coherent(ena_dev->dmadev,
>> +				       len,
>> +				       &phys_addr,
>> +				       GFP_KERNEL | __GFP_ZERO);
>> +	if (!virt_addr) {
>> +		ret = -ENOMEM;
>> +		goto done;
>> +	}
>> +	memset(&get_cmd, 0x0, sizeof(get_cmd));
>> +	ret = ena_com_mem_addr_set(ena_dev,
>> +				   &get_cmd.u.control_buffer.address,
>> +				   phys_addr);
>> +	if (unlikely(ret)) {
>> +		ena_trc_err("memory address set failed\n");
>> +		return ret;
>> +	}
>> +	get_cmd.u.control_buffer.length = len;
>> +
>> +	get_cmd.device_id = ena_dev->stats_func;
>> +	get_cmd.queue_idx = ena_dev->stats_queue;
>> +
>> +	ret = ena_get_dev_stats(ena_dev, &get_cmd, &get_resp,
>> +				ENA_ADMIN_GET_STATS_TYPE_EXTENDED);
>> +	if (ret < 0)
>> +		goto free_ext_stats_mem;
>> +
>> +	ret = snprintf(buff, len, "%s", (char *)virt_addr);
> So ENA_ADMIN_GET_STATS_TYPE_EXTENDED fills a buffer with bytes in the
> [0; 127] range, right ?

ENA_ADMIN_GET_STATS_TYPE_EXTENDED fills a buffer with 4K bytes.

>
>> +
>> +free_ext_stats_mem:
>> +	dma_free_coherent(ena_dev->dmadev, len, virt_addr, phys_addr);
>> +done:
>> +	return ret;
>> +}
>> +
>> +int ena_com_set_dev_mtu(struct ena_com_dev *ena_dev, int mtu)
>> +{
>> +	struct ena_com_admin_queue *admin_queue;
>> +	struct ena_admin_set_feat_cmd cmd;
>> +	struct ena_admin_set_feat_resp resp;
>> +	int ret = 0;
> Should be -ENODEV or left uninitialized.
I'll initialize it to -ENODEV
>
>> +
>> +	if (unlikely(!ena_dev)) {
>> +		ena_trc_err("%s : ena_dev is NULL\n", __func__);
>> +		return -ENODEV;
>> +	}
> Does it mean that ena_com_dev may go away while the net_device is in use ?
ena_com_dev can't go away while net_device is alive.
I'll remove this check.
>
>> +
>> +	if (!ena_com_check_supported_feature_id(ena_dev, ENA_ADMIN_MTU)) {
>> +		ena_trc_info("Feature %d isn't supported\n", ENA_ADMIN_MTU);
>> +		return -EPERM;
>> +	}
> 	rc = ena_com_check_supported_feature_id(...
> 	if (rc < 0) {
> 		ena_trc_info(...
> 		goto out;
> 	}
>> +
>> +	memset(&cmd, 0x0, sizeof(cmd));
>> +	admin_queue = &ena_dev->admin_queue;
>> +
>> +	cmd.aq_common_descriptor.opcode = ENA_ADMIN_SET_FEATURE;
>> +	cmd.aq_common_descriptor.flags = 0;
>> +	cmd.feat_common.feature_id = ENA_ADMIN_MTU;
>> +	cmd.u.mtu.mtu = mtu;
>> +
>> +	ret = ena_com_execute_admin_command(admin_queue,
>> +					    (struct ena_admin_aq_entry *)&cmd,
>> +					    sizeof(cmd),
>> +					    (struct ena_admin_acq_entry *)&resp,
>> +					    sizeof(resp));
>> +
>> +	if (unlikely(ret)) {
>> +		ena_trc_err("Failed to set mtu %d. error: %d\n", mtu, ret);
>> +		return -EINVAL;
> ena_com_execute_admin_command should return a proper status code.

ena_com_execute_admin_command already returns a proper status.
I'll remove the return value override.

>
> [...]
> diff --git a/drivers/net/ethernet/amazon/ena/ena_com.h b/drivers/net/ethernet/amazon/ena/ena_com.h
> new file mode 100644
> index 0000000..e49ba43
> --- /dev/null
> [...]
> +static inline void ena_com_update_intr_reg(struct ena_eth_io_intr_reg *intr_reg,
> +					   u32 rx_delay_interval,
> +					   u32 tx_delay_interval,
> +					   bool unmask)
> +{
> +	intr_reg->intr_control = 0;
> +	intr_reg->intr_control |= rx_delay_interval &
> +		ENA_ETH_IO_INTR_REG_RX_INTR_DELAY_MASK;
> +
> +	intr_reg->intr_control |=
> +		(tx_delay_interval << ENA_ETH_IO_INTR_REG_TX_INTR_DELAY_SHIFT)
> +		& ENA_ETH_IO_INTR_REG_RX_INTR_DELAY_MASK;
>                                       ^^ TX ?
>
> Extra: you should not return NETDEV_TX_BUSY in the xmit handler while
> queueing is still enabled. Please drop packet and return NETDEV_TX_OK.
Ack.

Thanks for your review.
>
