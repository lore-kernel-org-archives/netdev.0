From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: Re: [PATCH] netdev: pktgen xmit packet through vlan interface
Date: Fri, 2 May 2014 22:55:55 +0800
Message-ID: <CAABZP2wG-DnmvAzSapaC1nEyg0ArET93tbz-x3-a71-pLd4ELA@mail.gmail.com>
References: <1399015092-28643-1-git-send-email-zhouzhouyi@gmail.com>
	<20140502151921.014fbeec@redhat.com>
	<5363A4E0.2000403@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@davemloft.net>,
	steffen.klassert@secunet.com, fan.du@windriver.com,
	dborkman@redhat.com, Mathias Krause <minipli@googlemail.com>,
	tgraf@suug.ch, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5363A4E0.2000403@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for reviewing

On Fri, May 2, 2014 at 10:00 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> On 5/2/2014 6:19 AM, Jesper Dangaard Brouer wrote:
>>
>> On Fri,  2 May 2014 15:18:12 +0800
>> Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
>>
>>> As http://www.spinics.net/lists/netdev/msg165015.html
>>> pktgen generates shared packet through vlan interface will cause
>>> oops because of duplicate entering tc queue.
>>>
>>> Try to solve this problem by means of packet clone instead of sharing.
>>
>>
>> I really don't like adding this stuff to the fast path of pktgen.


>>
>> Why would you use pktgen on a VLAN?

I use pktgen on a VLAN under a special circumstance.

>
>
> Its a good way to test qdiscs. When you run pktgen over the VLAN
> you exercise the lower devices qdisc.
>
> Although I never submitted a patch like this because I figured it
> was a corner case and we would want to keep the hotpath clean.
>

I think is_vlan_dev(odev) have great chances to be in a cache line
that seldom got reset. Could we only judge is_vlan_dev(odev) in my
first if statement?


Also I guess if (nskb && !IS_ERR(nskb)) happens in rarely reached
cases when the interface is not overload.

>
>>
>> Why don't you use the "vlan_id" feature available in pktgen, and send
>> in the lower real device?

Could we automatically convert the VLAN device's joining effort to
real device + vlan_id settings in pkt_dev.
or could we issue a warning or a suggestion
when user try to add a VLAN device to the pktgen thread?

>>
>>
>>
>>> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
>>> ---
>>>   net/core/pktgen.c |   20 +++++++++++++++++---
>>>   1 files changed, 17 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
>>> index 0304f98..ced07fc 100644
>>> --- a/net/core/pktgen.c
>>> +++ b/net/core/pktgen.c
>>> @@ -3297,6 +3297,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>>>         netdev_tx_t (*xmit)(struct sk_buff *, struct net_device *)
>>>                 = odev->netdev_ops->ndo_start_xmit;
>>>         struct netdev_queue *txq;
>>> +       struct sk_buff *nskb = NULL;
>>>         u16 queue_map;
>>>         int ret;
>>>
>>> @@ -3347,8 +3348,18 @@ static void pktgen_xmit(struct pktgen_dev
>>> *pkt_dev)
>>>                 pkt_dev->last_ok = 0;
>>>                 goto unlock;
>>>         }
>>> -       atomic_inc(&(pkt_dev->skb->users));
>>> -       ret = (*xmit)(pkt_dev->skb, odev);
>>> +
>>> +       if (pkt_dev->clone_skb && is_vlan_dev(odev)) {
>>> +               nskb = skb_clone(pkt_dev->skb, GFP_ATOMIC);
>>> +               ret = -ENOMEM;
>>> +               if (nskb)
>>> +                       ret = (*xmit)(nskb, odev);
>>> +               else
>>> +                       nskb = ERR_PTR(ret);
>>> +       } else {
>>> +               atomic_inc(&(pkt_dev->skb->users));
>>> +               ret = (*xmit)(pkt_dev->skb, odev);
>>> +       }
>>>
>>>         switch (ret) {
>>>         case NETDEV_TX_OK:
>>> @@ -3372,7 +3383,10 @@ static void pktgen_xmit(struct pktgen_dev
>>> *pkt_dev)
>>>         case NETDEV_TX_LOCKED:
>>>         case NETDEV_TX_BUSY:
>>>                 /* Retry it next time */
>>> -               atomic_dec(&(pkt_dev->skb->users));
>>> +               if (nskb && !IS_ERR(nskb))
>>> +                       kfree_skb(nskb);
>>> +               else
>>> +                       atomic_dec(&(pkt_dev->skb->users));
>>>                 pkt_dev->last_ok = 0;
>>>         }
>>>   unlock:
>>
>>
>>
>>
>
