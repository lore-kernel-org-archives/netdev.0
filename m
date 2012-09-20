From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: mlx4: dropping multicast packets at promisc leave
Date: Wed, 19 Sep 2012 21:43:56 -0300
Message-ID: <505A66CC.8010701@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64481 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355Ab2ITAoD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 20:44:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a report that our mlx4 driver (RHEL 6.3) is dropping multicast 
packets when NIC leaves promisc mode. It seems this is being cause due 
to the new steering mode that took place near by commit 
1679200f91da6a054b06954c9bd3eeed29b6731f.

As it seems, the new steering mode needs more commands/time to leave the 
promisc mode, which may be leading to packet drops.

The details are bellow. My main question now is: wouldn't it be safer/is 
it possible to enable the MCAST_FLTR before removing the promisc entries?

I noticed that for entering promisc mode it first puts the NIC in 
promisc and only then disables MCAST_FLTR, and no packet drops are being 
observed.

Details:

At my system (line numbers won't directly match):
[633241.362775] device eth5 left promiscuous mode
[633241.362800] mlx4_en: eth5: 356 - mlx4_unicast_promisc_remove
[633241.362854] mlx4_en: eth5: 365 - mlx4_multicast_promisc_remove
[633241.363049] mlx4_en: eth5: 407 - mlx4_SET_MCAST_FLTR MLX4_MCAST_DISABLE
[633241.363098] mlx4_en: eth5: 414 - mlx4_SET_MCAST_FLTR MLX4_MCAST_CONFIG
[633241.363353] mlx4_en: eth5: 428 - mlx4_SET_MCAST_FLTR MLX4_MCAST_ENABLE

At theirs:
[  137.614253] device eth1 left promiscuous mode
[  137.667519] mlx4_en: eth1: 356 - mlx4_unicast_promisc_remove
[  137.735264] mlx4_en: eth1: 365 - mlx4_multicast_promisc_remove
[  137.805159] mlx4_en: eth1: 407 - mlx4_SET_MCAST_FLTR MLX4_MCAST_DISABLE
[  137.864581] mlx4_en: eth1: 414 - mlx4_SET_MCAST_FLTR MLX4_MCAST_CONFIG
[  137.943299] mlx4_en: eth1: 428 - mlx4_SET_MCAST_FLTR MLX4_MCAST_ENABLE

It takes 300ms to perform the change there against my 600us. Hitting 
something like tcpdump -c 10 in a loop helps triggering it.

Both NICs are:
06:00.0 Ethernet controller: Mellanox Technologies MT26448 [ConnectX EN 
10GigE, PCIe 2.0 5GT/s] (rev b0)

Tested on firmwares 2.8.600 and 2.9.1200, same issue. I could not 
reproduce the drops myself so far. Their NIC is IBM branded and mine is HP.

I checked commit 
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=6d19993788e080edb557178cc6aba2d963edce4e 
but even with it, it dropped packets.

Thanks,
Marcelo.
