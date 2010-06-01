From: Bob Copeland <me@bobcopeland.com>
Subject: Re: [PATCH] [ath5k][leds] Ability to disable leds support. If leds
	support enabled do not force mac802.11 leds layer selection.
Date: Tue, 1 Jun 2010 16:34:30 -0400
Message-ID: <AANLkTinFCuqgvnEGFmssL5R1J9-Yx7JB8mO9yKdXuYUj@mail.gmail.com>
References: <4c056b50.0c3fdf0a.500b.44af@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ath5k-devel@lists.ath5k.org, Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	GeunSik Lim <geunsik.lim@samsung.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Lukas Turek <8an@praha12.net>,
	Mark Hindley <mark@hindley.org.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jiri Kosina <jkosina@suse.cz>, Kalle Valo <kalle.valo@iki.fi>,
	Keng-Yu Lin <keng-yu.lin@canonical.com>,
	Luca Verdesca <magooz@salug.it>,
	Shahar Or <shahar@shahar-or.co.il>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dmytro Milinevskyy <milinevskyy@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4c056b50.0c3fdf0a.500b.44af@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 7, 2010 at 2:58 PM, Dmytro Milinevskyy
<milinevskyy@gmail.com> wrote:
> Hello!

Thanks, comments inline.


> +config ATH5K_LEDS
> + =A0 =A0 =A0 tristate "Atheros 5xxx wireless cards LEDs support"
> + =A0 =A0 =A0 depends on ATH5K
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 Atheros 5xxx LED support.
> +

This can select the proper LED classes?  Then you can get rid of anothe=
r
ifdef check later.

> -/* GPIO-controlled software LED */
> -#define AR5K_SOFTLED_PIN =A0 =A0 =A0 0
> -#define AR5K_SOFTLED_ON =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00
> -#define AR5K_SOFTLED_OFF =A0 =A0 =A0 1
> -

Please drop this hunk, no problem keeping it around.

> +#ifdef CONFIG_ATH5K_LEDS
> =A0/* LED functions */
> =A0int ath5k_init_leds(struct ath5k_softc *sc);
> =A0void ath5k_led_enable(struct ath5k_softc *sc);
> =A0void ath5k_led_off(struct ath5k_softc *sc);
> =A0void ath5k_unregister_leds(struct ath5k_softc *sc);
> +#else
> +#define ath5k_init_leds(sc) do {} while (0)
> +#define ath5k_led_enable(sc) do {} while (0)
> +#define ath5k_led_off(sc) do {} while (0)
> +#define ath5k_unregister_leds(sc) do {} while (0)
> +#endif

I prefer:

#ifdef
=2E..
#else
static inline int ath5k_init_leds(struct ath5k_softc *sc)
{
    return 0;
}
=2E..
#endif

so you get type-checking.  Also this doesn't quite work in your version=
:

    int foo =3D ath5k_init_leds(sc);

> +#ifdef CONFIG_ATH5K_LEDS
> =A0/*
> =A0* State for LED triggers
> =A0*/
> =A0struct ath5k_led
> =A0{
> - =A0 =A0 =A0 char name[ATH5K_LED_MAX_NAME_LEN + 1]; =A0/* name of th=
e LED in sysfs */
> =A0 =A0 =A0 =A0struct ath5k_softc *sc; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 /* driver state */
> +#ifdef CONFIG_LEDS_CLASS
> + =A0 =A0 =A0 char name[ATH5K_LED_MAX_NAME_LEN + 1]; =A0/* name of th=
e LED in sysfs */
> =A0 =A0 =A0 =A0struct led_classdev led_dev; =A0 =A0 =A0 =A0 =A0 =A0/*=
 led classdev */
> +#endif
> =A0};
> +#endif

Why move name?

> =A0/* Rfkill */
> =A0struct ath5k_rfkill {
> @@ -186,9 +190,6 @@ struct ath5k_softc {
>
> =A0 =A0 =A0 =A0u8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bssidmas=
k[ETH_ALEN];
>
> - =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0led_pin, =A0 =A0 =A0=
 =A0/* GPIO pin for driving LED */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 led_on;=
 =A0 =A0 =A0 =A0 /* pin setting for LED on */
> -
> =A0 =A0 =A0 =A0struct tasklet_struct =A0 restq; =A0 =A0 =A0 =A0 =A0/*=
 reset tasklet */
>
> =A0 =A0 =A0 =A0unsigned int =A0 =A0 =A0 =A0 =A0 =A0rxbufsize; =A0 =A0=
 =A0/* rx size based on mtu */
> @@ -196,7 +197,6 @@ struct ath5k_softc {
> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0rxbuflock;
> =A0 =A0 =A0 =A0u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *rxlink; =A0=
 =A0 =A0 =A0/* link ptr in last RX desc */
> =A0 =A0 =A0 =A0struct tasklet_struct =A0 rxtq; =A0 =A0 =A0 =A0 =A0 /*=
 rx intr tasklet */
> - =A0 =A0 =A0 struct ath5k_led =A0 =A0 =A0 =A0rx_led; =A0 =A0 =A0 =A0=
 /* rx led */
>
> =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0txbuf; =A0 =A0 =A0 =A0=
 =A0/* transmit buffer */
> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0txbuflock;
> @@ -204,7 +204,14 @@ struct ath5k_softc {
> =A0 =A0 =A0 =A0struct ath5k_txq =A0 =A0 =A0 =A0txqs[AR5K_NUM_TX_QUEUE=
S]; =A0 =A0 =A0 /* tx queues */
> =A0 =A0 =A0 =A0struct ath5k_txq =A0 =A0 =A0 =A0*txq; =A0 =A0 =A0 =A0 =
=A0 /* main tx queue */
> =A0 =A0 =A0 =A0struct tasklet_struct =A0 txtq; =A0 =A0 =A0 =A0 =A0 /*=
 tx intr tasklet */
> +
> +
> +#ifdef CONFIG_ATH5K_LEDS
> + =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0led_pin, =A0 =A0 =A0=
 =A0/* GPIO pin for driving LED */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 led_on;=
 =A0 =A0 =A0 =A0 /* pin setting for LED on */
> + =A0 =A0 =A0 struct ath5k_led =A0 =A0 =A0 =A0rx_led; =A0 =A0 =A0 =A0=
 /* rx led */
> =A0 =A0 =A0 =A0struct ath5k_led =A0 =A0 =A0 =A0tx_led; =A0 =A0 =A0 =A0=
 /* tx led */
> +#endif

You might want to do this in two stages: move the led-dependent things
together in the structure (or into a separate structure) and then only
have one #ifdef section.

Still too many ifdefs in general.

--=20
Bob Copeland %% www.bobcopeland.com
