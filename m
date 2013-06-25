From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v5 0/6] vxlan: allow specifying multiple default destinations
Date: Tue, 25 Jun 2013 16:01:50 +0300
Message-ID: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog102.obsmtp.com ([74.125.245.72]:52924 "HELO
	na3sys010aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751082Ab3FYNCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 09:02:05 -0400
Received: by mail-we0-f180.google.com with SMTP id w56so8997050wes.25
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 06:02:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add ability to specify multiple default destinations to
vxlan. This ability is usefull in cases when multicast are disabled on
infrastructure level, for instance in public clouds.

The default destinations list is managed via the fdb entry with
"00:00:00:00:00:00" MAC address and does not require changes to vxlan
netlink API.

The default destinations can be added/deleted using 'bridge fdb'
commands, e.g:

# ip link add vxlan0 type vxlan id 23 group 239.1.1.1 dev eth0
# bridge fdb show dev vxlan0
00:00:00:00:00:00 dst 239.1.1.1 self permanent

# bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst 54.242.49.246
# bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst 23.22.26.34
# bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst 184.72.129.120
# bridge fdb show dev vxlan0
00:00:00:00:00:00 dst 239.1.1.1 self permanent
00:00:00:00:00:00 dst 54.242.49.246 self permanent
00:00:00:00:00:00 dst 23.22.26.34 self permanent
00:00:00:00:00:00 dst 184.72.129.120 self permanent

# bridge fdb delete 00:00:00:00:00:00 dev vxlan0 dst 23.22.26.34
# bridge fdb append 00:00:00:00:00:00 dev vxlan0 dst 54.242.49.246
# bridge fdb show dev vxlan0
00:00:00:00:00:00 dst 239.1.1.1 self permanent
00:00:00:00:00:00 dst 184.72.129.120 self permanent

Since v5 is complete rework, I've dropped prevoius changelog as not relevant.

Mike Rapoport (6):
  vxlan: add implicit fdb entry for default destination
  vxlan: introduce vxlan_fdb_find_rdst
  vxlan: introduce vxlan_fdb_parse
  vxlan: allow removal of single destination from fdb entry
  rtnetlink: allow using zero MAC address in rtnl_fdb_{add,del}
  vxlan: fdb: allow specifying multiple destinations for zero MAC

 drivers/net/vxlan.c  | 219 +++++++++++++++++++++++++++++++++++++--------------
 net/core/rtnetlink.c |   8 --
 2 files changed, 159 insertions(+), 68 deletions(-)

-- 
1.8.1.5
