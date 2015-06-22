From: sfeldma@gmail.com
Subject: [PATCH net-next 0/2] switchdev; add VLAN support for port's bridge_getlink
Date: Mon, 22 Jun 2015 00:27:15 -0700
Message-ID: <1434958037-26057-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	vivien.didelot@savoirfairelinux.com, ronen.arad@intel.com,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34993 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879AbbFVHZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 03:25:44 -0400
Received: by pacyo7 with SMTP id yo7so25061700pac.2
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2015 00:25:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

One more missing piece of the puzzle.  Add vlan dump support to switchdev
port's bridge_getlink.  iproute2 "bridge vlan show" cmd already knows how
to show the vlans installed on the bridge and the device , but (until now)
no one implemented the port vlan part of the netlink PF_BRIDGE:RTM_GETLINK
msg.  Before this patch, "bridge vlan show":

	$ bridge -c vlan show
	port    vlan ids
	sw1p1    30-34			<< bridge side vlans
		 57

	sw1p1				<< device side vlans (missing)

	sw1p2    57

	sw1p2

	sw1p3

	sw1p4

	br0     None

(When the port is bridged, the output repeats the vlan list for the vlans
on the bridge side of the port and the vlans on the device side of the
port.  The listing above show no vlans for the device side even though they
are installed).

After this patch:

	$ bridge -c vlan show
	port    vlan ids
	sw1p1    30-34			<< bridge side vlan
		 57

	sw1p1    30-34			<< device side vlans
		 57
		 3840 PVID

	sw1p2    57

	sw1p2    57
		 3840 PVID

	sw1p3    3842 PVID

	sw1p4    3843 PVID

	br0     None


Scott Feldman (2):
  switchdev: rename vlan vid_start to vid_begin
  switchdev; add VLAN support for port's bridge_getlink

 drivers/net/ethernet/emulex/benet/be_main.c   |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c   |    4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    3 +-
 drivers/net/ethernet/rocker/rocker.c          |   29 +++++-
 include/linux/rtnetlink.h                     |    6 +-
 include/net/switchdev.h                       |    2 +-
 net/bridge/br_vlan.c                          |    4 +-
 net/core/rtnetlink.c                          |   18 +++-
 net/switchdev/switchdev.c                     |  135 +++++++++++++++++++++++--
 9 files changed, 183 insertions(+), 20 deletions(-)

-- 
1.7.10.4
