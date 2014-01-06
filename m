From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 1/2] macvlan: forbid L2 fowarding offload for macvtap
Date: Mon, 06 Jan 2014 15:54:21 +0800
Message-ID: <52CA612D.2000902@redhat.com>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com> <52CA5CDA.1020503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52CA5CDA.1020503@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/06/2014 03:35 PM, John Fastabend wrote:
> On 01/05/2014 07:21 PM, Jason Wang wrote:
>> L2 fowarding offload will bypass the rx handler of real device. This
>> will make
>> the packet could not be forwarded to macvtap device. Another problem
>> is the
>> dev_hard_start_xmit() called for macvtap does not have any
>> synchronization.
>>
>> Fix this by forbidding L2 forwarding for macvtap.
>>
>> Cc: John Fastabend <john.r.fastabend@intel.com>
>> Cc: Neil Horman <nhorman@tuxdriver.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>> ---
>>   drivers/net/macvlan.c |    5 ++++-
>>   1 files changed, 4 insertions(+), 1 deletions(-)
>>
>
> I must be missing something.
>
> The lower layer device should set skb->dev to the correct macvtap
> device on receive so that in netif_receive_skb_core() the macvtap
> handler is hit. Skipping the macvlan receive handler should be OK
> because the switching was done by the hardware. If I read macvtap.c
> correctly macvlan_common_newlink() is called with 'dev' where 'dev'
> is the macvtap device. Any idea what I'm missing? I guess I'll need
> to setup a macvtap test case.

Unlike macvlan, macvtap depends on rx handler on the lower device to
work. In this case macvlan_handle_frame() will call macvtap_receive().
So doing netif_receive_skb_core() for macvtap device directly won't work
since we need to forward the packet to userspace instead of kernel.

For net-next.git, it may work since commit
6acf54f1cf0a6747bac9fea26f34cfc5a9029523 let macvtap device register an
rx handler for itself.
>
> And what synchronization are you worried about on dev_hard_start_xmit()?
> In the L2 forwarding offload case macvlan_open() clears the NETIF_F_LLTX
> flag so HARD_TX_LOCK protects the driver txq. We might hit this warning
> in dev_queue_xmit() though,
>
>   net_crit_ratelimited("Virtual device %s asks to queue packet!\n",
>
> Perhaps we can remove it.

The problem is macvtap does not call dev_queue_xmit() for macvlan
device. It calls macvlan_start_xmit() directly from macvtap_get_user().
So HARD_TX_LOCK was not done for the txq.
>
>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>> index 60406b0..5360f73 100644
>> --- a/drivers/net/macvlan.c
>> +++ b/drivers/net/macvlan.c
>> @@ -338,6 +338,8 @@ static const struct header_ops
>> macvlan_hard_header_ops = {
>>       .cache_update    = eth_header_cache_update,
>>   };
>>
>> +static struct rtnl_link_ops macvlan_link_ops;
>> +
>>   static int macvlan_open(struct net_device *dev)
>>   {
>>       struct macvlan_dev *vlan = netdev_priv(dev);
>> @@ -353,7 +355,8 @@ static int macvlan_open(struct net_device *dev)
>>           goto hash_add;
>>       }
>>
>> -    if (lowerdev->features & NETIF_F_HW_L2FW_DOFFLOAD) {
>> +    if (lowerdev->features & NETIF_F_HW_L2FW_DOFFLOAD &&
>> +        dev->rtnl_link_ops == &macvlan_link_ops) {
>>           vlan->fwd_priv =
>>                 lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev,
>> dev);
>>
>>
>
>
