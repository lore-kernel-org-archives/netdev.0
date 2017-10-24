From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next v3 06/10] bnxt: Add devlink support for config get/set
Date: Tue, 24 Oct 2017 13:52:25 -0700
Message-ID: <CACKFLimoALDGk-ErroVWRGGQVa9QrTQQFXEuNAWUJvuaqGH41w@mail.gmail.com>
References: <1508875962-39233-1-git-send-email-steven.lin1@broadcom.com> <1508875962-39233-7-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>, jiri@mellanox.com,
        David Miller <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>, yuvalm@mellanox.com
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:46695 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750897AbdJXUw0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 16:52:26 -0400
Received: by mail-oi0-f65.google.com with SMTP id n82so39626477oig.3
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 13:52:25 -0700 (PDT)
In-Reply-To: <1508875962-39233-7-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 1:12 PM, Steve Lin <steven.lin1@broadcom.com> wrote:
> Implements get and set of configuration parameters using new devlink
> config get/set API.  Parameters themselves defined in later patches.
>
> Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
> Acked-by: Andy Gospodarek <gospo@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c | 262 +++++++++++++++++++++-
>  drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.h |  17 ++
>  drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 100 +++++++++
>  3 files changed, 373 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
> index f3f6aa8..81ab77e 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_devlink.c
> @@ -14,11 +14,261 @@
>  #include "bnxt_vfr.h"
>  #include "bnxt_devlink.h"
>
> -static const struct devlink_ops bnxt_dl_ops = {
> +struct bnxt_drv_cfgparam bnxt_drv_cfgparam_list[] = {
> +};
> +
> +#define BNXT_NUM_DRV_CFGPARAM ARRAY_SIZE(bnxt_drv_cfgparam_list)
> +
> +static int bnxt_nvm_read(struct bnxt *bp, int nvm_param, int idx,
> +                        void *buf, int size)
> +{
> +       struct hwrm_nvm_get_variable_input req = {0};
> +       dma_addr_t dest_data_dma_addr;
> +       void *dest_data_addr = NULL;
> +       int bytesize;
> +       int rc;
> +
> +       bytesize = (size + 7) / BITS_PER_BYTE;
> +       dest_data_addr = dma_alloc_coherent(&bp->pdev->dev, bytesize,
> +                                           &dest_data_dma_addr, GFP_KERNEL);
> +       if (!dest_data_addr) {
> +               netdev_err(bp->dev, "dma_alloc_coherent failure\n");
> +               return -ENOMEM;
> +       }
> +
> +       bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_NVM_GET_VARIABLE, -1, -1);
> +       req.dest_data_addr = cpu_to_le64(dest_data_dma_addr);
> +       req.data_len = cpu_to_le16(size);
> +       req.option_num = cpu_to_le16(nvm_param);
> +       req.index_0 = cpu_to_le16(idx);
> +       if (idx != 0)
> +               req.dimensions = cpu_to_le16(1);
> +
> +       rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);

This won't have the proper mutex protection.  You should call
hwrm_send_message() instead.
