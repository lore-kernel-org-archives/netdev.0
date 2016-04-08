From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 0/5] GRO Fixed IPv4 ID support and GSO partial
 support
Date: Fri, 08 Apr 2016 16:33:04 -0400
Message-ID: <20160408203013.12838.63429.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33973 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758773AbcDHUdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:33:09 -0400
Received: by mail-pf0-f179.google.com with SMTP id c20so82103784pfc.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 13:33:09 -0700 (PDT)
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

This patch series currently relies on a patch that is in the net tree.  As
such it may be best to defer applying it until the net tree is merged.  In
addition I have some patches for the Intel NIC drivers that I will submit
as an RFC for now and will submit to Jeff Kirsher once this patch series
has been applied.

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
 net/core/dev.c                                     |   38 +++++-
 net/core/ethtool.c                                 |    4 +
 net/core/skbuff.c                                  |   29 ++++
 net/ipv4/af_inet.c                                 |   70 ++++++++---
 net/ipv4/gre_offload.c                             |   27 +++-
 net/ipv4/tcp_offload.c                             |   30 ++++-
 net/ipv4/udp_offload.c                             |   27 +++-
 net/ipv6/ip6_offload.c                             |   21 +++
 12 files changed, 368 insertions(+), 51 deletions(-)
 create mode 100644 Documentation/networking/segmentation-offloads.txt
