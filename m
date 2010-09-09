From: john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] posix clocks: introduce a sysfs presence.
Date: Thu, 9 Sep 2010 15:19:44 -0700
Message-ID: <AANLkTin2K+Z1eF8s7DAA2LoEGMT4VvdeVPXjog=miLa1@mail.gmail.com>
References: <cover.1283504065.git.richard.cochran@omicron.at>
	<84124d2479b8967cac2b35f852fc0fcae6ad9444.1283504065.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <84124d2479b8967cac2b35f852fc0fcae6ad9444.1283504065.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 3, 2010 at 2:30 AM, Richard Cochran
<richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> This patch adds a 'timesource' class into sysfs. Each registered POSI=
X
> clock appears by name under /sys/class/timesource. The idea is to
> expose to user space the dynamic mapping between clock devices and
> clock IDs.

So I'm not a fan of this one. Timesource is way to close to
clocksource. Really something like "posix_clockid" would make way more
sense.

But really, I'd prefer we not consolidate the clock_ids into a
dictionary style interface, where we list them all.

Really, I'd much prefer that there be a clockid attribute that hangs
off of the sysfs entry for the device where the PTP clock resides (or
is connected to).  That way we solve the issue of how do we map the
device to the clockid, and provide a method for ptpd to get the
clockid.

It also makes these special ids a little less easy to find for normal
applications (which should be ok, as only special applications that
really need to know the underlying hardware values should be mucking
with these clockids).

thanks
-john


> Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
> ---
> =A0Documentation/ABI/testing/sysfs-timesource | =A0 24 ++++++++++++++=
++
> =A0drivers/char/mmtimer.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0=
 =A01 +
> =A0include/linux/posix-timers.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
4 +++
> =A0kernel/posix-cpu-timers.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A02 +
> =A0kernel/posix-timers.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|=
 =A0 40 ++++++++++++++++++++++++++++
