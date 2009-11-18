From: roel kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH 1/3] macvlan: Reflect macvlan packets meant for other
	macvlan devices
Date: Wed, 18 Nov 2009 11:00:57 +0100
Message-ID: <25e057c00911180200w6d732e29q3aba5f1b9d005cbd@mail.gmail.com>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de>
	 <1258497551-25959-2-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:48086 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756944AbZKRKAw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 05:00:52 -0500
In-Reply-To: <1258497551-25959-2-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 17, 2009 at 11:39 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> From: Eric Biederman <ebiederm@xmission.com>
>
> Switch ports do not send packets back out the same port they came
> in on. =A0This causes problems when using a macvlan device inside
> of a network namespace as it becomes impossible to talk to
> other macvlan devices.
>
> Signed-off-by: Eric Biederman <ebiederm@xmission.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

I found a problem:

> @@ -140,20 +145,45 @@ static void macvlan_broadcast(struct sk_buff *s=
kb,
> =A0 =A0 =A0 =A0}
> =A0}
>
> +static int macvlan_unicast(struct sk_buff *skb, const struct macvlan=
_dev *dest)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D dest->dev;
> +
> + =A0 =A0 =A0 if (unlikely(!dev->flags & IFF_UP)) {

parentheses are missing:

if (unlikely(!(dev->flags & IFF_UP))) {

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_skb(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NET_XMIT_DROP;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 skb =3D skb_share_check(skb, GFP_ATOMIC);
> + =A0 =A0 =A0 if (!skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_errors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_dropped++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NET_XMIT_DROP;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 dev->stats.rx_bytes +=3D skb->len + ETH_HLEN;
> + =A0 =A0 =A0 dev->stats.rx_packets++;
> +
> + =A0 =A0 =A0 skb->dev =3D dev;
> + =A0 =A0 =A0 skb->pkt_type =3D PACKET_HOST;
> + =A0 =A0 =A0 netif_rx(skb);
> + =A0 =A0 =A0 return NET_XMIT_SUCCESS;
> +}
