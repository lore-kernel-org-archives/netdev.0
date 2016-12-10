From: Jonathan Toppins <jtoppins@redhat.com>
Subject: Re: [PATCH V2 03/22] bnxt_re: register with the NIC driver
Date: Fri, 9 Dec 2016 19:03:21 -0500
Message-ID: <b2779a19-f7b8-9817-5103-eaee585f5630@redhat.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
 <1481266096-23331-4-git-send-email-selvin.xavier@broadcom.com>
Reply-To: jtoppins@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Selvin Xavier <selvin.xavier@broadcom.com>, dledford@redhat.com,
        linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33754 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751798AbcLJADX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Dec 2016 19:03:23 -0500
In-Reply-To: <1481266096-23331-4-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2016 01:47 AM, Selvin Xavier wrote:
> This patch handles the registration with bnxt_en driver. The driver registers
> with netdev notifier chain. Upon receiving NETDEV_REGISTER event, the driver
> in turn registers with bnxt_en driver.
> 	1. bnxt_en's ulp_probe function returns a structure that contains information
> 	   about the device and additional entry points.
> 	2. bnxt_en driver returns 'struct bnxt_eth_dev' that contains set of operation
> 	   vectors that RocE driver invokes later.
> 	3. bnxt_request_msix() allows the RoCE driver to specify the number of MSI-X
> 	   vectors that are needed.
> 	4. bnxt_send_fw_msg () can be used to send messages to the FW
> 	5. bnxt_register_async_events() can be used to register for async event
> 	   callbacks.
> 
> v2: Remove some sparse warning. Also, remove some unused code from unreg path.
> 
> Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
> Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
> Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
> Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
> ---
>  drivers/infiniband/hw/bnxtre/bnxt_re.h      |  48 +++
>  drivers/infiniband/hw/bnxtre/bnxt_re_main.c | 436 ++++++++++++++++++++++++++++
>  2 files changed, 484 insertions(+)
> 

[...]

>  #endif
> diff --git a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
> index ebe1c69..029824a 100644
> --- a/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
> +++ b/drivers/infiniband/hw/bnxtre/bnxt_re_main.c
> +
> +static int bnxt_re_ib_reg(struct bnxt_re_dev *rdev)
> +{
> +	int i, j, rc;
> +
> +	/* Registered a new RoCE device instance to netdev */
> +	rc = bnxt_re_register_netdev(rdev);
> +	if (rc) {
> +		pr_err("Failed to register with netedev: %#x\n", rc);
> +		return -EINVAL;
> +	}
> +	set_bit(BNXT_RE_FLAG_NETDEV_REGISTERED, &rdev->flags);
> +
> +	rc = bnxt_re_request_msix(rdev);
> +	if (rc) {
> +		pr_err("Failed to get MSI-X vectors: %#x\n", rc);
> +		rc = -EINVAL;
> +		goto fail;
> +	}
> +	set_bit(BNXT_RE_FLAG_GOT_MSIX, &rdev->flags);

Though this exit path looks correct (need to verify) once all patches
are applied, this looks incorrect if only considering this specific
patch. I think you need the following:

+ return 0;

> +
> +fail:
> +	bnxt_re_ib_unreg(rdev, true);
> +	return rc;
> +}
> +
