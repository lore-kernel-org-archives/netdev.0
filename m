From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/4] netfilter: xt_connlimit: fix daddr connlimit in SNAT scenario
Date: Mon, 14 Mar 2011 20:42:29 +0800
Message-ID: <AANLkTi=QgVBVAPcTmb_La=VJOLq5LmGPqMfw7bbCuByP@mail.gmail.com>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com> <alpine.LNX.2.01.1103141310140.27542@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58424 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480Ab1CNMmu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 08:42:50 -0400
In-Reply-To: <alpine.LNX.2.01.1103141310140.27542@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2011 at 8:26 PM, Jan Engelhardt <jengelh@medozas.de> wr=
ote:
> On Monday 2011-03-14 07:50, Changli Gao wrote:
>
>>We use the reply tuples when limiting the connections by the destinat=
ion
>>addresses, however, in SNAT scenario, the final reply tuples won't be
>>ready until SNAT is done in POSTROUING or INPUT chain
>
> If I am not mistaken: if you do daddr counting, SNAT is irrelevant.
> Consider ruleset
> =A0-t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to 1.2.3.4:80
> =A0-t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to 1.2.3.5:443
>
> The tuple will first be (as per conntrack -L):
> =A0src=3Dhome dst=3Drouter src=3Drouter dst=3Dhome
> After DNAT:
> =A0src=3Dhome dst=3Drouter src=3D1.2.3.4 dst=3Dhome
>
> Thus looking at the src of the reply tuple seems correct =97 at least=
 this
> is what was wanted, counting per stashed servers (=3D1 customer), not=
 per
> globally visible address.
>

Yes, you are correct only when there is no SNAT rule. If there is an SN=
AT rule:

-t nat -A POSTROUTING -p tcp --dport 80 -j SNAT --to-source 192.168.0.1

the final tuples will be:
src =3D home dst =3D router src=3D1.2.3.4 dst=3D192.168.0.1

However, the tuple saved by connlimit is src=3D1.2.3.4 dst=3Dhome, so t=
his
conn will be removed later as there isn't any conntrack, which has
this tuple in any direction.

You can't prevent a user from doing such a configuration, although you
might think it is stupid to do that.

Thanks for your review.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
