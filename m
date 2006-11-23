From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 06/06]: Fix endless loops (part 4): HTB
Date: Thu, 23 Nov 2006 10:48:40 +0100
Message-ID: <45656E78.6070108@trash.net>
References: <20061123083909.GA1586@ff.dom.local> <45655F54.2020501@trash.net> <20061123090113.GB1586@ff.dom.local> <456564D4.9010302@trash.net> <45656AAB.3080903@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:11666 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1757300AbWKWJsp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 04:48:45 -0500
To: Martin Devera <devik@cdi.cz>
In-Reply-To: <45656AAB.3080903@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Devera wrote:
>> In htb_graft it was necessary because the class could be
>> either active (qlen > 0) or inactive (qlen == 0). But since
>> qdisc_tree_decrease_qlen does nothing in case of a decrease
>> of zero the callback is only called for active classes and
>> the check becomes unnecessary.
>>
> 
> Patrick is right here. prio_activity for leaf is set in htb's enqueue
> routines. The qlen callback is called when len changed and because
> that zero test in htb's callback it is sure the subclass was nonempty
> before.

BTW, I plan to remove the check for empty child qdiscs in
htb_dequeue_tree and the check for prio_activity after the
calls to qdisc_tree_decrease_len in htb_change_class as a
follow-up patch in 2.6.20, for now I kept them to be safe.

> The only problem might be if some subqdisc "creates" new packets,
> then htb might deactivate non-active class (leading to BUG()).
> IIRC no qdisc does it...

netem can duplicate packets, but it enqueues them at the root,
so it shouldn't be a problem. It might be preferable to do
something similar to qdisc_tree_decrease_qlen in that case to
make sure the packet really ends up in the netem qdisc, but for
now I just wanted to fix the endless loops.

