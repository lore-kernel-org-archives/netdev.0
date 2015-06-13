From: sfeldma@gmail.com
Subject: [RFC PATCH net-next 0/4] switchdev: avoid duplicate packet forwarding
Date: Sat, 13 Jun 2015 11:04:26 -0700
Message-ID: <1434218670-43821-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	roopa@cumulusnetworks.com, ronen.arad@intel.com,
	john.r.fastabend@intel.com, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, davidch@broadcom.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34359 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022AbbFMSCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 14:02:35 -0400
Received: by iebmu5 with SMTP id mu5so40905629ieb.1
        for <netdev@vger.kernel.org>; Sat, 13 Jun 2015 11:02:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

(RFC because we're at rc7+ now)

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
   switch device (and optionally port).  This is a one-time operation done
   when port's netdev is setup.

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

Scott Feldman (4):
  net: don't reforward packets already forwarded by offload device
  switchdev: add fwd_mark generator helper
  rocker: add fwd_mark support
  switchdev: update documentation for fwd_mark

 Documentation/networking/switchdev.txt |   13 +++++-
 drivers/net/ethernet/rocker/rocker.c   |   24 +++++++++++
 drivers/net/ethernet/rocker/rocker.h   |    1 +
 include/linux/netdevice.h              |    6 +++
 include/linux/skbuff.h                 |    4 ++
 include/net/switchdev.h                |    6 +++
 net/core/dev.c                         |    9 ++++
 net/switchdev/switchdev.c              |   72 ++++++++++++++++++++++++++++++++
 8 files changed, 133 insertions(+), 2 deletions(-)

-- 
1.7.10.4
