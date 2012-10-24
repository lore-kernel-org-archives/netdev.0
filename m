From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v1 0/3] extend set/get netlink for embedded
Date: Wed, 24 Oct 2012 09:50:57 -0700
Message-ID: <20121024164906.14221.45341.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, chrisw@redhat.com, krkumar2@in.ibm.com,
	samudrala@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, gregory.v.rose@intel.com,
	eilong@broadcom.com
To: shemminger@vyatta.com, buytenh@wantstofly.org, davem@davemloft.net,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39202 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756966Ab2JXRIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 13:08:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extends the PF_BRIDGE setlink and getlink so that they can be
used generically outside of the Linux bridge module. Doing this
allows embedded devices to use the same netlink interface that
the software bridge is currently using.

In this patchset I opted to create two new ndo ops ndo_bridge_setlink
and ndo_bridge_getlink. These ops pass the nlmsghdr to the device
for handling. The netlink message is extended to support nested
IFLA_AF_SPEC attributes. A IFLA_BRIDGE_FLAGS attribute is used to
determine the target of the message either a master netdev is the
target or the target is "self" indicating the target is the netdev.
In this way we can send netlink msg to an embedded device or the
linux sw bridge or both. If the set completes sucessfully the flag
is cleared in this way we can learn what failed in the both case.
This scheme is similar to how FDB updates are handled. If no flag
attribute is present the message is sent to the master device to
support the existing messages.

An initial IFLA_BRIDGE_MODE attribute is added to indicate if the
bridge is in a VEPA mode or VEB mode. This is most useful for
SR-IOV device and can be used to indicate support for VF to VF or
VF to PF traffic. Without this we have no way of knowing this
other then trial and error because not all hardware supports
this.

In the future additional attributes can be added to handle other
attributes. We could for example move some of the linux bridge
sysfs attributes here if we want a netlink interface for them.
This should also allow DSA switches to use the bridging tools.
See RFC patch from Lennert

http://patchwork.ozlabs.org/patch/16578/

I could have simply added the VEPA attribute handling to the
rtnl_setlink() routine but it seemed like a good feature to have
all the bridging events and configuration on the same type. Also
this should allow more powerful offloaded switches like the
hardware supported via DSA access to the bridge control
interface.

Also I think this interface should allow Vlad to add his port based
VLAN interface here as well.

Any feedback/criticism appreciated thanks!

---

John Fastabend (3):
      ixgbe: add setlink, getlink support to ixgbe and ixgbevf
      net: set and query VEB/VEPA bridge mode via PF_BRIDGE
      net: create generic bridge ops


 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   59 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |    3 
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   10 +
 include/linux/netdevice.h                         |   10 +
 include/linux/rtnetlink.h                         |    3 
 include/uapi/linux/if_bridge.h                    |   18 ++
 net/bridge/br_device.c                            |    2 
 net/bridge/br_netlink.c                           |   75 +-------
 net/bridge/br_private.h                           |    7 +
 net/core/rtnetlink.c                              |  207 +++++++++++++++++++++
 10 files changed, 328 insertions(+), 66 deletions(-)

-- 
Signature
