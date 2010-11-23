From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] AF_UNIX: find the recipients for multicast messages
Date: Tue, 23 Nov 2010 10:39:49 -0800 (PST)
Message-ID: <20101123.103949.39186245.davem@davemloft.net>
References: <20101123150315.4e67a139@chocolatine.cbg.collabora.co.uk>
	<1290528517.3046.91.camel@edumazet-laptop>
	<20101123174701.1b2f6f16@chocolatine.cbg.collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com, gorcunov@openvz.org,
	adobriyan@gmail.com, lennart@poettering.net, kay.sievers@vrfy.org,
	ian.molton@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alban.crequy@collabora.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756352Ab0KWSjX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Nov 2010 13:39:23 -0500
In-Reply-To: <20101123174701.1b2f6f16@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Alban Crequy <alban.crequy@collabora.co.uk>
Date: Tue, 23 Nov 2010 17:47:01 +0000

> Le Tue, 23 Nov 2010 17:08:37 +0100,
> Eric Dumazet <eric.dumazet@gmail.com> a =E9crit :
>> I am not sure if doing 90 clones of skb and filtering them one by on=
e
>> is going to be fast :-(
>=20
> Yes... I think it can be optimized. Run the socket filter first by
> calling sk_run_filter() directly and then call skb_clone() + pskb_tri=
m()
> only on the few remaining sockets.

BTW, we have and have talked about the same exact problem with
AF_PACKET socket users such as DHCP.

We clone and push the packet down into the AF_PACKET protocol
code from the pt_type callback when %99 of the time the socket
filter doesn't match and thus the clone is completely wasted
work.

If we know the socket, or more specifically the filter, early enough,
we could have a special interface like:

	struct sk_buff *skb_filter_or_clone(struct sk_buff *skb, ...)

Which returns a non-NULL cloned SKB if the filter accepts the
packet.
