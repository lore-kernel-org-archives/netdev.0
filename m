From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 11/18] Bluetooth: Fix unset of SrejActioned flag
Date: Thu,  3 Dec 2009 19:45:48 +0100
Message-ID: <889a3ca466018ab68363c3168993793bc2d984f1.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
 <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
 <5990108cfcd3eb2d365c9ea6f82318be80c4e9d3.1259865280.git.marcel@holtmann.org>
 <329ab1b3e6ceac3f77ab400206a97cc402624259.1259865280.git.marcel@holtmann.org>
 <fed4c2508b7419d0a55958fead6151b32def1683.1259865280.git.marcel@holtmann.org>
 <2da31939a42f7a676a0bc5155d6a0a39ed8451f2.1259865280.git.marcel@holtmann.org>
 <7e21addcd0ad87696c17409399e56e874931da57.1259865280.git.marcel@holtmann.org>
 <76bca88012e1d27de794f32cc551d6314d38b6d9.1259865280.git.marcel@holtmann.org>
 <c78ae283145d3a8799b2fb01650166a66af3bff8.1259865280.git.marcel@holtmann.org>
 <cde9f807f003676862178a6f28b52c7d431511ed.1259865280.git.marcel@holtmann.org>
 <0565c1c24af94130b891f989fa608faddfadc52c.1259865280.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37647 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756530AbZLCSqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:46:00 -0500
In-Reply-To: <0565c1c24af94130b891f989fa608faddfadc52c.1259865280.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

SrejActioned  is a flag that when set prevents local side to retransmit a
I-frame(the data frame) already retransmitted. The local entity can
retransmit again only when it receives a SREJ frame with the F-bit set.
SREJ frame - Selective Reject frame  - is sent when an entity wants the
retransmission of a specific I-frame that was lost or corrupted.
This bug can put ERTM in an unknown state once the entity can't
retransmit.
A frame with the Final bit set is expected when the local side sends a
frame with the Poll bit set due to a local busy condition or a
retransmission timer expired. (Receipt of P-bit shall always be replied by
a frame with the F-bit set).
pi->conn_state keeps informations about many ERTM flags including
SrejActioned.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index dfd0327..2d5d375 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3443,7 +3443,7 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 		} else if (rx_control & L2CAP_CTRL_FINAL) {
 			if ((pi->conn_state & L2CAP_CONN_SREJ_ACT) &&
 					pi->srej_save_reqseq == tx_seq)
-				pi->srej_save_reqseq &= ~L2CAP_CONN_SREJ_ACT;
+				pi->conn_state &= ~L2CAP_CONN_SREJ_ACT;
 			else
 				l2cap_retransmit_frame(sk, tx_seq);
 		}
-- 
1.6.5.2

