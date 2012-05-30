From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v1 0/3] Expose switching attributes via PF_BRIDGE
Date: Tue, 29 May 2012 20:06:54 -0700
Message-ID: <20120530030531.7443.72024.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, gregory.v.rose@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	eric.w.multanen@intel.com
To: krkumar2@in.ibm.com, hadi@cyberus.ca, shemminger@vyatta.com,
	mst@redhat.com, buytenh@wantstofly.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29217 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932261Ab2E3DVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 23:21:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series decouples the remaining netlink PF_BRIDGE messages
from the bridging module and moves them into rtnetlink proper.
By doing this we can use these netlink messages to handle any
type of bridge and extend the attributes as needed.

I hope this resolves some of the concerns with the DSA patch
below and expect the attached series can be extended to
support the DSA infrastructure as needed:

http://patchwork.ozlabs.org/patch/16578/

Also this should resolve a patch here that tried to expose
the switching modes but did so using a device specific hook:

http://lists.openwall.net/netdev/2012/04/16/10

I've used a hacked version of the 'bridge' tool Stephen
Hemminger submitted as an RFC some months back to test this
the output looks like this:

[root@jf-dev1-dcblab iproute2]# ./br/br bridge show
eth2: bridge mode: VEB		embedded
eth3: bridge mode: VEB		embedded
[root@jf-dev1-dcblab iproute2]# ./br/br bridge mode dev eth2 mode vepa
[root@jf-dev1-dcblab iproute2]# ./br/br bridge show
eth2: bridge mode: VEPA		embedded
eth3: bridge mode: VEB		embedded

I could have just added a ndo op and IFLA_XXX message to
set the switching mode but IMHO this is not going to scale
as more bridging functionality becomes offloaded. The DSA
example is a case where we already have a fully offloaded
switch. Any solution we come up with should support both
embedded switches and SW switches.

Any comments would be appreciated Thanks!

---

John Fastabend (3):
      ixgbe: add setlink, getlink support to ixgbe and ixgbevf
      net: add VEPA, VEB bridge mode
      net: create generic bridge ops


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  100 +++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |    3 
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   10 ++
 include/linux/if_link.h                           |   16 ++
 include/linux/netdevice.h                         |   10 ++
 net/bridge/br_device.c                            |    2 
 net/bridge/br_netlink.c                           |   75 ++---------
 net/bridge/br_private.h                           |    3 
 net/core/rtnetlink.c                              |  137 +++++++++++++++++++++
 9 files changed, 291 insertions(+), 65 deletions(-)

-- 
Signature
