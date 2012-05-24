From: Simon Horman <horms@verge.net.au>
Subject: [RFC v4 00/21] Flow Based Tunneling for Open vSwitch
Date: Thu, 24 May 2012 18:08:53 +0900
Message-ID: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Kyle Mestery <kmestery@cisco.com>
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46647 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130Ab2EXJJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 05:09:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series comprises a fresh batch of proposed changes to introduce
flow-based tunnelling.

At the heart of these changes is the following structure, which
is attached as a pointer to skb->cb.

struct ovs_key_ipv4_tunnel {
        __be64 tun_id;
        __u32  tun_flags;
        __be32 ipv4_src;
        __be32 ipv4_dst;
        __u8   ipv4_tos;
        __u8   ipv4_ttl;
        __u8   pad[2];
};

This series does not introdue use of in-tree kernel tunneling code
by Open vSwitch. However, it is intended as preliminary work
for that goal and I believe attaching a structure similar
to the one above to to skb->cb could be mechanism to achieve that.

I have CCed netdev for any comment on that.

Some details of the implementatoin follow, they are not
particularly related to the use of in-tree kernel tunneling code.


Overview:

In general the appraoch that I have taken in user-space is to split
tunneling into realdevs and tundevs.  Tunnel realdevs are devices that look
to users like the existing port-based tunnelling implementation. Tunnel
tundevs exist in the datapath and are where tx and rx occur.  Tunnel
tundevs have very little configuration and are unable to opperate without
flow information that describes at least the remote IP.

Changes:

* Do not attempt to configure a tundev realport, it will fail which
  results in ovs-vswitchd to start. I had not noticed this as
  ovs-vswitchd will start if there are no tundevs present in the databse
  when it starts, and I usally test on a fresh install.

* Add a flags fields to ovs_key_ipv4_tunnel (above) and use it
  to reinstate the functionality of various flags e.g. tunnel checksum,
  tunnel out key. Previously these flags were set on the 'mutable' of
  a tunnel device in the kernel, however this is no longer appropriate
  as a tunnel device may now handle multiple tunnels.

* Cleaned up output and parsing of tunnel flows.
  Test Suite enhancements to come.

* Do not use Linux kernel headers in lib/odp-util.c.
  This is achieved by defining a new structure flow_tun_key
  and using it instead of ovs_key_ipv4_tunnel. THe structure
  is currently the same internally as ovs_key_ipv4_tunnel.

Limiations:

* In this series, realdevs exist in the kernel although I believe
  it should not be necessary for them to do so. The reason that they are
  there is to limit the changes that are needed to the user-space netdev
  code and to allow review of the series before making those changes.

* PMTU discovery is broken and I'm unsure if it has been fixed.
  Jesse Gross sugested that a uer-space implemtation of MSS clampint would
  be a good solution to this. I have made a start on that and sent a
  separate email about it.

* The header cache has been removed, but some reminants of the
  API remain. In particualr the tunnel header is still created and updated,
  even thogh both occur for each transmit. It may make sense to
  recombine those calls into a single call if the header cache is
  to be permantently removed.

* Multicast could be implemented in user-space byt currently isn't.
  This means that muilticast remote IP for tunneling is broken.

* I have not implemented matches for tun_keys. This means
  that the current implementation only provides port-based tunneling
  implemented on top of flow-bassed tunneling. It is not yet possible for a
  controller to match on or set the tun_key of flows.

  I expect this to be a small body of work to complete.

* The way that I have split the patchs is still somewhat arbitrary.
  I wanted to avoid one very large patch to aid review.  But a lot of the
  chagnes are inter-related, so a bisectable split seems rather difficult.
  None the less, the split could be significantly improved.

----------------------------------------------------------------
Simon Horman (21):
      datapath: tunnelling: Replace tun_id with tun_key
      datapath: Use tun_key on transmit
      odp-util: Add tun_key to parse_odp_key_attr()
      vswitchd: Add iface_parse_tunnel
      vswitchd: Add add_tunnel_ports()
      ofproto: Add set_tunnelling()
      vswitchd: Configure tunnel interfaces.
      ofproto: Add realdev_to_txdev()
      ofproto: Add tundev_to_realdev()
      classifier: Convert struct flow flow_metadata to use tun_key
      datapath, vport: Provide tunnel realdev and tundev classes and vports
      lib: Replace commit_set_tun_id_action() with commit_set_tunnel_action()
      global: Remove OVS_KEY_ATTR_TUN_ID
      ofproto: Set flow tun_key in compose_output_action()
      datapath: Remove mlink element from tnl_mutable_config
      datapath: remove tunnel cache
      datapath: Always use tun_key addresses for route lookup
      dataptah: remove ttl and tos from tnl_mutable_config
      datapath: Simplify vport lookup
      datapath: Use tun_key flags for id and csum settings on transmit
      datapath: Always use tun_key flags

 datapath/Modules.mk             |   3 +-
 datapath/actions.c              |   6 +-
 datapath/datapath.c             |  11 +-
 datapath/datapath.h             |   5 +-
 datapath/flow.c                 |  35 +-
 datapath/flow.h                 |  27 +-
 datapath/tunnel.c               | 782 +++++-----------------------------------
 datapath/tunnel.h               |  98 +----
 datapath/vport-capwap.c         |  45 +--
 datapath/vport-gre.c            |  62 ++--
 datapath/vport-tunnel-realdev.c | 260 +++++++++++++
 datapath/vport.c                |   3 +-
 datapath/vport.h                |   1 +
 include/linux/openvswitch.h     |  24 +-
 include/openvswitch/tunnel.h    |   4 +
 lib/classifier.c                |   8 +-
 lib/dpif-linux.c                |   2 +-
 lib/dpif-netdev.c               |   2 +-
 lib/flow.c                      |  31 +-
 lib/flow.h                      |  21 +-
 lib/meta-flow.c                 |   4 +-
 lib/netdev-vport.c              | 333 ++++-------------
 lib/nx-match.c                  |   2 +-
 lib/odp-util.c                  |  72 +++-
 lib/odp-util.h                  |   5 +-
 lib/ofp-print.c                 |  12 +-
 lib/ofp-util.c                  |   4 +-
 ofproto/ofproto-dpif.c          | 347 ++++++++++++++++--
 ofproto/ofproto-provider.h      |  12 +
 ofproto/ofproto.c               |  28 ++
 ofproto/ofproto.h               |  46 +++
 tests/test-classifier.c         |   7 +-
 vswitchd/bridge.c               | 350 ++++++++++++++++++
 33 files changed, 1451 insertions(+), 1201 deletions(-)
 create mode 100644 datapath/vport-tunnel-realdev.c
