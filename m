From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/4] net/sched: Use TC skip flags to reflect HW offload status
Date: Thu,  9 Feb 2017 16:18:04 +0200
Message-ID: <1486649888-2786-1-git-send-email-ogerlitz@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirva@vadai.me>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52550 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752505AbdBIOSR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:18:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is no way of querying whether a filter is
offloaded to HW or not when using both policy (no flag).

Reuse the skip flags to show the insertion status by setting
the skip_hw flag in case the filter wasn't offloaded.

The bpf patch is compile tested only, Daniel/Jakub, will 
appreciate your review/ack.

I was able to test the u32 patch (as shown below), just one thing
I wasn't sure on is if this matter w.r.t hnodes (vs knodes), John,
could you look and tell me if something is missing?

As an example, add two vlan push + fwd rules over mlx5 SRIOV VF rep, 
one match all and one u32 rule without any flags, which would cause
the TC subsystem to attempt and offload all of them:

#tc filter add dev eth2_0 protocol ip parent ffff: 
  flower indev eth2_0 src_mac e4:11:22:33:44:50 dst_mac e4:1d:2d:a5:f3:9d 
  action vlan push id 52 action mirred egress redirect dev eth2

#tc filter add dev eth2_0 protocol ip parent ffff: 
  flower indev eth2_0 src_mac e4:11:22:33:44:50 dst_mac e4:11:22:33:44:51
  action vlan push id 53 action mirred egress redirect dev eth2

#tc filter add dev eth2_0 parent ffff: matchall action mirred egress mirror dev veth1

Currenly we can only offload one vlan push per VF vport, so the 2nd flower rule is 
not offloaded, same for the matchall and the u32 rules. With this series, user-space 
can note that as the skip_hw flag is set for this rule when they dump it.

#tc  filter show dev eth2_0 parent ffff:

filter protocol ip pref 99 u32 
filter protocol ip pref 99 u32 fh 800: ht divisor 1 
filter protocol ip pref 99 u32 fh 800::1 order 1 key ht 800 bkt 0 flowid 800:1 skip_hw 
  match c0a80100/ffffff00 at 12
	action order 1: gact action drop
	 random type none pass val 0
	 index 17 ref 1 bind 1
 
filter protocol all pref 49150 matchall 
filter protocol all pref 49150 matchall handle 0x1 
  skip_hw
	action order 1: mirred (Egress Mirror to device veth1) pipe
 	index 119 ref 1 bind 1
 
filter protocol ip pref 49151 flower 
filter protocol ip pref 49151 flower handle 0x1 
  indev eth2_0
  dst_mac e4:11:22:33:44:51
  src_mac e4:11:22:33:44:50
  eth_type ipv4
  skip_hw
	action order 1:  vlan push id 53 protocol 802.1Q priority 0 pipe
	 index 56 ref 1 bind 1
 
	action order 2: mirred (Egress Redirect to device eth2) stolen
 	index 118 ref 1 bind 1
 
filter protocol ip pref 49152 flower 
filter protocol ip pref 49152 flower handle 0x1 
  indev eth2_0
  dst_mac e4:1d:2d:a5:f3:9d
  src_mac e4:11:22:33:44:50
  eth_type ipv4
	action order 1:  vlan push id 52 protocol 802.1Q priority 0 pipe
	 index 55 ref 1 bind 1
 
	action order 2: mirred (Egress Redirect to device eth2) stolen
 	index 117 ref 1 bind 1
 
Or Gerlitz (3):
  net/sched: cls_matchall: Dump skip flags and use them to reflect HW offload status
  net/sched: cls_u32: Use skip flags to reflect HW offload status
  net/sched: cls_bpf: Use skip flags to reflect HW offload status

Paul Blakey (1):
  net/sched: cls_flower: Use skip flags to reflect HW offload status

 net/sched/cls_bpf.c      | 17 +++++++++++++----
 net/sched/cls_flower.c   |  7 ++++++-
 net/sched/cls_matchall.c |  6 +++++-
 net/sched/cls_u32.c      | 20 ++++++++++++++------
 4 files changed, 38 insertions(+), 12 deletions(-)

-- 
2.3.7
