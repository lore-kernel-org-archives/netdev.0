From: Jan Altenberg <jan@linutronix.de>
Subject: [PATCH resend] can: c_can: Fix tx_bytes accounting
Date: Thu, 24 Mar 2011 12:26:50 +0100
Message-ID: <1300966010.3295.40.camel@localhost>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
	 <D5ECB3C7A6F99444980976A8C6D896384DF0D6F721@EAPEX1MAIL1.st.com>
	 <1300963120.3295.7.camel@localhost>  <4D8B1641.6000706@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bhupesh SHARMA <bhupesh.sharma@st.com>,
	"kurt.van.dijck@eia.be" <kurt.van.dijck@eia.be>,
	"b.spranger@linutronix.de" <b.spranger@linutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Socketcan-core@lists.berlios.de" <Socketcan-core@lists.berlios.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:32935 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932907Ab1CXKcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 06:32:43 -0400
In-Reply-To: <4D8B1641.6000706@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current SocketCAN implementation for the Bosch c_can cell doesn't
account the TX bytes correctly, because it calls
c_can_inval_msg_object() (which clears the msg ctrl register) before
reading the DLC value:

for (/* nix */; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
        msg_obj_no = get_tx_echo_msg_obj(priv);
        c_can_inval_msg_object(dev, 0, msg_obj_no);
        val = c_can_read_reg32(priv, &priv->regs->txrqst1);
        if (!(val & (1 << msg_obj_no))) {
                can_get_echo_skb(dev,
                                msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
                stats->tx_bytes += priv->read_reg(priv,
                                &priv->regs->ifregs[0].msg_cntrl)
                                & IF_MCONT_DLC_MASK;
                stats->tx_packets++;
        }
}

So, we will always read 0 for the DLC value and "ifconfig" will report
*0* TX Bytes.

The fix is quite easy: Just move c_can_inval_msg_object() to the end of
the if() statement. So:
      * We only call c_can_inval_msg_object() if the message was
        actually transmitted
      * We read out the DLC value _before_ clearing the msg ctrl
        register

Signed-off-by: Jan Altenberg <jan@linutronix.de>
---
diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index 110eda0..f895c04 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -704,7 +704,6 @@ static void c_can_do_tx(struct net_device *dev)
 
 	for (/* nix */; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
 		msg_obj_no = get_tx_echo_msg_obj(priv);
-		c_can_inval_msg_object(dev, 0, msg_obj_no);
 		val = c_can_read_reg32(priv, &priv->regs->txrqst1);
 		if (!(val & (1 << msg_obj_no))) {
 			can_get_echo_skb(dev,
@@ -713,6 +712,7 @@ static void c_can_do_tx(struct net_device *dev)
 					&priv->regs->ifregs[0].msg_cntrl)
 					& IF_MCONT_DLC_MASK;
 			stats->tx_packets++;
+			c_can_inval_msg_object(dev, 0, msg_obj_no);
 		}
 	}
 


