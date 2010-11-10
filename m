From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [e1000e] BUG triggered when triggering LED blinking
Date: Wed, 10 Nov 2010 10:32:52 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1011101030130.14720@jbrandeb-desk1.amr.corp.intel.com>
References: <20101109083954.GB11829@mail.eitzenberger.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Holger Eitzenberger <holger@eitzenberger.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23981 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755351Ab0KJScx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 13:32:53 -0500
In-Reply-To: <20101109083954.GB11829@mail.eitzenberger.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 9 Nov 2010, Holger Eitzenberger wrote:

> Hi,
> 
> using e1000e driver version 1.2.10 and kernel version 2.6.32.24 I see
> the kernel go BUG() sporadically at the time 'ethtool -p eth0 3' comes
> back.
> 
> Network hardware is four times 'Intel Corporation 82583V Gigabit Network
> Connection' (0x8086:0x150c) on Atom N450.
> 
> kernel BUG at kernel/workqueue.c:287!

<snip>

> 
> The full trace is attached, it may become clearer from that.
> 
> After taking a look I think this may be caused by initializing
> adapter->led_blink_task several times in e1000_phys_id(), while possibly
> led_blink_task is running:
> 
> 	if ((hw->phy.type == e1000_phy_ife) ||
> 	    (hw->mac.type == e1000_pchlan) ||
> 	    (hw->mac.type == e1000_82574)) {
> 		INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
> 		if (!adapter->blink_timer.function) {
> 
> I can't reproduce it after moving it inside the following if block,
> but I'm not quite sure if this catches all races in there.  Especially
> the msleep_interruptible() may be too optimistic because it may
> actually not wait long enough.  Someone with more knowledge of the
> driver should take a look.

thanks for your investigation and troubleshooting.  I don't think it is 
correct at all to be calling INIT_WORK more than once.  In fact the 
INIT_WORK should just be moved into probe, and then e1000_phys_id should 
just do schedule_work.


