From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v16 0/4] Add packet recirculation
Date: Tue, 30 Jul 2013 10:14:29 +0900
Message-ID: <1375146873-3192-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39565 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756442Ab3G3BPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 21:15:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ CC Ethan Jackson.

  Ethan, this makes changes to ofproto-dpif and ofproto-dpif-xlate.
  We would appreciate some feedback with how these changes fit with
  your ongoing refactoring in this area. ]

Recirculation is a technique to allow a frame to re-enter
frame processing. This is intended to be used after actions
have been applied to the frame with modify the frame in
some way that makes it possible for richer processing to occur.

An example is and indeed targeted use case is MPLS. If an MPLS frame has an
mpls_pop action applied with the IPv4 ethernet type then it becomes
possible to decode the IPv4 portion of the frame. This may be used to
construct a facet that modifies the IPv4 portion of the frame. This is not
possible prior to the mpls_pop action as the contents of the frame after
the MPLS stack is not known to be IPv4.


Design:

* New recirculation action.

  ovs-vswitchd adds a recirculation action to the end of a list of
  datapath actions for a flow when the actions are truncated because
  insufficient flow match information is available to add the next
  OpenFlow action.  The recirculation action is preceded by an action
  to set the skb_mark to an id which can be used to scope a facet lookup
  of a recirculated packet.

  e.g.  pop_mpls(0x0800),dec_ttl becomes pop_mpls(0x800),set(skb_mark(id)),recirculate

* Datapath behaviour

  Then the datapath encounters a recirculate action it:
  + Recalculates the flow key based on the packet
    which will typically have been modified by previous actions
  + As the recirculate action is preceded by a set(skb_mark(id)) action,
    the new match key will now include skb_mark=id.
  + Performs a lookup using the new match key
  + Processes the packet if a facet matches the key or;
  + Makes an upcall if necessary

* No facet behaviour

  + Loop:
    1) translate actions
    2) If there is a recirculate action, execute packet
       and go back to 1) for remaining actions.


Base/Pre-requisites:

This series applies to the git master branch on openvswtich.org
and does not have any pre-requisites.


Availability:

To aid review and testing this series is available in git at:

	git://github.com/horms/openvswitch.git devel/mpls-recirculate-v16

N.B: The above branch is based on a merge of the openvswtich.org master
branch and devel/mpls-v2.35. As such it supports both MPLS in
the kernel datapath and recirculation.



Change Log Highlights:

v16
* Ensure that locks are released and memory freed in the case
  of recirculation in dpif_netdev_execute()
* Separate controller and MPLS tests
  - MPLS adds a number of tests and there are already a number 
    of controller tests. It seems to make sense to separate them.
* Do not add reference count to facet
  - This does not appear to be necessary any more as situations
    where the parent-facet of a recirculated child-facet does not exist
    may be handled using the drop rule.
* Do not add 'strict' parameter from get_facet_chain.        
  This is no longer useful as recirculated facets chains
  may me incomplete if parent-facets may be removed before child-facets. 
  This is quite possible now that there is no reference count.
* Clarify comments relating to recirculated facet chain revalidation
* Now based on MPLS datapath "[PATCH v2.35 0/6] MPLS actions and matches"
  Accordingly, a patch is added to this series to allow multiple levels
  of MPLS pop in the kernel datapath. This depends on MPLS support for
  the kernel datapath, which is added in the series mentioned, and
  recirculation, which is added by this series.

v15
* Add additional flow removal tests to cover double,multiple recirculation
* Rebase for ofproto-dpif-xlate modularization
* Replace rule pointers in facet with offsets
 - Use rule offset to determine if facet was created by recirculation
 - Refactor xin->ofpacts initialisation to handle cases where the rule
   has disappeared but the facets still exist

v14
* Enhance "ofproto-dpif: Add 'force-miss-model' configuration" patch
  to use strings.
* Enhance "Add MPLS recirculation tests" to allow testing of remote datapaths
  - this was used to create an environment to test the kernel datapath
* Allow matching of zero skb_mark
 - Include skb_mark in flow key passed from datapath
 - Include skb_mark in flow key constructed from flow if the mask is non-zero
* Set skb_mark mask for recirculated facets during revalidation
* Run through facets in reverse order in facet_revalidate(), so that children
  are always destroyed before their parents.
