From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [Q] How to invalidate ARP cache for a network device from within
 kernel
Date: Fri, 26 Nov 2010 19:38:19 +0200
Message-ID: <1290793099.3716.21.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	linux1394-devel <linux1394-devel@lists.sourceforge.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56108 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754710Ab0KZRiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 12:38:25 -0500
Received: by bwz15 with SMTP id 15so2021114bwz.19
        for <netdev@vger.kernel.org>; Fri, 26 Nov 2010 09:38:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am currently dealing with one of the last issues present in
implementation of networking over firewire as described in RFC 2734.
The driver in question is firewire-net.

Here is the description of the problem:

To communicate with a remote network node, the sender node must know the
target node ID and a bus address within its bus address space.

Both things, unlike ethernet MAC, aren't fixed and can change on each
bus reset that happens every time a device appears/disappers from a bus
and can happen due to few more reasons.

The nodes on the bus do have a unique permanent label, a GUID, but it
can't be used for addressing.

Unfortunately, instead of defining a private ARP like broadcast message
that would map a GUID to nodeID/bus address on every bus reset, the 
RFC 2734 abuses ARP for that.

Every ARP response in addition to IP, includes all needed information
about the sending node.

This sort of works as long as firewire-net driver translates between
hardware specific and standard ARP formats.

However as soon as bus reset happens, the upper layer ARP cache isn't
invalidated, thus all attempts to send packets to remote node now fail,
because the additional information (node id and bus address) about
remote node is now invalid, but ARP core doesn't send ARP requests
because it has the response in the cache.

Now there are 2 ways to resolve this issue, I can implement ether of
them, but I need some assistance from you.


1. Make firewire-net send ARP requests on its own for all new discovered
remote nodes.

The easiest solution, but I am not sure if right one.
Also if such ARP packet won't reach the destination on first try, which
can happen because bus resets severe the IO for a while, the problem
will persist.


2. Allow firewire-net to discard the ARP cache for its generated
entries.
Not sure if that is possible now, but that will solve the problem for
sure.
I did look at arp core code, and I didn't find a way to do that yet.


Best regards,
	Maxim Levitsky

