From: "Jan Altenberg" <jan@linutronix.de>
Subject: can: c_can: TX handling
Date: Tue, 22 Mar 2011 16:59:23 +0100
Message-ID: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: wg@grandegger.com, kurt.van.dijck@eia.be, b.spranger@linutronix.de,
	netdev@vger.kernel.org
To: bhupesh.sharma@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:53881 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751368Ab1CVQaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 12:30:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I did some more testing on the SocketCAN driver for the Bosch c_can
controller and I observed some strange behaviour for the TX handling.
First of all the TX bytes are not accounted correctly. The reason for that
seems to be quite obvious if we look into c_can_do_tx():

[...]

c_can_inval_msg_object(dev, 0, msg_obj_no);
val = c_can_read_reg32(priv, &priv->regs->txrqst1);
if (!(val & (1 << msg_obj_no))) {
        can_get_echo_skb(dev,
                        msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
        stats->tx_bytes += priv->read_reg(priv,
                        &priv->regs->ifregs[0].msg_cntrl)
                        & IF_MCONT_DLC_MASK;

So, we first invalidate the message object and afterwards we read the DLC
value from the msg_cntrl (which is 0 after invalidating the
message object) to account the TX bytes. So tx_bytes will always be 0. The
fix should be easy, I think, we can just move
c_can_inval_msg_object to the end of that loop.

The second problem is related to tx_next, which should hold the number of
the oldest CAN frame, which was not on the line:

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

But tx_echo is incremented unconditionally and we don't actually track the
number of the oldest unsent frame.
Let's assume the following scenario: We bring up can0 and send 3
frames: TX object: 0, 1, 2; 1 and 2 make it on the line, but 0 is
still pending. If we go through the above loop in that situation, we will
skip message object 0, because the txrqst bit is still set.  We will
account message object 1 and 2. That's correct, but afterwards tx_echo is
set to 2, BUT the oldest message which is pending is 0. Am I right or did
I get something wrong?
The operation of c_can_do_tx() is described as follows: "We iterate from
priv->tx_echo to priv->tx_next and check if the packet has been
transmitted, echo it back to the CAN framework. If we discover a not yet
transmitted package, stop looking for more." The actual
implementation doesn't seem to stop if we discover a not yet
transmitted package. But I'm not sure if just stopping might be a
good idea, because in that case, the echo skb for already transmitted
messages might be delayed by not yet transmitted messages.

Cheers,
        Jan




