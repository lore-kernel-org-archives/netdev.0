From: David Miller <davem@davemloft.net>
Subject: Re: TSO trimming question
Date: Wed, 19 Dec 2007 23:54:50 -0800 (PST)
Message-ID: <20071219.235450.170670042.davem@davemloft.net>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758104AbXLTHyz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 02:54:55 -0500
In-Reply-To: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 19 Dec 2007 23:46:33 +0200 (EET)

> I'm not fully sure what's purpose of this code in tcp_write_xmit:
>=20
>                        if (skb->len < limit) {
>                                unsigned int trim =3D skb->len % mss_n=
ow;
>=20
>                                if (trim)
>                                        limit =3D skb->len - trim;
> 			}
>=20
> Is it used to make sure we send only multiples of mss_now here and le=
ave=20
> the left-over into another skb? Or does it try to make sure that
> tso_fragment result honors multiple of mss_now boundaries when snd_wn=
d
> is the limitting factor? For latter IMHO this would be necessary:
>=20
> 			if (skb->len > limit)
> 				limit -=3D limit % mss_now;

The purpose of the test is to make sure we process tail sub-mss chunks
correctly wrt. Nagle, which most closely matches the first purpose
you've listed.

So I think the calculation really does belong where it is.

Because of the way that the sendmsg() super-skb formation logic
works, we always will tack on more data and grow the tail
SKB before creating a new one.  So any sub-mss chunk at the
end of a TSO frame really is at the end of the write queue
and really should get nagle processing.

Actually, there is an exception, which is when we run out of
skb_frag_list slots.  In that case we'll potentially have breaks at
odd boundaries in the middle of the queue.  But this can only happen
in exceptional cases (user does tons of 1-byte sendfile()'s over
random non-consequetive locations of a file) or outright bugs
(MAX_SKB_FRAGS is defined incorrectly, for example) and thus this
situation is not worth coding for.

sendmsg()'s goal, when TSO is enabled, is to append to the write
queue tail SKB, and it does so until the MAX_SKB_FRAGS limit
is reached.
