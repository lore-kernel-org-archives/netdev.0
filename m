From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net v3] be2net: Warn users of possible broken functionality
 on BE2 cards with very old FW versions with latest driver
Date: Thu, 24 Oct 2013 10:37:06 +0200
Message-ID: <5268DC32.8090306@redhat.com>
References: <6e195c58-1709-45de-a2e6-59cd40c0e591@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Somnath Kotur <somnath.kotur@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753519Ab3JXIhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 04:37:11 -0400
In-Reply-To: <6e195c58-1709-45de-a2e6-59cd40c0e591@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Som,
see my inline comment below...

Ivan
On 10/23/2013 01:29 PM, Somnath Kotur wrote:
> On very old FW versions < 4.0, the mailbox command to set interrupts
> on the card succeeds even though it is not supported and should have
> failed, leading to a scenario where interrupts do not work.
> Hence warn users to upgrade to a suitable FW version to avoid seeing
> broken functionality.
>
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> ---
> v3: Incorporated comments from Ben Hutchings, Joe Perches and Ivan Vercera
>
>   drivers/net/ethernet/emulex/benet/be.h      |    9 +++++++++
>   drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
>   2 files changed, 15 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
> index db02023..da9c04b 100644
> --- a/drivers/net/ethernet/emulex/benet/be.h
> +++ b/drivers/net/ethernet/emulex/benet/be.h
> @@ -696,6 +696,15 @@ static inline int qnq_async_evt_rcvd(struct be_adapter *adapter)
>   	return adapter->flags & BE_FLAGS_QNQ_ASYNC_EVT_RCVD;
>   }
>
> +static inline u32 fw_major_num(const char *fw_ver)
> +{
> +	int fw_major = 0;
> +
> +	sscanf(fw_ver, "%d.", &fw_major);
> +
> +	return fw_major;
> +}
> +
You changed fw_major as I mentioned in our private discussion but the 
return type should be also 'int' and not 'u32'.

>   extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
>   		u16 num_popped);
>   extern void be_link_status_update(struct be_adapter *adapter, u8 link_status);
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index 2c38cc4..53ed58b 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -3247,6 +3247,12 @@ static int be_setup(struct be_adapter *adapter)
>
>   	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter->fw_on_flash);
>
> +	if (BE2_chip(adapter) && fw_major_num(adapter->fw_ver) < 4) {
> +		dev_err(dev, "Firmware on card is old(%s), IRQs may not work",
> +			adapter->fw_ver);
> +		dev_err(dev, "Please upgrade firmware to version >= 4.0\n");
> +	}
> +
>   	if (adapter->vlans_added)
>   		be_vid_config(adapter);
>
>
