From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 12 Feb 2008 22:00:03 -0800 (PST)
Message-ID: <20080212.220003.108906105.davem@davemloft.net>
References: <47B0DD1E.5000608@katalix.com>
	<20080211.213048.192442721.davem@davemloft.net>
	<47B17BCD.2070903@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55221
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751772AbYBMF7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 00:59:31 -0500
In-Reply-To: <47B17BCD.2070903@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue, 12 Feb 2008 10:58:21 +0000

> Here is a trace from when we had _bh locks.

The problem is that the pppol2tp code calls sk_dst_get() in software
interrupt context and that is not allowed.

sk_dst_get() grabs sk->sk_dst_lock without any BH enabling or
disabling.

It can do that because the usage is to make all the lock
taking calls in user context, and in the packet processing
paths use __sk_dst_get().

Probably what the pppol2tp code should do is use __sk_dst_check()
instead of sk_dst_get().  You then have to be able to handle
NULL returns, just like UDP sendmsg() does, which means you'll
need to cook up a routing lookup if __sk_dst_check() gives you
NULL because the route became obsolete.
