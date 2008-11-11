From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Mon, 10 Nov 2008 16:29:07 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA6116F@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
	 <1225838743.6116.20.camel@fry>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61126@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>,
	Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:2351 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbYKKA3K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 19:29:10 -0500
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61126@NASANEXMB10.na.qualcomm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Also, there's no need to support both header versions in the tx path -
> since v2 should be used anyways and there's no legacy (v1 headers are
> deprecated no?), we can use v2 only in the tx path.
There's also a minor typo anyways in tpacket_fill_skb where you read tp_len.  You check for the header version, & then load the tp_len from tpacket_hdr always (this code should be removed anyways).

The assignment of -EFAULT to err write before filling the fragments is redundant since err is never used after that.

You don't reset the tp_status flag when you reject a message for being too short.

You incorrectly calculate to_write in the situation of sock->type == SOCK_DGRAM.

You don't check for the MAX_SKB_FRAGS condition.

Not your code, but in packet_set_ring, it's redundant to clear the status for all the frames to TP_STATUS_KERNEL (0) since the pages are allocated with kzalloc (pages are already zeroed).  I surrounded this with a CONFIG_DEBUG_KERNEL block.

Earlier, I think I had said that the mapped variable should be placed in packet_ring_buffer struct - I was wrong.  It's correct where it is.  I had forgotten that rx & tx are mapped contiguously and simultaneously.  There needs to be a note in the doc that the rings should be set up before mapping (i.e. cannot set up the rx or tx ring buffer first, mmap, and then try to change it). We do need still need a check for tx_pending_skb when sizing the ring buffer (in the situation where we unfreed skbs created by a call to send from Thread B, while Thread A unmaps the ring buffer and trys a resize).  Also, in tpacket_snd, we need to increment mapped before allocating the skb and test if the original value was 0 (we decrement after incrementing tx_pending_skb).  If it was, then that indicates tha
 t the user had unmapped the ring buffer, which means we should stop sending.  No need for additional locking because of the atomic relationship this sets up between tx_pending_skb and mapped.

I'll be posting my suggested patch tomorrow.
