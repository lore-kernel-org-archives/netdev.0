From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCHv2 net-next-2.6 2/2] qlcnic: Take FW dump via ethtool
Date: Tue, 10 May 2011 14:00:55 -0700
Message-ID: <3D85CC75-765C-4059-BB3F-82CCBF748FBC@qlogic.com>
References: <1304989352-24810-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1304989352-24810-4-git-send-email-anirban.chakraborty@qlogic.com>
 <1305052826.2859.53.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:5420 "EHLO
	VA3EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750750Ab1EJVBB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 17:01:01 -0400
In-Reply-To: <1305052826.2859.53.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 10, 2011, at 11:40 AM, Ben Hutchings wrote:

> On Mon, 2011-05-09 at 18:02 -0700, Anirban Chakraborty wrote:
>> Driver checks if the previous dump has been cleared before taking the dump.
>> It doesn't take the dump if it is not cleared.
>> 
>> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>> ---
>> drivers/net/qlcnic/qlcnic_ethtool.c |   60 +++++++++++++++++++++++++++++++++++
>> 1 files changed, 60 insertions(+), 0 deletions(-)
>> 
>> diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
>> index c541461..1237449 100644
>> --- a/drivers/net/qlcnic/qlcnic_ethtool.c
>> +++ b/drivers/net/qlcnic/qlcnic_ethtool.c
>> @@ -965,6 +965,64 @@ static void qlcnic_set_msglevel(struct net_device *netdev, u32 msglvl)
>> 	adapter->msg_enable = msglvl;
>> }
>> 
>> +static int
>> +qlcnic_get_dump(struct net_device *netdev, struct ethtool_dump *dump,
>> +		void *buffer)
>> +{
>> +	int i, copy_sz;
>> +	u32 *hdr_ptr, *data;
>> +	struct qlcnic_adapter *adapter = netdev_priv(netdev);
>> +	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
>> +
>> +	if (dump->type == ETHTOOL_DUMP_FLAG) {
>> +		dump->len = fw_dump->tmpl_hdr->size + fw_dump->size;
>> +		dump->flag = fw_dump->tmpl_hdr->drv_cap_mask;
>> +		return 0;
>> +	}
>> +	if (!fw_dump->clr) {
>> +		netdev_info(netdev, "Dump not available\n");
>> +		return -EINVAL;
>> +	}
>> +	copy_sz = fw_dump->tmpl_hdr->size;
>> +	/* Copy template header first */
>> +	hdr_ptr = (u32 *) fw_dump->tmpl_hdr;
>> +	data = (u32 *) buffer;
>> +	for (i = 0; i < copy_sz/sizeof(u32); i++)
>> +		*data++ = cpu_to_le32(*hdr_ptr++);
>> +	/* Copy captured dump data */
>> +	memcpy(buffer + copy_sz, fw_dump->data, fw_dump->size);
>> +	dump->len = copy_sz + fw_dump->size;
>> +	dump->flag = fw_dump->tmpl_hdr->drv_cap_mask;
>> +	/* free dump area once the whoel dump data has been captured */
>> +	vfree(fw_dump->data);
>> +	fw_dump->size = 0;
>> +	fw_dump->data = NULL;
>> +	fw_dump->clr = 0;
> 
> This doesn't seem to be serialised with the code that captures firmware
> dumps.  They need to use the same lock!
When we take the dump, we bring down the interface. So, ethtool will not get a chance to
fetch the dump data while the dump operation is in progress.

> 
>> +	return 0;
>> +}
>> +
>> +static int
>> +qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
>> +{
>> +	struct qlcnic_adapter *adapter = netdev_priv(netdev);
>> +	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
>> +	if (val->flag == QLCNIC_FORCE_FW_DUMP_KEY) {
>> +		netdev_info(netdev, "Forcing a FW dump\n");
>> +		qlcnic_dev_request_reset(adapter);
>> +	} else {
>> +		if (val->flag > QLCNIC_DUMP_MASK_MAX ||
>> +			val->flag < QLCNIC_DUMP_MASK_MIN) {
>> +				netdev_info(netdev,
>> +				"Invalid dump level: 0x%x\n", val->flag);
>> +				return -EINVAL;
>> +		}
>> +		fw_dump->tmpl_hdr->drv_cap_mask = val->flag & 0xff;
>> +		netdev_info(netdev, "Driver mask changed to: 0x%x\n",
>> +			fw_dump->tmpl_hdr->drv_cap_mask);
> 
> If the flags change, doesn't this invalidate any dump that has been
> collected by the driver but not saved?
If the flags change, its effect would be relevant from the next dump capture. The flag indicates to the
driver to gather FW dump for a specific level of detail.

> 
> Also, same locking problem here.
Addressed above.

Thanks for reviewing. 

-Anirban


