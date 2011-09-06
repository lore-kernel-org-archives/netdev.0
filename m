From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Tue, 06 Sep 2011 19:40:05 +0200
Message-ID: <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45812 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295Ab1IFRkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 13:40:06 -0400
Received: by wyh22 with SMTP id 22so4629815wyh.19
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2011 10:40:04 -0700 (PDT)
In-Reply-To: <1315326326.2576.2980.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 septembre 2011 =C3=A0 09:25 -0700, Tim Chen a =C3=A9crit :
> On Sun, 2011-09-04 at 13:44 +0800, Yan, Zheng wrote:
> > Commit 0856a30409 (Scm: Remove unnecessary pid & credential referen=
ces
> > in Unix socket's send and receive path) introduced a use-after-free=
 bug.
> > It passes the scm reference to the first skb. Skb(s) afterwards may
> > reference freed data structure because the first skb can be destruc=
ted
> > by the receiver at anytime. The fix is by passing the scm reference=
 to
> > the very last skb.
> >=20
> > Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> > Reported-by: Jiri Slaby <jirislaby@gmail.com>
> > ---
>=20
> Thanks for finding this bug in my original patch.  I've missed the ca=
se
> where receiving side could have released the all the references to th=
e
> credential before the send side is using the credential again for
> subsequent skbs in the stream, thus causing the problem we saw.  Gett=
ing
> an extra reference for pid/credentials at the beginning of the stream
> and not getting reference for the last skb is the right approach.
>=20
> Thanks also to Sedat, Valdis and Jiri for their extensive testing to
> discover the bug and testing the subsequent fixes.=20
>=20
> Acked-by: Tim Chen <tim.c.chen@linux.intel.com>

What happens if message must be split in two skb,
first skb is built, queued (without scm reference)

Second skb allocation fails.

Rule about refs/norefs games is : As soon as you put skb into a list, i=
t
should have all appropriate references if this skb has pointer(s) to
objects(s)

We should revert 0856a304091b33a and code the thing differently.

Instead of storing pointer to pid and cred in UNIXSKB(), why dont we
copy all needed information ? No ref counts at all.

skb->cb[] is large enough.
