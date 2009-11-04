From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch] net: fix incorrect counting in __scm_destroy()
Date: Wed, 04 Nov 2009 11:29:05 +0100
Message-ID: <4AF15771.8060204@gmail.com>
References: <20091104100717.4785.57149.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755216AbZKDK3P@vger.kernel.org>
In-Reply-To: <20091104100717.4785.57149.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amerigo Wang a =E9crit :
> It seems that in __scm_destroy() we forgot to decrease
> the ->count after fput(->fp[i]), this may cause some
> problem when we recursively call fput() again.
>=20
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: David S. Miller <davem@davemloft.net>
>=20
> ---
> diff --git a/net/core/scm.c b/net/core/scm.c
> index b7ba91b..fa53219 100644
> --- a/net/core/scm.c
> +++ b/net/core/scm.c
> @@ -120,8 +120,10 @@ void __scm_destroy(struct scm_cookie *scm)
>  				fpl =3D list_first_entry(&work_list, struct scm_fp_list, list);
> =20
>  				list_del(&fpl->list);
> -				for (i=3Dfpl->count-1; i>=3D0; i--)
> +				for (i =3D fpl->count-1; i >=3D 0; i--) {
>  					fput(fpl->fp[i]);
> +					fpl->count--;
> +				}
>  				kfree(fpl);
>  			}
> =20

Hmm, your patch seems suspicious.

Are you fixing a real crash/bug, or is it something you discovered in a=
 code review ?

Given we kfree(fpl) at the end of loop, we cannot recursively call __sc=
m_destroy()
on same fpl, it would be a bug anyway ?

So you probably need something better, like testing fpl->list being not=
 re-included
in current->scm_work_list before kfree() it=20
