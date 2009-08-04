From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] igbvf: Allow VF driver to correctly recognize failure
	to set mac
Date: Tue, 04 Aug 2009 10:21:04 -0700
Message-ID: <20090804172103.23659.5847.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:58420
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932811AbZHDRVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 13:21:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The VF driver was not correctly recognizing that it did not correctly set
it's mac address.  As a result the VF driver was unable to receive network
traffic until being unloaded and reloaded.  The issue was root caused to
the fact that the CTS bit was not taken into account when checking for the
request being NAKed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/vf.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igbvf/vf.c b/drivers/net/igbvf/vf.c
index 2a4faf9..a9a61ef 100644
--- a/drivers/net/igbvf/vf.c
+++ b/drivers/net/igbvf/vf.c
@@ -274,6 +274,8 @@ static s32 e1000_set_vfta_vf(struct e1000_hw *hw, u16 vid, bool set)
 
 	err = mbx->ops.read_posted(hw, msgbuf, 2);
 
+	msgbuf[0] &= ~E1000_VT_MSGTYPE_CTS;
+
 	/* if nacked the vlan was rejected */
 	if (!err && (msgbuf[0] == (E1000_VF_SET_VLAN | E1000_VT_MSGTYPE_NACK)))
 		err = -E1000_ERR_MAC_INIT;
@@ -317,6 +319,8 @@ static void e1000_rar_set_vf(struct e1000_hw *hw, u8 * addr, u32 index)
 	if (!ret_val)
 		ret_val = mbx->ops.read_posted(hw, msgbuf, 3);
 
+	msgbuf[0] &= ~E1000_VT_MSGTYPE_CTS;
+
 	/* if nacked the address was rejected, use "perm_addr" */
 	if (!ret_val &&
 	    (msgbuf[0] == (E1000_VF_SET_MAC_ADDR | E1000_VT_MSGTYPE_NACK)))

