From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Sun, 3 Nov 2013 18:18:46 +0100
Message-ID: <20131103171846.GB4151@cpaasch-mac>
References: <20131029090849.GC5944@cpaasch-mac>
 <1383051962.5464.25.camel@edumazet-glaptop.roam.corp.google.com>
 <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:53729 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350Ab3KCRS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 12:18:58 -0500
Content-Disposition: inline
In-Reply-To: <1383422330.4291.58.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/13 - 12:58:50, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Christoph Paasch and Jerry Chu reported crashes in skb_segment() caused
> by commit 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> 
> skb_segment() only deals with a frag_list chain containing MSS sized
> fragments. Even if we fix this problem, its better if GRO layer
> doesn't build skb with a frag_list in the first place, to let TSO
> packets reaching output devices.
>  
> David Miller and Ben Hutchings suggested we keep track of number of
> forwarding users to be able to :
> 
> - Disable LRO
> - Make sure GRO layer do not use skb frag_list to extend skb capacity
> 
> Note that after this patch, LRO is automatically re-enabled if
> forwarding is disabled on the device, or if a device is removed
> from a bridge.
> 
> Tested:
> 
> lpq84:~# ethtool -k eth0 | grep "large-receive"
> large-receive-offload: on
> lpq84:~# echo 1 >/proc/sys/net/ipv4/conf/eth0/forwarding
> lpq84:~# ethtool -k eth0 | grep "large-receive"
> large-receive-offload: off [requested on]
> lpq84:~# echo 0 >/proc/sys/net/ipv4/conf/eth0/forwarding
> lpq84:~# ethtool -k eth0 | grep "large-receive"
> large-receive-offload: on
> 
> 
> lpq84:~# ethtool -K eth0 lro off
> lpq84:~# ethtool -k eth0 | grep "large-receive"
> large-receive-offload: off
> lpq84:~# echo 1 >/proc/sys/net/ipv4/conf/eth0/forwarding
> lpq84:~# ethtool -k eth0 | grep "large-receive"
> large-receive-offload: off
> lpq84:~# echo 0 >/proc/sys/net/ipv4/conf/eth0/forwarding
> lpq84:~# ethtool -k eth0 | grep "large-receive"
> large-receive-offload: off
> lpq84:~# ethtool -K eth0 lro on 
> 
> 
> lpq84:~# cat /proc/sys/net/ipv4/ip_forward
> 0
> lpq84:~# echo 1 >/proc/sys/net/ipv4/ip_forward
> lpq84:~# ethtool -k eth0 | grep "large-receive"
> large-receive-offload: off [requested on]
> lpq84:~# echo 0 >/proc/sys/net/ipv4/ip_forward
> lpq84:~# ethtool -k eth0 | grep "large-receive"
> large-receive-offload: on
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Reported-by: Jerry Chu <hkchu@google.com>
> Cc: Michael Dalton <mwdalton@google.com>
> Fixes: 8a29111c7ca6 ("net: gro: allow to build full sized skb")
> ---
> v4: drop LRO in netdev_fix_features(), ase Ben pointed out.
> 
>  include/linux/netdevice.h |    3 ++-
>  net/bridge/br_if.c        |    4 +++-
>  net/core/dev.c            |   31 ++++++++++++++++++++-----------
>  net/core/skbuff.c         |   11 ++++++++---
>  net/ipv4/devinet.c        |   14 ++++++++------
>  net/ipv6/addrconf.c       |    5 ++---
>  net/ipv6/addrconf_core.c  |    2 ++
>  7 files changed, 45 insertions(+), 25 deletions(-)

Good, this fixes the crash I experienced on my workload.

Tested-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Thanks, Eric!
