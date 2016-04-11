From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 0/5] GRO Fixed IPv4 ID support and GSO partial
 support
Date: Sun, 10 Apr 2016 21:44:38 -0400
Message-ID: <20160411013855.11189.56567.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35820 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbcDKBoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 21:44:44 -0400
Received: by mail-pf0-f172.google.com with SMTP id n1so113591616pfn.2
        for <netdev@vger.kernel.org>; Sun, 10 Apr 2016 18:44:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series sets up a few different things.

First it adds support for GRO of frames with a fixed IP ID value.  This
will allow us to perform GRO for frames that go through things like an IPv6
to IPv4 header translation.

The second item we add is support for segmenting frames that are generated
this way.  Most devices only support an incrementing IP ID value, and in
the case of TCP the IP ID can be ignored in many cases since the DF bit
should be set.  So we can technically segment these frames using existing
TSO if we are willing to allow the IP ID to be mangled.  As such I have
added a matching feature for the new form of GRO/GSO called TCP IPv4 ID
mangling.  With this enabled we can assemble and disassemble a frame with
the sequence number fixed and the only ill effect will be that the IPv4 ID
will be altered which may or may not have any noticeable effect.  As such I
have defaulted the feature to disabled.

The third item this patch series adds is support for partial GSO
segmentation.  Partial GSO segmentation allows us to split a large frame
into two pieces.  The first piece will have an even multiple of MSS worth
of data and the headers before the one pointed to by csum_start will have
been updated so that they are correct for if the data payload had already
been segmented.  By doing this we can do things such as precompute the
outer header checksums for a frame to be segmented allowing us to perform
TSO on devices that don't support tunneling, or tunneling with outer header
checksums.

This patch set is based on the net-next tree, but I included "net: remove
netdevice gso_min_segs" in my tree as I assume it is likely to be applied
before this patch set will and I wanted to avoid a merge conflict.

v2: Fixed items reported by Jesse Gross
	fixed missing GSO flag in MPLS check
	adding DF check for MANGLEID
    Moved extra GSO feature checks into gso_features_check
    Rebased batches to account for "net: remove netdevice gso_min_segs"

Driver patches from the first patch set should still be compatible.  However
I do have a few changes in them so I will submit a v2 of those to Jeff
Kirsher once these patches are accepted into net-next.

Example driver patches for i40e, ixgbe, and igb:
https://patchwork.ozlabs.org/patch/608221/
https://patchwork.ozlabs.org/patch/608224/
https://patchwork.ozlabs.org/patch/608225/

---

Alexander Duyck (5):
      ethtool: Add support for toggling any of the GSO offloads
      GSO: Add GSO type for fixed IPv4 ID
      GRO: Add support for TCP with fixed IPv4 ID field, limit tunnel IP ID values
      GSO: Support partial segmentation offload
      Documentation: Add documentation for TSO and GSO features


 Documentation/networking/segmentation-offloads.txt |  130 ++++++++++++++++++++
 include/linux/netdev_features.h                    |    8 +
 include/linux/netdevice.h                          |    8 +
 include/linux/skbuff.h                             |   27 +++-
 net/core/dev.c                                     |   67 +++++++++-
 net/core/ethtool.c                                 |    4 +
 net/core/skbuff.c                                  |   29 ++++
 net/ipv4/af_inet.c                                 |   70 ++++++++---
 net/ipv4/gre_offload.c                             |   27 +++-
 net/ipv4/tcp_offload.c                             |   30 ++++-
 net/ipv4/udp_offload.c                             |   27 +++-
 net/ipv6/ip6_offload.c                             |   21 +++
 net/mpls/mpls_gso.c                                |    1 
 13 files changed, 395 insertions(+), 54 deletions(-)
 create mode 100644 Documentation/networking/segmentation-offloads.txt