> =A05 files changed, 71 insertions(+), 0 deletions(-)
> =A0create mode 100644 Documentation/ABI/testing/sysfs-timesource
>
> diff --git a/Documentation/ABI/testing/sysfs-timesource b/Documentati=
on/ABI/testing/sysfs-timesource
> new file mode 100644
> index 0000000..f991de2
> --- /dev/null
> +++ b/Documentation/ABI/testing/sysfs-timesource
> @@ -0,0 +1,24 @@
> +What: =A0 =A0 =A0 =A0 =A0/sys/class/timesource/
> +Date: =A0 =A0 =A0 =A0 =A0September 2010
> +Contact: =A0 =A0 =A0 Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> +Description:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 This directory contains files and direc=
tories
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 providing a standardized interface to t=
he available
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 time sources.
> +
> +What: =A0 =A0 =A0 =A0 =A0/sys/class/timesource/<name>/
> +Date: =A0 =A0 =A0 =A0 =A0September 2010
> +Contact: =A0 =A0 =A0 Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> +Description:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 This directory contains the attributes =
of a time
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 source registered with the POSIX clock =
subsystem.
> +
> +What: =A0 =A0 =A0 =A0 =A0/sys/class/timesource/<name>/id
> +Date: =A0 =A0 =A0 =A0 =A0September 2010
> +Contact: =A0 =A0 =A0 Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> +Description:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 This file contains the clock ID (a non-=
negative
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 integer) of the named time source regis=
tered with the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 POSIX clock subsystem. This value may b=
e passed as the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 first argument to the POSIX clock and t=
imer system
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 calls. See man CLOCK_GETRES(2) and TIME=
R_CREATE(2).
> diff --git a/drivers/char/mmtimer.c b/drivers/char/mmtimer.c
> index ea7c99f..e9173e3 100644
> --- a/drivers/char/mmtimer.c
> +++ b/drivers/char/mmtimer.c
> @@ -758,6 +758,7 @@ static int sgi_timer_set(struct k_itimer *timr, i=
nt flags,
> =A0}
>
> =A0static struct k_clock sgi_clock =3D {
> + =A0 =A0 =A0 .name =3D "sgi_cycle",
> =A0 =A0 =A0 =A0.res =3D 0,
> =A0 =A0 =A0 =A0.clock_set =3D sgi_clock_set,
> =A0 =A0 =A0 =A0.clock_get =3D sgi_clock_get,
> diff --git a/include/linux/posix-timers.h b/include/linux/posix-timer=
s.h
> index 08aa4da..64e6fee 100644
> --- a/include/linux/posix-timers.h
> +++ b/include/linux/posix-timers.h
> @@ -67,7 +67,11 @@ struct k_itimer {
> =A0 =A0 =A0 =A0} it;
> =A0};
>
> +#define KCLOCK_MAX_NAME 32
> +
> =A0struct k_clock {
> + =A0 =A0 =A0 char name[KCLOCK_MAX_NAME];
> + =A0 =A0 =A0 struct device *dev;
> =A0 =A0 =A0 =A0clockid_t id;
> =A0 =A0 =A0 =A0int res; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* in nanoseco=
nds */
> =A0 =A0 =A0 =A0int (*clock_getres) (const clockid_t which_clock, stru=
ct timespec *tp);
> diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
> index e1c2e7b..df9cbab 100644
> --- a/kernel/posix-cpu-timers.c
> +++ b/kernel/posix-cpu-timers.c
> @@ -1611,6 +1611,7 @@ static long thread_cpu_nsleep_restart(struct re=
start_block *restart_block)
> =A0static __init int init_posix_cpu_timers(void)
> =A0{
> =A0 =A0 =A0 =A0struct k_clock process =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "process_cputime",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_getres =3D process_cpu_clock_ge=
tres,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_get =3D process_cpu_clock_get,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_set =3D do_posix_clock_nosettim=
e,
> @@ -1619,6 +1620,7 @@ static __init int init_posix_cpu_timers(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nsleep_restart =3D process_cpu_nsleep=
_restart,
> =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0struct k_clock thread =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "thread_cputime",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_getres =3D thread_cpu_clock_get=
res,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_get =3D thread_cpu_clock_get,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_set =3D do_posix_clock_nosettim=
e,
> diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
> index 67fba5c..719aa11 100644
> --- a/kernel/posix-timers.c
> +++ b/kernel/posix-timers.c
> @@ -46,6 +46,7 @@
> =A0#include <linux/wait.h>
> =A0#include <linux/workqueue.h>
> =A0#include <linux/module.h>
> +#include <linux/device.h>
>
> =A0/*
> =A0* Management arrays for POSIX timers. =A0Timers are kept in slab m=
emory
> @@ -135,6 +136,8 @@ static struct k_clock posix_clocks[MAX_CLOCKS];
> =A0static DECLARE_BITMAP(clocks_map, MAX_CLOCKS);
> =A0static DEFINE_MUTEX(clocks_mux); /* protects 'posix_clocks' and 'c=
locks_map' */
>
> +static struct class *timesource_class;
> +
> =A0/*
> =A0* These ones are defined below.
> =A0*/
> @@ -271,20 +274,40 @@ static int posix_get_coarse_res(const clockid_t=
 which_clock, struct timespec *tp
> =A0 =A0 =A0 =A0*tp =3D ktime_to_timespec(KTIME_LOW_RES);
> =A0 =A0 =A0 =A0return 0;
> =A0}
> +
> +/*
> + * sysfs attributes
> + */
> +
> +static ssize_t show_clock_id(struct device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct devic=
e_attribute *attr, char *page)
> +{
> + =A0 =A0 =A0 struct k_clock *kc =3D dev_get_drvdata(dev);
> + =A0 =A0 =A0 return snprintf(page, PAGE_SIZE-1, "%d\n", kc->id);
> +}
> +
> +static struct device_attribute timesource_dev_attrs[] =3D {
> + =A0 =A0 =A0 __ATTR(id, =A0 0444, show_clock_id, =A0 NULL),
> + =A0 =A0 =A0 __ATTR_NULL,
> +};
> +
> =A0/*
> =A0* Initialize everything, well, just everything in Posix clocks/tim=
ers ;)
> =A0*/
> =A0static __init int init_posix_timers(void)
> =A0{
> =A0 =A0 =A0 =A0struct k_clock clock_realtime =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "realtime",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_getres =3D hrtimer_get_res,
> =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0struct k_clock clock_monotonic =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "monotonic",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_getres =3D hrtimer_get_res,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_get =3D posix_ktime_get_ts,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_set =3D do_posix_clock_nosettim=
e,
> =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0struct k_clock clock_monotonic_raw =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "monotonic_raw",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_getres =3D hrtimer_get_res,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_get =3D posix_get_monotonic_raw=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_set =3D do_posix_clock_nosettim=
e,
> @@ -292,6 +315,7 @@ static __init int init_posix_timers(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nsleep =3D no_nsleep,
> =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0struct k_clock clock_realtime_coarse =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "realtime_coarse",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_getres =3D posix_get_coarse_res=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_get =3D posix_get_realtime_coar=
se,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_set =3D do_posix_clock_nosettim=
e,
> @@ -299,6 +323,7 @@ static __init int init_posix_timers(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nsleep =3D no_nsleep,
> =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0struct k_clock clock_monotonic_coarse =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "monotonic_coarse",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_getres =3D posix_get_coarse_res=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_get =3D posix_get_monotonic_coa=
rse,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.clock_set =3D do_posix_clock_nosettim=
e,
> @@ -306,6 +331,13 @@ static __init int init_posix_timers(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.nsleep =3D no_nsleep,
> =A0 =A0 =A0 =A0};
>
> + =A0 =A0 =A0 timesource_class =3D class_create(NULL, "timesource");
> + =A0 =A0 =A0 if (IS_ERR(timesource_class)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("posix-timers: failed to allocat=
e timesource class\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(timesource_class);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 timesource_class->dev_attrs =3D timesource_dev_attrs;
> +
> =A0 =A0 =A0 =A0register_posix_clock(CLOCK_REALTIME, &clock_realtime);
> =A0 =A0 =A0 =A0register_posix_clock(CLOCK_MONOTONIC, &clock_monotonic=
);
> =A0 =A0 =A0 =A0register_posix_clock(CLOCK_MONOTONIC_RAW, &clock_monot=
onic_raw);
> @@ -500,6 +532,14 @@ int register_posix_clock(const clockid_t id, str=
uct k_clock *clock)
> =A0 =A0 =A0 =A0kc =3D &posix_clocks[id];
> =A0 =A0 =A0 =A0*kc =3D *clock;
> =A0 =A0 =A0 =A0kc->id =3D id;
> + =A0 =A0 =A0 kc->dev =3D device_create(timesource_class, NULL, MKDEV=
(0, 0),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kc, "%s=
", kc->name);
> + =A0 =A0 =A0 if (IS_ERR(kc->dev)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("failed to create device clock_i=
d %d\n", id);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D PTR_ERR(kc->dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 dev_set_drvdata(kc->dev, kc);
> =A0 =A0 =A0 =A0set_bit(id, clocks_map);
> =A0out:
> =A0 =A0 =A0 =A0mutex_unlock(&clocks_mux);
> --
> 1.7.0.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
