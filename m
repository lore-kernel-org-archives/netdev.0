From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 09:44:48 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B8@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
 <1225838743.6116.20.camel@fry>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61126@NASANEXMB10.na.qualcomm.com>
 <7e0dd21a0811110410v5fa8abadib70cebecb282bc1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:7673 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbYKKRow convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 12:44:52 -0500
In-Reply-To: <7e0dd21a0811110410v5fa8abadib70cebecb282bc1@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann,

> > Additionally, if the packet size is too long, the kernel has a
> responsibility to clear that flag (otherwise that slot will never free
> up).
> I'm not sure to understand, could you please clarify ?
If the user places a 1 KB packet into the buffer, but then when we try to send it, it turns out the mtu is too small (or something like that), if we don't clear the flag back to TP_STATUS_KERNEL and just return an error, the user will never know.

      --------------------------------------
0    | 1 KB frame - status = TP_STATUS_USER |
      --------------------------------------
1    | 1 KB frame - status = TP_STATUS_USER |
      --------------------------------------
Etc

So when the user fills up the ring buffer and goes back to frame 0, he won't know that that packet was actually fatally rejected (i.e. the kernel moved on) and will just block waiting for the status to clear (which it never will).  Similarly in the case where the packet gets rejected for being too small.

In other words, when the kernel doesn't send a packet but moves on and doesn't keep trying (as would be the case for the packet size being too small or too big because that is considered an irrecoverable error), it has to notify the user by clearing that status flag for that frame.
