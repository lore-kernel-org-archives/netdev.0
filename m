From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: [PATCH] ath:Release resources for structure pointer, ar if error
 pointing device in the function, ath10k_core_register_work
Date: Tue, 3 Mar 2015 07:40:17 +0100
Message-ID: <CA+BoTQnNgNd4V9FN5SON387s7XuowFSDgrFUjZTn9Qm-sJ+NbQ@mail.gmail.com>
References: <1425350171-26333-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	"ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425350171-26333-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3 March 2015 at 03:36, Nicholas Krause <xerofoify@gmail.com> wrote:
> Releases resources and deregisters the stucture pointer ar passed by =
the caller to the function, ath10k_core_register_work
> if unable to probe the structure pointer successfully with a call to =
ath10k_core_probe_fw. Further more if this happerns
> we must first jump to the label err for the goto statement required t=
o jump to handle this particular error in the function,
> ath10k_core_register_work.  After we are in the correct error section=
 we must free the resources for the structure pointer,ar
> with a call to the function,  ath10k_core_unregister to free resource=
s allocated for the structure pointer,ar.
>
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/net/wireless/ath/ath10k/core.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wir=
eless/ath/ath10k/core.c
> index 310e12b..8b2ca25 100644
> --- a/drivers/net/wireless/ath/ath10k/core.c
> +++ b/drivers/net/wireless/ath/ath10k/core.c
> @@ -1307,9 +1307,7 @@ err_unregister_mac:
>  err_release_fw:
>         ath10k_core_free_firmware_files(ar);
>  err:
> -       /* TODO: It's probably a good idea to release device from the=
 driver
> -        * but calling device_release_driver() here will cause a dead=
lock.
> -        */
> +       ath10k_core_unregister(ar);
>         return;
>  }

Did you test this? This will deadlock. ath10k_core_unregister() tries
to cancel ar->register_work. This won't work if you call it from the
worker itself. Moreover if I ignore the deadlock
ath10k_core_unregister() would do nothing else in this context because
ATH10K_FLAG_CORE_REGISTERED wouldn't be even set.

If you're interested in dealing with this TODO I suggest you read
through the original thread which led to the current state of affairs:

  http://www.spinics.net/lists/linux-wireless/msg124004.html


Micha=C5=82
