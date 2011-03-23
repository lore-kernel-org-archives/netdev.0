From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: can: c_can: TX delivery
Date: Wed, 23 Mar 2011 09:53:40 +0100
Message-ID: <20110323085340.GC346@e-circ.dyndns.org>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bhupesh.sharma@st.com, wg@grandegger.com, b.spranger@linutronix.de,
	netdev@vger.kernel.org
To: Jan Altenberg <jan@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:22341 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753345Ab1CWIxr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:53:47 -0400
Content-Disposition: inline
In-Reply-To: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan,

I split your 2 questions in 2 replies.

On Tue, Mar 22, 2011 at 04:59:23PM +0100, Jan Altenberg wrote:
> Hi all,
> 

> The second problem is related to tx_next, which should hold the number of
> the oldest CAN frame, which was not on the line:
> 
> for (/* nix */; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
>         msg_obj_no = get_tx_echo_msg_obj(priv);
>         c_can_inval_msg_object(dev, 0, msg_obj_no);
>         val = c_can_read_reg32(priv, &priv->regs->txrqst1);
>         if (!(val & (1 << msg_obj_no))) {
>                 can_get_echo_skb(dev,
>                                 msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
>                 stats->tx_bytes += priv->read_reg(priv,
>                                 &priv->regs->ifregs[0].msg_cntrl)
>                                 & IF_MCONT_DLC_MASK;
>                 stats->tx_packets++;
>         }
> }
> 
> But tx_echo is incremented unconditionally and we don't actually track the
> number of the oldest unsent frame.
> Let's assume the following scenario: We bring up can0 and send 3
> frames: TX object: 0, 1, 2; 1 and 2 make it on the line, but 0 is
> still pending. If we go through the above loop in that situation, we will
> skip message object 0, because the txrqst bit is still set.  We will
> account message object 1 and 2. That's correct, but afterwards tx_echo is
> set to 2, BUT the oldest message which is pending is 0. Am I right or did
> I get something wrong?
> The operation of c_can_do_tx() is described as follows: "We iterate from
> priv->tx_echo to priv->tx_next and check if the packet has been
> transmitted, echo it back to the CAN framework. If we discover a not yet
> transmitted package, stop looking for more." The actual
> implementation doesn't seem to stop if we discover a not yet
> transmitted package. But I'm not sure if just stopping might be a
> good idea, because in that case, the echo skb for already transmitted
> messages might be delayed by not yet transmitted messages.

It is better to deliver the echo's in the order they were delivered
on CAN.
For that, we can replace the tx_next/tx_echo pair with a single tx_bitmask.
In the tx_bitmask, we could set a bit when the TX is queued, and test for
those bits in the tx interrupt.
When tx is done, clear the bit in tx_bitmask & stuff.

16 tx objects fit inside a single int.

c_can_start_xmit would look a bit different. I think of something like this:

	/* find free object */
	for (j = 0; j < TX_MAX; ++j) {
		if (!(priv->tx_bitmask & (1 << j)))
			break;
	}
	if (j >= TX_MAX)
		/* no free objects */
		return NETDEV_TX_BUSY;
		
	c_can_write_...(j, ...)
	can_put_echo_skb(, j, ...)
	priv->tx_bitmask |= (1 << j);
	return NETDEV_TX_OK;

not sure if I made my point.
Note that this will eliminate the need for explicit wrap-around. It's
done implicitely.
> 
> Cheers,
>         Jan
> 
Regards,
Kurt
