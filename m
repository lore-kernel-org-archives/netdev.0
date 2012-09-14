From: "Bhanu Prakash Gollapudi" <bprakash@broadcom.com>
Subject: Re: [RFC PATCH 4/5] bnx2fc: Use new fcoe_sysfs control
 interface
Date: Fri, 14 Sep 2012 00:28:54 -0700
Message-ID: <5052DCB6.4030704@broadcom.com>
References: <20120910225908.13140.97277.stgit@fritz>
 <20120910225930.13140.97949.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	linux-scsi@vger.kernel.org, devel@open-fcoe.org
To: "Robert Love" <robert.w.love@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2149 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756468Ab2INH3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 03:29:08 -0400
In-Reply-To: <20120910225930.13140.97949.stgit@fritz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2012 03:59 PM, Robert Love wrote:
> Convert	bnx2fc to use the new fcoe_sysfs create, delete,
> enable, disable, start and mode.
>
> bnx2fc doesn't support VN2VN. bnx2fc will not initialize
> the set_fcoe_ctlr_mode routine and therefore its instances
> will always be in FABRIC mode. There was previously an
> explicit check for the ctlr's mode, but this is no longer
> needed because not implementing set_fcoe_ctlr_mode implies
> that the ctlr cannot change from the FABRIC mode.
>
> Signed-off-by: Robert Love <robert.w.love@intel.com>
> ---
>   drivers/scsi/bnx2fc/bnx2fc_fcoe.c |   98 +++++++++++++++++++++++--------------
>   1 file changed, 60 insertions(+), 38 deletions(-)
>
> diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
> index f52f668f..560c8c8 100644
> --- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
> +++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
<snip>

>   /**
> + * bnx2fc_alloc - Alocate a bnx2fc FCoE interface
> + *
> + * @cdev: The FCoE Controller Device to start
> + *
> + * Called from sysfs.
> + *
> + * Returns: 0 for success
> + */
> +static int bnx2fc_start(struct fcoe_ctlr_device *cdev)
> +{
> +	struct fcoe_ctlr *ctlr = fcoe_ctlr_device_priv(cdev);
> +	struct fc_lport *lport = ctlr->lp;
> +	struct fcoe_port *port = lport_priv(lport);
> +	struct bnx2fc_interface *interface = port->priv;
> +
> +	lport->boot_time = jiffies;
> +
> +	/* Make this master N_port */
> +	ctlr->lp = lport;

ctlr->lp should be set in bnx2fc_alloc() as we access it here in the 
beginning of this function.

> +
> +	if (!bnx2fc_link_ok(lport)) {
> +		fcoe_ctlr_link_up(ctlr);
> +		fc_host_port_type(lport->host) = FC_PORTTYPE_NPORT;
> +		set_bit(ADAPTER_STATE_READY, &interface->hba->adapter_state);
> +	}
> +
> +	BNX2FC_HBA_DBG(lport, "create: START DISC\n");
> +	bnx2fc_start_disc(interface);
I think more changes are required for bnx2fc as fc_lport_init() is 
called just before calling fc_fabric_login() - whcih is called during 
'start'. Because of this, if we just call 'create' followed by 'destroy' 
without calling 'start', lport is not initialized and I expect to see 
some panics when destroy is called.

Let me try testing your patches and send you any fixes that are required.

> +	interface->enabled = true;
> +
> +	return 0;
> +}
> +
> +/**
>    * bnx2fc_find_hba_for_cnic - maps cnic instance to bnx2fc hba instance
>    *
>    * @cnic:	Pointer to cnic device instance
> @@ -2271,10 +2292,8 @@ static struct fcoe_transport bnx2fc_transport = {
>   	.attached = false,
>   	.list = LIST_HEAD_INIT(bnx2fc_transport.list),
>   	.match = bnx2fc_match,
> -	.create = bnx2fc_create,
> +	.alloc = bnx2fc_alloc,
>   	.destroy = bnx2fc_destroy,
> -	.enable = bnx2fc_enable,
> -	.disable = bnx2fc_disable,
>   };
>   
>   /**
> @@ -2514,6 +2533,9 @@ module_init(bnx2fc_mod_init);
>   module_exit(bnx2fc_mod_exit);
>   
>   static struct fcoe_sysfs_function_template bnx2fc_fcoe_sysfs_templ = {
> +	.set_fcoe_ctlr_start = bnx2fc_start,
> +	.set_fcoe_ctlr_enable = bnx2fc_enable,
> +	.set_fcoe_ctlr_disable = bnx2fc_disable,
>   	.get_fcoe_ctlr_mode = fcoe_ctlr_get_fip_mode,
>   	.get_fcoe_ctlr_link_fail = bnx2fc_ctlr_get_lesb,
>   	.get_fcoe_ctlr_vlink_fail = bnx2fc_ctlr_get_lesb,
>
>
