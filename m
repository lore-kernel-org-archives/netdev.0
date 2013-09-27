From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.40 0/7] MPLS actions and matches
Date: Fri, 27 Sep 2013 09:18:29 +0900
Message-ID: <1380241116-7661-1-git-send-email-horms@verge.net.au>
Cc: Pravin B Shelar <pshelar@nicira.com>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60349 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823Ab3I0ASo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 20:18:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series implements MPLS actions and matches based on work by
Ravi K, Leo Alterman, Yamahata-san and Joe Stringer.

This series provides two changes

* Patches 1 - 5

  Provide user-space support for the VLAN/MPLS tag insertion order
  up to and including OpenFlow 1.2, and the different ordering
  specified from OpenFlow 1.3. In a nutshell the datapath always
  uses the OpenFlow 1.3 ordering, which is to always insert tags
  immediately after the L2 header, regardless of the presence of other
  tags. And ovs-vswtichd provides compatibility for the behaviour up
  to OpenFlow 1.2, which is that MPLS tags should follow VLAN tags
  if present.

  Ben, these are for you to review.

* Patches 6 and 7

  Adding basic MPLS action and match support to the kernel datapath

  Jesse, these are for you to review.


Differences between v2.40 and v2.39:

* Rebase for:
  + New dev_queue_xmit compat code
  + Updated put_vlan()
  + Removal of mpls_depth field from struct flow
* As suggested by Jesse Gross
  + Remove bogus mac_len update from push_mpls()
  + Slightly simplify push_mpls() by using eth_hdr()
  + Remove dubious condition !eth_p_mpls(inner_protocol) on
    an skb being considered to be MPLS in netdev_send()
  + Only use compatibility code for MPLS GSO segmentation on kernels
    older than 3.11
  + Revamp setting of inner_protocol
    1. Do not unconditionally set inner_protocol to the value of
       skb->protocol in ovs_execute_actions().
    2. Initialise inner_protocol it to zero only if compatibility code is in
       use. In the case where compatibility code is not in use it will either
       be zero due since the allocation of the skb or some other value set
       by some other user.
    3. Conditionally set the inner_protocol in push_mpls() to the value of
       skb->protocol when entering push_mpls(). The condition is that
       inner_protocol is zero and the value of skb->protocol is not an MPLS
       ethernet type.
    - This new scheme:
      + Pushes logic to set inner_protocol closer to the case where it is
	needed.
      + Avoids over-writing values set by other users.
* As suggested by Pravin Shelar
  + Only set and restore skb->protocol in rpl___skb_gso_segment() in the
    case of MPLS
  + Add inner_protocol field to struct ovs_gso_cb instead of ovs_skb_cb.
    This moves compatibility code closer to where it is used
    and creates fewer differences with mainline.
* Update comment on mac_len updates in datapath/actions.c
* Remove HAVE_INNER_PROCOTOL and instead just check
  against kernel version 3.11 directly.
  HAVE_INNER_PROCOTOL is a hang-over from work done prior
  to the merge of inner_protocol into the kernel.
* Remove dubious condition !eth_p_mpls(inner_protocol) on
  using inner_protocol as the type in rpl_skb_network_protocol()
* Do not update type of features in rpl_dev_queue_xmit.
  Though arguably correct this is not an inherent part of
  the changes made by this patch.
* Use skb_cow_head() in push_mpls()
  + Call skb_cow_head(skb, MPLS_HLEN) instead of
    make_writable(skb, skb->mac_len) to ensure that there is enough head
    room to push an MPLS LSE regardless of whether the skb is cloned or not.
  + This is consistent with the behaviour of rpl__vlan_put_tag().
  + This is a fix for crashes reported when performing mpls_push
    with headroom less than 4. This problem was introduced in v3.36.
* Skip popping in mpls_pop if the skb is too short to contain an MPLS LSE


Differences between v2.39 and v2.38:

* Rebase for removal of vlan, checksum and skb->mark compat code
  - This includes adding adding a new patch,
    "[PATCH v2.39 6/7] datapath: Break out deacceleration portion of
    vlan_push" to allow re-use of some existing code.


Differences between v2.38 and v2.37:

* Rebase for SCTP support
* Refactor validate_tp_port() to iterate over eth_types rather
  than open-coding the loop. With the addition of SCTP this logic
  is now used three times.


