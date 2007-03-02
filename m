From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [Bugme-new] [Bug 8107] New: dev->header_cache_update has a random value
Date: Sat, 03 Mar 2007 00:38:23 +0100
Message-ID: <m3bqjb6wsw.fsf@maximus.localdomain>
References: <200703011933.l21JX5hw018666@fire-2.osdl.org>
	<20070301143417.00b49e81.akpm@linux-foundation.org>
	<m3zm6vk6kd.fsf@maximus.localdomain>
	<20070302.112325.39160082.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, loveminix@yahoo.com.cn
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:48143 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992753AbXCBXiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 18:38:25 -0500
In-Reply-To: <20070302.112325.39160082.davem@davemloft.net> (David Miller's message of "Fri, 02 Mar 2007 11:23:25 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> I disagree, you can't leave dangling references to functions
> which are potentially inside of unloaded modules, as this code
> does.

All such pointers were thought to be initialized by all HDLC protocol
handlers before device activation, but they were actually used by the
hdlc* code, and this one doesn't seem to...

> Rather, HDLC Cisco should implement a proper protocol destructor
> method to clean up these function pointers.

No, it wouldn't work - hdlc_cisco doesn't use it at all, it's just
a victim. But now I think there may be other victims.

It seems the only way to become non-NULL is through ether_setup()
from hdlc_raw_eth.c (Ethernet framing over HDLC).

I think it's best to NULLify it and the like in hdlc.c
unconditionally, it's slow path and we don't need another useless
EXPORT_SYMBOL(s). It would fix all such problems forever.

Compile-tested only but it seems pretty obvious and of course I check
if the packets still flow after regular kernel upgrades (and I run
automatic tests checking all protos except X.25 from time to time as
well).

(the patch is in the next message).

Not sure if 2.6.21 material.
-- 
Krzysztof Halasa
