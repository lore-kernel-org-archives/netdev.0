From: "kus Kusche Klaus" <kus@keba.com>
Subject: RE: My vote against eepro* removal
Date: Tue, 24 Jan 2006 08:38:04 +0100
Message-ID: <AAD6DA242BC63C488511C611BD51F36732332A@MAILIT.keba.co.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Lee Revell" <rlrevell@joe-job.com>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Adrian Bunk" <bunk@stusta.de>, <linux-kernel@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>, <netdev@vger.kernel.org>,
	"Steven Rostedt" <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030206AbWAXHiR@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Jesse Brandeburg" <jesse.brandeburg@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Jesse Brandeburg
> On Mon, 23 Jan 2006, kus Kusche Klaus wrote:
> > Here are my results:
> >=20
> > If the watchdog doesn't get interrupted, preempted, or whatever,
> > it spends 340 us in its body:
> > * 303 us in the mii code
> > *=A0 36 us in the following code up to e100_adjust_adaptive_ifs
> > *=A0=A0 1 us in the remaining code (I think my chip doesn't need an=
y
> > of those chip-specific fixups)
> >=20
> > The 303 us in the mii code are divided in the following way:
> > * 101 us in mii_ethtool_gset
> > * 135 us in the whole if
> > *=A0 67 us in mii_check_link
> >=20
> > This is with the udelay(2) instead of udelay(20) hack applied.
> > With udelay(20), the mii times are 128 + 170 + 85 us,
> > i.e. 383 us instead of 303 us, or >=3D 420 us for the whole watchdo=
g.
>=20
> Thank you very much for that detailed analysis!  okay, so=20
> calls to mii.c=20
> take too long, but those depend on mmio_read in e100 to do=20
> the work, so=20
> this patch attempts to minimize the latency.
>=20
> This patch is against linus-2.6.git, I compile and ssh/ping=20
> tested it.=20
> Would you be willing to send your instrumentation patches?  I=20
> could then=20
> test any fixes easier.

No deep magic behind my instrumentation:

A few global variables and some rdtscl in the watchdog:

unsigned long my_tsc_1 =3D 0;
unsigned long my_tsc_2 =3D 0;
unsigned long my_tsc_3 =3D 0;
unsigned long my_tsc_4 =3D 0;
EXPORT_SYMBOL(my_tsc_1);
EXPORT_SYMBOL(my_tsc_2);
EXPORT_SYMBOL(my_tsc_3);
EXPORT_SYMBOL(my_tsc_4);

static void e100_watchdog(unsigned long data)
{
	struct nic *nic =3D (struct nic *)data;
	struct ethtool_cmd cmd;

	DPRINTK(TIMER, DEBUG, "right now =3D %ld\n", jiffies);

	/* mii library handles link maintenance tasks */
	rdtscl(my_tsc_1);

	mii_ethtool_gset(&nic->mii, &cmd);

	rdtscl(my_tsc_2);
	if(mii_link_ok(&nic->mii) && !netif_carrier_ok(nic->netdev)) {
		DPRINTK(LINK, INFO, "link up, %sMbps, %s-duplex\n",
			cmd.speed =3D=3D SPEED_100 ? "100" : "10",
			cmd.duplex =3D=3D DUPLEX_FULL ? "full" : "half");
	} else if(!mii_link_ok(&nic->mii) && netif_carrier_ok(nic->netdev)) {
		DPRINTK(LINK, INFO, "link down\n");
	}

	rdtscl(my_tsc_3);
	mii_check_link(&nic->mii);
	rdtscl(my_tsc_4);

	/* Software generated interrupt to recover from (rare) Rx
	* allocation failure.
=2E..

And a small module which prints the timings periodically=20
when loaded:

/* Example module, built after LDD book release 3 */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/version.h>
#include <linux/errno.h>
#include <linux/timer.h>

MODULE_LICENSE("GPL");

/* Output interval, in jiffies */
#define INTERVAL 2111
/* Output scaling: TSC =3D=3D> microseconds */
#define SCALE(x) ((x)/500)

extern unsigned long my_tsc_1;
extern unsigned long my_tsc_2;
extern unsigned long my_tsc_3;
extern unsigned long my_tsc_4;

static struct timer_list my_timer;

static void timer_func(unsigned long dummy)
{
  printk(KERN_NOTICE "my_timer: diff =3D %lu / %lu / %lu\n",
         SCALE(my_tsc_2 - my_tsc_1),
         SCALE(my_tsc_3 - my_tsc_2),
         SCALE(my_tsc_4 - my_tsc_3));

  my_timer.expires +=3D INTERVAL;
  add_timer(&my_timer);
}

static int __init mymod_init(void)
{
  init_timer(&my_timer);
  my_timer.function =3D timer_func;
  my_timer.expires =3D jiffies + INTERVAL;
  add_timer(&my_timer);
 =20
  printk(KERN_NOTICE "Started mymod...\n");
  return 0;
}

static void __exit mymod_exit(void)
{
  del_timer_sync(&my_timer);
  printk(KERN_NOTICE "Finished mymod...\n");
}

module_init(mymod_init);
module_exit(mymod_exit);


>=20
> e100: attempt a shorter delay for mdio reads
>=20
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>=20
> Simply reorder our write/read sequence for mdio reads to=20
> minimize latency
> as well as delay a shorter interval for each loop.
>
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -891,23 +891,25 @@ static u16 mdio_ctrl(struct nic *nic, u3
>   	 * procedure it should be done under lock.
>   	 */
>   	spin_lock_irqsave(&nic->mdio_lock, flags);
> -	for (i =3D 100; i; --i) {
> +	for (i =3D 1000; i; --i) {
>   		if (readl(&nic->csr->mdi_ctrl) & mdi_ready)
>   			break;
> -		udelay(20);
> +		udelay(2);
>   	}
>   	if (unlikely(!i)) {
> -		printk("e100.mdio_ctrl(%s) won't go Ready\n",
> +		DPRINTK(PROBE, ERR, "e100.mdio_ctrl(%s) won't=20
> go Ready\n",
>   			nic->netdev->name );
>   		spin_unlock_irqrestore(&nic->mdio_lock, flags);
>   		return 0;		/* No way to indicate=20
> timeout error */
>   	}

The piece of code above is not yet present=20
in my version of e100.
(I'm still at 2.6.15, there is no -rt patch for 2.6.16 yet)

>   	writel((reg << 16) | (addr << 21) | dir | data,=20
> &nic->csr->mdi_ctrl);
>=20
> -	for (i =3D 0; i < 100; i++) {
> -		udelay(20);
> +	/* to avoid latency, read to flush the write, then=20
> delay, and only
> +	 * delay 2us per loop, manual says read should complete=20
> in < 64us */
> +	for (i =3D 0; i < 1000; i++) {
>   		if ((data_out =3D readl(&nic->csr->mdi_ctrl)) & mdi_ready)
>   			break;
> +		udelay(2);
>   	}

Exchanging the if and the udelay made things slightly worse:
It runs with 103 / 136 / 68 instead of 101 / 135 / 67 us.


--=20
Klaus Kusche                 (Software Development - Control Systems)
KEBA AG             Gewerbepark Urfahr, A-4041 Linz, Austria (Europe)
Tel: +43 / 732 / 7090-3120                 Fax: +43 / 732 / 7090-6301
E-Mail: kus@keba.com                                WWW: www.keba.com
=20
