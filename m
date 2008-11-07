From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Fri, 7 Nov 2008 17:36:06 +0100
Message-ID: <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
	 <1225838743.6116.20.camel@fry>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:39529 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbYKGQgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 11:36:08 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1327447rvb.1
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2008 08:36:07 -0800 (PST)
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali.

> Which brings up a possible bug in the proposed patch - the mapped atomic int field should be part of the struct containing a ring buffer - each ring buffer has a different number of mappings.  Otherwise, there will be issues trying to create both a tx & rx ring.

Could you please clarify?
tx_pending_skb is only used for TX process.

> Are there any consequences to bypassing qdisc (other than not participating in any load balancing)?  Also, since any users using the tx ring approach would have to write new code, it would be part of the documentation that the send behaviour is optimized for the least latency and highest throughput, thus no guarantees and assumptions can be made about the path the data takes through the stack.
>
> I agree with you about not using the cb - I was just looking at all possible alternatives of how this can be solved.  I'm liking my approach of using the frag list because it's the least intrusive (doesn't require modification of the skb_buff structure) and the seems to be the most resilient (trying to hide data in some unused skb field and hope no one overwrites it)
>

My feeling is that all socket families have to use the same interface.
We must not bypass it, otherwise we're gonna make a mess.

I think we must not care about skb frags/device management to get
tpacket_hdr pointer back from skb. If it is changing tomorrow, we will
be in trouble.

A generic solution could be to forward a void* argument as the skb
destructor is forwarded through layers. Kind of:
skb->destructor(skb->desctructor_arg) when executing the callback. A
backup copy of destructor/destruct_arg pair should be performed if
someone needs to replace it.
This way all entities/layers could use this field to give an argument
to their destructor without adding a new field in sk_buff struct.

Thanks,
Johann
-- 
Johann Baudy
johaahn@gmail.com
