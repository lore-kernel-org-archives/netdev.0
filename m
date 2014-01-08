From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net 1/2] macvlan: forbid L2 fowarding offload for macvtap
Date: Wed, 08 Jan 2014 11:05:42 -0800
Message-ID: <52CDA186.1080601@gmail.com>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com> <52CA5CDA.1020503@gmail.com> <52CA612D.2000902@redhat.com> <20140106122628.GA24280@hmsreliant.think-freely.org> <52CB7009.2030903@redhat.com> <52CB8D54.9090506@gmail.com> <52CB9D1A.1050101@redhat.com> <52CBAC2A.90005@intel.com> <52CBC22D.3050002@redhat.com> <20140108125528.GC14741@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:52734 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbaAHTGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 14:06:10 -0500
In-Reply-To: <20140108125528.GC14741@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>> OK I think I'm finally putting all the pieces together thanks.
>>>
>>> Do you know why macvtap is setting dev->tx_queue_len by default? If you
>>> zero this then the noqueue_qdisc is used and the q->enqueue check in
>>> dev_queue_xmit will fail.
>>
>> It was introduced in commit 8a35747a5d13b99e076b0222729e0caa48cb69b6
>> ("macvtap: Limit packet queue length") to limit the length of socket
>> receive queue of macvtap. But I'm not sure whether the qdisc is a
>> byproduct of this commit, maybe we can switch to use another name
>> instead of just reuse dev->tx_queue_length.
>
> You mean tx_queue_len really, right?
>
> Problem is tx_queue_len can be accessed using netlink sysfs or ioctl,
> so if someone uses these to control or check the # of packets that
> can be queued by device, this will break.
>
> How about adding ndo_set_tx_queue_len then?
>
> At some point we wanted to decouple queue length from tx_queue_length
> for tun as well, so that would be benefitial there as well.

On the receive side we need to limit the receive queue and the
dev->tx_queue_len value was used to do this.

However on the tx side when dev->tx_queue_len is set the default
qdisc pfifo_fast or mq is used depending on if there is multiqueue
or not. Unless the user specifies some numtxqueues when creating
the macvtap device then it will be a single queue device and use
the pfifo_fast qdisc.

This is the default behaviour users could zero txqueuelen when
they create the device because it is a stacked device with
NETIF_F_LLTX using the lower devices qdisc makes sense but this
would appear (from code inspection) to break macvtap_forward()?

         if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
                 goto drop;

I'm not sure any of this is a problem other than its a bit
confusing to overload tx_queue_len for the rx_queue_len but the
precedent has been there for sometime. It is a change in behaviour
though in net-next. Previously dev_queue_xmit() was not used so
the qdisc layer was never hit on the macvtap device. Now with
dev_queue_xmit() if the user attaches multiple macvlan queues to a
single qdisc queue this should still work but wont be optimal. Ideally
the user should create as many qdisc queues at creation time via
numtxqueues as macvtap queues will be used during runtime so that there
is a 1:1 mapping or use some heuristic to avoid cases where there
is a many to 1 mapping.

 From my perspective it would be OK to push this configuration/policy
to the management layer. After all it is the entity that knows how
to distribute system resources amongst the objects running over the
macvtap devices. The relevance for me is I defaulted the l2 offloaded
macvlans to single queue devices and wanted to note in net-next this
is the same policy used in the non-offloaded case.

Bit long-winded there.

Thanks,
John
