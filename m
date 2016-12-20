From: Weilong Chen <chenweilong@huawei.com>
Subject: Re: [PATCH net-next] ixgbevf: fix 'Etherleak' in ixgbevf
Date: Tue, 20 Dec 2016 19:50:30 +0800
Message-ID: <5c942aba-f7fb-ede6-b6a2-e591025f53a5@huawei.com>
References: <1481802034-77729-1-git-send-email-chenweilong@huawei.com>
 <CAKgT0UfA9VG4NQZLLxXvobtfp22yPpPssSM4Ge94KFa1RVnhyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        <wangkefeng.wang@huawei.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UfA9VG4NQZLLxXvobtfp22yPpPssSM4Ge94KFa1RVnhyg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thanks for you reply.
We test you patch, but the problem is still there, it seems do not work.

I'm not sure why ixgbe use the limit 17. The kenel use ETH_ZLEN (60) 
with out FCS. A lot of drivers such as e1000 use it. Any explaination?

Thanks.

On 2016/12/16 0:13, Alexander Duyck wrote:
> On Thu, Dec 15, 2016 at 3:40 AM, Weilong Chen <chenweilong@huawei.com> wrote:
>> Nessus report the vf appears to leak memory in network packets.
>> Fix this by padding all small packets manually.
>>
>> And the CVE-2003-0001.
>> https://ofirarkin.files.wordpress.com/2008/11/atstake_etherleak_report.pdf
>>
>> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
>> ---
>>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> index 6d4bef5..137a154 100644
>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> @@ -3654,6 +3654,13 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>>                 return NETDEV_TX_OK;
>>         }
>>
>> +       /* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
>> +        * packets may get corrupted during padding by HW.
>> +        * To WA this issue, pad all small packets manually.
>> +        */
>> +       if (eth_skb_pad(skb))
>> +               return NETDEV_TX_OK;
>> +
>
> So the patch description for this probably isn't correct.  It looks
> like the problem isn't leaking data it is the fact that the frames
> aren't being padded to prevent malicious events.  The only issue is
> the patch is padding by a bit too much.  I would recommend replacing
> this with the following from ixgbe:
>
>         /*
>          * The minimum packet size for olinfo paylen is 17 so pad the skb
>          * in order to meet this minimum size requirement.
>          */
>         if (skb_put_padto(skb, 17))
>                 return NETDEV_TX_OK;
>
>
>>         tx_ring = adapter->tx_ring[skb->queue_mapping];
>>
>>         /* need: 1 descriptor per page * PAGE_SIZE/IXGBE_MAX_DATA_PER_TXD,
>> --
>> 1.7.12
>>
>
> .
>
