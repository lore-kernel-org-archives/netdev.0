From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [PATCH] atl1: fix oops when changing tx/rx ring params
Date: Wed, 5 Jan 2011 16:42:17 +0100
Message-ID: <AANLkTinizyGFhzTgTMQ=ojL4v+htqvRM9c62dgHUss3f@mail.gmail.com>
References: <20110101090212.7149010d@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org, jussuf@linux.ee, chris.snook@gmail.com,
	Xiong.Huang@atheros.com
To: "J. K. Cliburn" <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:61148 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1AEPmS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 10:42:18 -0500
Received: by ywl5 with SMTP id 5so6034504ywl.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 07:42:18 -0800 (PST)
In-Reply-To: <20110101090212.7149010d@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 1, 2011 at 4:02 PM, J. K. Cliburn <jcliburn@gmail.com> wrot=
e:
> Commit 3f5a2a713aad28480d86b0add00c68484b54febc zeroes out the statis=
tics
> message block (SMB) and coalescing message block (CMB) when adapter r=
ing
> resources are freed. =C2=A0This is desirable behavior, but, as a side=
 effect,
> the commit leads to an oops when atl1_set_ringparam() attempts to alt=
er
> the number of rx or tx elements in the ring buffer (by using ethtool
> -G, for example). =C2=A0We don't want SMB or CMB to change during thi=
s
> operation.
>
> Modify atl1_set_ringparam() to preserve SMB and CMB when changing rin=
g
> parameters.
>
> Cc: stable@kernel.org
> Signed-off-by: Jay Cliburn <jcliburn@gmail.com>
> Reported-by: T=C3=B5nu Raitviir <jussuf@linux.ee>
> ---
> =C2=A0drivers/net/atlx/atl1.c | =C2=A0 10 ++++++++++
> =C2=A01 files changed, 10 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index 5336310..3acf512 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -3504,6 +3504,8 @@ static int atl1_set_ringparam(struct net_device=
 *netdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct atl1_rfd_ring rfd_old, rfd_new;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct atl1_rrd_ring rrd_old, rrd_new;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct atl1_ring_header rhdr_old, rhdr_new=
;
> + =C2=A0 =C2=A0 =C2=A0 struct atl1_smb smb;
> + =C2=A0 =C2=A0 =C2=A0 struct atl1_cmb cmb;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0tpd_old =3D adapter->tpd_ring;
> @@ -3544,11 +3546,19 @@ static int atl1_set_ringparam(struct net_devi=
ce *netdev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->rrd_r=
ing =3D rrd_old;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->tpd_r=
ing =3D tpd_old;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->ring_=
header =3D rhdr_old;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Save SMB a=
nd CMB, since atl1_free_ring_resources
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* will clear=
 them.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 smb =3D adapter->s=
mb;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cmb =3D adapter->c=
mb;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0atl1_free_ring=
_resources(adapter);

Hum, unless I'm missing something atl1_free_ring_resources frees the
whole ring_header->dma block which contains both SMB and CMB.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->rfd_r=
ing =3D rfd_new;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->rrd_r=
ing =3D rrd_new;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->tpd_r=
ing =3D tpd_new;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0adapter->ring_=
header =3D rhdr_new;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 adapter->smb =3D s=
mb;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 adapter->cmb =3D c=
mb;

So here you're using pointers to freed memory.
In order to preserve the stats you'd have to copy the structure.

Luca
