From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: [PATCH] netxen: sparse warning and ioctl bug fixes
Date: Wed, 6 Dec 2006 21:40:34 +0530
Message-ID: <200612062140.35176.amitkale@linsyssoft.com>
References: <20061205120717.2e362ddf@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@netxen.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:34952 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936067AbWLFQKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 11:10:25 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061205120717.2e362ddf@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

This patch looks good. 

ioctls: NetXen chip is far more generic and will eventually show a significant 
amount of functionality in different products. We need ioctl analysis for 
user level tools that can tell states of registers etc. Removing ioctls all 
together will make any analysis from userland extremely difficult.

Does anyone have ideas on improving this ioctl interface?

Thanks.
-Amit

On Wednesday 06 December 2006 01:37, Stephen Hemminger wrote:
> Fix sparse warnings and get rid of casts that hide misuse
> of __user pointers.  There were two real bugs here:
>   * ioctl was copying uninitialized stack om NETXEN_NIC_NAME
>   * ioctl was dereferencing a user pointer
>     in nettxen_nic_cmd_clear_stats.
>
> IMHO the ioctl usage in this driver is going to be more maintenance
> burden than useful. and should be removed.
>
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> ---
>  drivers/net/netxen/netxen_nic.h       |    5 +
>  drivers/net/netxen/netxen_nic_hdr.h   |  128
> +++++++++++++++++---------------- drivers/net/netxen/netxen_nic_init.c  |  
> 38 +++++-----
>  drivers/net/netxen/netxen_nic_ioctl.h |    2 -
>  drivers/net/netxen/netxen_nic_main.c  |   34 +++------
>  5 files changed, 99 insertions(+), 108 deletions(-)
>
> diff --git a/drivers/net/netxen/netxen_nic.h
> b/drivers/net/netxen/netxen_nic.h index d925053..f66ebe3 100644
> --- a/drivers/net/netxen/netxen_nic.h
> +++ b/drivers/net/netxen/netxen_nic.h
> @@ -916,9 +916,8 @@ void netxen_tso_check(struct netxen_adap
>  		      struct cmd_desc_type0 *desc, struct sk_buff *skb);
>  int netxen_nic_hw_resources(struct netxen_adapter *adapter);
>  void netxen_nic_clear_stats(struct netxen_adapter *adapter);
> -int
> -netxen_nic_do_ioctl(struct netxen_adapter *adapter, void *u_data,
> -		    struct netxen_port *port);
> +int netxen_nic_do_ioctl(struct netxen_adapter *adapter, void __user
> *u_data, +			struct netxen_port *port);
>  int netxen_nic_rx_has_work(struct netxen_adapter *adapter);
>  int netxen_nic_tx_has_work(struct netxen_adapter *adapter);
>  void netxen_watchdog_task(unsigned long v);
> diff --git a/drivers/net/netxen/netxen_nic_hdr.h
> b/drivers/net/netxen/netxen_nic_hdr.h index 72c6ec4..2461afc 100644
> --- a/drivers/net/netxen/netxen_nic_hdr.h
> +++ b/drivers/net/netxen/netxen_nic_hdr.h
> @@ -228,139 +228,139 @@ enum {
>  /*  This field defines CRB adr [31:20] of the agents */
>
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_MN	\
> -	((NETXEN_HW_H0_CH_HUB_ADR << 7) | NETXEN_HW_MN_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H0_CH_HUB_ADR << 7) | NETXEN_HW_MN_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PH	\
> -	((NETXEN_HW_H0_CH_HUB_ADR << 7) | NETXEN_HW_PH_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H0_CH_HUB_ADR << 7) | NETXEN_HW_PH_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_MS	\
> -	((NETXEN_HW_H0_CH_HUB_ADR << 7) | NETXEN_HW_MS_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H0_CH_HUB_ADR << 7) | NETXEN_HW_MS_CRB_AGT_ADR)
>
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PS	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_PS_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_PS_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SS	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SS_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SS_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_RPMX3	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_RPMX3_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_RPMX3_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_QMS	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_QMS_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_QMS_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SQS0	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SQGS0_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SQGS0_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SQS1	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SQGS1_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SQGS1_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SQS2	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SQGS2_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SQGS2_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SQS3	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SQGS3_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SQGS3_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_C2C0	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_C2C0_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_C2C0_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_C2C1	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_C2C1_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_C2C1_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_RPMX2	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_RPMX2_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_RPMX2_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_RPMX4	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_RPMX4_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_RPMX4_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_RPMX7	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_RPMX7_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_RPMX7_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_RPMX9	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_RPMX9_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_RPMX9_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SMB	\
> -	((NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SMB_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H1_CH_HUB_ADR << 7) | NETXEN_HW_SMB_CRB_AGT_ADR)
>
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_NIU	\
> -	((NETXEN_HW_H2_CH_HUB_ADR << 7) | NETXEN_HW_NIU_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H2_CH_HUB_ADR << 7) | NETXEN_HW_NIU_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_I2C0	\
> -	((NETXEN_HW_H2_CH_HUB_ADR << 7) | NETXEN_HW_I2C0_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H2_CH_HUB_ADR << 7) | NETXEN_HW_I2C0_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_I2C1	\
> -	((NETXEN_HW_H2_CH_HUB_ADR << 7) | NETXEN_HW_I2C1_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H2_CH_HUB_ADR << 7) | NETXEN_HW_I2C1_CRB_AGT_ADR)
>
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SRE	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_SRE_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_SRE_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_EG	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_EG_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_EG_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_RPMX0	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_RPMX0_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_RPMX0_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_QMN	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_QM_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_QM_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SQN0	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_SQG0_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_SQG0_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SQN1	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_SQG1_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_SQG1_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SQN2	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_SQG2_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_SQG2_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SQN3	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_SQG3_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_SQG3_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_RPMX1	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_RPMX1_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_RPMX1_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_RPMX5	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_RPMX5_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_RPMX5_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_RPMX6	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_RPMX6_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_RPMX6_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_RPMX8	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_RPMX8_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_RPMX8_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_CAS0	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_CAS0_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_CAS0_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_CAS1	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_CAS1_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_CAS1_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_CAS2	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_CAS2_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_CAS2_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_CAS3	\
> -	((NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_CAS3_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H3_CH_HUB_ADR << 7) | NETXEN_HW_CAS3_CRB_AGT_ADR)
>
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGNI	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGNI_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGNI_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGND	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGND_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGND_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGN0	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN0_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN0_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGN1	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN1_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN1_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGN2	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN2_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN2_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGN3	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN3_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN3_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGNC	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGNC_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGNC_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGR0	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGR0_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGR0_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGR1	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGR1_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGR1_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGR2	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGR2_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGR2_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGR3	\
> -	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGR3_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGR3_CRB_AGT_ADR)
>
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGSI	\
> -	((NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGSI_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGSI_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGSD	\
> -	((NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGSD_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGSD_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGS0	\
> -	((NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGS0_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGS0_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGS1	\
> -	((NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGS1_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGS1_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGS2	\
> -	((NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGS2_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGS2_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGS3	\
> -	((NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGS3_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGS3_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_PGSC	\
> -	((NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGSC_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H5_CH_HUB_ADR << 7) | NETXEN_HW_PEGSC_CRB_AGT_ADR)
>
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_CAM	\
> -	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_NCM_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_NCM_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_TIMR	\
> -	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_TMR_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_TMR_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_XDMA	\
> -	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_XDMA_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_XDMA_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_SN	\
> -	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_SN_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_SN_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_I2Q	\
> -	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_I2Q_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_I2Q_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_ROMUSB	\
> -	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_ROMUSB_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_ROMUSB_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_OCM0	\
> -	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_OCM0_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_OCM0_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_OCM1	\
> -	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_OCM1_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_OCM1_CRB_AGT_ADR)
>  #define NETXEN_HW_CRB_HUB_AGT_ADR_LPC	\
> -	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_LPC_CRB_AGT_ADR)
> +	(((u32)NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_LPC_CRB_AGT_ADR)
>
>  /*
>   * MAX_RCV_CTX : The number of receive contexts that are available on
> diff --git a/drivers/net/netxen/netxen_nic_init.c
> b/drivers/net/netxen/netxen_nic_init.c index 0dca029..042766e 100644
> --- a/drivers/net/netxen/netxen_nic_init.c
> +++ b/drivers/net/netxen/netxen_nic_init.c
> @@ -49,7 +49,7 @@ #define NETXEN_ADDR_ERROR ((unsigned lon
>
>  #define crb_addr_transform(name) \
>  	crb_addr_xform[NETXEN_HW_PX_MAP_CRB_##name] = \
> -	NETXEN_HW_CRB_HUB_AGT_ADR_##name << 20
> +		NETXEN_HW_CRB_HUB_AGT_ADR_##name << 20
>
>  #define NETXEN_NIC_XDMA_RESET 0x8000ff
>
> @@ -1168,18 +1168,15 @@ netxen_nic_clear_statistics(struct netxe
>  }
>
>  int
> -netxen_nic_do_ioctl(struct netxen_adapter *adapter, void *u_data,
> +netxen_nic_do_ioctl(struct netxen_adapter *adapter, void __user *u_data,
>  		    struct netxen_port *port)
>  {
>  	struct netxen_nic_ioctl_data data;
> -	struct netxen_nic_ioctl_data *up_data;
>  	int retval = 0;
>  	struct netxen_statistics netxen_stats;
>
> -	up_data = (void *)u_data;
> -
>  	DPRINTK(INFO, "doing ioctl for %p\n", adapter);
> -	if (copy_from_user(&data, (void __user *)up_data, sizeof(data))) {
> +	if (copy_from_user(&data, u_data, sizeof(data))) {
>  		/* evil user tried to crash the kernel */
>  		DPRINTK(ERR, "bad copy from userland: %d\n", (int)sizeof(data));
>  		retval = -EFAULT;
> @@ -1199,8 +1196,9 @@ netxen_nic_do_ioctl(struct netxen_adapte
>  		if ((retval = netxen_nic_hw_read_wx(adapter, data.off,
>  						    &(data.u), data.size)))
>  			goto error_out;
> -		if (copy_to_user
> -		    ((void __user *)&(up_data->u), &(data.u), data.size)) {
> +
> +		if (copy_to_user(u_data + offsetof(typeof(data), u),
> +				 &(data.u),  data.size)) {
>  			DPRINTK(ERR, "bad copy to userland: %d\n",
>  				(int)sizeof(data));
>  			retval = -EFAULT;
> @@ -1232,8 +1230,9 @@ netxen_nic_do_ioctl(struct netxen_adapte
>  							(u32 *) & (data.u));
>  			break;
>  		}
> -		if (copy_to_user
> -		    ((void __user *)&(up_data->u), &(data.u), data.size)) {
> +
> +		if (copy_to_user(u_data + offsetof(typeof(data), u),
> +				 &(data.u), data.size)) {
>  			DPRINTK(ERR, "bad copy to userland: %d\n",
>  				(int)sizeof(data));
>  			retval = -EFAULT;
> @@ -1264,26 +1263,24 @@ netxen_nic_do_ioctl(struct netxen_adapte
>  	case netxen_nic_cmd_get_stats:
>  		data.rv =
>  		    netxen_nic_fill_statistics(adapter, port, &netxen_stats);
> -		if (copy_to_user
> -		    ((void __user *)(up_data->ptr), (void *)&netxen_stats,
> -		     sizeof(struct netxen_statistics))) {
> +
> +		if (copy_to_user(data.ptr, &netxen_stats,
> +				 sizeof(struct netxen_statistics))) {
>  			DPRINTK(ERR, "bad copy to userland: %d\n",
>  				(int)sizeof(netxen_stats));
>  			retval = -EFAULT;
>  			goto error_out;
>  		}
> -		up_data->rv = data.rv;
>  		break;
>
>  	case netxen_nic_cmd_clear_stats:
>  		data.rv = netxen_nic_clear_statistics(adapter, port);
> -		up_data->rv = data.rv;
>  		break;
>
>  	case netxen_nic_cmd_get_version:
> -		if (copy_to_user
> -		    ((void __user *)&(up_data->u), NETXEN_NIC_LINUX_VERSIONID,
> -		     sizeof(NETXEN_NIC_LINUX_VERSIONID))) {
> +		if (copy_to_user(u_data + offsetof(typeof(data), u),
> +				 NETXEN_NIC_LINUX_VERSIONID,
> +				 sizeof(NETXEN_NIC_LINUX_VERSIONID))) {
>  			DPRINTK(ERR, "bad copy to userland: %d\n",
>  				(int)sizeof(data));
>  			retval = -EFAULT;
> @@ -1296,7 +1293,10 @@ netxen_nic_do_ioctl(struct netxen_adapte
>  		retval = -EOPNOTSUPP;
>  		goto error_out;
>  	}
> -	put_user(data.rv, (u16 __user *) (&(up_data->rv)));
> +
> +	put_user(data.rv,
> +		 &(((struct netxen_nic_ioctl_data __user *)u_data)->rv));
> +
>  	DPRINTK(INFO, "done ioctl for %p well.\n", adapter);
>
>        error_out:
> diff --git a/drivers/net/netxen/netxen_nic_ioctl.h
> b/drivers/net/netxen/netxen_nic_ioctl.h index 23e53ad..cefccf1 100644
> --- a/drivers/net/netxen/netxen_nic_ioctl.h
> +++ b/drivers/net/netxen/netxen_nic_ioctl.h
> @@ -58,7 +58,7 @@ struct netxen_nic_ioctl_data {
>  	u32 size;
>  	u32 rv;
>  	char u[64];
> -	void *ptr;
> +	void __user *ptr;
>  };
>
>  struct netxen_statistics {
> diff --git a/drivers/net/netxen/netxen_nic_main.c
> b/drivers/net/netxen/netxen_nic_main.c index 1cb662d..827336f 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -105,10 +105,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
>  	struct net_device *netdev = NULL;
>  	struct netxen_adapter *adapter = NULL;
>  	struct netxen_port *port = NULL;
> -	u8 *mem_ptr0 = NULL;
> -	u8 *mem_ptr1 = NULL;
> -	u8 *mem_ptr2 = NULL;
> -
> +	u8 __iomem *mem_ptr0, *mem_ptr1, *mem_ptr2;
>  	unsigned long mem_base, mem_len;
>  	int pci_using_dac, i, err;
>  	int ring;
> @@ -152,7 +149,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
>  	mem_ptr2 =
>  	    ioremap(mem_base + THIRD_PAGE_GROUP_START, THIRD_PAGE_GROUP_SIZE);
>
> -	if ((mem_ptr0 == 0UL) || (mem_ptr1 == 0UL) || (mem_ptr2 == 0UL)) {
> +	if (!mem_ptr0 || !mem_ptr1 || !mem_ptr2) {
>  		DPRINTK(1, ERR,
>  			"Cannot remap adapter memory aborting.:"
>  			"0 -> %p, 1 -> %p, 2 -> %p\n",
> @@ -1099,38 +1096,33 @@ #endif
>  static int
>  netxen_nic_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
>  {
> -	int err = 0;
> -	unsigned long nr_bytes = 0;
>  	struct netxen_port *port = netdev_priv(netdev);
>  	struct netxen_adapter *adapter = port->adapter;
> -	char dev_name[NETXEN_NIC_NAME_LEN];
>
>  	DPRINTK(INFO, "doing ioctl for %s\n", netdev->name);
>  	switch (cmd) {
>  	case NETXEN_NIC_CMD:
> -		err = netxen_nic_do_ioctl(adapter, (void *)ifr->ifr_data, port);
> +		return netxen_nic_do_ioctl(adapter, ifr->ifr_data, port);
>  		break;
>
>  	case NETXEN_NIC_NAME:
>  		DPRINTK(INFO, "ioctl cmd for NetXen\n");
>  		if (ifr->ifr_data) {
> -			sprintf(dev_name, "%s-%d", NETXEN_NIC_NAME_RSP,
> -				port->portnum);
> -			nr_bytes = copy_to_user((char *)ifr->ifr_data, dev_name,
> -						NETXEN_NIC_NAME_LEN);
> -			if (nr_bytes)
> -				err = -EIO;
> -
> +			char dev_name[NETXEN_NIC_NAME_LEN];
> +			memset(dev_name, 0, NETXEN_NIC_NAME_LEN);
> +			snprintf(dev_name, NETXEN_NIC_NAME_LEN,
> +				 "%s-%d", NETXEN_NIC_NAME_RSP, port->portnum);
> +
> +			if (copy_to_user(ifr->ifr_data, dev_name,
> +					 NETXEN_NIC_NAME_LEN))
> +				return -EFAULT;
>  		}
> -		break;
> +		return 0;
>
>  	default:
>  		DPRINTK(INFO, "ioctl cmd %x not supported\n", cmd);
> -		err = -EOPNOTSUPP;
> -		break;
> +		return -EOPNOTSUPP;
>  	}
> -
> -	return err;
>  }
>
>  static struct pci_driver netxen_driver = {
