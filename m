From: "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 net-next 06/12] qed: Add LL2 slowpath handling
Date: Tue, 3 Oct 2017 19:48:53 +0000
Message-ID: <CY1PR0701MB201219AAD4C8C91B7D132D6688720@CY1PR0701MB2012.namprd07.prod.outlook.com>
References: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
 <1507020902-4952-7-git-send-email-Michal.Kalderon@cavium.com>,<20171003132632.GB25829@mtr-leonro.local>
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
In-Reply-To: <20171003132632.GB25829-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sent: Tuesday, October 3, 2017 4:26 PM

>On Tue, Oct 03, 2017 at 11:54:56AM +0300, Michal Kalderon wrote:
>> For iWARP unaligned MPA flow, a slowpath event of flushing an
>> MPA connection that entered an unaligned state is required.
>> The flush ramrod is received on the ll2 queue, and a pre-registered
>> callback function is called to handle the flush event.
>>
>> Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>> ---
>>  drivers/net/ethernet/qlogic/qed/qed_ll2.c | 40 ++++++++++++++++++++++++=
+++++--
>>  include/linux/qed/qed_ll2_if.h            |  5 ++++
>>  2 files changed, 43 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/eth=
ernet/qlogic/qed/qed_ll2.c
>> index 8eb9645..047f556 100644
>> --- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
>> +++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
>> @@ -423,6 +423,41 @@ static void qed_ll2_rxq_parse_reg(struct qed_hwfn *=
p_hwfn,
>>  }
>>
>>  static int
>> +qed_ll2_handle_slowpath(struct qed_hwfn *p_hwfn,
>> +                     struct qed_ll2_info *p_ll2_conn,
>> +                     union core_rx_cqe_union *p_cqe,
>> +                     unsigned long *p_lock_flags)
>> +{
>> +     struct qed_ll2_rx_queue *p_rx =3D &p_ll2_conn->rx_queue;
>> +     struct core_rx_slow_path_cqe *sp_cqe;
>> +
>> +     sp_cqe =3D &p_cqe->rx_cqe_sp;
>> +     if (sp_cqe->ramrod_cmd_id !=3D CORE_RAMROD_RX_QUEUE_FLUSH) {
>> +             DP_NOTICE(p_hwfn,
>> +                       "LL2 - unexpected Rx CQE slowpath ramrod_cmd_id:=
%d\n",
>> +                       sp_cqe->ramrod_cmd_id);
>> +             return -EINVAL;
>> +     }
>> +
>> +     if (!p_ll2_conn->cbs.slowpath_cb) {
>> +             DP_NOTICE(p_hwfn,
>> +                       "LL2 - received RX_QUEUE_FLUSH but no callback w=
as provided\n");
>> +             return -EINVAL;
>> +     }
>> +
>> +     spin_unlock_irqrestore(&p_rx->lock, *p_lock_flags);
>
>Interesting, you are unlock the lock which was taken in upper layer.
>It is not actual error, but chances to have such error are pretty high
>(for example, after refactoring).

Thanks. Ensuring that the lock will only be unlocked inside the calling fun=
ction would make=20
the calling function long and less readable.
The risk exists, but I think the fact that p_lock_flags is passed as parame=
ter should=20
give a strong indication in the future that lock should be handled delicate=
ly. =
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
