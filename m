From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: ath10k: ret used but uninitialized (was: Re: ath10k: add initial SDIO support)
Date: Thu, 6 Jul 2017 10:27:08 +0200
Message-ID: <CAMuHMdWVYA4TejcTjOQh7CBfFwJ=q59pzvuHrpH91Kx=-BK9fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Arnd Bergmann <arnd@arndb.de>,
        "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Erik Stromdahl <erik.stromdahl@gmail.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 5, 2017 at 9:52 PM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Web:        https://git.kernel.org/torvalds/c/d96db25d20256208ce47d71b9f6=
73a1de4c6fd7e
> Commit:     d96db25d20256208ce47d71b9f673a1de4c6fd7e
> Parent:     f008d1537bf88396cf41a7c7a831e3acd1ee92a1
> Refname:    refs/heads/master
> Author:     Erik Stromdahl <erik.stromdahl@gmail.com>
> AuthorDate: Wed Apr 26 12:18:00 2017 +0300
> Committer:  Kalle Valo <kvalo@qca.qualcomm.com>
> CommitDate: Thu May 4 15:55:55 2017 +0300
>
>     ath10k: add initial SDIO support
>
>     Chipsets like QCA6584 have support for SDIO so add initial SDIO bus s=
upport to
>     ath10k. With this patch we have the low level HTC protocol working an=
d it's
>     possible to boot the firmware, but it's still not possible to connect=
 or
>     anything like. More changes are needed for full functionality. For th=
at reason
>     we print during initialisation:
>
>     WARNING: ath10k SDIO support is incomplete, don't expect anything to =
work!
>
>     Signed-off-by: Erik Stromdahl <erik.stromdahl@gmail.com>
>     [kvalo@qca.qualcomm.com: refactoring, cleanup, commit log]
>     Signed-off-by: Kalle Valo <kvalo@qca.qualcomm.com>

> --- /dev/null
> +++ b/drivers/net/wireless/ath/ath10k/sdio.c

> +static int ath10k_sdio_mbox_rxmsg_pending_handler(struct ath10k *ar,
> +                                                 u32 msg_lookahead, bool=
 *done)
> +{
> +       struct ath10k_sdio *ar_sdio =3D ath10k_sdio_priv(ar);
> +       u32 lookaheads[ATH10K_SDIO_MAX_RX_MSGS];
> +       int n_lookaheads =3D 1;
> +       unsigned long timeout;
> +       int ret;

With gcc 4.1.2:

drivers/net/wireless/ath/ath10k/sdio.c: In function
=E2=80=98ath10k_sdio_mbox_rxmsg_pending_handler=E2=80=99:
drivers/net/wireless/ath/ath10k/sdio.c:676: warning: =E2=80=98ret=E2=80=99 =
may be used
uninitialized in this function

> +
> +       *done =3D true;
> +
> +       /* Copy the lookahead obtained from the HTC register table into o=
ur
> +        * temp array as a start value.
> +        */
> +       lookaheads[0] =3D msg_lookahead;
> +
> +       timeout =3D jiffies + SDIO_MBOX_PROCESSING_TIMEOUT_HZ;

Although very unlikely due to the long timeout, if the code is preempted he=
re,
and the loop below never entered, ret will indeed be uninitialized.

It's unclear to me what the proper initialization would be, though, so
that's why I didn't send a patch.

> +       while (time_before(jiffies, timeout)) {
> +               /* Try to allocate as many HTC RX packets indicated by
> +                * n_lookaheads.
> +                */
> +               ret =3D ath10k_sdio_mbox_rx_alloc(ar, lookaheads,
> +                                               n_lookaheads);
> +               if (ret)
> +                       break;
> +
> +               if (ar_sdio->n_rx_pkts >=3D 2)
> +                       /* A recv bundle was detected, force IRQ status
> +                        * re-check again.
> +                        */
> +                       *done =3D false;
> +
> +               ret =3D ath10k_sdio_mbox_rx_fetch(ar);
> +
> +               /* Process fetched packets. This will potentially update
> +                * n_lookaheads depending on if the packets contain looka=
head
> +                * reports.
> +                */
> +               n_lookaheads =3D 0;
> +               ret =3D ath10k_sdio_mbox_rx_process_packets(ar,
> +                                                         lookaheads,
> +                                                         &n_lookaheads);
> +
> +               if (!n_lookaheads || ret)
> +                       break;
> +
> +               /* For SYNCH processing, if we get here, we are running
> +                * through the loop again due to updated lookaheads. Set
> +                * flag that we should re-check IRQ status registers agai=
n
> +                * before leaving IRQ processing, this can net better
> +                * performance in high throughput situations.
> +                */
> +               *done =3D false;
> +       }
> +
> +       if (ret && (ret !=3D -ECANCELED))
> +               ath10k_warn(ar, "failed to get pending recv messages: %d\=
n",
> +                           ret);
> +
> +       return ret;
> +}

> +static void ath10k_sdio_irq_handler(struct sdio_func *func)
> +{
> +       struct ath10k_sdio *ar_sdio =3D sdio_get_drvdata(func);
> +       struct ath10k *ar =3D ar_sdio->ar;
> +       unsigned long timeout;
> +       bool done =3D false;
> +       int ret;

drivers/net/wireless/ath/ath10k/sdio.c: In function =E2=80=98ath10k_sdio_ir=
q_handler=E2=80=99:
drivers/net/wireless/ath/ath10k/sdio.c:1331: warning: =E2=80=98ret=E2=80=99=
 may be
used uninitialized in this function

> +
> +       /* Release the host during interrupts so we can pick it back up w=
hen
> +        * we process commands.
> +        */
> +       sdio_release_host(ar_sdio->func);
> +
> +       timeout =3D jiffies + ATH10K_SDIO_HIF_COMMUNICATION_TIMEOUT_HZ;

Same here.

Should ret be preinitialized to 0, -ECANCELED, or something else?

> +       while (time_before(jiffies, timeout) && !done) {
> +               ret =3D ath10k_sdio_mbox_proc_pending_irqs(ar, &done);
> +               if (ret)
> +                       break;
> +       }
> +
> +       sdio_claim_host(ar_sdio->func);
> +
> +       wake_up(&ar_sdio->irq_wq);
> +
> +       if (ret && ret !=3D -ECANCELED)
> +               ath10k_warn(ar, "failed to process pending SDIO interrupt=
s: %d\n",
> +                           ret);
> +}

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
