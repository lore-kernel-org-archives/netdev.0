From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net 2/2] bnx2x: fix memory leak in
 bnx2x_init_firmware()
Date: Fri, 16 Mar 2012 09:24:34 +0200
Message-ID: <1331882675.4251.10.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1331856509-9159-1-git-send-email-mschmidt@redhat.com>
 <1331856509-9159-2-git-send-email-mschmidt@redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3553 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757159Ab2CPHYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2012 03:24:47 -0400
In-Reply-To: <1331856509-9159-2-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-16 at 01:08 +0100, Michal Schmidt wrote:
> When cycling the interface down and up, bnx2x_init_firmware() knows that
> the firmware is already loaded, but nevertheless it allocates certain
> arrays anew (init_data, init_ops, init_ops_offsets, iro_arr). The old
> arrays are leaked.
> 
> Fix the leaks by returning early if the firmware was already loaded.
> Because if the firmware is loaded, so are the arrays.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>


Acked-by: Eilon Greenstein <eilong@broadcom.com>

Thanks Michal!

> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   50 ++++++++++-----------
>  1 files changed, 24 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 00ff62f..b69f876 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -10824,38 +10824,36 @@ do {									\
>  
>  int bnx2x_init_firmware(struct bnx2x *bp)
>  {
> +	const char *fw_file_name;
>  	struct bnx2x_fw_file_hdr *fw_hdr;
>  	int rc;
>  
> +	if (bp->firmware)
> +		return 0;
>  
> -	if (!bp->firmware) {
> -		const char *fw_file_name;
> -
> -		if (CHIP_IS_E1(bp))
> -			fw_file_name = FW_FILE_NAME_E1;
> -		else if (CHIP_IS_E1H(bp))
> -			fw_file_name = FW_FILE_NAME_E1H;
> -		else if (!CHIP_IS_E1x(bp))
> -			fw_file_name = FW_FILE_NAME_E2;
> -		else {
> -			BNX2X_ERR("Unsupported chip revision\n");
> -			return -EINVAL;
> -		}
> -		BNX2X_DEV_INFO("Loading %s\n", fw_file_name);
> +	if (CHIP_IS_E1(bp))
> +		fw_file_name = FW_FILE_NAME_E1;
> +	else if (CHIP_IS_E1H(bp))
> +		fw_file_name = FW_FILE_NAME_E1H;
> +	else if (!CHIP_IS_E1x(bp))
> +		fw_file_name = FW_FILE_NAME_E2;
> +	else {
> +		BNX2X_ERR("Unsupported chip revision\n");
> +		return -EINVAL;
> +	}
> +	BNX2X_DEV_INFO("Loading %s\n", fw_file_name);
>  
> -		rc = request_firmware(&bp->firmware, fw_file_name,
> -				      &bp->pdev->dev);
> -		if (rc) {
> -			BNX2X_ERR("Can't load firmware file %s\n",
> -				  fw_file_name);
> -			goto request_firmware_exit;
> -		}
> +	rc = request_firmware(&bp->firmware, fw_file_name, &bp->pdev->dev);
> +	if (rc) {
> +		BNX2X_ERR("Can't load firmware file %s\n",
> +			  fw_file_name);
> +		goto request_firmware_exit;
> +	}
>  
> -		rc = bnx2x_check_firmware(bp);
> -		if (rc) {
> -			BNX2X_ERR("Corrupt firmware file %s\n", fw_file_name);
> -			goto request_firmware_exit;
> -		}
> +	rc = bnx2x_check_firmware(bp);
> +	if (rc) {
> +		BNX2X_ERR("Corrupt firmware file %s\n", fw_file_name);
> +		goto request_firmware_exit;
>  	}
>  
>  	fw_hdr = (struct bnx2x_fw_file_hdr *)bp->firmware->data;
