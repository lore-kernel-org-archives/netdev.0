From: Simon Horman <simon.horman@netronome.com>
Subject: OVS Offload Decision Proposal
Date: Wed, 4 Mar 2015 10:18:21 +0900
Message-ID: <20150304011817.GA29502@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:42867 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbbCDBSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 20:18:30 -0500
Received: by padfa1 with SMTP id fa1so28754358pad.9
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 17:18:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ CCed netdev as although this is primarily about Open vSwitch userspace
  I believe there are some interested parties not on the Open vSwitch
  dev mailing list ]

Hi,

The purpose of this email is to describe a rough design for driving Open
vSwitch flow offload from user-space. But before getting to that I would
like to provide some background information.

The proposed design is for "OVS Offload Decision": a proposed component of
ovs-vswitchd. In short the top-most red box in the first figure in the
"OVS HW Offload Architecture" document edited by Thomas Graf[1].

[1] https://docs.google.com/document/d/195waUliu7G5YYVuXHmLmHgJ38DFSte321WPq0oaFhyU/edit#heading=h.116je16s8xzw

Assumptions
-----------

There is currently a lively debate on various aspects of flow offloads
within the Linux networking community. As of writing the latest discussion
centers around the "Flows! Offload them." thread[2] on the netdev mailing
list.

[2] http://thread.gmane.org/gmane.linux.network/351860

My aim is not to preempt the outcome of those discussions. But rather to
investigate what offloads might look like in ovs-vswitchd. In order to make
that investigation concrete I have made some assumptions about facilities
that may be provided by the kernel in future. Clearly if the discussions
within the Linux networking community end in a solution that differs from
my assumptions then this work will need to be revisited. Indeed, I entirely
expect this work to be revised and refined and possibly even radically
rethought as time goes on.

That said, my working assumptions are:

* That Open vSwitch may manage flow offloads from user-space. This is as
  opposed to them being transparently handled in the datapath. This does
  not preclude the existence of transparent offloading in the datapath.
  But rather limits this discussion to a mode where offloads are managed
  from user-space.

* That Open vSwitch may add flows to hardware via an API provided by the
  kernel. In particular my working assumption is that the Flow API proposed
  by John Fastabend[3] may be used to add flows to hardware. While the
  existing netlink API may be used to add flows to the kernel datapath.

* That there will be an API provided by the kernel to allow the discovery
  of hardware offload capabilities by user-space. Again my working
  assumption is that the Flow API proposed by John Fastabend[3] may be used
  for this purpose.

[3] http://thread.gmane.org/gmane.linux.network/347188

Rough Design
------------

* Modify flow translation so that the switch parent id[4] of the flow is
  recorded as part of its translation context. The switch parent id was
  recently added to the Linux kernel and provides a common identifier for
  all netdevices that are backed by the same underlying switch hardware for
  some very loose definition of switch. In this scheme if the input and all
  output ports of a flow belong to the same switch hardware then the switch
  id of the translation context would be set accordingly, indicating
  offload of the flow may occur to that switch.

  [4] https://github.com/torvalds/linux/blob/master/Documentation/networking/switchdev.txt

  At this time this excludes both flows that either span multiple switch
  devices or use vports that are not backed directly by netdevices, for
  example tunnel vports. While important I believe these are topics for
  further work.

* At the point where a flow is to be added to the datapath ovs-vswitchd
  should determine if it should be offloaded and if so translate it to a
  flow for the hardware offload API and queue this translated flow up to be
  added to hardware as well as the datapath.

  The translation to hardware flows could be performed along with the
  translation that already occurs from OpenFlow to ODP flows. However, that
  translation is already quite complex and called for a variety of reasons
  other than to prepare flows to be added to the datapath. So I think it
  makes some sense to keep the new translation separate from the existing
  one.

  The determination mentioned above could first check if the switch id is
  set and then may make further checks: for example that there is space in
  the hardware for a new flow, that all the matches and actions of the flow
  may be offloaded.

  There seems to be ample scope for complex logic to determine which flows
  should be offloaded. And I believe that one motivation for handling
  offloads in user-space for such complex logic to live in user-space.
  However, in order to keep things simple in the beginning I propose some
  very simple logic: offload all flows that the hardware supports up until
  the hardware runs out of space.

  This seems like a reasonable start keeping in mind that all flows will
  also be added to the datapath and that ovs-vswitchd constructs flows such
  that they do not overlap.

  A more conservative version of this simple rule would be to remove all
  flows from hardware if a flow is encountered that is not to be added to
  hardware. That is, ensure either all flows that are in hardware are also
  in software or no flows are in hardware at all. This is the approach
  being initially taken for L3 offloads in the Linux kernel[5].

  [5] http://thread.gmane.org/gmane.linux.network/352481/focus=352658

* It seems to me that somewhat tricky problem is how to manage flows in
  hardware. As things stand ovs-vswitchd generally manages flows in the
  datapath by dumping flows, inspecting the dumped flows to see how
  recently they have been used and removing idle flows from the datapath.
  Unfortunately this approach may not be well suited to flows offloaded to
  hardware as dumping flows may be prohibitively expensive. As such I would
  like some consideration given to three approaches. Perhaps in the end all
  will need to be supported. And perhaps there are others:

  1. Dump Flows
     This is the approach currently taken to managing datapath flows. As
     stated above my feeling is that this will not be well suited much
     hardware. However, for simplicity it may be a good place to start.

  2. Notifications
     In this approach flows are added to hardware with a soft timeout and
     hardware removes flows when they timeout sending a notification when
     that occurs. Notifications would be relayed up to user space from the
     driver in the kernel. Some effort may be required to mitigate
     notification storms if many flows are removed in a short space of
     time. It is also of note that there is likely to be hardware that
     can't generate notifications on flow removal.

  3. Aging in hardware
     In this approach flows are added to hardware with a soft timeout and
     hardware removes the flows when they timeout. However no notification
     is generated. And thus ovs-vswitchd has no way of knowing if a flow is
     still present in hardware or not. From a hardware point of view this
     seems to be the simplest to support. But I suspect that it would
     present some significant challenges to ovs-vswitchd in the context of
     its current implementation of flow management. Especially if flows are
     also to be present in the datapath as proposed above.
