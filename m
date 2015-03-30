From: Tim Niemeyer <tim.niemeyer@corscience.de>
Subject: [3.4 PATCH] Bluetooth: Fix invalid length check in l2cap_information_rsp()
Date: Mon, 30 Mar 2015 11:27:37 +0200
Message-ID: <1427707657-28545-1-git-send-email-tim.niemeyer@corscience.de>
Cc: Jaganath Kanakkassery <jaganath.k@samsung.com>,
	Chan-Yeol Park <chanyeol.park@samsung.com>,
	Gustavo Padovan <gustavo.padovan@collabora.co.uk>,
	Jianguo Wu <wujianguo@huawei.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

first backport commit 6ec88fcb4aa2c33fe2fe2a23c576a7e2581c5c3d changes
l2cap_move_channel_confirm_rsp and not the l2cap_information_rsp. So
revert this and fix at the correct position.

commit 3f6fa3d489e127ca5a5b298eabac3ff5dbe0e112 upstream.

The length check is invalid since the length varies with type of
info response.

This was introduced by the commit cb3b3152b2f5939d67005cff841a1ca748b19888

Because of this, l2cap info rsp is not handled and command reject is sent.

> ACL data: handle 11 flags 0x02 dlen 16
        L2CAP(s): Info rsp: type 2 result 0
          Extended feature mask 0x00b8
            Enhanced Retransmission mode
            Streaming mode
            FCS Option
            Fixed Channels
< ACL data: handle 11 flags 0x00 dlen 10
        L2CAP(s): Command rej: reason 0
          Command not understood

Cc: stable@vger.kernel.org
Signed-off-by: Jaganath Kanakkassery <jaganath.k@samsung.com>
Signed-off-by: Chan-Yeol Park <chanyeol.park@samsung.com>
Signed-off-by: Gustavo Padovan <gustavo.padovan@collabora.co.uk>
Cc: Jianguo Wu <wujianguo@huawei.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Tim Niemeyer <tim.niemeyer@corscience.de>
Acked-by: Johan Hedberg <johan.hedberg@intel.com>
---
Patch for 3.4-stable.

 net/bluetooth/l2cap_core.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 3bb535b..c11fd9e 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -3239,7 +3239,7 @@ static inline int l2cap_information_rsp(struct l2cap_conn *conn,
 	struct l2cap_info_rsp *rsp = (struct l2cap_info_rsp *) data;
 	u16 type, result;
 
-	if (cmd_len != sizeof(*rsp))
+	if (cmd_len < sizeof(*rsp))
 		return -EPROTO;
 
 	type   = __le16_to_cpu(rsp->type);
@@ -3445,7 +3445,7 @@ static inline int l2cap_move_channel_confirm_rsp(struct l2cap_conn *conn,
 	struct l2cap_move_chan_cfm_rsp *rsp = data;
 	u16 icid;
 
-	if (cmd_len < sizeof(*rsp))
+	if (cmd_len != sizeof(*rsp))
 		return -EPROTO;
 
 	icid = le16_to_cpu(rsp->icid);
-- 
1.7.10.4
