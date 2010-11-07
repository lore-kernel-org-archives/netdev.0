From: Jan Engelhardt <jengelh@medozas.de>
Subject: Netlink limitations
Date: Sun, 7 Nov 2010 17:44:02 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011071743070.21289@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:38453 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984Ab0KGQoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Nov 2010 11:44:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


we mentioned it only briefly at the Netfilter workshop a few weeks ago, 
but as I am trying to figure out how to use Netlink in Xtables, 
Netlink's limitations really start ruining my day.

The well-known issue is that NL messages the kernel is supposed to 
receive have a max size of 64K, due to nlmsghdr's use of uint16_t. This 
is very problematic because attributes can easily amass more than 64K. 
Think of a chain full of rules, represented by a top-level attribute 
that nests attributes. The problem is bidirectional, a table 
dump has the same problem.

A further problem seems to be that the kernel does not seem to have 
support for receiving NLM_F_MULTI messages, so even assuming chains were 
just 40K, one cannot atomically replace an entire table with 2 chains of 
40K each. Trying to slap transaction support on _top_ of netlink is not 
going to work with the current implementation, because there is no 
notification of when the socket is closed before a NLMSG_DONE has been 
sent.

What I would also like is streaming support, i.e. that I can tag an 
attribute container (one that has nested attrs) with .len = -1 to define 
that the end of the container is given not by .len, but by a stop 
marker.

Hacks like nfnetlink or genetlink also seem unnecessary to me, and the 
limit of MAX_LINKS=32 most likely just stems from nl_table being an 
array that is not very sparse.

Perhaps it is time to replace Netlink by something new?
Trying to elicit some opinions.


Jan
