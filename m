From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [patch] qlcnic: fix a timeout loop
Date: Tue, 15 Dec 2015 13:46:08 +0000
Message-ID: <BLUPR11MB0114ED16EBE57CC01FD9797393EE0@BLUPR11MB0114.namprd11.prod.outlook.com>
References: <20151215101618.GG20848@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20151215101618.GG20848@mwanda>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com
> [mailto:dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com] On Behalf
> Of Dan Carpenter
> Sent: Tuesday, December 15, 2015 3:46 PM
> To: Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>; Rajesh
> Borundia <rajesh.borundia@qlogic.com>
> Cc: netdev <netdev@vger.kernel.org>; kernel-janitors@vger.kernel.org
> Subject: [patch] qlcnic: fix a timeout loop
> 
> The problem here is that at the end of the loop we test for if
> idc->vnic_wait_limit is zero, but since idc->vnic_wait_limit-- is a
> post-op, it actually ends up set to (u8)-1.  I have fixed this by changing it to a
> pre-op.  I had to change the starting value from
> "QLCNIC_DEV_NPAR_OPER_TIMEO" (30) to "QLCNIC_DEV_NPAR_OPER_TIMEO
> + 1" so that we still loop the same number of times as before.
> 
> Fixes: 486a5bc77a4a ('qlcnic: Add support for 83xx suspend and resume.')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
> index be7d7a6..9919245 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
> @@ -234,7 +234,7 @@ int qlcnic_83xx_config_vnic_opmode(struct
> qlcnic_adapter *adapter)
>  	}
> 
>  	ahw->idc.vnic_state = QLCNIC_DEV_NPAR_NON_OPER;
> -	ahw->idc.vnic_wait_limit = QLCNIC_DEV_NPAR_OPER_TIMEO;
> +	ahw->idc.vnic_wait_limit = QLCNIC_DEV_NPAR_OPER_TIMEO + 1;
> 
>  	return 0;
>  }
> @@ -246,7 +246,7 @@ int qlcnic_83xx_check_vnic_state(struct qlcnic_adapter
> *adapter)
>  	u32 state;
> 
>  	state = QLCRDX(ahw, QLC_83XX_VNIC_STATE);
> -	while (state != QLCNIC_DEV_NPAR_OPER && idc->vnic_wait_limit--) {
> +	while (state != QLCNIC_DEV_NPAR_OPER && --idc->vnic_wait_limit) {
>  		msleep(1000);
>  		state = QLCRDX(ahw, QLC_83XX_VNIC_STATE);
>  	}

Hi Dan,
It looks bit odd incrementing 1 in QLCNIC_DEV_NPAR_OPER_TIMEO. Can't we just post increment inside the loop ?

ahw->idc.vnic_wait_limit = QLCNIC_DEV_NPAR_OPER_TIMEO;
while (state != QLCNIC_DEV_NPAR_OPER && idc->vnic_wait_limit) {
	idc->vnic_wait_limit--;
	-----;
	-----;
}

Thanks,
Manish 
 

