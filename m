From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V2 0/3] net/sched: act_pedit: Use offset relative to conventional network headers
Date: Thu,  5 Jan 2017 11:54:51 +0200
Message-ID: <20170105095454.32644-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33131 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754326AbdAEJzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 04:55:21 -0500
Received: by mail-wm0-f68.google.com with SMTP id u144so95568427wmu.0
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 01:55:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This is a respin of the patchset. V1 was sent and didn't make it for 4.10.

You asked me [1] why did I use specific header names instead of layers (L2, L3...),
and I explained that it is on purpose, this extra information is planned to be used
by hardware drivers to offload the action.

Some FW/HW parser APIs are such that they need to get the specific header type (e.g
IPV4 or IPV6, TCP or UDP) and not only the networking level (e.g network or transport).

Enhancing the UAPI to allow for specifying that would allow the same flows to be
set into both SW and HW.

This patchset also makes pedit more robust. Currently fields offset is specified
by offset relative to the ip header, while using negative offsets for 
MAC layer fields.

This series enables the user to set offset relative to the relevant header.

This patch is reusing existing fields in a way where backward UAPI 
compatibility is being kept.

Usage example:
$ tc filter add dev enp0s9 protocol ip parent ffff: \
   flower \
     ip_proto tcp \
    dst_port 80 \
   action \
       pedit munge ip ttl add 0xff \
       pedit munge tcp dport set 8080 \
     pipe action mirred egress redirect dev veth0

Will forward traffic destined to tcp dport 80, while modifying the
destination port to 8080, and decreasing the ttl by one.

I've uploaded a draft for the userspace [2] to make it easier to review and
test the patchset.

[1] - http://patchwork.ozlabs.org/patch/700909/
[2] - git: https://bitbucket.org/av42/iproute2.git
      branch: pedit

Patchset was tested and applied on top of upstream commit 57ea884b0dcf
("packet: fix panic in __packet_set_timestamp on tpacket_v3 in tx mode")

Thanks,
Amir

Amir Vadai (3):
  net/skbuff: Introduce skb_mac_offset()
  net/act_pedit: Support using offset relative to the conventional
    network headers
  net/act_pedit: Introduce 'add' operation

 include/linux/skbuff.h               |  5 +++
 include/uapi/linux/tc_act/tc_pedit.h | 27 ++++++++++++
 net/sched/act_pedit.c                | 81 ++++++++++++++++++++++++++++++------
 3 files changed, 100 insertions(+), 13 deletions(-)

-- 
2.11.0
