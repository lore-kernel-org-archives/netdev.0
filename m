From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] mlxsw: GRE: Offload decap without encap
Date: Mon, 16 Oct 2017 16:26:34 +0200
Message-ID: <20171016142639.2453-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:49492 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753198AbdJPO0m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 10:26:42 -0400
Received: by mail-wm0-f67.google.com with SMTP id b189so3857360wmd.4
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 07:26:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Petr says:

The current code doesn't offload GRE decapsulation unless there's a
corresponding encapsulation route as well. While not strictly incorrect (when
encap route is absent, the decap route traps traffic to CPU and the kernel
handles it), it's a missed optimization opportunity.

With this patchset, IPIP entries are created as soon as offloadable tunneling
netdevice is created. This then leads to offloading of decap route, if one
exists, or is added afterwards, even when no encap route is present.

In Linux, when there is a decap route, matching IP-in-IP packets are always
decapsulated. However, with IPv4 overlays in particular, whether the inner
packet is then forwarded depends on setting of net.ipv4.conf.*.rp_filter. When
RP filtering is turned on, inner packets aren't forwarded unless there's a
matching encap route. The mlxsw driver doesn't reflect this behavior in other
router interfaces, and thus it's not implemented for tunnel types either. A
better support for this will be subject of follow-up work.

Petr Machata (5):
  mlxsw: spectrum: Move netdevice NB to struct mlxsw_sp
  mlxsw: spectrum_router: Move mlxsw_sp_netdev_ipip_type()
  mlxsw: spectrum: Support decap-only IP-in-IP tunnels
  mlxsw: spectrum: Support IPIP overlay VRF migration
  mlxsw: spectrum: Drop refcounting of IPIP entries

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  31 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   8 +
 .../net/ethernet/mellanox/mlxsw/spectrum_ipip.h    |   1 -
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 233 ++++++++++++++++-----
 4 files changed, 209 insertions(+), 64 deletions(-)

-- 
2.9.5
