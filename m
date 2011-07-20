From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Wed, 20 Jul 2011 17:30:17 +0200
Message-ID: <1311175817.2338.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	 <1311105738.3113.11.camel@edumazet-laptop>
	 <20110719202922.GA2352@minipsycho>
	 <1311108107.3113.22.camel@edumazet-laptop>
	 <20110720001904.GA1992@neilslaptop.think-freely.org>
	 <1311122593.3113.46.camel@edumazet-laptop>
	 <4E2626E1.6030005@candelatech.com>
	 <20110720020737.GB2692@neilslaptop.think-freely.org>
	 <1311135855.3113.66.camel@edumazet-laptop>
	 <20110720151827.GD12349@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, robert.olsson@its.uu.se
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60358 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460Ab1GTPaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 11:30:25 -0400
Received: by wyg8 with SMTP id 8so252921wyg.19
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 08:30:24 -0700 (PDT)
In-Reply-To: <20110720151827.GD12349@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 juillet 2011 =C3=A0 11:18 -0400, Neil Horman a =C3=A9cri=
t :
> On Wed, Jul 20, 2011 at 06:24:15AM +0200, Eric Dumazet wrote:
> > Le mardi 19 juillet 2011 =C3=A0 22:07 -0400, Neil Horman a =C3=A9cr=
it :
> > > >=20
> > > I think this is a good idea.  It lets pktgen dynamically make the=
 clone/share
> > > decision dynamically and only impacts performance for those syste=
ms.
> > >=20
> >=20
> > Just let pktgen refuse to use clone_skb command for these devices.
> >=20
> copy that, This is by no means final, but what do you think of this? =
 If its
> agreeable to you, Ben, et al. I can add this to my local tree and sta=
rt auditing
> all the drivers that may need to have the flag set.
>=20
> Regards
> Neil
>=20
>=20
> diff --git a/include/linux/if.h b/include/linux/if.h
> index 3bc63e6..ae904fe 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -76,6 +76,7 @@
>  #define IFF_BRIDGE_PORT	0x4000		/* device used as bridge port */
>  #define IFF_OVS_DATAPATH	0x8000	/* device used as Open vSwitch
>  					 * datapath port */
> +#define IFF_CANT_SHARE_SKB	0x10000	/* Device can't share skbs in tx =
path */
> =20
>  #define IF_GET_IFACE	0x0001		/* for querying only */
>  #define IF_GET_PROTO	0x0002
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index f76079c..bf6d88d 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -1071,6 +1071,9 @@ static ssize_t pktgen_if_write(struct file *fil=
e,
>  		if (len < 0)
>  			return len;
> =20
> +		if (pkt_dev->priv_flags & IFF_CANT_SHARE_SKB)
> +			return -EOPNOTSUPP;
> +

Well, the general idea was to intercept the "clone_skb XXX" command and
cap XXX to 0 for said devices.

So some admin can still use pktgen without clone_skb stuff.


