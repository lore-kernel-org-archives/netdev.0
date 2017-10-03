From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/7] mlxsw: Add support for partial multicast route offload
Date: Tue,  3 Oct 2017 09:58:05 +0200
Message-ID: <20171003075812.1540-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, f.fainelli@gmail.com, fw@strlen.de,
        gfree.wind@vip.163.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:48262 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdJCH6O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 03:58:14 -0400
Received: by mail-wm0-f65.google.com with SMTP id i82so12684984wmd.3
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 00:58:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Yotam says:

Previous patchset introduced support for offloading multicast MFC routes to
the Spectrum hardware. As described in that patchset, no partial offloading
is supported, i.e if a route has one output interface which is not a valid
offloadable device (e.g. pimreg device, dummy device, management NIC), the
route is trapped to the CPU and the forwarding is done in slow-path.

Add support for partial offloading of multicast routes, by letting the
hardware to forward the packet to all the in-hardware devices, while the
kernel ipmr module will continue forwarding to all other interfaces.

Similarly to the bridge, the kernel ipmr module will forward a marked
packet to an interface only if the interface has a different parent ID than
the packet's ingress interfaces.

The first patch introduces the offload_mr_fwd_mark skb field, which can be
used by offloading drivers to indicate that a packet had already gone
through multicast forwarding in hardware, similarly to the offload_fwd_mark
field that indicates that a packet had already gone through L2 forwarding
in hardware.

Patches 2 and 3 change the ipmr module to not forward packets that had
already been forwarded by the hardware, i.e. packets that are marked with
offload_mr_fwd_mark and the ingress VIF shares the same parent ID with the
egress VIF.

Patches 4, 5, 6 and 7 add the support in the mlxsw Spectrum driver for trap
and forward routes, while marking the trapped packets with the
offload_mr_fwd_mark.

Yotam Gigi (7):
  skbuff: Add the offload_mr_fwd_mark field
  ipv4: ipmr: Add the parent ID field to VIF struct
  ipv4: ipmr: Don't forward packets already forwarded by hardware
  mlxsw: acl: Introduce ACL trap and forward action
  mlxsw: spectrum: Add trap for multicast trap-and-forward routes
  mlxsw: spectrum: mr_tcam: Add trap-and-forward multicast route
  mlxsw: spectrum: mr: Support trap-and-forward routes

 .../mellanox/mlxsw/core_acl_flex_actions.c         | 17 ++++++++
 .../mellanox/mlxsw/core_acl_flex_actions.h         |  2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 13 ++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c  | 17 ++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h  |  1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c |  8 ++++
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |  2 +
 include/linux/mroute.h                             |  1 +
 include/linux/skbuff.h                             |  1 +
 net/ipv4/ipmr.c                                    | 48 +++++++++++++++++++---
 10 files changed, 96 insertions(+), 14 deletions(-)

-- 
2.9.5
