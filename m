From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 0/3] net/sched: act_pedit: Support using offset relative to the conventional network headers
Date: Wed, 30 Nov 2016 11:09:25 +0200
Message-ID: <20161130090928.14816-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:34136 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756425AbcK3JJs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 04:09:48 -0500
Received: by mail-wj0-f194.google.com with SMTP id xy5so21299965wjc.1
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 01:09:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Patch 1/3 ("net/skbuff: Introduce skb_mac_offset()") adds a utility function to
get mac header offset.

Patch 2/3 ("net/act_pedit: Support using offset relative to the conventional
network headers") extends pedit to enable the user to set offset relative to
MAC/IPv4/IPv6/TCP network headers.
This would enable to work with more complex header schemes (vs the simple IPv4
case) where setting a fixed offset relative to the network header is not
enough. It is also forward looking to enable hardware offloading of pedit more
easier.

The header type is embedded in the 8 MSB of the u32 key->shift which
were never used till now. Therefore backward compatibility is being
kept.

Patch 3/3 ("net/act_pedit: Introduce 'add' operation") add a new operation to
increase the value of a header field. The operation is passed on another free
8bit in the key->shift.

Usage example:
$ tc filter add dev enp0s9 protocol ip parent ffff: \
  flower \
    ip_proto tcp \
    src_port 80 \
  action \
	  pedit munge ip ttl add 0xff \
	  pedit munge tcp dport set 8080 \
	pipe action mirred egress redirect dev veth0

Will forward traffic with tcp dport 80, and modify the destination port to
8080, and decrease the ttl by 1.

I've uploaded a draft for the userspace [2] to make it easier to review and
test the patchset.

The patchset will conflict if already accepted patch [1] from net is missing.
It was applied and tested with [1] on top of commit 93ba22225504 ("hv_netvsc:
remove excessive logging on MTU change").

[1] - 95c2027bfeda ("net/sched: pedit: make sure that offset is valid")
[2] - git: https://bitbucket.org/av42/iproute2.git
      branch: pedit

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
2.10.2
