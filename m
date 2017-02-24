From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH] drivers: net: xgene: Simplify xgene_enet_setup_mss() to
 kill warning
Date: Fri, 24 Feb 2017 12:13:37 -0800
Message-ID: <CAKh23Fnzux4DA3Sac3zixqtWw6pY9V24kkHN2+f==DW59fNabA@mail.gmail.com>
References: <1487932203-31799-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S . Miller" <davem@davemloft.net>,
        Keyur Chudgar <kchudgar@apm.com>,
        Arnd Bergmann <arnd@arndb.de>, netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487932203-31799-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 24, 2017 at 2:30 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> With gcc-4.1.2 and -Os:
>
>     drivers/net/ethernet/apm/xgene/xgene_enet_main.c: In function =E2=80=
=98xgene_enet_start_xmit=E2=80=99:
>     drivers/net/ethernet/apm/xgene/xgene_enet_main.c:297: warning: =E2=80=
=98mss_index=E2=80=99 may be used uninitialized in this function
>
> Using a separate variable to track success may confuse the compiler.
> Preinitialize mss_index with -EBUSY and check for negative error values
> instead to kill the warning.
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> Compile-tested only.
>
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 13 +++----------
>  1 file changed, 3 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/n=
et/ethernet/apm/xgene/xgene_enet_main.c
> index d0d0d12b531fc683..e536301acfdec9fd 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -293,36 +293,29 @@ static int xgene_enet_tx_completion(struct xgene_en=
et_desc_ring *cp_ring,
>  static int xgene_enet_setup_mss(struct net_device *ndev, u32 mss)
>  {
>         struct xgene_enet_pdata *pdata =3D netdev_priv(ndev);
> -       bool mss_index_found =3D false;
> -       int mss_index;
> +       int mss_index =3D -EBUSY;
>         int i;
>
>         spin_lock(&pdata->mss_lock);
>
>         /* Reuse the slot if MSS matches */
> -       for (i =3D 0; !mss_index_found && i < NUM_MSS_REG; i++) {
> +       for (i =3D 0; mss_index < 0 && i < NUM_MSS_REG; i++) {
>                 if (pdata->mss[i] =3D=3D mss) {
>                         pdata->mss_refcnt[i]++;
>                         mss_index =3D i;
> -                       mss_index_found =3D true;
>                 }
>         }
>
>         /* Overwrite the slot with ref_count =3D 0 */
> -       for (i =3D 0; !mss_index_found && i < NUM_MSS_REG; i++) {
> +       for (i =3D 0; mss_index < 0 && i < NUM_MSS_REG; i++) {
>                 if (!pdata->mss_refcnt[i]) {
>                         pdata->mss_refcnt[i]++;
>                         pdata->mac_ops->set_mss(pdata, mss, i);
>                         pdata->mss[i] =3D mss;
>                         mss_index =3D i;
> -                       mss_index_found =3D true;
>                 }
>         }
>
> -       /* No slots with ref_count =3D 0 available, return busy */
> -       if (!mss_index_found)
> -               mss_index =3D -EBUSY;
> -
>         spin_unlock(&pdata->mss_lock);
>
>         return mss_index;
> --
> 2.7.4
>

Thanks.

Acked-by: Iyappan Subramanian <isubramanian@apm.com>
