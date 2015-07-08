From: sfeldma@gmail.com
Subject: [PATCH net-next 0/5] switchdev: avoid duplicate packet forwarding
Date: Wed,  8 Jul 2015 16:16:38 -0700
Message-ID: <1436397403-62412-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34201 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbbGHXOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:14:12 -0400
Received: by pdbep18 with SMTP id ep18so153259372pdb.1
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 16:14:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This patchset was previously submitted as RFC.  No changes from the last
version (v2) sent under RFC.  Including RFC version history here for reference.

RFC v2:

 - s/fwd_mark/offload_fwd_mark
 - use consume_skb rather than kfree_skb when dropping pkt on egress.
 - Use Jiri's suggestion to use ifindex of one of the ports in a group
   as the mark for all the ports in the group.  This can be done with
   no additional storage (no hashtable from v1).  To pull it off, we
   need some simple recursive routines to walk the netdev tree ensuring
   all leaves in the tree (ports) in the same group (e.g. bridge)
   belonging to the same switch device will have the same offload fwd mark.
   Maybe someone sees a better design for the recusive routines?  They're
   not too bad, and should cover the stacked driver cases.

RFC v1:

With switchdev support for offloading L2/L3 forwarding data path to a
switch device, we have a general problem where both the device and the
kernel may forward the packet, resulting in duplicate packets on the wire.
Anytime a packet is forwarded by the device and a copy is sent to the CPU,
there is potential for duplicate forwarding, as the kernel may also do a
forwarding lookup and send the packet on the wire.

The specific problem this patch series is interested in solving is avoiding
duplicate packets on bridged ports.  There was a previous RFC from Roopa
(http://marc.info/?l=linux-netdev&m=142687073314252&w=2) to address this
problem, but didn't solve the problem of mixed ports in the bridge from
different devices; there was no way to exclude some ports from forwarding
and include others.  This RFC solves that problem by tagging the ingressing
packet with a unique mark, and then comparing the packet mark with the
egress port mark, and skip forwarding when there is a match.  For the mixed
ports bridge case, only those ports with matching marks are skipped.

The switchdev port driver must do two things:

1) Generate a fwd_mark for each switch port, using some unique key of the
   switch device (and optionally port).  This is done when the port netdev
   is registered or if the port's group membership changes (joins/leaves
   a bridge, for example).

2) On packet ingress from port, mark the skb with the ingress port's
   fwd_mark.  If the device supports it, it's useful to only mark skbs
   which were already forwarded by the device.  If the device does not
   support such indication, all skbs can be marked, even if they're
   local dst.

Two new 32-bit fields are added to struct sk_buff and struct netdevice to
hold the fwd_mark.  I've wrapped these with CONFIG_NET_SWITCHDEV for now. I
tried using skb->mark for this purpose, but ebtables can overwrite the
skb->mark before the bridge gets it, so that will not work.

In general, this fwd_mark can be used for any case where a packet is
forwarded by the device and a copy is sent to the CPU, to avoid the kernel
re-forwarding the packet.  sFlow is another use-case that comes to mind,
but I haven't explored the details.

Scott Feldman (5):
  net: don't reforward packets already forwarded by offload device
  net: add phys ID compare helper to test if two IDs are the same
  switchdev: add offload_fwd_mark generator helper
  rocker: add offload_fwd_mark support
  switchdev: update documentation for offload_fwd_mark

 Documentation/networking/switchdev.txt |   14 +++-
 drivers/net/ethernet/rocker/rocker.c   |   14 +++-
 drivers/net/ethernet/rocker/rocker.h   |    1 +
 include/linux/netdevice.h              |   13 ++++
 include/linux/skbuff.h                 |    4 ++
 include/net/switchdev.h                |    9 +++
 net/core/dev.c                         |   10 +++
 net/switchdev/switchdev.c              |  111 ++++++++++++++++++++++++++++++--
 8 files changed, 167 insertions(+), 9 deletions(-)

-- 
1.7.10.4
