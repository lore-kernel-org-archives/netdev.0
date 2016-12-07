From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: return value of skb_linearize should be handled in
 Linux kernel
Date: Wed, 7 Dec 2016 09:57:45 -0800
Message-ID: <CAM_iQpWPkUnMhNykQtg3fSh6-SnB893p0j6-m0E0fZUgTUBw0g@mail.gmail.com>
References: <1481008233-16777-1-git-send-email-zhouzhouyi@gmail.com>
 <CAM_iQpX0nA10tCzfZr_q5i6V2hWqfMUkvXdfo+Ro1TWHOEVi_A@mail.gmail.com> <CAABZP2w_YsXgzZ0tH=r3mnLUbVfpY8Xn3vk9XoS_Hq1r8aeNUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: faisal.latif@intel.com, dledford@redhat.com, sean.hefty@intel.com,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        QLogic-Storage-Upstream@qlogic.com, jejb@linux.vnet.ibm.com,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Johannes Thumshirn <jth@kernel.org>, jon.maloy@ericsson.com,
        ying.xue@windriver.com, David Miller <davem@davemloft.net>,
        linux-rdma@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-scsi@vger.kernel.org, fcoe-devel@open-fcoe.org,
        tipc-discussion@lists.sourceforge.net
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAABZP2w_YsXgzZ0tH=r3mnLUbVfpY8Xn3vk9XoS_Hq1r8aeNUQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 6, 2016 at 10:27 PM, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
> On Wed, Dec 7, 2016 at 1:02 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Mon, Dec 5, 2016 at 11:10 PM, Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
>>> index 2a653ec..ab787cb 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
>>> @@ -490,7 +490,11 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
>>>          */
>>>         if ((fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA) &&
>>>             (fctl & FC_FC_END_SEQ)) {
>>> -               skb_linearize(skb);
>>> +               int err = 0;
>>> +
>>> +               err = skb_linearize(skb);
>>> +               if (err)
>>> +                       return err;
>>
>>
>> You can reuse 'rc' instead of adding 'err'.
> rc here is meaningful for the length of data being ddped. If using rc
> here, a successful
> skb_linearize will assign rc to 0.

Right, I thought it returns 0 on success.


>>
>>
>>
>>>                 crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
>>>                 crc->fcoe_eof = FC_EOF_T;
>>>         }
>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> index fee1f29..4926d48 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>>> @@ -2173,8 +2173,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>>>                                 total_rx_bytes += ddp_bytes;
>>>                                 total_rx_packets += DIV_ROUND_UP(ddp_bytes,
>>>                                                                  mss);
>>> -                       }
>>> -                       if (!ddp_bytes) {
>>> +                       } else {
>>>                                 dev_kfree_skb_any(skb);
>>>                                 continue;
>>>                         }
>>
>>
>> This piece doesn't seem to be related.
> if ddp_bytes is negative there will be some error, I think the skb
> should not pass to upper layer.

You misunderstand my point, this return value is for ixgbe_fcoe_ddp()
not skb_linearize(), you need to make it a separate patch because this
patch, as in $subject, only fixes skb_linearize().
