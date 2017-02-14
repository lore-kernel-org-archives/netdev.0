From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 0/6] net/sched: Reflect HW offload status
Date: Tue, 14 Feb 2017 16:30:34 +0200
Message-ID: <1487082640-24813-1-git-send-email-ogerlitz@mellanox.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54493 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752597AbdBNOay (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 09:30:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is no way of querying whether a filter is
offloaded to HW or not when using "both" policy (where none
of skip_sw or skip_hw flags are set by user-space).

Added two new flags, "in hw" and "not in hw" such that user space 
can determine if a filter is actually offloaded to hw. The "in hw" 
UAPI semantics was chosen so it's similar to the "skip hw" flag logic.

If none of these two flags are set, this signals running
over older kernel.

As an example, add one vlan push + fwd rules over mlx5 SRIOV VF rep, 
one match all and one u32 rule without any flags, and another vlan + fwd
skip_sw rule over the VF rep, such that the TC attempt and offload all of them:

# tc filter add dev eth2_0 protocol ip parent ffff: 
	flower skip_sw indev eth2_0 src_mac e4:11:22:33:44:50 dst_mac e4:1d:2d:a5:f3:9d 
	action vlan push id 52 action mirred egress redirect dev eth2

# tc filter add dev eth2_0 protocol ip parent ffff: 
	flower indev eth2_0 src_mac e4:11:22:33:44:50 dst_mac e4:11:22:33:44:51 
	action vlan push id 53 action mirred egress redirect dev eth2

# tc filter add dev eth2_0 parent ffff: matchall action mirred egress mirror dev veth1

# tc filter add dev eth2_0 parent ffff: protocol ip prio 99 handle 800:0:1 
	u32 ht 800: flowid 800:1 match ip src 192.168.1.0/24 action drop

# tc filter show dev eth2_0 parent ffff:

filter protocol ip pref 99 u32 
filter protocol ip pref 99 u32 fh 800: ht divisor 1 
filter protocol ip pref 99 u32 fh 800::1 order 1 key ht 800 bkt 0 flowid 800:1 not in_hw 
  match c0a80100/ffffff00 at 12
	action order 1: gact action drop
	 random type none pass val 0
	 index 8 ref 1 bind 1
 
filter protocol all pref 49150 matchall 
filter protocol all pref 49150 matchall handle 0x1 
  not in_hw
	action order 1: mirred (Egress Mirror to device veth1) pipe
 	index 27 ref 1 bind 1
 
filter protocol ip pref 49151 flower 
filter protocol ip pref 49151 flower handle 0x1 
  indev eth2_0
  dst_mac e4:11:22:33:44:51
  src_mac e4:11:22:33:44:50
  eth_type ipv4
  not in_hw
	action order 1:  vlan push id 53 protocol 802.1Q priority 0 pipe
	 index 20 ref 1 bind 1
 
	action order 2: mirred (Egress Redirect to device eth2) stolen
 	index 26 ref 1 bind 1
 
filter protocol ip pref 49152 flower 
filter protocol ip pref 49152 flower handle 0x1 
  indev eth2_0
  dst_mac e4:1d:2d:a5:f3:9d
  src_mac e4:11:22:33:44:50
  eth_type ipv4
  skip_sw
  in_hw
	action order 1:  vlan push id 52 protocol 802.1Q priority 0 pipe
	 index 19 ref 1 bind 1
 
	action order 2: mirred (Egress Redirect to device eth2) stolen
 	index 25 ref 1 bind 1
 
v1 --> v2 changes:
 - applied feedback from Jakub and Dave -- where none of the skip flags were set, 
   the suggested approach didn't allow user space to distringuish between old kernel
   to a case when offloading to HW worked fine.

Or Gerlitz (6):
  net/sched: cls_matchall: Dump skip flags
  net/sched: Reflect HW offload status
  net/sched: cls_flower: Reflect HW offload status
  net/sched: cls_matchall: Reflect HW offloading status
  net/sched: cls_u32: Reflect HW offload status
  net/sched: cls_bpf: Reflect HW offload status

 include/net/pkt_cls.h        |  5 +++++
 include/uapi/linux/pkt_cls.h |  6 ++++--
 net/sched/cls_bpf.c          | 13 +++++++++++--
 net/sched/cls_flower.c       |  5 +++++
 net/sched/cls_matchall.c     | 14 ++++++++++++--
 net/sched/cls_u32.c          | 10 ++++++++++
 6 files changed, 47 insertions(+), 6 deletions(-)

-- 
2.3.7
