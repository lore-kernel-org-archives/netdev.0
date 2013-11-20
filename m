From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] packet: fix use after free race in send path when
 dev is released
Date: Wed, 20 Nov 2013 09:30:17 +0100
Message-ID: <528C7319.5050309@redhat.com>
References: <1384902503-1588-1-git-send-email-dborkman@redhat.com> <20131119.203451.358808893783927503.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, noureddine@aristanetworks.com,
	greearb@candelatech.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60067 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330Ab3KTIaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 03:30:24 -0500
In-Reply-To: <20131119.203451.358808893783927503.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/20/2013 02:34 AM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Wed, 20 Nov 2013 00:08:23 +0100
>
>> To avoid reverting 827d9780 entirely, we could make use of po->running
>> member that gets reset when we're calling __unregister_prot_hook() in
>> packet_notifier() when we receive NETDEV_DOWN or NETDEV_UNREGISTER
>> notification. Plus, we still need to hold ref to the netdev, so
>> that we can assure it won't be released while we're in send path.
>
> The avoidance of the atomic ref counting of the network device is the
> main performance gain we get from that commit.
>
> Now we'll be doing the refcount _and_ taking a spinlock, it'll be
> worse than beforehand.
>
> And this is doubly silly because we already have a reference
> when we install the device into po->prot_hook.dev
>
> I bet you can fix this by just deferring the NETDEV_UNREGISTER
> AF_PACKET notifier work to RCU.

Yep, will try if this approach works, in other words doing the earlier
exit via !po->running, plus deferring the dev_put() et al to RCU.
