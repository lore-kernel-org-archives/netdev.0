From: Yavor Goulishev <yavor@simplifymedia.com>
Subject: RE: [Patch] Establishing more than 64K outgoing TCP connections
Date: Fri, 7 Nov 2008 01:12:36 -0500
Message-ID: <241CE5A1B2AFFA4987A663380D74C0BB3FFD158878@MBX73.ad2.softcom.biz>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B08A7@MBX73.ad2.softcom.biz>,<20081101.211541.182428064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp04.mail2web.com ([168.144.250.226]:32909 "EHLO
	xsmtp04.mail2web.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbYKGGMw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 01:12:52 -0500
In-Reply-To: <20081101.211541.182428064.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK,
I see that you want to access the hash table in O(1)  and
you try to get a port number at empty bucket. This is clever.
However having hash table size 65536 and hash function just the port number can
work only for 64K binds, right? If I need more they need to go in the chains.

So may be having a better hash function and configurable table size (/proc/sys/net/...)
can work without limitation and with good performance.
For example:
    hash_fn = (port + local_ip) % size

--Yavor
________________________________________
From: David Miller [davem@davemloft.net]
Sent: Saturday, November 01, 2008 8:15 PM
To: Yavor Goulishev
Cc: netdev@vger.kernel.org
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections

From: Yavor Goulishev <yavor@simplifymedia.com>
Date: Tue, 28 Oct 2008 17:06:33 -0400

> I'm sending you a tiny patch for the kernel.  The change allowed me
> to establish more than 64K outgoing TCP connections from a single
> Linux box.  Being able to use multihomed client box to load test a
> server reduced dramatically the number of physical boxes I needed.
> The other way to go was virtual machines, but you can't beat the
> simplicity of the single multihomed client.  Also the patch fixes an
> important symmetry.  Using the multihome setup is a simple technique
> to overcome the 64K limit on the server side.  The patch makes it
> possible on the client side too.
>
> The fix is only for TCP but probably the same issue exists for UDP.
> I didn't had the time to investigate.
>
> The patch is against the latest code base 2.6.28-rc2.

As I mentioned in my initial reply to you, this exact patch
has been proposed in the future and rejected.

The problem is that although it fixes the limitation, it
introduces a new problem.

The current code tries to keep the hash chains as shallow
as possible.  One part of how it achieves this is that it
tries to use up all the available ports using it's
scanning algorithm.  Your change works against this, and
will tend to make the hash chains deeper.

A solution needs to be devised which handles both issues.
