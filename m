From: "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/4] qed: Add iWARP out of order support
Date: Wed, 20 Sep 2017 06:03:32 +0000
Message-ID: <CY1PR0701MB2012F515805B94D83D4CB2A788610@CY1PR0701MB2012.namprd07.prod.outlook.com>
References: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
 <1505841979-26365-3-git-send-email-Michal.Kalderon@cavium.com>,<20170919174511.GJ5788@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Elior, Ariel" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170919174511.GJ5788-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sent: Tuesday, September 19, 2017 8:45 PM
On Tue, Sep 19, 2017 at 08:26:17PM +0300, Michal Kalderon wrote:
>> iWARP requires OOO support which is already provided by the ll2
>> interface (until now was used only for iSCSI offload).
>> The changes mostly include opening a ll2 dedicated connection for
>> OOO and notifiying the FW about the handle id.
>>
>> Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>> ---
>>  drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 44 ++++++++++++++++++++++=
+++++++
>>  drivers/net/ethernet/qlogic/qed/qed_iwarp.h | 11 +++++++-
>>  drivers/net/ethernet/qlogic/qed/qed_rdma.c  |  7 +++--
>>  3 files changed, 59 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/e=
thernet/qlogic/qed/qed_iwarp.c
>> index 9d989c9..568e985 100644
>> --- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
>> +++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
>> @@ -41,6 +41,7 @@
>>  #include "qed_rdma.h"
>>  #include "qed_reg_addr.h"
>>  #include "qed_sp.h"
>> +#include "qed_ooo.h"
>>
>>  #define QED_IWARP_ORD_DEFAULT                32
>>  #define QED_IWARP_IRD_DEFAULT                32
>> @@ -119,6 +120,13 @@ static void qed_iwarp_cid_cleaned(struct qed_hwfn *=
p_hwfn, u32 cid)
>>       spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
>>  }
>>
>> +void qed_iwarp_init_fw_ramrod(struct qed_hwfn *p_hwfn,
>> +                           struct iwarp_init_func_params *p_ramrod)
>> +{
>> +     p_ramrod->ll2_ooo_q_index =3D RESC_START(p_hwfn, QED_LL2_QUEUE) +
>> +                                 p_hwfn->p_rdma_info->iwarp.ll2_ooo_han=
dle;
>> +}
>> +
>>  static int qed_iwarp_alloc_cid(struct qed_hwfn *p_hwfn, u32 *cid)
>>  {
>>       int rc;
>> @@ -1876,6 +1884,16 @@ static int qed_iwarp_ll2_stop(struct qed_hwfn *p_=
hwfn, struct qed_ptt *p_ptt)
>>               iwarp_info->ll2_syn_handle =3D QED_IWARP_HANDLE_INVAL;
>>       }
>>
>> +     if (iwarp_info->ll2_ooo_handle !=3D QED_IWARP_HANDLE_INVAL) {
>> +             rc =3D qed_ll2_terminate_connection(p_hwfn,
>> +                                               iwarp_info->ll2_ooo_hand=
le);
>> +             if (rc)
>> +                     DP_INFO(p_hwfn, "Failed to terminate ooo connectio=
n\n");
>
>What exactly will you do with this knowledge? Anyway you are not
>interested in return values of qed_ll2_terminate_connection function in
>this place and other places too.
>
>Why don't you handle EAGAIN returned from the qed_ll2_terminate_connection=
()?
>
>Thanks
Thanks for pointing this out, you're right we could have ignored the return=
 code, as there's
not much we can do at this point if it failed. But I still feel failures ar=
e worth knowing about,
and could help in analysis if they unexpectedly lead to another issue.
As for EAGAIN, it is very unlikely that we'll get this return code. Will co=
nsider adding generic
handling for this as a separate patch, as this currently isn't handled in a=
ny of the ll2 flows.
thanks,=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
