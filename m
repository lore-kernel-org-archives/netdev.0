From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v4] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Sat, 21 Sep 2013 02:43:57 +0200
Message-ID: <523CEBCD.10808@xdin.com>
References: <523A4F5E.9070503@xdin.com> <20130920.151017.2125552741552759738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>,
	<joe@perches.com>, <jboticario@gmail.com>,
	<balferreira@googlemail.com>, <elias.molina@ehu.es>,
	Arvid Brodin <arvid.brodin@xdin.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:56000 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070Ab3IUAzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Sep 2013 20:55:13 -0400
In-Reply-To: <20130920.151017.2125552741552759738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-09-20 21:10, David Miller wrote:
> From: Arvid Brodin <arvid.brodin@xdin.com>
> Date: Thu, 19 Sep 2013 03:11:58 +0200
>=20
>> +#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
>> +		/* We need to memmove the whole header to work around
>> +		 * alignment problems caused by the 6-byte HSR tag.
>> +		 */
>> +		memmove(skb_deliver->data - HSR_TAGLEN, skb_deliver->data,
>> +			skb_headlen(skb_deliver));
>> +		skb_deliver->data -=3D HSR_TAGLEN;
>> +		skb_deliver->tail -=3D HSR_TAGLEN;
>> +#endif
>=20
> You can't do this.
>=20
> First of all, you have no idea if subtracting skb->data a given amoun=
t
> will underflow the skb buffer start.  You aren't even checking, all
> of the standard skb_*() data adjustment interfaces do.

Isn't it reasonable to assume that skb points to an sk_buff with a
valid Ethernet header, and with skb->data pointing to the end of that
header, at the start of ETH_P_... protocol handlers?


> Secondly, everything after the header is now at the wrong offset from
> the beginning of the packet.
>=20
> You will have to memmove() the entire packet if you want to realign
> where it starts.

Are you saying packet data may contain offsets from itself to the mac=20
header? Or are you talking about fragments? This being the Ethernet=20
protocol handler, e.g. skb->network_header and skb->transport_header=20
should not have been set yet.

Anyway, I should do
	skb_deliver->len -=3D HSR_TAGLEN;
here! (I'm removing 6 bytes after the mac header from the packet, not=20
just realigning it.)

Given all this, and looking at e.g. __pskb_pull_tail(), it should be=20
correct to memmove() only the linear part of the packet after the remov=
ed=20
bytes - any fragments will just be appended directly after the end of t=
he=20
(shortened) linear part on use?

It's weird though, the "len" bug doesn't show up in my practical tests =
-=20
scp of 16 MiB file (sha1sum compared afterwards) and ping with default=20
and 65 KB packets work just fine before and after this change - even
between one fixed system and one with the bug remaining. Could it be
that none of the network device drivers we use (e1000e and macb) make=20
use of nonlinear skbs?


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
