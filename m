From: Fabian Pietsch <fabian@canvon.de>
Subject: Backwards route when adding IPv6 peer?
Date: Fri, 21 Jul 2017 13:54:14 +0200
Message-ID: <20170721115414.remsfxzvxo3goxsn@blackbox.nebel.canvon.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from delta.canvon.de ([81.169.252.194]:56627 "EHLO delta.canvon.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750802AbdGUMDx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 08:03:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this looks backwards to me:

| root@blackbox:~# ip -6 addr add fd12:3456:789a::1 peer fd99:9999:9999::1/48 dev sit0
| root@blackbox:~# ip -6 route show dev sit0
| fd12:3456:789a::/48 proto kernel metric 256  pref medium
| fd99:9999:9999::1 proto kernel metric 256  pref medium

| root@blackbox:~# ip -6 addr show dev sit0
| 4: sit0@NONE: <NOARP> mtu 1480 state DOWN qlen 1
|     inet6 fd12:3456:789a::1 peer fd99:9999:9999::1/48 scope global
|        valid_lft forever preferred_lft forever

The address+peer pair gets added just fine / appears correctly
in the addr show output. But the routing table has the *local*
address widened to the given prefix len, routing the local
address space to the remote side.

That is, I wanted to get a route to the peer's whole address space
implicitly, but I got a route of *my* address space to the tunnel.

Is this a Linux kernel bug? Or is it just working as expected?


Quoting from http://www.policyrouting.org/iproute2.doc.html#ss9.2.1
| peer ADDRESS--- address of remote endpoint for pointopoint interfaces.
| Again, the ADDRESS may be followed by a slash and decimal number,
| encoding the network prefix length. If a peer address is specified then
| the local address cannot have a network prefix length as the network
| prefix is associated with the peer rather than with the local address.
| In other words, netmasks can only be assigned to peer addresses when
| specifying both peer and local addresses.

This reads to me as if to support that the current kernel behaviour
is wrong.


blackbox is my notebook running something just before release of Debian 9:

| root@blackbox:~# dpkg -l iproute2 | grep ^.i
| ii  iproute2       4.9.0-1      amd64        networking and traffic control tools
| root@blackbox:~# uname -a
| Linux blackbox 4.9.0-2-amd64 #1 SMP Debian 4.9.13-1 (2017-02-27) x86_64 GNU/Linux

but I had the same problem initially on my home server/router/firewall
running Debian 8, while tweaking my OpenVPN tunnel configuration.

| root@mandarb:~# dpkg -l iproute2 | grep ^.i
| ii  iproute2       3.16.0-2     amd64        networking and traffic control tools
| root@mandarb:~# uname -a
| Linux mandarb 3.16.0-4-amd64 #1 SMP Debian 3.16.7-ckt20-1+deb8u3 (2016-01-17) x86_64 GNU/Linux

Regards,
Fabian
