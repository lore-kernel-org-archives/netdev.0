From: David Miller <davem@davemloft.net>
Subject: Re: setsockopt()
Date: Mon, 07 Jul 2008 16:00:29 -0700 (PDT)
Message-ID: <20080707.160029.13296246.davem@davemloft.net>
References: <20080707142408.43aa2a2e@extreme>
	<48728B09.1050801@citi.umich.edu>
	<48729DAD.8010400@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aglo@citi.umich.edu, shemminger@vyatta.com, netdev@vger.kernel.org,
	rees@umich.edu, bfields@fieldses.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60858
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758070AbYGGXA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 19:00:29 -0400
In-Reply-To: <48729DAD.8010400@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 07 Jul 2008 15:50:21 -0700

> I'm still a triffle puzzled/concerned/confused by the extent to which 
> autotuning will allow the receive window to grow, again based on some 
> netperf experience thusfar, and patient explanations provided here and 
> elsewhere, it seems as though autotuning will let things get to 2x what 
> it thinks the sender's cwnd happens to be.  So far under netperf testing 
> that seems to be the case, and 99 times out of ten my netperf tests will 
> have the window grow to the max.

We need 2x, in order to have a full window during recovery.

There was a measurement bug found a few months ago when the
google folks were probing in this area, which was fixed
by John Heffner.  Most of which had to deal with TSO subtleties.

--------------------
commit 246eb2af060fc32650f07203c02bdc0456ad76c7
Author: John Heffner <johnwheffner@gmail.com>
Date:   Tue Apr 29 03:13:52 2008 -0700

    tcp: Limit cwnd growth when deferring for GSO
    
    This fixes inappropriately large cwnd growth on sender-limited flows
    when GSO is enabled, limiting cwnd growth to 64k.
    
    Signed-off-by: John Heffner <johnwheffner@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

commit ce447eb91409225f8a488f6b7b2a1bdf7b2d884f
Author: John Heffner <johnwheffner@gmail.com>
Date:   Tue Apr 29 03:13:02 2008 -0700

    tcp: Allow send-limited cwnd to grow up to max_burst when gso disabled
    
    This changes the logic in tcp_is_cwnd_limited() so that cwnd may grow
    up to tcp_max_burst() even when sk_can_gso() is false, or when
    sysctl_tcp_tso_win_divisor != 0.
    
    Signed-off-by: John Heffner <johnwheffner@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
--------------------

Setting TCP socket buffer via setsockopt() is always wrong.
If there is a bug, let's fix it.
