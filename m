From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] vt6656: [BUG] - Failed connection, incorrect endian.
 v2
Date: Wed, 29 Aug 2012 16:20:09 -0500
Message-ID: <503E8789.6050809@lwfinger.net>
References: <1346273644.2077.3.camel@router7789>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Malcolm Priestley <tvboxspy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:47182 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819Ab2H2VUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 17:20:14 -0400
In-Reply-To: <1346273644.2077.3.camel@router7789>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2012 03:54 PM, Malcolm Priestley wrote:
>
> This patch fixes a bug with driver failing to negotiate a connection.
>
> The bug was traced to commit
> 203e4615ee9d9fa8d3506b9d0ef30095e4d5bc90
> staging: vt6656: removed custom definitions of Ethernet packet types
>
> In that patch, definitions in include/linux/if_ether.h replaced ones
> in tether.h which had both big and little endian definitions.
>
> include/linux/if_ether.h only refers to big endian values, cpu_to_be16
> should be used for the correct endian architectures.
>
> checkpatch fixed version.
>
> Signed-off-by: Malcolm Priestley <tvboxspy@gmail.com>

Patches for staging drivers should be sent to gregkh@linuxfoundation.org. He is 
the one that handles them. In addition, the patch subject line usually has the 
sequence "staging: vt6656: blabla" the way the faulty patch did.

> ---
>   drivers/staging/vt6656/dpc.c  |    2 +-
>   drivers/staging/vt6656/rxtx.c |   38 +++++++++++++++++++-------------------
>   2 files changed, 20 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/staging/vt6656/dpc.c b/drivers/staging/vt6656/dpc.c
> index e4bdf2a..3aa895e 100644
> --- a/drivers/staging/vt6656/dpc.c
> +++ b/drivers/staging/vt6656/dpc.c
> @@ -200,7 +200,7 @@ s_vProcessRxMACHeader (
>       } else if (!compare_ether_addr(pbyRxBuffer, &pDevice->abySNAP_RFC1042[0])) {
>           cbHeaderSize += 6;
>           pwType = (PWORD) (pbyRxBufferAddr + cbHeaderSize);
> -	if ((*pwType == cpu_to_le16(ETH_P_IPX)) ||
> +	if ((*pwType == cpu_to_be16(ETH_P_IPX)) ||
>   	    (*pwType == cpu_to_le16(0xF380))) {
>   		cbHeaderSize -= 8;
>               pwType = (PWORD) (pbyRxBufferAddr + cbHeaderSize);
> diff --git a/drivers/staging/vt6656/rxtx.c b/drivers/staging/vt6656/rxtx.c
> index bb46452..b6e04e7 100644
> --- a/drivers/staging/vt6656/rxtx.c
> +++ b/drivers/staging/vt6656/rxtx.c
> @@ -1699,7 +1699,7 @@ s_bPacketToWirelessUsb(
>       // 802.1H
>       if (ntohs(psEthHeader->wType) > ETH_DATA_LEN) {
>   	if (pDevice->dwDiagRefCount == 0) {
> -		if ((psEthHeader->wType == cpu_to_le16(ETH_P_IPX)) ||
> +		if ((psEthHeader->wType == cpu_to_be16(ETH_P_IPX)) ||
>   		    (psEthHeader->wType == cpu_to_le16(0xF380))) {
>   			memcpy((PBYTE) (pbyPayloadHead),
>   			       abySNAP_Bridgetunnel, 6);
> @@ -2838,10 +2838,10 @@ int nsDMA_tx_packet(PSDevice pDevice, unsigned int uDMAIdx, struct sk_buff *skb)
>       Packet_Type = skb->data[ETH_HLEN+1];
>       Descriptor_type = skb->data[ETH_HLEN+1+1+2];
>       Key_info = (skb->data[ETH_HLEN+1+1+2+1] << 8)|(skb->data[ETH_HLEN+1+1+2+2]);
> -    if (pDevice->sTxEthHeader.wType == cpu_to_le16(ETH_P_PAE)) {
> -	/* 802.1x OR eapol-key challenge frame transfer */
> -	if (((Protocol_Version == 1) || (Protocol_Version == 2)) &&
> -		(Packet_Type == 3)) {
> +	if (pDevice->sTxEthHeader.wType == cpu_to_be16(ETH_P_PAE)) {
> +		/* 802.1x OR eapol-key challenge frame transfer */
> +		if (((Protocol_Version == 1) || (Protocol_Version == 2)) &&
> +			(Packet_Type == 3)) {
>                           bTxeapol_key = TRUE;
>                          if(!(Key_info & BIT3) &&  //WPA or RSN group-key challenge
>   			   (Key_info & BIT8) && (Key_info & BIT9)) {    //send 2/2 key
> @@ -2987,19 +2987,19 @@ int nsDMA_tx_packet(PSDevice pDevice, unsigned int uDMAIdx, struct sk_buff *skb)
>           }
>       }
>
> -    if (pDevice->sTxEthHeader.wType == cpu_to_le16(ETH_P_PAE)) {
> -        if (pDevice->byBBType != BB_TYPE_11A) {
> -            pDevice->wCurrentRate = RATE_1M;
> -            pDevice->byACKRate = RATE_1M;
> -            pDevice->byTopCCKBasicRate = RATE_1M;
> -            pDevice->byTopOFDMBasicRate = RATE_6M;
> -        } else {
> -            pDevice->wCurrentRate = RATE_6M;
> -            pDevice->byACKRate = RATE_6M;
> -            pDevice->byTopCCKBasicRate = RATE_1M;
> -            pDevice->byTopOFDMBasicRate = RATE_6M;
> -        }
> -    }
> +	if (pDevice->sTxEthHeader.wType == cpu_to_be16(ETH_P_PAE)) {
> +		if (pDevice->byBBType != BB_TYPE_11A) {
> +			pDevice->wCurrentRate = RATE_1M;
> +			pDevice->byACKRate = RATE_1M;
> +			pDevice->byTopCCKBasicRate = RATE_1M;
> +			pDevice->byTopOFDMBasicRate = RATE_6M;
> +		} else {
> +			pDevice->wCurrentRate = RATE_6M;
> +			pDevice->byACKRate = RATE_6M;
> +			pDevice->byTopCCKBasicRate = RATE_1M;
> +			pDevice->byTopOFDMBasicRate = RATE_6M;
> +		}
> +	}
>
>       DBG_PRT(MSG_LEVEL_DEBUG,
>   	    KERN_INFO "dma_tx: pDevice->wCurrentRate = %d\n",
> @@ -3015,7 +3015,7 @@ int nsDMA_tx_packet(PSDevice pDevice, unsigned int uDMAIdx, struct sk_buff *skb)
>
>       if (bNeedEncryption == TRUE) {
>           DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO"ntohs Pkt Type=%04x\n", ntohs(pDevice->sTxEthHeader.wType));
> -	if ((pDevice->sTxEthHeader.wType) == cpu_to_le16(ETH_P_PAE)) {
> +	if ((pDevice->sTxEthHeader.wType) == cpu_to_be16(ETH_P_PAE)) {
>   		bNeedEncryption = FALSE;
>               DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO"Pkt Type=%04x\n", (pDevice->sTxEthHeader.wType));
>               if ((pMgmt->eCurrMode == WMAC_MODE_ESS_STA) && (pMgmt->eCurrState == WMAC_STATE_ASSOC)) {
>

The white space looks a bit funny; however, it seems that this driver does not 
use tabs at the start, and your patch does.

Larry
