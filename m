From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] bnx2i: fix bnx2i driver to test for physical device
 support of iscsi early
Date: Wed, 8 Jun 2011 12:36:30 -0700
Message-ID: <20110608123630.22df20c8.randy.dunlap@oracle.com>
References: <1307561363-11677-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:35412 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755559Ab1FHThD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 15:37:03 -0400
In-Reply-To: <1307561363-11677-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  8 Jun 2011 15:29:23 -0400 Neil Horman wrote:


> ---
>  drivers/net/bnx2.c              |    2 +-
>  drivers/net/cnic.c              |   15 +++------------
>  drivers/scsi/bnx2i/bnx2i_init.c |   29 +++++++++++++++--------------
>  3 files changed, 19 insertions(+), 27 deletions(-)
> 

> diff --git a/drivers/scsi/bnx2i/bnx2i_init.c b/drivers/scsi/bnx2i/bnx2i_init.c
> index 1d24a28..263bc60 100644
> --- a/drivers/scsi/bnx2i/bnx2i_init.c
> +++ b/drivers/scsi/bnx2i/bnx2i_init.c
> @@ -163,21 +163,14 @@ void bnx2i_start(void *handle)
>  	struct bnx2i_hba *hba = handle;
>  	int i = HZ;
>  
> -	if (!hba->cnic->max_iscsi_conn) {
> -		printk(KERN_ALERT "bnx2i: dev %s does not support "
> -			"iSCSI\n", hba->netdev->name);
> +	/**

Just use /* here.

> +	 * We should never register devices that don't support iscsi
> +	 * (see bnx2i_init_one), so something is wrong if we try to
> +	 * to start an iscsi adapter on hardware wtih 0 supported
> +	 * iscsi connections
> +	 */
> +	BUG_ON(!hba->cnic->max_iscsi_conn);
>  
> -		if (test_bit(BNX2I_CNIC_REGISTERED, &hba->reg_with_cnic)) {
> -			mutex_lock(&bnx2i_dev_lock);
> -			list_del_init(&hba->link);
> -			adapter_count--;
> -			hba->cnic->unregister_device(hba->cnic, CNIC_ULP_ISCSI);
> -			clear_bit(BNX2I_CNIC_REGISTERED, &hba->reg_with_cnic);
> -			mutex_unlock(&bnx2i_dev_lock);
> -			bnx2i_free_hba(hba);
> -		}
> -		return;
> -	}
>  	bnx2i_send_fw_iscsi_init_msg(hba);
>  	while (!test_bit(ADAPTER_STATE_UP, &hba->adapter_state) && i--)
>  		msleep(BNX2I_INIT_POLL_TIME);


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
