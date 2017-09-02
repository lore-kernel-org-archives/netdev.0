From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 00/21] mlxsw: Offloading GRE tunnels
Date: Sat,  2 Sep 2017 23:49:08 +0200
Message-ID: <20170902214929.2890-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:33767 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752761AbdIBVte (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 17:49:34 -0400
Received: by mail-wr0-f170.google.com with SMTP id k94so7187346wrc.0
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 14:49:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Petr says:

This patch series introduces to mlxsw driver support for offloading
IP-in-IP tunnels in general, and for (subset of) GRE in particular.

This patchset supports two ways of configuring GRE:

- So called "hierarchical configuration", where the GRE device has a bound
  dummy device, which is in a different VRF. The VRF with host traffic is
  called "overlay", the one with encapsulated traffic is called "underlay".

- So called "flat configuration", where the GRE device doesn't have a bound
  device, and overlay and underlay are both in the same VRF (possibly the
  default one).

Two routes are then interesting: a route that directs traffic to a GRE
device (which would typically be in overlay VRF, but could be in another
one), and a local route for the tunnel's local address (in underlay).
Handling of these two route types is then introduced as patches to support,
respectively, IPv4 and IPv6 encapsulation and IPv4 decapsulation.

The encap and decap routes then reference a loopback device, a new type of
RIF introduced by this patchset for the specific use of offloading tunnels.

The encap and decap code is abstract with respect to the particulars of
individual L3 tunnel types. This patchset introduces support for GRE
tunnels in particular.

Limitations:

- Each tunnel needs to have a different local address (within a given VRF).
  When two tunnels are used that are in conflict, FIB abort is triggered
  and the driver ceases offloading FIBs. Full handling of such
  configurations needs special setup in the hardware, such that the tunnels
  that share an address are dispatched correctly according to their key (or
  lack thereof). That's currently not implemented, and to keep things
  deterministic, the driver triggers FIB abort.

- A next hop that uses an incompletely-specified tunnel (e.g. such that are
  used for LWT) is not offloaded, but doesn't trigger FIB abort like the
  above. If such routes end up being in a de facto conflict with other
  tunnels, then if there already is an offload for that address, the
  traffic for the conflicting tunnel will end up mismatching the
  configuration of the offloaded tunnel, and thus gets to slow path through
  an error trap.

- GRE checksumming and sequence numbers are not supported and TTL and TOS
  need to be set to inherit. Tunnels with a different configuration are not
  offloaded and their traffic is trapping to slow path.

  Note in particular that TOS of inherit is not the default configuration
  and needs to be explicitly specified when the tunnel is created.

- The only feature that is not graciously handled is that if a change is
  made to the tunnel, e.g. through "ip tunnel change", such changes are not
  reflected in the driver. There is currently no notification mechanism for
  these changes. Introduction of this mechanism and its leverage in the
  driver will be subject of follow-up work. For now this limitation can be
  worked around by removing and re-adding the encap route.

---
v1->v2:
-fix order of patch 5

Petr Machata (21):
  mlxsw: reg: Update RITR to support loopback device
  mlxsw: reg: Update RATR to support IP-in-IP tunnels
  mlxsw: reg: Move enum mlxsw_reg_ratr_trap_id
  mlxsw: reg: Add mlxsw_reg_ralue_act_ip2me_tun_pack()
  mlxsw: reg: Add Routing Tunnel Decap Properties Register
  mlxsw: reg: Extract mlxsw_reg_ritr_mac_pack()
  mlxsw: reg: Give mlxsw_reg_ratr_pack a type parameter
  mlxsw: spectrum_router: Publish mlxsw_sp_l3proto
  mlxsw: spectrum_router: Add mlxsw_sp_ipip_ops
  mlxsw: spectrum_router: Support FID-less RIFs
  mlxsw: spectrum_router: Introduce loopback RIFs
  mlxsw: spectrum_router: Extract mlxsw_sp_fi_is_gateway()
  mlxsw: spectrum_router: Extract mlxsw_sp_rt6_is_gateway()
  mlxsw: spectrum_router: Make nexthops typed
  mlxsw: spectrum_router: Support IPv4 overlay encap
  mlxsw: spectrum_router: Support IPv6 overlay encap
  mlxsw: spectrum_router: Support IPv4 underlay decap
  mlxsw: spectrum_router: Use existing decap route
  mlxsw: spectrum: Register for IPIP_DECAP_ERROR trap
  mlxsw: spectrum_router: Add loopback accessors
  mlxsw: spectrum_router: Support GRE tunnels

 drivers/net/ethernet/mellanox/mlxsw/Makefile       |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 311 ++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   1 +
 .../net/ethernet/mellanox/mlxsw/spectrum_ipip.c    | 214 +++++
 .../net/ethernet/mellanox/mlxsw/spectrum_ipip.h    |  79 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 947 +++++++++++++++++++--
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  28 +
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |   1 +
 9 files changed, 1485 insertions(+), 101 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.h

-- 
2.9.3
