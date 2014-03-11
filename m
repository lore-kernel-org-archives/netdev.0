From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC PATCH 0/2] remove netpoll rx support
Date: Tue, 11 Mar 2014 01:43:10 -0700
Message-ID: <87a9cxf7mp.fsf_-_@xmission.com>
References: <871ty9qvaf.fsf_-_@xmission.com> <87vbvlpgnk.fsf_-_@xmission.com>
	<1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311.004217.1616529960369263682.davem@davemloft.net>
	<1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:44166 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787AbaCKInR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 04:43:17 -0400
In-Reply-To: <1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Mon, 10 Mar 2014 22:02:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Tue, 2014-03-11 at 00:42 -0400, David Miller wrote:
>
>> These changes eminate from a recent discussion about netpoll, which can
>> call into the driver from hardware interrupts, particularly when netconsole
>> services a printk from hardware interrupt context.
>> 
>> bnx2x already makes similar ammends.
>> 
>> I hope that Eric B. here audited to make sure he's only doing this
>> transformation in situations that actually need this treatment for
>> the above mentioned issue.
>
> I totally understand the TX path, not the RX.
>
> It seems netpoll should not drain rx queues.

It does seem desirable that netpoll should not drain the rx queues.
Unfortunately that is not how netpoll is built.  By my quick count
there are 132 drivers in the kernel that support netpoll.

Several of them such as the e1000e driver already call dev_kfree_skb_any
or dev_kfree_skb_irq in their rx paths.  What I am implementing seems to
be the pattern that the better drivers follow today.

Furthermore netpoll by it's design depends on the ability to receive
packets in netpoll_poll_dev.  It is a capability I don't think we have
ever used in the mainline kernel but it is a capability that is there
deliberately.  Which means if we want netpoll to not mess with the rx
path we need to change netpoll.


If we are willing to change the definition of netpoll this is fixable.

The big enabler is the fact that calling the napi poll function with a
budget of 0 means don't perform any rx work.

Which leads to the following set of changes to netpoll if we are brave.

Eric W. Biederman (2):
      netpoll:  Remove dead netpoll_rx code
      netpoll: Don't poll for received packets

 drivers/net/Kconfig       |    5 -
 include/linux/netdevice.h |   17 --
 include/linux/netpoll.h   |   59 ------
 net/core/dev.c            |   11 +-
 net/core/netpoll.c        |  499 +--------------------------------------------
 5 files changed, 10 insertions(+), 581 deletions(-)

Eric