* Recirculate on more than one pop otherwise intermediate eth type is lost

v13
* Add patch to allow configuration of flow miss handling to force
  handling with or without facets. This is used by the
  patch to exercise recirculation using ofproto-dpif.
* Extensive rebase for megaflow changes

v12
* Rebase
* Add much more extensive tests by Joe Stringer
* Ensure pre_push_mpls_lse is never used uninitialised in do_xlate_actions()
* Copy flow tunnel when recirculating in xlate_and_recirculate().
  This avoids a bug that occurred when recirculating more than once
  and thus using flow_storage as the flow passed to flow_extract()
  and flow_storage.tunnel as the tunnel passed to flow_extract().
  The tunnel parameter passed to flow_extract() must not be
  the tunnel element of its flow parameter.
* In xlate_and_recirculate() ensure that there is sufficient headroom in
  packet for both the key, which is present if xlate_and_recirculate()
  is called by handle_flow_miss_without_facet(), and an MPLS LSE in case
  mpls_push() occurs.
* As suggested by Ben Pfaff
  - Do not unnecessarily rename flow variable in dp_netdev_port_input()
  - Rename tun_key_from_attr() as odp_tun_key_from_attr() as it is now
    exported

v11
* Add patches to handle multiple levels of push and pop
* Addressed review by Jarno Rajahalme

v10
* As suggested by Ben Pfaff
- Rename lib/execute-actions.[ch] as lib/odp-execute.[ch]
- Sort headers in alphabetical order
- Minimise includes in lib/odp-execute.h
- Include lib/odp-execute.h immediately after config.h in lib/odp-execute.c
- Correct coding style of prototype of tun_key_from_attr
- Remove dubious memset from set_tunnel_action
- use {} with if statement for OVS_ACTION_ATTR_OUTPUT in execute_actions()
- Do not put required side effects in conditions for ovs_assert();
- Remove execute_actions_for_recircualtion() helper and
  use odp_execute_actions directly()

v9
* As suggested by Jesse Gross
- Follow the convention on other code that when passing around
  a void pointer and casting it, the variable named with an underscore
  is the void pointer.
- Move extraction of userspace data into execute_actions().
  Previously it was in the userspace callback passed to execute_actions().
- Remove ovs_assert() calls from execute_actions().
  They seem unnecessary at best.
- Reduce the number of new parameters added to functions,
  in many cases to zero, by using the skb_priority, skb_mark
  and tunnel elements of struct flow.
- Add patch to make use of execute_actions() to execute controller actions

v8
* For a learn action recirculate regardless of the value of
  ctx->may_learn in do_xlate_actions(). Previously recirculation
  only occurred if ctx->may_learn was true. That is a bug as it causes
  revalidation to fail. Flagged by the tests developed as part of a patch
  to allow multiple MPLS push and poop actions.
* Update tests removing unnecessary dl_type pre-requisite

v7
* Rebase
* Add skb_priority, skb_mark and tun_key parameters to dp_netdev_port_input()
  This allows the skb_priority, skb_mark and tun_key  to be passed from
  dpif_netdev_execute() to honour corresponding set actions.
* Recirculate on reg load and move, stack push and pop,
  multipath, bundle, and learn actions.
* Add tests

v6
* Rearange patches so as only to add self-contained working chages
* Create execute_actions() in lib/execute-actions.c
  - This moves makes much more action execution code than before
    from the user-spcace datapath into common library code.
* Add set skb_priority support to execute_set_action()
* Add set tunnel support to execute_set_action()
* Support revalidation of facets for recirculated packets
* Address other elements Jesse's review, as noted in
  per-patch changelogs


v5
* Correct declaration of facet_find_by_id to match definition:
  ovs_be32 -> uint32_t.
* Enhancements to recirculation id code:
  - Allow efficient lookup of facets by their recirculation id
  - Add RECIRCULATION_ID_DUMMY which may be used in cases
    where no facet it used. It is an arbitrary valid id.
  - Also add recirculated element to action_xlate_ctx()
    to use to detect if a recirculation action was added during
    translation. The previous scheme of checking if recirculation_id
    was not RECIRCULATION_ID_NONE is broken for cases where
    the context is initialised with a recirculation_id other than
    RECIRCULATION_ID_NONE. E.g. when RECIRCULATION_ID_DUMMY is used.
  - Avoid id collision

