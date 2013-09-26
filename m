From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v4 0/3] bonding: modify the current and add new hash functions
Date: Thu, 26 Sep 2013 18:13:41 +0200
Message-ID: <1380212024-3417-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441Ab3IZQRV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 12:17:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
This is a complete remake of my old patch that modified the bonding hash
functions to use skb_flow_dissect which was suggested by Eric Dumazet.
This time around I've left the old modes although using a new hash function
again suggested by Eric, which is the same for all modes. The only
difference is the way the headers are obtained. The old modes obtain them
as before in order to address concerns about speed, but the 2 new ones use
skb_flow_dissect. The unification of the hash function allows to remove a
pointer from struct bonding and also a few extra functions that dealt with
it. Two new functions are added which take care of the hashing based on
bond->params.xmit_policy only:
bond_xmit_hash() - global function, used by XOR and 3ad modes
bond_flow_dissect() - used by bond_xmit_hash() to obtain the necessary
headers and combine them according to bond->params.xmit_policy.
Also factor out the ports extraction from skb_flow_dissect and add a new
function - skb_flow_get_ports() which can be re-used.

v2: add the flow_dissector patch and use skb_flow_get_ports in patch 02
v3: fix a bug in the flow_dissector patch that caused a different thoff
    by modifying the thoff argument in skb_flow_get_ports directly, most
    of the users already do it anyway.
    Also add the necessary export symbol for skb_flow_get_ports.
v4: integrate the thoff bug fix in patch 01

Best regards,
 Nikolay Aleksandrov


Nikolay Aleksandrov (3):
  flow_dissector: factor out the ports extraction in skb_flow_get_ports
  bonding: modify the old and add new xmit hash policies
  bonding: document the new xmit policy modes and update the changed
    ones

 Documentation/networking/bonding.txt |  66 ++++++------
 drivers/net/bonding/bond_3ad.c       |   2 +-
 drivers/net/bonding/bond_main.c      | 197 ++++++++++++-----------------------
 drivers/net/bonding/bond_sysfs.c     |   2 -
 drivers/net/bonding/bonding.h        |   3 +-
 include/net/flow_keys.h              |   1 +
 include/uapi/linux/if_bonding.h      |   2 +
 net/core/flow_dissector.c            |  39 +++++--
 8 files changed, 137 insertions(+), 175 deletions(-)

-- 
1.8.1.4
