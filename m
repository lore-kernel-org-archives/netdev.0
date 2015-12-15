From: walter harms <wharms@bfs.de>
Subject: Re: [patch] qlcnic: fix a timeout loop
Date: Tue, 15 Dec 2015 17:35:45 +0100
Message-ID: <56704161.6040901@bfs.de>
References: <20151215101618.GG20848@mwanda> <BLUPR11MB0114ED16EBE57CC01FD9797393EE0@BLUPR11MB0114.namprd11.prod.outlook.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Manish Chopra <manish.chopra@qlogic.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <BLUPR11MB0114ED16EBE57CC01FD9797393EE0@BLUPR11MB0114.namprd11.prod.outlook.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 15.12.2015 14:46, schrieb Manish Chopra:
>> -----Original Message-----
>> From: dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com
>> [mailto:dept_hsg_linux_nic_dev-bounces@qlclistserver.qlogic.com] On Behalf
>> Of Dan Carpenter
>> Sent: Tuesday, December 15, 2015 3:46 PM
>> To: Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>; Rajesh
>> Borundia <rajesh.borundia@qlogic.com>
>> Cc: netdev <netdev@vger.kernel.org>; kernel-janitors@vger.kernel.org
>> Subject: [patch] qlcnic: fix a timeout loop
>>
>> The problem here is that at the end of the loop we test for if
>> idc->vnic_wait_limit is zero, but since idc->vnic_wait_limit-- is a
>> post-op, it actually ends up set to (u8)-1.  I have fixed this by changing it to a
>> pre-op.  I had to change the starting value from
>> "QLCNIC_DEV_NPAR_OPER_TIMEO" (30) to "QLCNIC_DEV_NPAR_OPER_TIMEO
>> + 1" so that we still loop the same number of times as before.
>>
>> Fixes: 486a5bc77a4a ('qlcnic: Add support for 83xx suspend and resume.')
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>
>> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
>> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
>> index be7d7a6..9919245 100644
>> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
>> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
>> @@ -234,7 +234,7 @@ int qlcnic_83xx_config_vnic_opmode(struct
>> qlcnic_adapter *adapter)
>>  	}
>>
>>  	ahw->idc.vnic_state = QLCNIC_DEV_NPAR_NON_OPER;
>> -	ahw->idc.vnic_wait_limit = QLCNIC_DEV_NPAR_OPER_TIMEO;
>> +	ahw->idc.vnic_wait_limit = QLCNIC_DEV_NPAR_OPER_TIMEO + 1;
>>
>>  	return 0;
>>  }
>> @@ -246,7 +246,7 @@ int qlcnic_83xx_check_vnic_state(struct qlcnic_adapter
>> *adapter)
>>  	u32 state;
>>
>>  	state = QLCRDX(ahw, QLC_83XX_VNIC_STATE);
>> -	while (state != QLCNIC_DEV_NPAR_OPER && idc->vnic_wait_limit--) {
>> +	while (state != QLCNIC_DEV_NPAR_OPER && --idc->vnic_wait_limit) {
>>  		msleep(1000);
>>  		state = QLCRDX(ahw, QLC_83XX_VNIC_STATE);
>>  	}
> 
> Hi Dan,
> It looks bit odd incrementing 1 in QLCNIC_DEV_NPAR_OPER_TIMEO. Can't we just post increment inside the loop ?
> 
> ahw->idc.vnic_wait_limit = QLCNIC_DEV_NPAR_OPER_TIMEO;
> while (state != QLCNIC_DEV_NPAR_OPER && idc->vnic_wait_limit) {
> 	idc->vnic_wait_limit--;
> 	-----;
> 	-----;
> }
> 
> Thanks,
> Manish 


Hi Manish,
i would like to ask an other question. Why do you choose this way ?
Basicly you have a
#define QLCNIC_DEV_NPAR_OPER_TIMEO
idc->vnic_wait_limit=QLCNIC_DEV_NPAR_OPER_TIMEO;
while ( ... --idc->vnic_wait_limit)

Do you need the time it took to chance the state ?

Look at Dan patches, there is a whole list that shows that programmers are
terrible at counting backwarts. Maybe it is possible to change the code into
something like

while (  cnt++ < idc->vnic_wait_limit)

this way you have a flexible limit, and it is better to understand for others
what you want to archive.

just my 2 cents,
re,
 wh






>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
