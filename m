From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] tun/macvtap: limit the packets queued through
 rcvbuf
Date: Thu, 16 Jan 2014 14:03:38 +0800
Message-ID: <52D7763A.4040100@redhat.com>
References: <1389682387-28601-1-git-send-email-jasowang@redhat.com> <20140114082516.GB1101@redhat.com> <52D4F924.2040502@redhat.com> <20140114095219.GB2846@redhat.com> <52D60221.1060701@redhat.com> <20140115072104.GA32078@redhat.com> <52D7602F.8090800@redhat.com> <20140116054700.GC8915@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vlad Yasevich <vyasevic@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29997 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886AbaAPGFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 01:05:01 -0500
In-Reply-To: <20140116054700.GC8915@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2014 01:47 PM, Michael S. Tsirkin wrote:
> On Thu, Jan 16, 2014 at 12:29:35PM +0800, Jason Wang wrote:
>> On 01/15/2014 03:21 PM, Michael S. Tsirkin wrote:
>>> On Wed, Jan 15, 2014 at 11:36:01AM +0800, Jason Wang wrote:
>>>> On 01/14/2014 05:52 PM, Michael S. Tsirkin wrote:
>>>>> On Tue, Jan 14, 2014 at 04:45:24PM +0800, Jason Wang wrote:
>>>>>>> On 01/14/2014 04:25 PM, Michael S. Tsirkin wrote:
>>>>>>>>> On Tue, Jan 14, 2014 at 02:53:07PM +0800, Jason Wang wrote:
>>>>>>>>>>> We used to limit the number of packets queued through tx_queue_length. This
>>>>>>>>>>> has several issues:
>>>>>>>>>>>
>>>>>>>>>>> - tx_queue_length is the control of qdisc queue length, simply reusing it
>>>>>>>>>>>    to control the packets queued by device may cause confusion.
>>>>>>>>>>> - After commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523 ("macvtap: Add
>>>>>>>>>>>    support of packet capture on macvtap device."), an unexpected qdisc
>>>>>>>>>>>    caused by non-zero tx_queue_length will lead qdisc lock contention for
>>>>>>>>>>>    multiqueue deivce.
>>>>>>>>>>> - What we really want is to limit the total amount of memory occupied not
>>>>>>>>>>>    the number of packets.
>>>>>>>>>>>
>>>>>>>>>>> So this patch tries to solve the above issues by using socket rcvbuf to
>>>>>>>>>>> limit the packets could be queued for tun/macvtap. This was done by using
>>>>>>>>>>> sock_queue_rcv_skb() instead of a direct call to skb_queue_tail(). Also two
>>>>>>>>>>> new ioctl() were introduced for userspace to change the rcvbuf like what we
>>>>>>>>>>> have done for sndbuf.
>>>>>>>>>>>
>>>>>>>>>>> With this fix, we can safely change the tx_queue_len of macvtap to
>>>>>>>>>>> zero. This will make multiqueue works without extra lock contention.
>>>>>>>>>>>
>>>>>>>>>>> Cc: Vlad Yasevich<vyasevic@redhat.com>
>>>>>>>>>>> Cc: Michael S. Tsirkin<mst@redhat.com>
>>>>>>>>>>> Cc: John Fastabend<john.r.fastabend@intel.com>
>>>>>>>>>>> Cc: Stephen Hemminger<stephen@networkplumber.org>
>>>>>>>>>>> Cc: Herbert Xu<herbert@gondor.apana.org.au>
>>>>>>>>>>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>>>>>>>>> No, I don't think we can change userspace-visible behaviour like that.
>>>>>>>>>
>>>>>>>>> This will break any existing user that tries to control
>>>>>>>>> queue length through sysfs,netlink or device ioctl.
>>>>>>> But it looks like a buggy API, since tx_queue_len should be for qdisc
>>>>>>> queue length instead of device itself.
>>>>> Probably, but it's been like this since 2.6.x time.
>>>>> Also, qdisc queue is unused for tun so it seemed kind of
>>>>> reasonable to override tx_queue_len.
>>>>>
>>>>>>> If we really want to preserve the
>>>>>>> behaviour, how about using a new feature flag and change the behaviour
>>>>>>> only when the device is created (TUNSETIFF) with the new flag?
>>>>> OK this addresses the issue partially, but there's also an issue
>>>>> of permissions: tx_queue_len can only be changed if
>>>>> capable(CAP_NET_ADMIN). OTOH in your patch a regular user
>>>>> can change the amount of memory consumed per queue
>>>>> by calling TUNSETRCVBUF.
>>>> Yes, but we have the same issue for TUNSETSNDBUF.
>>> To an extent, but TUNSETSNDBUF is different. It limits how much device can queue
>>> *in the networking stack* but each queue in the stack is also
>>> limited, when we exceed that we star dropping packets.
>>> So while with infinite value (which is the default btw)
>>> you can keep host pretty busy, you will not be able to run
>>> it out of memory.
>>>
>>> The proposed TUNSETRCVBUF would keep configured amount
>>> of memory around indefinitely so you can run host out of memory.
>>>
>>> So assuming all this
>>> How about an ethtool or netlink command to configure this
>>> instead?
>>>
>> Ok, so we can add net admin check for before trying to set rcvbuf.
> No, in practice I think using ioctl for sndbuf was also a mistake.
> Applications have no idea what to set it to - you need to know what else
> is running on the system, after a while
> QEMU ended up setting it back to infinity otherwise things kept
> breaking.

Yes, but it's not the problem of ioctl itself.
> ethtool or netlink would not have this problem.
> Which of the two is preferable I'm not sure.
> I wonder what do management tools such as libvirt prefer.
>

Libvirt usually create file descriptor, so it can also use ioctl() to 
set sndbuf.
>> I
>> think it's better to use ioctl since we've already use it for
>> sndbuf. Using ethool means you need a dedicated new ethtool method
>> just for tuntap which seems sub-optimal.
>> Netlink looks better, but
>> we should also implement other ioctl also.
> I'm not sure what this last phrase means. Can you clarify pls?
>

Sure, I mean if we choose netlink, we'd better add other function such 
as sndbuf, persistent flag and so on. Consider lots of existed function 
were implemented through ioctl(), using it also for rcvbuf looks ok and 
can simplify the changes of userspace.
>>>>>>>>> Take a look at my patch in msg ID 20140109071721.GD19559@redhat.com
>>>>>>>>> which gives one way to set tx_queue_len to zero without
>>>>>>>>> breaking userspace.
>>>>>>> If I read the patch correctly, it will make no way for the user who
>>>>>>> really want to change the qdisc queue length for tun.
>>>>> Why would this matter?  As far as I can see qdisc queue is currently unused.
>>>>>
>>>> User may use qdisc to do port mirroring, bandwidth limitation, traffic
>>>> prioritization or more for a VM. So we do have users and maybe more
>>>> consider the case of vpn.
>>> Well it's not used by default at least.
>>> I remember that we discussed this previously actually.
>>>
>>> If all we want to do actually is utilize no_qdisc by default,
>>> we can simply use Eric's patch:
>>>
>>> http://article.gmane.org/gmane.linux.kernel/1279597
>>>
>>> and a similar patch for macvtap.
>>> I tried it at the time and it didn't seem to help performance
>>> at all, but a lot has changed since, in particular I didn't
>>> test mq.
>>>
>>> If you now have results showing how it's beneficial, pls post them.
>>>
>> I will have a test to see the difference.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
