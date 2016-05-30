From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Mon, 30 May 2016 23:41:22 +0200
Message-ID: <574CB382.7030102@gmx.de>
References: <20160518225529.GA18671@electric-eye.fr.zoreil.com>
 <573E2D0C.604@gmx.de> <20160520003145.GA22420@electric-eye.fr.zoreil.com>
 <20160521160910.GA14945@debian-dorm> <5740E82F.8040903@gmx.de>
 <20160522091742.GA8681@debian-dorm> <57419853.9050701@gmx.de>
 <20160522223659.GB5086@electric-eye.fr.zoreil.com> <5743A9DD.8010202@gmx.de>
 <5744EA24.7060806@gmx.de> <20160528064348.GA19649@debian-dorm>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, wxt@rock-chips.com,
	heiko@sntech.de, linux-rockchip@lists.infradead.org,
	netdev@vger.kernel.org, al.kochet@gmail.com
To: Shuyu Wei <wsy2220@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:63102 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161768AbcE3VmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2016 17:42:13 -0400
In-Reply-To: <20160528064348.GA19649@debian-dorm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shuyu,

On 28.05.2016 08:43, Shuyu Wei wrote:
> 
> After some stress testing, it worked well most of the time.
> But there is a chance that it may get stuck when I use 2 nc process
> to send TCP packects at full speed.  Only when a new rx packet 
> arrive can trigger it to run again. This happens only once per several
> hours. No problem in UDP mode.  I'm not sure if it's related to tx code in
> the driver.
> 

This sounds strange. One reason I could imagine for such an issue is that 
occassionally tx completion interrupts get lost: 
In this case skbs may not be freed (or be freed too late) which may result in a TCP
stream getting stuck, because each skb belongs to a socket and there is a limit for
the allowed number of skbs per socket. TCP would only proceed if the number of pending 
skbs falls under this limit again but since the tx completion irq is lost, the only thing 
that could trigger the tx completion handler is another irq, e.g for a received packet.
At least this could explain what you observed.

Did you see the same issues with the patch before (the one that, as you wrote,
survived a whole night of stress testing)?

Lino