Differences between v2.37 and v2.36:

* Rebase


Differences between v2.36 and v2.35:

* Rebase

* Do not add set_ethertype() to datapath/actions.c.
  As this patch has evolved this function had devolved into
  to sets of functionality wrapped into a single function with
  only one line of common code. Refactor things to simply
  open-code setting the ether type in the two locations where
  set_ethertype() was previously used. The aim here is to improve
  readability.

* Update setting skb->ethertype after mpls push and pop.
  - In the case of push_mpls it should be set unconditionally
    as in v2.35 the behaviour of this function to always push
    an MPLS LSE before any VLAN tags.
  - In the case of mpls_pop eth_p_mpls(skb->protocol) is a better
    test than skb->protocol != htons(ETH_P_8021Q) as it will give the
    correct behaviour in the presence of other VLAN ethernet types,
    for example 0x88a8 which is used by 802.1ad. Moreover, it seems
    correct to update the ethernet type if it was previously set
    according to the top-most MPLS LSE.

* Deaccelerate VLANs when pushing MPLS tags the
  - Since v2.35 MPLS push will insert an MPLS LSE before any VLAN tags.
    This means that if an accelerated tag is present it should be
    deaccelerated to ensure it ends up in the correct position.

* Update skb->mac_len in push_mpls() so that it will be correct
  when used by a subsequent call to pop_mpls().

  As things stand I do not believe this is strictly necessary as
  ovs-vswitchd will not send a pop MPLS action after a push MPLS action.
  However, I have added this in order to code more defensively as I believe
  that if such a sequence did occur it would be rather unobvious why
  it didn't work.

* Do not add skb_cow_head() call in push_mpls().
  It is unnecessary as there is a make_writable() call.
  This change was also made in v2.30 but some how the
  code regressed between then and v2.35.


Differences between v2.35 and v2.34:

* Add support for the tag ordering specified up until OpenFlow 1.2 and
  the ordering specified from OpenFlow 1.3.

* Correct error in datapath patch's handling of GSO in the presence
  of MPLS and absence of VLANs.


Pre-requisites.

This series applies on top of "[PATCH v3] Remove mpls_depth field from flow"

To aid review this series and its pre-requisite is available in git at:

git://github.com/horms/openvswitch.git devel/mpls-v2.40


Patch list and overall diffstat:

Joe Stringer (5):
  odp: Only pass vlan_tci to commit_vlan_action()
  odp: Allow VLAN actions after MPLS actions
  ofp-actions: Add OFPUTIL_OFPAT13_PUSH_MPLS
  ofp-actions: Add separate OpenFlow 1.3 action parser
  lib: Push MPLS tags in the OpenFlow 1.3 ordering

Simon Horman (2):
  datapath: Break out deacceleration portion of vlan_push
  datapath: Add basic MPLS support to kernel

 datapath/Modules.mk                             |   1 +
 datapath/actions.c                              | 156 ++++++++-
 datapath/datapath.c                             | 259 ++++++++++++--
 datapath/datapath.h                             |   2 +
 datapath/flow.c                                 |  58 ++-
 datapath/flow.h                                 |  17 +-
 datapath/linux/compat/gso.c                     | 117 ++++++-
 datapath/linux/compat/gso.h                     |  53 +++
 datapath/linux/compat/include/linux/netdevice.h |  14 +-
 datapath/linux/compat/netdevice.c               |  28 --
 datapath/mpls.h                                 |  15 +
 include/linux/openvswitch.h                     |   7 +-
 lib/flow.c                                      |   2 +-
 lib/odp-util.c                                  |  21 +-
 lib/odp-util.h                                  |   2 +-
 lib/ofp-actions.c                               |  68 +++-
 lib/ofp-parse.c                                 |   1 +
 lib/ofp-util.c                                  |   3 +
 lib/ofp-util.h                                  |   1 +
 lib/packets.c                                   |  10 +-
 lib/packets.h                                   |   2 +-
 ofproto/ofproto-dpif-xlate.c                    |  98 ++++--
 ofproto/ofproto-dpif-xlate.h                    |   5 +
 tests/ofproto-dpif.at                           | 446 ++++++++++++++++++++++++
 24 files changed, 1246 insertions(+), 140 deletions(-)
 create mode 100644 datapath/mpls.h
