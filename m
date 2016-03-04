From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] be2net: Don't leak iomapped memory on removal.
Date: Fri, 4 Mar 2016 16:18:18 +0300
Message-ID: <56D98B1A.1070804@cogentembedded.com>
References: <1457044549-10563-1-git-send-email-dougmill@linux.vnet.ibm.com>
 <1457044549-10563-2-git-send-email-dougmill@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: Douglas Miller <dougmill@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:33298 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbcCDNSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 08:18:22 -0500
Received: by mail-lb0-f179.google.com with SMTP id k15so60715534lbg.0
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 05:18:21 -0800 (PST)
In-Reply-To: <1457044549-10563-2-git-send-email-dougmill@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/4/2016 1:35 AM, Douglas Miller wrote:

> The adapter->pcicfg resource is either mapped via pci_iomap() or
> derived from adapter->db. During be_remove() this resource was ignored
> and so could remain mapped after remove.
>
> Add a flag to track whether adapter->pcicfg was mapped or not, then
> use that flag in be_unmap_pci_bars() to unmap if required.
>
> Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>
> ---
>   drivers/net/ethernet/emulex/benet/be.h      |    1 +
>   drivers/net/ethernet/emulex/benet/be_main.c |    4 ++++
>   2 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
> index cf83783..f975129 100644
> --- a/drivers/net/ethernet/emulex/benet/be.h
> +++ b/drivers/net/ethernet/emulex/benet/be.h
> @@ -531,6 +531,7 @@ struct be_adapter {
>
>   	struct delayed_work be_err_detection_work;
>   	u8 err_flags;
> +	bool pcicfg_mapped;	/* pcicfg obtained via pci_iomap() */
>   	u32 flags;
>   	u32 cmd_privileges;
>   	/* Ethtool knobs and info */
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index f99de36..a79b8a5 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
[...]
> @@ -5019,8 +5021,10 @@ static int be_map_pci_bars(struct be_adapter *adapter)
>   			if (!addr)
>   				goto pci_map_err;
>   			adapter->pcicfg = addr;
> +			adapter->pcicfg_mapped = 1;

    s/1/true/.

>   		} else {
>   			adapter->pcicfg = adapter->db + SRIOV_VF_PCICFG_OFFSET;
> +			adapter->pcicfg_mapped = 0;

    s/0/false/.

[...]

MBR, Sergei
