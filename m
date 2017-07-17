From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/10] xfrm: remove flow cache
Date: Mon, 17 Jul 2017 13:57:17 +0200
Message-ID: <20170717115727.26042-1-fw@strlen.de>
Cc: steffen.klassert@secunet.com, ilant@mellanox.com
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43882 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751280AbdGQL5I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 07:57:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After RCU-ification of ipsec packet path there are no major scalability
issues anymore without flow cache.

We still incur a performance hit, which comes mostly from the extra xfrm
dst allocation/freeing.
The last patch in the series adds a simple percpu cache to avoid the
extra allocation if a packet matched the same policies as last one.

The main concern with this is that we will see performance drops,
especially with large numbers of policies/SAs.

However, during hallway discussions at nfws 2017 it seemed the issues
with flow caching outweight the removal downsides, and that it
might be best to just 'remove it' and see where the practical issues
(if any) will appear.

It should now be possible to also remove the genid member in the policies
as we don't hold bundles for prolonged time anymore, but I think
this change is controversial (and intrusive) enough as-is, so defer
that to a later point in time.

Changes since last rfc:

- fix build failures due to implicit interrupt.h includes
- rework last patch (pcpu cache):
 * avoid xchg()
 * check policies for walk.dead = 1 instead of more costly bundle_ok().
 * flush pcpu bundles when sa/policies get removed, to allow module
   references to go away (suggested by Ilan Tayari)

Documentation/networking/ip-sysctl.txt         |    7
drivers/net/arcnet/arcdevice.h                 |    2
drivers/net/ethernet/amd/xgbe/xgbe.h           |    1
drivers/net/ethernet/synopsys/dwc-xlgmac-net.c |    1
drivers/net/ieee802154/ca8210.c                |    1
include/net/flow.h                             |   34 -
include/net/netns/xfrm.h                       |   11
include/net/xfrm.h                             |    9
net/core/Makefile                              |    1
net/ipv4/ip_vti.c                              |   31 -
net/ipv4/xfrm4_policy.c                        |   11
net/ipv6/ip6_vti.c                             |   31 -
net/ipv6/xfrm6_policy.c                        |   11
net/key/af_key.c                               |    6
net/xfrm/xfrm_device.c                         |    4
net/xfrm/xfrm_policy.c                         |  417 +++++++-----------
net/xfrm/xfrm_state.c                          |    5
net/xfrm/xfrm_user.c                           |    3
security/selinux/include/xfrm.h                |    4
include/net/flowcache.h                        |   25 -
net/core/flow.c                                |  516 -----------------------
 21 files changed, 173 insertions(+), 957 deletions(-)
