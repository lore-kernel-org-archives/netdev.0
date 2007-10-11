From: Moni Shoua <monis@voltaire.com>
Subject: Re: [PATCH] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Thu, 11 Oct 2007 16:48:13 +0200
Message-ID: <470E37AD.3070408@voltaire.com>
References: <11916151232222-git-send-email-fubar@us.ibm.com>	<470C200D.4010705@pobox.com> <470C2343.1020800@garzik.org>	<20071009.181246.41634534.davem@davemloft.net> <706.1191979132@death>	<470CF7E1.6060503@voltaire.com> <aday7eaddod.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ogerlitz@voltaire.com,
	netdev@vger.kernel.org, Moni Levy <monil@voltaire.com>
To: Roland Dreier <rdreier@cisco.com>, Jay Vosburgh <fubar@us.ibm.com>,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:44602 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752537AbXJKOsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 10:48:16 -0400
In-Reply-To: <aday7eaddod.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > I also ran a test for the code in the branch of 2.6.24 and found a problem.
>  > I see that ifconfig down doesn't return (for IPoIB interfaces) and it's stuck in napi_disable() in the kernel (any idea why?)
> 
> For what it's worth, I took the upstream 2.6.23 git tree and merged in
> Dave's latest net-2.6.24 tree and my latest for-2.6.24 tree and tried
> that.  I brought up an IPoIB interface, sent a few pings, and did
> ifconfig down, and it worked fine.
> 
> Can you try the same thing without the bonding patches to see if your
> setup works OK too?
> 
> Also can you give more details about what you do to get ifconfig down stuck?
> 
>  - R.

Without bonding ifconfig down works fine. 
It happens only when ib interfaces are slaves of a bonding device.
I thought before that the stuck is in napi_disable() but it's almost right.
I put prints before and after call to napi_disable and see that it is called twice.
I'll try to investigate in this direction.

ib0: stopping interface
ib0: before napi_disable
ib0: after napi_disable
ib0: downing ib_dev
ib0: All sends and receives done.
ib0: stopping interface
ib0: before napi_disable



There is also a dump of the kernel log after 'echo t > /proc/sysrq-trigger' (for ifconfig)

SysRq : Show State

ifconfig      S 0000000000000000     0  6311   6099
 ffff810034f49d18 0000000000000086 0000000000000000 ffffffffffffffff
 ffff810037e747c0 ffff810037e747c0 000000013481e000 ffff81003a851a78
 ffff81003a851840 000000003b0c8c00 0000000000000000 00000000802358ee
Call Trace:
 [<ffffffff8023cc89>] lock_timer_base+0x24/0x49
 [<ffffffff80403754>] schedule_timeout+0x8a/0xad
 [<ffffffff8023d241>] process_timeout+0x0/0x5
 [<ffffffff8023d6ec>] msleep_interruptible+0x11/0x39
 [<ffffffff884081a7>] :ib_ipoib:ipoib_stop+0x64/0x12c
 [<ffffffff8039fc07>] dev_close+0x3e/0x56
 [<ffffffff803a1c31>] dev_change_flags+0xa7/0x15f
 [<ffffffff803e5bee>] devinet_ioctl+0x293/0x5ed
 [<ffffffff803e775b>] inet_ioctl+0x7f/0x9d
 [<ffffffff80395b2e>] sock_ioctl+0x0/0x1fe
 [<ffffffff80395d08>] sock_ioctl+0x1da/0x1fe
 [<ffffffff802947d9>] do_ioctl+0x29/0x6f
 [<ffffffff80294a75>] vfs_ioctl+0x256/0x267
 [<ffffffff80294adf>] sys_ioctl+0x59/0x7a
 [<ffffffff8020bc0e>] system_call+0x7e/0x83


