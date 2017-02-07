From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V3 0/3] net/sched: act_pedit: Use offset relative to conventional network headers
Date: Tue,  7 Feb 2017 09:56:05 +0200
Message-ID: <20170207075608.8430-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36531 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752003AbdBGH4Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 02:56:24 -0500
Received: by mail-wr0-f193.google.com with SMTP id k90so4942971wrc.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 23:56:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Some FW/HW parser APIs are such that they need to get the specific header type (e.g
IPV4 or IPV6, TCP or UDP) and not only the networking level (e.g network or transport).

Enhancing the UAPI to allow for specifying that, would allow the same flows to be
set into both SW and HW.

This patchset also makes pedit more robust. Currently fields offset is specified
by offset relative to the ip header, while using negative offsets for 
MAC layer fields.

This series enables the user to set offset relative to the relevant header.

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

Patchset was tested and applied on top of upstream commit bd092ad1463c ("Merge
branch 'remove-__napi_complete_done'")

Thanks,
Amir

Changes since V2:
- Instead of reusing unused bits in existing uapi fields, using new netlink
	attributes for the new information. This way new/old user space and new/old
	kernel can live together without having misunderstandings.

Changes since V1:
- No changes - V1 was sent and didn't make it for 4.10.
- You asked me [1] why did I use specific header names instead of layers (L2,
	L3...), and I explained that it is on purpose, this extra information is
	planned to be used by hardware drivers to offload the action.


Amir Vadai (3):
  net/skbuff: Introduce skb_mac_offset()
  net/act_pedit: Support using offset relative to the conventional
    network headers
  net/act_pedit: Introduce 'add' operation

 include/linux/skbuff.h               |   5 +
 include/net/tc_act/tc_pedit.h        |   6 +
 include/uapi/linux/tc_act/tc_pedit.h |  31 +++++
 net/sched/act_pedit.c                | 220 ++++++++++++++++++++++++++++++++---
 4 files changed, 245 insertions(+), 17 deletions(-)

-- 
2.11.0
