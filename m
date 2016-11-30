From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 V3 0/3] tc: Support for ip tunnel metadata set/unset/classify
Date: Wed, 30 Nov 2016 09:38:37 +0200
Message-ID: <20161130073840.5269-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33211 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752078AbcK3HnH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 02:43:07 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so27933129wmu.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 23:43:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This short series adds support for matching and setting metadata for ip tunnel
shared device using the TC system, introduced in kernel 4.9 [1].

Applied and tested on top of commit f3f339e9590a ("cleanup debris from revert")

Example usage:

$ tc filter add dev vxlan0 protocol ip parent ffff: \
    flower \
      enc_src_ip 11.11.0.2 \
      enc_dst_ip 11.11.0.1 \
      enc_key_id 11 \
      dst_ip 11.11.11.1 \
    action mirred egress redirect dev vnet0

$ tc filter add dev net0 protocol ip parent ffff: \
    flower \
      ip_proto 1 \
      dst_ip 11.11.11.2 \
    action tunnel_key set \
      src_ip 11.11.0.1 \
      dst_ip 11.11.0.2 \
      id 11 \
    action mirred egress redirect dev vxlan0

[1] - d1ba24feb466 ("Merge branch 'act_tunnel_key'")

Thanks,
Amir

Changes from V2:
- Use const where needed
- Don't lose return value
- Introduce rta_getattr_be16() and rta_getattr_be32()

Changes from V1:
- Updated Patch 2/2 ("tc/act_tunnel: Introduce ip tunnel action") commit log
	and the man page tc-tunnel_key to reflect the fact that 'unset' operation is
	no mandatory.
	And describe when it might be needed.
- Rename the 'release' operation to 'unset'

Amir Vadai (3):
  libnetlink: Introduce rta_getattr_be*()
  tc/cls_flower: Classify packet in ip tunnels
  tc/act_tunnel: Introduce ip tunnel action

 bridge/fdb.c                         |   4 +-
 include/libnetlink.h                 |   9 ++
 include/linux/tc_act/tc_tunnel_key.h |  42 ++++++
 ip/iplink_geneve.c                   |   2 +-
 ip/iplink_vxlan.c                    |   2 +-
 man/man8/tc-flower.8                 |  17 ++-
 man/man8/tc-tunnel_key.8             | 113 +++++++++++++++
 tc/Makefile                          |   1 +
 tc/f_flower.c                        |  84 +++++++++++-
 tc/m_tunnel_key.c                    | 258 +++++++++++++++++++++++++++++++++++
 10 files changed, 523 insertions(+), 9 deletions(-)
 create mode 100644 include/linux/tc_act/tc_tunnel_key.h
 create mode 100644 man/man8/tc-tunnel_key.8
 create mode 100644 tc/m_tunnel_key.c

-- 
2.10.2
