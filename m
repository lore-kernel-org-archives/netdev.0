From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel behavior when returning NETDEV_TX_BUSY from
 hard_start_xmit
Date: Thu, 19 Feb 2009 13:26:57 -0800
Message-ID: <20090219132657.6df59e0e@extreme>
References: <587a3eeb0902191219r1c3e61dbkee1a5b45dceacc1b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tony Asleson <linux.netdev.list@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51619 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756403AbZBSV06 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2009 16:26:58 -0500
In-Reply-To: <587a3eeb0902191219r1c3e61dbkee1a5b45dceacc1b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Feb 2009 14:19:10 -0600
Tony Asleson <linux.netdev.list@gmail.com> wrote:

> I am running into the following scenario and I wanted to verify that it is
> expected.
> 
> A user application does a single 8k UDP send.  While the Ethernet device
> driver is accepting each skb via hard_start_xmit it temporarily runs out
> of resources and calls netif_stop_queue and returns NETDEV_TX_BUSY.

> When the driver catches up it does a netif_wake_queue to resume skb
> transmission.  When this occurs during the UDP send, the Ethernet driver
> does not get any of the remaining skb buffers and the UDP send is
> incomplete.  However, the user application returns from the sendto
> with success.
> 
> Because UDP has no guaranteed delivery this seems like an acceptable thing.
> However, if a device driver imposes a limit to the number of skb buffers
> it can handle in flight which is < the total number of skb buffers it takes
> to complete.  The operation will never be successful.
> 
> For example, to support a single 64k UDP send, the device driver must be
> able to accept ~45 skb buffers (1500 MTU) without returning NETDEV_TX_BUSY.
> If the Ethernet device is unable to transmit faster than the arrival rate
> of skb buffers the driver then needs to queue them up.
> 
> Is this expected behavior or am I missing something in my driver?  How
> much should a device driver be expected to queue before calling
> netif_stop_queue and ensure normal packet transmission?  Why doesn't
> the network stack continue after the queue has been stopped?
> 
> Notes:
> -Linux 2.6.16.21 kernel (sles 10) embedded PPC platform.
> -Pseudo Ethernet device in question has ~2.8 MiB bandwidth.


Well written drivers never return TX_BUSY. They manage the queue
such that it is stopped when there is no space and only woken up
when there is space.
