From: Patrick McHardy <kaber@trash.net>
Subject: IPv4/IPv6 sysctl unregistration deadlock
Date: Wed, 25 Feb 2009 06:23:33 +0100
Message-ID: <49A4D5D5.5090602@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51458 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbZBYFXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 00:23:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear reported sporadically hanging ip processes when adding or
removing MACVLAN devices, which seem to be caused by a race between
sysctl handling and device notifiers.

What is happening is:

Process 1:

- "ip" deletes a macvlan device (or any other kind of device gets
   removed for whatever reason)
- netdev notifier chain notifies IPv6 addrconf while holding the RTNL

Process 2:

- a different process writes something to /proc/sys/net/ipv6/forwarding
- sysctl table is marked as busy, addrconf_sysctl_forward() is invoked
- tries to take rtnl, waits for process 1

Process 1:

- IPv6 begins sysctl unregistration, which is deferred using a
   completion until the table is not busy anymore (=> waiting for
   process 2)

At this point both processes are deadlocked. Judging by a quick look,
IPv4 seems to have the exact same problem.

An easy fix would be to keep track of whether sysctl unregistration
is in progress in IPv4/IPv6 and ignore new requests from that point
on. Its not very elegant though, so I was wondering whether anyone
has a better suggestion.