rfc4:
* Allow recirculation without facets in ovs-vswitchd
  - Handle flow miss without facet
  - Packet out
* Minor enhancement to recirculation id management: Add RECIRCULATE_ID_NONE
  to use instead of using 0 directly.
* Correct calculation of facet->recirculation_ofpacts and
  facet->recirculation_ofpacts_len in subfacet_make_actions()
  in the case of more than one level of recirculation.

rfc3
* Use IS_ERR_OR_NULL()
* Handle facet consistency checking by constructing a chain of facets
  from the given facet, to its recirculation parent and then its parent
  until the topmost facet.  If there is no recirculation  the chain will
  be of length one. If there is one recirculation action then the chain
  will be of length two. And so on.

  The topmost facet in the chain can is used to lookup the rule to be
  verified. The chain is then walked from top to bottom, translating
  actions up to the end or the first recirculation action that is
  encountered, whichever comes first. As the code walks down the chain
  it updates the actions that are executed to start of the actions to
  be executed to be just after the end of the actions executed in the
  previous facet in the chain. This is similar to the way that facets
  are created when a recirculation action is encountered.

rfc2
* As suggested by Jesse Gross
  - Update for changes to ovs_dp_process_received_packet()
    to no longer check if OVS_CB(skb)->flow is pre-initialised.
  - Do not add spurious printk debugging to ovs_execute_actions()
  - Do not add spurious debugging messages to commit_set_nw_action()
  - Correct typo in comment above commit_odp_actions().
  - Do not execute recirculation in ovs-vswitchd, rather allow
    the datapath to make an upcall when a recirculation action
    is encountered on execute.
    + This implicitly breaks support for recirculation without facets,
      so for now force all misses of MPLS frames to be handled with
      a facet; and treat handling of recirculation for packet_out as
      a todo item.
  - Use skb_mark for recirculation_id in match. This avoids
    both expanding the match and including a recirculation_id parameter
    with the recirculation action: set_skb_mark should be used before
    the recirculation action.
  - Tidy up ownership of skb in ovs_execute_actions

rfc1
* Initial post


Patch List and Diffstat:

Joe Stringer (2):
  ofproto-dpif: Add 'force-miss-model' configuration
  Add MPLS recirculation tests

Simon Horman (2):
  Add packet recirculation
  Allow multiple levels of MPLS push and pop

 datapath/actions.c           |   9 +-
 datapath/datapath.c          | 105 +++---
 datapath/datapath.h          |   2 +-
 datapath/flow.c              |   5 +-
 include/linux/openvswitch.h  |   4 +
 lib/dpif-netdev.c            |  79 +++--
 lib/flow.c                   |   6 +-
 lib/flow.h                   |  13 +-
 lib/list.h                   |   6 +
 lib/match.c                  |   2 +-
 lib/nx-match.c               |   2 +-
 lib/odp-execute.c            |   7 +-
 lib/odp-execute.h            |   3 +-
 lib/odp-util.c               |  69 ++--
 lib/odp-util.h               |   3 +-
 lib/ofp-actions.c            |   6 -
 lib/ofp-util.c               |   5 +-
 lib/packets.c                |  33 +-
 lib/packets.h                |   2 -
 ofproto/ofproto-dpif-xlate.c | 293 +++++++++++++++--
 ofproto/ofproto-dpif-xlate.h |  27 +-
 ofproto/ofproto-dpif.c       | 580 ++++++++++++++++++++++++++++++---
 ofproto/ofproto-dpif.h       |   7 +-
 ofproto/ofproto-provider.h   |   4 +
 ofproto/ofproto.c            |   8 +
 ofproto/ofproto.h            |   8 +
 tests/automake.mk            |   1 +
 tests/ofproto-dpif.at        | 752 +++++++++++++++++++++++++++++++++++++++++--
 tests/test-bundle.c          |   1 -
 tests/test-mpls.py           | 491 ++++++++++++++++++++++++++++
 tests/test-multipath.c       |   1 -
 utilities/ovs-dpctl.c        |   2 +-
 utilities/ovs-ofctl.8.in     |  20 +-
 vswitchd/bridge.c            |  23 ++
 vswitchd/vswitch.xml         |  22 ++
 35 files changed, 2329 insertions(+), 272 deletions(-)
 create mode 100644 tests/test-mpls.py

