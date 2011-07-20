From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Wed, 20 Jul 2011 17:35:47 +0200
Message-ID: <CAHXqBFKD1bD8uMYOwbhsutT0ZuEiw=7pUDM1hVGpCgrdnV6zAg@mail.gmail.com>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
 <1311105738.3113.11.camel@edumazet-laptop> <20110719202922.GA2352@minipsycho>
 <1311108107.3113.22.camel@edumazet-laptop> <20110720001904.GA1992@neilslaptop.think-freely.org>
 <1311122593.3113.46.camel@edumazet-laptop> <4E2626E1.6030005@candelatech.com>
 <20110720020737.GB2692@neilslaptop.think-freely.org> <1311135855.3113.66.camel@edumazet-laptop>
 <20110720151827.GD12349@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, robert.olsson@its.uu.se
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:58360 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab1GTPgJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 11:36:09 -0400
Received: by qyk29 with SMTP id 29so2735766qyk.19
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 08:36:08 -0700 (PDT)
In-Reply-To: <20110720151827.GD12349@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/20 Neil Horman <nhorman@tuxdriver.com>:
> On Wed, Jul 20, 2011 at 06:24:15AM +0200, Eric Dumazet wrote:
>> Le mardi 19 juillet 2011 =C3=A0 22:07 -0400, Neil Horman a =C3=A9cri=
t :
>> > >
>> > I think this is a good idea. =C2=A0It lets pktgen dynamically make=
 the clone/share
>> > decision dynamically and only impacts performance for those system=
s.
>> >
>>
>> Just let pktgen refuse to use clone_skb command for these devices.
>>
> copy that, This is by no means final, but what do you think of this? =
=C2=A0If its
> agreeable to you, Ben, et al. I can add this to my local tree and sta=
rt auditing
> all the drivers that may need to have the flag set.
>
> Regards
> Neil
>
>
> diff --git a/include/linux/if.h b/include/linux/if.h
> index 3bc63e6..ae904fe 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -76,6 +76,7 @@
> =C2=A0#define IFF_BRIDGE_PORT =C2=A0 =C2=A0 =C2=A0 =C2=A00x4000 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* device used as bridge port */
> =C2=A0#define IFF_OVS_DATAPATH =C2=A0 =C2=A0 =C2=A0 0x8000 =C2=A0/* d=
evice used as Open vSwitch
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
* datapath port */
> +#define IFF_CANT_SHARE_SKB =C2=A0 =C2=A0 0x10000 /* Device can't sha=
re skbs in tx path */
>
> =C2=A0#define IF_GET_IFACE =C2=A0 0x0001 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0/* for querying only */
> =C2=A0#define IF_GET_PROTO =C2=A0 0x0002
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index f76079c..bf6d88d 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -1071,6 +1071,9 @@ static ssize_t pktgen_if_write(struct file *fil=
e,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (len < 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return len;
>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pkt_dev->priv_=
flags & IFF_CANT_SHARE_SKB)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return -EOPNOTSUPP;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0i +=3D len;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pkt_dev->clone=
_skb =3D value;
>

I would prefer that the flag be inclusive, i.e. it should mark drivers
which can use shared skbs. And it might be better to clone the skb in
case the flag is disabled to keep functionality working.

Best Regards,
Micha=C5=82 Miros=C5=82aw
