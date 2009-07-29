From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH] cnic: Fix ISCSI_KEVENT_IF_DOWN message handling.
Date: Wed, 29 Jul 2009 02:50:31 -0500
Message-ID: <4A6FFF47.1040107@cs.wisc.edu>
References: <1248318115-14214-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, James.Bottomley@HansenPartnership.com,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1248318115-14214-1-git-send-email-mchan@broadcom.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> When a net device goes down or when the bnx2i driver is unloaded,
> the code was not generating the ISCSI_KEVENT_IF_DOWN message
> properly and this could cause the userspace driver to crash.
> 
> This is fixed by sending the message properly in the shutdown path.
> cnic_uio_stop() is also added to send the message when bnx2i is
> unregistering.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/cnic.c |   23 +++++++++++++++++++++--
>  1 files changed, 21 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
> index 4d1515f..4869d77 100644
> --- a/drivers/net/cnic.c
> +++ b/drivers/net/cnic.c
> @@ -227,7 +227,7 @@ static int cnic_send_nlmsg(struct cnic_local *cp, u32 type,
>  	}
>  
>  	rcu_read_lock();
> -	ulp_ops = rcu_dereference(cp->ulp_ops[CNIC_ULP_ISCSI]);
> +	ulp_ops = rcu_dereference(cnic_ulp_tbl[CNIC_ULP_ISCSI]);
>  	if (ulp_ops)
>  		ulp_ops->iscsi_nl_send_msg(cp->dev, msg_type, buf, len);
>  	rcu_read_unlock();
> @@ -319,6 +319,20 @@ static int cnic_abort_prep(struct cnic_sock *csk)
>  	return 0;
>  }
>  
> +static void cnic_uio_stop(void)
> +{
> +	struct cnic_dev *dev;
> +
> +	read_lock(&cnic_dev_lock);
> +	list_for_each_entry(dev, &cnic_dev_list, list) {
> +		struct cnic_local *cp = dev->cnic_priv;
> +
> +		if (cp->cnic_uinfo)
> +			cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);

I don't think you can call this with the cnic_dev_lock held. They have 
the same sleeping restrictions as a spin_lock right? If so, the problem 
is that iscsi_nl_send_ms calls iscsi_offload_mesg which uses GFP_NOIO 
and can sleep.
