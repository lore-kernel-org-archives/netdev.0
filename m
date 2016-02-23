From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH net-next 0/3] Extend macvtap with multiple qdiscs
Date: Tue, 23 Feb 2016 10:38:02 +0800
Message-ID: <56CBC60A.1000404@redhat.com>
References: <1454901296-9915-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756769AbcBWCiL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 21:38:11 -0500
In-Reply-To: <1454901296-9915-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/08/2016 11:14 AM, Vladislav Yasevich wrote:
> This is an RFC series to extend macvtap with multiple qdisc.  Right now
> multiqueue macvtap setups suffer from lock contention.  Macvtap sets
> the queue index and thus gets a default qdisc allocated to it.  Since
> it later users dev_queue_xmit() call to the macvlan type device (so that
> we can packet captures and other filtering on macvtap itself) we end up
> with qdisc lock contention since what we have is multiple file descriptors
> writing to the same qdisc.
>
> With this series, the macvtap device now becomes a true multi-queue device
> that defaults to 1 queue.  Every time the user opens the device (this is
> how multiqueue macvtap is used), we update the number of real queues for
> the device.  When the user writes to the device, we record the queue index
> associted with the file descriptor to the skb, and that ends up translating
> to the device queue index.  This is one transmit only.  Receive side
> is left alone and will prefer skb hash if available. 
>
> Macvlan through this all is left with lockless transmit path.
>
> Thanks
> -vlad

A question is do we really want a qdisc for macvtap (and other pseudo
device)? If yes, the "problem" may not be specific to macvtap. Consider
you may get contention after place a qdisc on vlan device. If not,
probably a one line patch with IFF_NO_QUEUE is sufficient?

Thanks

>
> Vladislav Yasevich (3):
>   macvtap: mutiple qdiscs support
>   macvlan: add queue selection functionality
>   macvtap: Record the rx queue based on the user tap queue
>
>  drivers/net/macvlan.c | 20 ++++++++++++++++++++
>  drivers/net/macvtap.c | 19 +++++++++++++++++++
>  2 files changed, 39 insertions(+)
>
