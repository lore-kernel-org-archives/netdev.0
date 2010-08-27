From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [PATCH] wireless: fix 64K kernel heap content leak via ioctl
Date: Fri, 27 Aug 2010 15:35:19 -0700
Message-ID: <AANLkTimeEa_=dqX5yFnYzaSaL90TfOg3=MsydG81naAC@mail.gmail.com>
References: <20100827210240.GC4703@outflux.net> <20100827212254.GB32275@bougret.hpl.hp.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100827212254.GB32275@bougret.hpl.hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 27, 2010 at 2:22 PM, Jean Tourrilhes <jt@hpl.hp.com> wrote:
> On Fri, Aug 27, 2010 at 02:02:41PM -0700, Kees Cook wrote:
>> This problem was originally tracked down by Brad Spengler.
>>
>> When calling wireless ioctls, if a driver does not correctly
>> validate/shrink iwp->length, the resulting copy_to_user can leak up =
to
>> 64K of kernel heap contents.
>>
>> It seems that this is triggerable[1] in 2.6.32 at least on ath5k, bu=
t
>> I was not able to track down how. The twisty maze of ioctl handlers
>> stumped me. :)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0You can always ask.
>
>> Other drivers I checked did not appear to have any problems,
>> but the potential remains. I'm not sure if this patch is the right a=
pproach;
>> it was fixed differently[2] in grsecurity.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Did you tried your patch for real ? With l=
arge scan request ?
> =C2=A0 =C2=A0 =C2=A0 =C2=A0I ask because at first glance, it looks in=
correct, asI believe
> it kills large request. But someone would need to test, for sure.
>
>> [1] http://forums.grsecurity.net/viewtopic.php?f=3D3&t=3D2290&start=3D=
0
>> [2] http://grsecurity.net/~spender/wireless-infoleak-fix2.patch
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0I believe this patch would make the situat=
ion worse.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Would you mind validating the following pa=
tch ? I've just
> verified that it compiles and I believe it does what you are asking i=
n
> a much more predictable way.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Regards,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Jean
>
> diff -u -p wext.j2.c wext.c
> --- wext.j2.c   2010-08-27 14:17:26.000000000 -0700
> +++ wext.c      2010-08-27 14:19:33.000000000 -0700
> @@ -800,9 +800,12 @@ static int ioctl_standard_iw_point(struc
>                        goto out;
>                }
>
> -               if (copy_to_user(iwp->pointer, extra,
> -                                iwp->length *
> -                                descr->token_size)) {
> +               /* Verify how much we should return. Some driver
> +                * may abuse iwp->length... */
> +               if((iwp->length * descr->token_size) < extra_size)
> +                       extra_size =3D iwp->length * descr->token_siz=
e;
> +
> +               if (copy_to_user(iwp->pointer, extra, extra_size)) {
>                        err =3D -EFAULT;
>                        goto out;
>                }


Jean, can you submit in a new thread and right before the SOB add in
the commit log Cc: stable@kernel.org [2.6.32+]

  Luis
