From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.38 0/6] MPLS actions and matches
Date: Fri, 23 Aug 2013 13:16:50 +1000
Message-ID: <1377227816-15303-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This series implements MPLS actions and matches based on work by
Ravi K, Leo Alterman, Yamahata-san and Joe Stringer.

This series provides two changes

* Provide user-space support for the VLAN/MPLS tag insertion order
  up to and including OpenFlow 1.2, and the different ordering
  specified from OpenFlow 1.3. In a nutshell the datapath always
  uses the OpenFlow 1.3 ordering, which is to always insert tags
  immediately after the L2 header, regardless of the presence of other
  tags. And ovs-vswtichd provides compatibility for the behaviour up
  to OpenFlow 1.2, which is that MPLS tags should follow VLAN tags
  if present.

* Adding basic MPLS action and match support to the kernel datapath


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


Patch overview:

* The first 5 patches of this series are new,
  adding support for different tag ordering.
* The last patch is a revised version of the patch to add MPLS support
  to the datapath. It has been updated to use OpenFlow 1.3 tag ordering
  and resolve a GSO handling bug: both mentioned above. Its change log
  includes a history of changes.


To aid review this series is available in git at:

git://github.com/horms/openvswitch.git devel/mpls-v2.38


Patch list and overall diffstat:

Joe Stringer (5):
  odp: Only pass vlan_tci to commit_vlan_action()
  odp: Allow VLAN actions after MPLS actions
  ofp-actions: Add OFPUTIL_OFPAT13_PUSH_MPLS
  ofp-actions: Add separate OpenFlow 1.3 action parser
  lib: Push MPLS tags in the OpenFlow 1.3 ordering

Simon Horman (1):
  datapath: Add basic MPLS support to kernel

 datapath/Modules.mk                             |    1 +
 datapath/actions.c                              |  121 +++++-
 datapath/datapath.c                             |  259 +++++++++++--
 datapath/datapath.h                             |    9 +
 datapath/flow.c                                 |   58 ++-
 datapath/flow.h                                 |   17 +-
 datapath/linux/compat/gso.c                     |   50 ++-
 datapath/linux/compat/gso.h                     |   39 ++
 datapath/linux/compat/include/linux/netdevice.h |   12 -
 datapath/linux/compat/netdevice.c               |   28 --
 datapath/mpls.h                                 |   15 +
 datapath/vport-lisp.c                           |    1 +
 datapath/vport-netdev.c                         |   44 ++-
 include/linux/openvswitch.h                     |    7 +-
 lib/flow.c                                      |    2 +-
 lib/odp-util.c                                  |   22 +-
 lib/odp-util.h                                  |    4 +-
 lib/ofp-actions.c                               |   68 +++-
 lib/ofp-parse.c                                 |    1 +
 lib/ofp-util.c                                  |    3 +
 lib/ofp-util.h                                  |    1 +
 lib/packets.c                                   |   10 +-
 lib/packets.h                                   |    2 +-
 ofproto/ofproto-dpif-xlate.c                    |  103 ++++--
 ofproto/ofproto-dpif-xlate.h                    |    5 +
 tests/ofproto-dpif.at                           |  446 +++++++++++++++++++++++
 26 files changed, 1198 insertions(+), 130 deletions(-)
 create mode 100644 datapath/mpls.h

-- 
1.7.10.4
