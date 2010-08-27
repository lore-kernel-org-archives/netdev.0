From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH] wireless: fix 64K kernel heap content leak via ioctl
Date: Fri, 27 Aug 2010 15:51:47 -0700
Message-ID: <AANLkTinZmG-bv_m0ktL+NBbtMRtHkM+urfD9M1GdLxCD@mail.gmail.com>
References: <20100827210240.GC4703@outflux.net> <20100827212254.GB32275@bougret.hpl.hp.com>
 <AANLkTimeEa_=dqX5yFnYzaSaL90TfOg3=MsydG81naAC@mail.gmail.com> <20100827223926.GB32498@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kees Cook <kees.cook@canonical.com>, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Joe Perches <joe@perches.com>, Tejun Heo <tj@kernel.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: jt@hpl.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:45072 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726Ab0H0WwI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 18:52:08 -0400
In-Reply-To: <20100827223926.GB32498@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 27, 2010 at 3:39 PM, Jean Tourrilhes <jt@hpl.hp.com> wrote:
> On Fri, Aug 27, 2010 at 03:35:19PM -0700, Luis R. Rodriguez wrote:
>> >
>> > diff -u -p wext.j2.c wext.c
>> > --- wext.j2.c =C2=A0 2010-08-27 14:17:26.000000000 -0700
>> > +++ wext.c =C2=A0 =C2=A0 =C2=A02010-08-27 14:19:33.000000000 -0700
>> > @@ -800,9 +800,12 @@ static int ioctl_standard_iw_point(struc
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0goto out;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (copy_to_use=
r(iwp->pointer, extra,
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0iwp->length *
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0descr->token_size)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Verify how m=
uch we should return. Some driver
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* may abu=
se iwp->length... */
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if((iwp->length=
 * descr->token_size) < extra_size)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 extra_size =3D iwp->length * descr->token_size;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (copy_to_use=
r(iwp->pointer, extra, extra_size)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0err =3D -EFAULT;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0goto out;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>>
>> Jean, can you submit in a new thread and right before the SOB add in
>> the commit log Cc: stable@kernel.org [2.6.32+]
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0The current patch was made for 2.6.27 and =
was only
> compiled. Someone would need to verify it works for 2.6.32. I could
> probably find some time next week.

Got it, ah so it would be Cc: stable@kernel.org [2.6.27+]. To get this
trickled in we first need it for wireless-testing.git, and provide
links / patches to the backport of the patch for each kernel. Once it
gets merged into Linus' tree the stable team can apply the respective
backported patches.

  Luis
