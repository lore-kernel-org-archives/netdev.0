From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Tue, 30 Aug 2011 20:27:28 +0200
Message-ID: <CAHXqBFLgTHvxL34eR1qX7nEmntyOBXYrg-7LQvW=d8dnDpbhWg@mail.gmail.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com> <1314714646-3642-8-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vladz@broadcom.com, dmitry@broadcom.com,
	eilong@broadcom.com
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:61734 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258Ab1H3S1s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 14:27:48 -0400
Received: by iabu26 with SMTP id u26so1803410iab.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 11:27:48 -0700 (PDT)
In-Reply-To: <1314714646-3642-8-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/8/30 Michal Schmidt <mschmidt@redhat.com>:
> Allow disabling of HW RX VLAN stripping with ethtool.
>
> [v2: Store the flag in the fp to ensure that pending packets are
> =C2=A0 =C2=A0 handled correctly during a switch.]
[...]
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -66,6 +66,9 @@ static inline void bnx2x_bz_fp(struct bnx2x *bp, in=
t index)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((bp->flags & TPA_ENABLE_FLAG) && !IS_F=
COE_FP(fp))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fp->flags =3D =
=46P_TPA;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (bp->flags & RX_VLAN_STRIP_FLAG)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fp->flags |=3D FP_=
VLAN_STRIP;
> =C2=A0}
[...]
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -2719,9 +2719,8 @@ static unsigned long bnx2x_get_q_flags(struct b=
nx2x *bp,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__set_bit(BNX2=
X_Q_FLG_MCAST, &flags);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 /* Always set HW VLAN stripping */
> - =C2=A0 =C2=A0 =C2=A0 __set_bit(BNX2X_Q_FLG_VLAN, &flags);
> -
> + =C2=A0 =C2=A0 =C2=A0 if (fp->flags & FP_VLAN_STRIP)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __set_bit(BNX2X_Q_=
=46LG_VLAN, &flags);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return flags | bnx2x_get_common_flags(bp, =
fp, true);
> =C2=A0}


It seems rather convoluted and unnecessary that you mirror
NETIF_F_HW_VLAN_RX in bp->flags and then also in fp->flags. Are the
fp->flags strictly mirroring hardware state (as in: there is no way
the states can differ in any point in time where the flags are
tested)? For this to be true, the two functions above need to be
called only without releasing a lock between them that is also taken
by receive handler. Isn't there a flag in the rx descriptor of a
packet that says if VLAN was stripped? (All that flag keeping would be
unnecessary then.)

Best Regards,
Micha=C5=82 Miros=C5=82aw
