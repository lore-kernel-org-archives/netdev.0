From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC V3 PATCH 4/6] tuntap: multiqueue support
Date: Thu, 28 Jun 2012 11:15:03 +0800
Message-ID: <4FEBCC37.707@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com> <20120625061018.6765.76633.stgit@amd-6168-8-1.englab.nay.redhat.com> <20120625082553.GC18229@redhat.com> <4FE94E39.6070305@redhat.com> <20120626115420.GD13108@redhat.com> <4FEAA149.5010306@redhat.com> <20120627082635.GB15406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: habanero@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com,
	tahm@linux.vnet.ibm.com, akong@redhat.com, davem@davemloft.net,
	shemminger@vyatta.com, mashirle@us.ibm.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120627082635.GB15406@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/27/2012 04:26 PM, Michael S. Tsirkin wrote:
> On Wed, Jun 27, 2012 at 01:59:37PM +0800, Jason Wang wrote:
>> On 06/26/2012 07:54 PM, Michael S. Tsirkin wrote:
>>> On Tue, Jun 26, 2012 at 01:52:57PM +0800, Jason Wang wrote:
>>>> On 06/25/2012 04:25 PM, Michael S. Tsirkin wrote:
>>>>> On Mon, Jun 25, 2012 at 02:10:18PM +0800, Jason Wang wrote:
>>>>>> This patch adds multiqueue support for tap device. This is done by abstracting
>>>>>> each queue as a file/socket and allowing multiple sockets to be attached to the
>>>>>> tuntap device (an array of tun_file were stored in the tun_struct). Userspace
>>>>>> could write and read from those files to do the parallel packet
>>>>>> sending/receiving.
>>>>>>
>>>>>> Unlike the previous single queue implementation, the socket and device were
>>>>>> loosely coupled, each of them were allowed to go away first. In order to let the
>>>>>> tx path lockless, netif_tx_loch_bh() is replaced by RCU/NETIF_F_LLTX to
>>>>>> synchronize between data path and system call.
>>>>> Don't use LLTX/RCU. It's not worth it.
>>>>> Use something like netif_set_real_num_tx_queues.
>>>>>
>>>> For LLTX, maybe it's better to convert it to alloc_netdev_mq() to
>>>> let the kernel see all queues and make the queue stopping and
>>>> per-queue stats eaiser.
>>>> RCU is used to handle the attaching/detaching when tun/tap is
>>>> sending and receiving packets which looks reasonalbe for me.
>>> Yes but do we have to allow this? How about we always ask
>>> userspace to attach to all active queues?
>> Attaching/detaching is a method to active/deactive a queue, if all
>> queues were kept attached, then we need other method or flag to mark
>> the queue as activateddeactived and still need to synchronize with
>> data path.
> This is what I am trying to say: use an interface flag for
> multiqueue. When it is set activate all queues attached.
> When unset deactivate all queues except the default one.
>
>
>>>> Not
>>>> sure netif_set_real_num_tx_queues() can help in this situation.
>>> Check it out.
>>>
>>>>>> The tx queue selecting is first based on the recorded rxq index of an skb, it
>>>>>> there's no such one, then choosing based on rx hashing (skb_get_rxhash()).
>>>>>>
>>>>>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>>>>> Interestingly macvtap switched to hashing first:
>>>>> ef0002b577b52941fb147128f30bd1ecfdd3ff6d
>>>>> (the commit log is corrupted but see what it
>>>>> does in the patch).
>>>>> Any idea why?
>>>>>
>>>>>> ---
>>>>>>   drivers/net/tun.c |  371 +++++++++++++++++++++++++++++++++--------------------
>>>>>>   1 files changed, 232 insertions(+), 139 deletions(-)
>>>>>>
>>>>>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>>>>>> index 8233b0a..5c26757 100644
>>>>>> --- a/drivers/net/tun.c
>>>>>> +++ b/drivers/net/tun.c
>>>>>> @@ -107,6 +107,8 @@ struct tap_filter {
>>>>>>   	unsigned char	addr[FLT_EXACT_COUNT][ETH_ALEN];
>>>>>>   };
>>>>>>
>>>>>> +#define MAX_TAP_QUEUES (NR_CPUS<    16 ? NR_CPUS : 16)
>>>>> Why the limit? I am guessing you copied this from macvtap?
>>>>> This is problematic for a number of reasons:
>>>>> 	- will not play well with migration
>>>>> 	- will not work well for a large guest
>>>>>
>>>>> Yes, macvtap needs to be fixed too.
>>>>>
>>>>> I am guessing what it is trying to prevent is queueing
>>>>> up a huge number of packets?
>>>>> So just divide the default tx queue limit by the # of queues.
>>>> Not sure,
>>>> another reasons I can guess:
>>>> - to prevent storing a large array of pointers in tun_struct or macvlan_dev.
>>> OK so with the limit of e.g. 1024 we'd allocate at most
>>> 2 pages of memory. This doesn't look too bad. 1024 is probably a
>>> high enough limit: modern hypervisors seem to support on the order
>>> of 100-200 CPUs so this leaves us some breathing space
>>> if we want to match a queue per guest CPU.
>>> Of course we need to limit the packets per queue
>>> in such a setup more aggressively. 1000 packets * 1000 queues
>>> * 64K per packet is too much.
>>>
>>>> - it may not be suitable to allow the number of virtqueues greater
>>>> than the number of physical queues in the card
>>> Maybe for macvtap, here we have no idea which card we
>>> are working with and how many queues it has.
>>>
>>>>> And by the way, for MQ applications maybe we can finally
>>>>> ignore tx queue altogether and limit the total number
>>>>> of bytes queued?
>>>>> To avoid regressions we can make it large like 64M/# queues.
>>>>> Could be a separate patch I think, and for a single queue
>>>>> might need a compatible mode though I am not sure.
>>>> Could you explain more about this?
>>>> Did you mean to have a total
>>>> sndbuf for all sockets that attached to tun/tap?
>>> Consider that we currently limit the # of
>>> packets queued at tun for xmit to userspace.
>>> Some limit is needed but # of packets sounds
>>> very silly - limiting the total memory
>>> might be more reasonable.
>>>
>>> In case of multiqueue, we really care about
>>> total # of packets or total memory, but a simple
>>> approximation could be to divide the allocation
>>> between active queues equally.
>> A possible method is to divce the TUN_READQ_SIZE by #queues, but
>> make it at least to be equal to the vring size (256).
> I would not enforce any limit actually.
> Simply divide by # of queues, and
> fail if userspace tries to attach>  queue size packets.
>
> With 1000 queues this is 64Mbyte worst case as is.
> If someone wants to allow userspace to drink
> 256 times as much that is 16Giga byte per
> single device, let the user tweak tx queue len.
>
>
>
>>> qdisc also queues some packets, that logic is
>>> using # of packets anyway. So either make that
>>> 1000/# queues, or even set to 0 as Eric once
>>> suggested.
>>>
>>>>>> +
>>>>>>   struct tun_file {
>>>>>>   	struct sock sk;
>>>>>>   	struct socket socket;
>>>>>> @@ -114,16 +116,18 @@ struct tun_file {
>>>>>>   	int vnet_hdr_sz;
>>>>>>   	struct tap_filter txflt;
>>>>>>   	atomic_t count;
>>>>>> -	struct tun_struct *tun;
>>>>>> +	struct tun_struct __rcu *tun;
>>>>>>   	struct net *net;
>>>>>>   	struct fasync_struct *fasync;
>>>>>>   	unsigned int flags;
>>>>>> +	u16 queue_index;
>>>>>>   };
>>>>>>
>>>>>>   struct tun_sock;
>>>>>>
>>>>>>   struct tun_struct {
>>>>>> -	struct tun_file		*tfile;
>>>>>> +	struct tun_file		*tfiles[MAX_TAP_QUEUES];
>>>>>> +	unsigned int            numqueues;
>>>>>>   	unsigned int 		flags;
>>>>>>   	uid_t			owner;
>>>>>>   	gid_t			group;
>>>>>> @@ -138,80 +142,159 @@ struct tun_struct {
>>>>>>   #endif
>>>>>>   };
>>>>>>
>>>>>> -static int tun_attach(struct tun_struct *tun, struct file *file)
>>>>>> +static DEFINE_SPINLOCK(tun_lock);
>>>>>> +
>>>>>> +/*
>>>>>> + * tun_get_queue(): calculate the queue index
>>>>>> + *     - if skbs comes from mq nics, we can just borrow
>>>>>> + *     - if not, calculate from the hash
>>>>>> + */
>>>>>> +static struct tun_file *tun_get_queue(struct net_device *dev,
>>>>>> +				      struct sk_buff *skb)
>>>>>>   {
>>>>>> -	struct tun_file *tfile = file->private_data;
>>>>>> -	int err;
>>>>>> +	struct tun_struct *tun = netdev_priv(dev);
>>>>>> +	struct tun_file *tfile = NULL;
>>>>>> +	int numqueues = tun->numqueues;
>>>>>> +	__u32 rxq;
>>>>>>
>>>>>> -	ASSERT_RTNL();
>>>>>> +	BUG_ON(!rcu_read_lock_held());
>>>>>>
>>>>>> -	netif_tx_lock_bh(tun->dev);
>>>>>> +	if (!numqueues)
>>>>>> +		goto out;
>>>>>>
>>>>>> -	err = -EINVAL;
>>>>>> -	if (tfile->tun)
>>>>>> +	if (numqueues == 1) {
>>>>>> +		tfile = rcu_dereference(tun->tfiles[0]);
>>>>> Instead of hacks like this, you can ask for an MQ
>>>>> flag to be set in SETIFF. Then you won't need to
>>>>> handle attach/detach at random times.
>>>> Consier user switch between a sq guest to mq guest, qemu would
>>>> attach or detach the fd which could not be expceted in kernel.
>>> Can't userspace keep it attached always, just deactivate MQ?
>>>
>>>>> And most of the scary num_queues checks can go away.
>>>> Even we has a MQ flag, userspace could still just attach one queue
>>>> to the device.
>>> I think we allow too much flexibility if we let
>>> userspace detach a random queue.
>> The point is to let tun/tap has the same flexibility as macvtap.
>> Macvtap allows add/delete queues at any time and it's very easy to
>> add detach/attach to macvtap. So we can easily use almost the same
>> ioctls to active/deactive a queue at any time for both tap and
>> macvtap.
> Yes but userspace does not do this in practice:
> it decides how many queues and just activates them all.

The problem here I think is:

- We export files descriptors to userspace, so any of the files could  
be closed at anytime which could not be expected.
- Easy to let tap and macvtap has the same ioctls.
>
>
[...]
