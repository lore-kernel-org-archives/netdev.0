From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Rework rx_work_todo
Date: Wed, 15 Jan 2014 14:45:19 +0000
Message-ID: <20140115144519.GO5698@zion.uk.xensource.com>
References: <1389727719-21439-1-git-send-email-zoltan.kiss@citrix.com>
 <20140115103707.GI5698@zion.uk.xensource.com>
 <52D67536.4030106@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:24016 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbaAOOpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:45:20 -0500
Content-Disposition: inline
In-Reply-To: <52D67536.4030106@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 11:47:02AM +0000, Zoltan Kiss wrote:
> On 15/01/14 10:37, Wei Liu wrote:
> >On Tue, Jan 14, 2014 at 07:28:39PM +0000, Zoltan Kiss wrote:
> >>The recent patch to fix receive side flow control (11b57f) solved the spinning
> >>thread problem, however caused an another one. The receive side can stall, if:
> >>- xenvif_rx_action sets rx_queue_stopped to false
> >>- interrupt happens, and sets rx_event to true
> >>- then xenvif_kthread sets rx_event to false
> >>
> >
> >If you mean "rx_work_todo" returns false.
> >
> >In this case
> >
> >(!skb_queue_empty(&vif->rx_queue) && !vif->rx_queue_stopped) || vif->rx_event;
> >
> >can still be true, can't it?
> Sorry, I should wrote rx_queue_stopped to true
> 

In this case, if rx_queue_stopped is true, then we're expecting frontend
to notify us, right?

rx_queue_stopped is set to true if we cannot make any progress to queue
packet into the ring. In that situation we can expect frontend will send
notification to backend after it goes through the backlog in the ring.
That means rx_event is set to true, and rx_work_todo is true again. So
the ring is actually not stalled in this case as well. Did I miss
something?

> >
> >>Also, through rx_event a malicious guest can force the RX thread to spin. This
> >>patch ditch that two variable, and rework rx_work_todo. If the thread finds it
> >
> >This seems to be a bigger problem. Can you elaborate?
> My mistake too. I forgot that rx_action set it to false, so it's not
> really a spinning. However the thread should still run
> xenvif_rx_action to figure out there is no space in the ring before
> it sets rx_event to false. In my patch we can quit earlier.
> 
> Zoli
