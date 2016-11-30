From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [patch net / RFC] net: fec: increase frame size limitation to
 actually available buffer
Date: Wed, 30 Nov 2016 07:35:13 +0000
Message-ID: <AM4PR0401MB2260F7ADB5A5567F0896A81DFF8C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
 <AM4PR0401MB2260D022EC9B9E4C4333E621FF8C0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <dab27a3d-821c-8d07-ad98-2bdd8c442bc5@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        "Andrew Lunn" <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <dab27a3d-821c-8d07-ad98-2bdd8c442bc5@cogentembedded.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com> Sent: Wednesday, =
November 30, 2016 2:36 PM
 >To: Andy Duan <fugang.duan@nxp.com>; David S. Miller
 ><davem@davemloft.net>; Troy Kisky <troy.kisky@boundarydevices.com>;
 >Andrew Lunn <andrew@lunn.ch>; Eric Nelson <eric@nelint.com>; Philippe
 >Reynes <tremyfr@gmail.com>; Johannes Berg <johannes@sipsolutions.net>;
 >netdev@vger.kernel.org
 >Cc: Chris Healy <cphealy@gmail.com>; Fabio Estevam
 ><fabio.estevam@nxp.com>; linux-kernel@vger.kernel.org
 >Subject: Re: [patch net / RFC] net: fec: increase frame size limitation t=
o
 >actually available buffer
 >
 >> But I think it is not necessary since the driver don't support jumbo fr=
ame.
 >
 >Hardcoded 1522 raises two separate issues.
 >
 >(1) When DSA is in use, frames processed by FEC chip contain DSA tag and
 >thus can be larger than hardcoded limit of 1522. This issue is not FEC-sp=
ecific,
 >any driver that hardcodes maximum frame size to 1522 (many
 >do) will have this issue if used with DSA.
 >
 >Clean solution for this must take into account that difference between MT=
U
 >and max frame size is no longer known at compile time. Actually this is t=
he
 >case even without DSA, due to VLANs: max frame size is (MTU + 18) without
 >VLANs, but (MTU + 22) with VLANs. However currently drivers tend to ignor=
e
 >this and hardcode 22.  With DSA, 22 is not enough, need to add switch-
 >specific tag size to that.
 >
 >Not yet sure how to handle this. DSA-specific API to find out tag size co=
uld be
 >added, but generic solution should handle all cases of dynamic difference
 >between MTU and max frame size, not only DSA.
 >
 >
 >(2) There is some demand to use larger frames for optimization purposes.
 >
 >FEC register fields that limit frame size are 14-bit, thus allowing frame=
s up to
 >(4k-1). I'm about to prepare a larger patch:
 >- add ndo_change_mtu handler, allowing MTU up to (4k - overhead),
 >- set MAX_FL / TRUNC_FL based on configured MTU,
 >- if necessary, do buffer reallocation with larger buffers.
 >
 >Is this suitable for upstreaming?
 >Is there any policy related to handling larger frames?

Of course, welcome to upstream the jumbo frame patches, but hope to also ad=
d the transmit jumbo frame, not only receive path, which is helpful for tes=
ting with two boards connection.
And, some notes need you to care:
- the maximum jumbo frame should consider the fifo size. Different chip has=
 different fifo size. Like i.MX53 tx and rx share one fifo, i.mx6q/dl/sl ha=
ve separate 4k fifo for tx and rx, i.mx6sx/i.mx7x have separate 8k fifo for=
 tx and rx.
- rx fifo watermark to generate pause frame in busy loading system to avoid=
 fifo overrun. In general,  little pause frames bring better performance, m=
ass of pause frames cause worse performance.


Regards,
Andy