-- 
1.8.2.1

_______________________________________________
dev mailing list
dev@openvswitch.org
http://openvswitch.org/mailman/listinfo/dev


Joe Stringer (1):
  Add MPLS recirculation tests

Simon Horman (2):
  Add packet recirculation
  Allow multiple levels of MPLS push and pop

 datapath/actions.c           |   9 +-
 datapath/datapath.c          | 105 ++++--
 datapath/datapath.h          |   2 +-
 datapath/flow.c              |   5 +-
 include/linux/openvswitch.h  |   4 +
 lib/dpif-netdev.c            |  79 +++--
 lib/flow.c                   |   6 +-
 lib/flow.h                   |  13 +-
 lib/match.c                  |   2 +-
 lib/nx-match.c               |   2 +-
 lib/odp-execute.c            |   7 +-
 lib/odp-execute.h            |   3 +-
 lib/odp-util.c               |  68 ++--
 lib/odp-util.h               |   3 +-
 lib/ofp-actions.c            |   6 -
 lib/ofp-actions.h            |   6 +
 lib/ofp-util.c               |   5 +-
 lib/packets.c                |  33 +-
 lib/packets.h                |   2 -
 ofproto/ofproto-dpif-xlate.c | 304 +++++++++++++++--
 ofproto/ofproto-dpif-xlate.h |  27 +-
 ofproto/ofproto-dpif.c       | 521 +++++++++++++++++++++++++++--
 ofproto/ofproto-dpif.h       |   5 +
 tests/automake.mk            |   1 +
 tests/ofproto-dpif.at        | 780 +++++++++++++++++++++++++++++++++++++++++--
 tests/test-bundle.c          |   1 -
 tests/test-mpls.py           | 491 +++++++++++++++++++++++++++
 tests/test-multipath.c       |   1 -
 utilities/ovs-dpctl.c        |   2 +-
 utilities/ovs-ofctl.8.in     |  20 +-
 30 files changed, 2260 insertions(+), 253 deletions(-)
 create mode 100644 tests/test-mpls.py

-- 
1.8.2.1

_______________________________________________
dev mailing list
dev@openvswitch.org
http://openvswitch.org/mailman/listinfo/dev


Joe Stringer (1):
  Add MPLS recirculation tests

Simon Horman (3):
  Add packet recirculation
  Allow multiple levels of MPLS push and pop
  datapath: Enable multiple levels of MPLS pop

 datapath/actions.c           |    9 +-
 datapath/datapath.c          |  116 +++--
 datapath/datapath.h          |    2 +-
 datapath/flow.c              |    5 +-
 include/linux/openvswitch.h  |    4 +
 lib/dpif-netdev.c            |   80 +++-
 lib/flow.c                   |    6 +-
 lib/flow.h                   |   13 +-
 lib/match.c                  |    2 +-
 lib/nx-match.c               |    2 +-
 lib/odp-execute.c            |    7 +-
 lib/odp-execute.h            |    3 +-
 lib/odp-util.c               |   69 +--
 lib/odp-util.h               |    5 +-
 lib/ofp-actions.c            |    6 -
 lib/ofp-actions.h            |    6 +
 lib/ofp-util.c               |    5 +-
 lib/packets.c                |   33 +-
 lib/packets.h                |    2 -
 ofproto/ofproto-dpif-xlate.c |  307 ++++++++++--
 ofproto/ofproto-dpif-xlate.h |   27 +-
 ofproto/ofproto-dpif.c       |  504 ++++++++++++++++++--
 ofproto/ofproto-dpif.h       |    5 +
 tests/automake.mk            |    1 +
 tests/ofproto-dpif.at        | 1077 ++++++++++++++++++++++++++++++++++++------
 tests/test-bundle.c          |    1 -
 tests/test-mpls.py           |  491 +++++++++++++++++++
 tests/test-multipath.c       |    1 -
 utilities/ovs-dpctl.c        |    2 +-
 utilities/ovs-ofctl.8.in     |   20 +-
 30 files changed, 2417 insertions(+), 394 deletions(-)
 create mode 100644 tests/test-mpls.py

-- 
1.8.3.2
