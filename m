From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 08/12] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 15 Jun 2010 11:00:10 -0600
Message-ID: <AANLkTin4lYghEWhjzEyARvYDgHaXdniwLbfyZ4jY0rwm@mail.gmail.com>
References: <cover.1276615626.git.richard.cochran@omicron.at>
	<4a030d2bace90f089f2f3f61496b918c6f1dfb52.1276615626.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Thomas Gleixner <tglx@linutronix.de>, linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <4a030d2bace90f089f2f3f61496b918c6f1dfb52.1276615626.git.richard.cochran@omicron.at>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 15, 2010 at 10:09 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> This patch adds an infrastructure for hardware clocks that implement
> IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
> registration method to particular hardware clock drivers. Each clock is
> exposed to user space as a character device with ioctls that allow tuning
> of the PTP clock.
>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
> =A0Documentation/ptp/ptp.txt =A0 =A0 =A0 =A0| =A0 95 +++++++
> =A0Documentation/ptp/testptp.c =A0 =A0 =A0| =A0269 ++++++++++++++++++++
> =A0Documentation/ptp/testptp.mk =A0 =A0 | =A0 33 +++
> =A0drivers/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +
> =A0drivers/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0drivers/ptp/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 26 ++
> =A0drivers/ptp/Makefile =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 +
> =A0drivers/ptp/ptp_clock.c =A0 =A0 =A0 =A0 =A0| =A0514 ++++++++++++++++++=
++++++++++++++++++++
> =A0include/linux/Kbuild =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0include/linux/ptp_clock.h =A0 =A0 =A0 =A0| =A0 79 ++++++
> =A0include/linux/ptp_clock_kernel.h | =A0137 ++++++++++
> =A011 files changed, 1162 insertions(+), 0 deletions(-)
> =A0create mode 100644 Documentation/ptp/ptp.txt
> =A0create mode 100644 Documentation/ptp/testptp.c
> =A0create mode 100644 Documentation/ptp/testptp.mk
> =A0create mode 100644 drivers/ptp/Kconfig
> =A0create mode 100644 drivers/ptp/Makefile
> =A0create mode 100644 drivers/ptp/ptp_clock.c
> =A0create mode 100644 include/linux/ptp_clock.h
> =A0create mode 100644 include/linux/ptp_clock_kernel.h
>
> diff --git a/Documentation/ptp/ptp.txt b/Documentation/ptp/ptp.txt
> new file mode 100644
> index 0000000..46858b3
> --- /dev/null
> +++ b/Documentation/ptp/ptp.txt
> @@ -0,0 +1,95 @@
> +
> +* PTP infrastructure for Linux
> +
> + =A0This patch set introduces support for IEEE 1588 PTP clocks in
> + =A0Linux. Together with the SO_TIMESTAMPING socket options, this
> + =A0presents a standardized method for developing PTP user space
> + =A0programs, synchronizing Linux with external clocks, and using the
> + =A0ancillary features of PTP hardware clocks.
> +
> + =A0A new class driver exports a kernel interface for specific clock
> + =A0drivers and a user space interface. The infrastructure supports a
> + =A0complete set of PTP functionality.
> +
> + =A0+ Basic clock operations
> + =A0 =A0- Set time
> + =A0 =A0- Get time
> + =A0 =A0- Shift the clock by a given offset atomically
> + =A0 =A0- Adjust clock frequency
> +
> + =A0+ Ancillary clock features
> + =A0 =A0- One short or periodic alarms, with signal delivery to user pro=
gram
> + =A0 =A0- Time stamp external events
> + =A0 =A0- Period output signals configurable from user space
> + =A0 =A0- Synchronization of the Linux system time via the PPS subsystem
> +
> +** PTP kernel API
> +
> + =A0 A PTP clock driver registers itself with the class driver. The
> + =A0 class driver handles all of the dealings with user space. The
> + =A0 author of a clock driver need only implement the details of
> + =A0 programming the clock hardware. The clock driver notifies the class
> + =A0 driver of asynchronous events (alarms and external time stamps) via
> + =A0 a simple message passing interface.
> +
> + =A0 The class driver supports multiple PTP clock drivers. In normal use
> + =A0 cases, only one PTP clock is needed. However, for testing and
> + =A0 development, it can be useful to have more than one clock in a
> + =A0 single system, in order to allow performance comparisons.
> +
> +** PTP user space API
> +
> + =A0 The class driver creates a character device for each registered PTP
> + =A0 clock. User space programs may control the clock using standardized
> + =A0 ioctls. A program may query, enable, configure, and disable the
> + =A0 ancillary clock features. User space can receive time stamped
> + =A0 events via blocking read() and poll(). One shot and periodic
> + =A0 signals may be configured via an ioctl API with semantics similar
> + =A0 to the POSIX timer_settime() system call.
> +
> + =A0 As an real life example, the following two patches for ptpd version
> + =A0 1.0.0 demonstrate how the API works.
> +
> + =A0 https://sourceforge.net/tracker/?func=3Ddetail&aid=3D2992845&group_=
id=3D139814&atid=3D744634
> +
> + =A0 https://sourceforge.net/tracker/?func=3Ddetail&aid=3D2992847&group_=
id=3D139814&atid=3D744634

Question from an ignorant reviewer:  Why a new interface instead of
working with the existing high resolution timers infrastructure?

g.

> +
> +** Writing clock drivers
> +
> + =A0 Clock drivers include include/linux/ptp_clock_kernel.h and register
> + =A0 themselves by presenting a 'struct ptp_clock_info' to the
> + =A0 registration method. Clock drivers must implement all of the
> + =A0 functions in the interface. If a clock does not offer a particular
> + =A0 ancillary feature, then the driver should just return -EOPNOTSUPP
> + =A0 from those functions.
> +
> + =A0 Drivers must ensure that all of the methods in interface are
> + =A0 reentrant. Since most hardware implementations treat the time value
> + =A0 as a 64 bit integer accessed as two 32 bit registers, drivers
> + =A0 should use spin_lock_irqsave/spin_unlock_irqrestore to protect
> + =A0 against concurrent access. This locking cannot be accomplished in
> + =A0 class driver, since the lock may also be needed by the clock
> + =A0 driver's interrupt service routine.
> +
> +** Supported hardware
> +
> + =A0 + Standard Linux system timer
> + =A0 =A0 - No special PTP features
> + =A0 =A0 - For use with software time stamping
> +
> + =A0 + Freescale eTSEC gianfar
> + =A0 =A0 - 2 Time stamp external triggers, programmable polarity (opt. i=
nterrupt)
> + =A0 =A0 - 2 Alarm registers (optional interrupt)
> + =A0 =A0 - 3 Periodic signals (optional interrupt)
> +
> + =A0 + National DP83640
> + =A0 =A0 - 6 GPIOs programmable as inputs or outputs
> + =A0 =A0 - 6 GPIOs with dedicated functions (LED/JTAG/clock) can also be
> + =A0 =A0 =A0 used as general inputs or outputs
> + =A0 =A0 - GPIO inputs can time stamp external triggers
> + =A0 =A0 - GPIO outputs can produce periodic signals
> + =A0 =A0 - 1 interrupt pin
> +
> + =A0 + Intel IXP465
> + =A0 =A0 - Auxiliary Slave/Master Mode Snapshot (optional interrupt)
> + =A0 =A0 - Target Time (optional interrupt)
> diff --git a/Documentation/ptp/testptp.c b/Documentation/ptp/testptp.c
> new file mode 100644
> index 0000000..e30f758
> --- /dev/null
> +++ b/Documentation/ptp/testptp.c
> @@ -0,0 +1,269 @@
> +/*
> + * PTP 1588 clock support - User space test program
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or modi=
fy
> + * =A0it under the terms of the GNU General Public License as published =
by
> + * =A0the Free Software Foundation; either version 2 of the License, or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public License
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#include <errno.h>
> +#include <fcntl.h>
> +#include <signal.h>
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <sys/ioctl.h>
> +#include <sys/mman.h>
> +#include <sys/stat.h>
> +#include <sys/time.h>
> +#include <sys/types.h>
> +#include <time.h>
> +#include <unistd.h>
> +
> +#include <linux/ptp_clock.h>
> +
> +static void handle_alarm(int s)
> +{
> + =A0 =A0 =A0 printf("received signal %d\n", s);
> +}
> +
> +static int install_handler(int signum, void (*handler)(int))
> +{
> + =A0 =A0 =A0 struct sigaction action;
> + =A0 =A0 =A0 sigset_t mask;
> +
> + =A0 =A0 =A0 /* Unblock the signal. */
> + =A0 =A0 =A0 sigemptyset(&mask);
> + =A0 =A0 =A0 sigaddset(&mask, signum);
> + =A0 =A0 =A0 sigprocmask(SIG_UNBLOCK, &mask, NULL);
> +
> + =A0 =A0 =A0 /* Install the signal handler. */
> + =A0 =A0 =A0 action.sa_handler =3D handler;
> + =A0 =A0 =A0 action.sa_flags =3D 0;
> + =A0 =A0 =A0 sigemptyset(&action.sa_mask);
> + =A0 =A0 =A0 sigaction(signum, &action, NULL);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void usage(char *progname)
> +{
> + =A0 =A0 =A0 fprintf(stderr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "usage: %s [options]\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -a val =A0 =A0 request a one-shot alarm a=
fter 'val' seconds\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -A val =A0 =A0 request a periodic alarm e=
very 'val' seconds\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -c =A0 =A0 =A0 =A0 query the ptp clock's =
capabilities\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -d name =A0 =A0device to open\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -e val =A0 =A0 read 'val' external time s=
tamp events\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -f val =A0 =A0 adjust the ptp clock frequ=
ency by 'val' PPB\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -g =A0 =A0 =A0 =A0 get the ptp clock time=
\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -h =A0 =A0 =A0 =A0 prints this message\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -s =A0 =A0 =A0 =A0 set the ptp clock time=
 from the system time\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -t val =A0 =A0 shift the ptp clock time b=
y 'val' seconds\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " -v =A0 =A0 =A0 =A0 query the ptp clock ap=
i version\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 progname);
> +}
> +
> +int main(int argc, char *argv[])
> +{
> + =A0 =A0 =A0 struct ptp_clock_caps caps;
> + =A0 =A0 =A0 struct ptp_clock_timer timer;
> + =A0 =A0 =A0 struct ptp_extts_event event;
> + =A0 =A0 =A0 struct ptp_clock_request request;
> + =A0 =A0 =A0 struct timespec ts;
> + =A0 =A0 =A0 char *progname;
> + =A0 =A0 =A0 int c, cnt, fd, val =3D 0;
> +
> + =A0 =A0 =A0 char *device =3D "/dev/ptp_clock_0";
> + =A0 =A0 =A0 int adjfreq =3D 0x7fffffff;
> + =A0 =A0 =A0 int adjtime =3D 0;
> + =A0 =A0 =A0 int capabilities =3D 0;
> + =A0 =A0 =A0 int extts =3D 0;
> + =A0 =A0 =A0 int gettime =3D 0;
> + =A0 =A0 =A0 int oneshot =3D 0;
> + =A0 =A0 =A0 int periodic =3D 0;
> + =A0 =A0 =A0 int settime =3D 0;
> + =A0 =A0 =A0 int version =3D 0;
> +
> + =A0 =A0 =A0 progname =3D strrchr(argv[0], '/');
> + =A0 =A0 =A0 progname =3D progname ? 1+progname : argv[0];
> + =A0 =A0 =A0 while (EOF !=3D (c =3D getopt(argc, argv, "a:A:cd:e:f:ghst:=
v"))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (c) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'a':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 oneshot =3D atoi(optarg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'A':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 periodic =3D atoi(optarg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'c':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 capabilities =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'd':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 device =3D optarg;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'e':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 extts =3D atoi(optarg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'f':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 adjfreq =3D atoi(optarg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'g':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gettime =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 's':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 settime =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 't':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 adjtime =3D atoi(optarg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'v':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 version =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'h':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usage(progname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case '?':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usage(progname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 fd =3D open(device, O_RDWR);
> + =A0 =A0 =A0 if (fd < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fprintf(stderr, "cannot open %s: %s", devic=
e, strerror(errno));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (version) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioctl(fd, PTP_CLOCK_APIVERS, &val)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("PTP_CLOCK_APIVERS");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("version =3D 0x%08x\=
n", val);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (capabilities) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioctl(fd, PTP_CLOCK_GETCAPS, &caps)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("PTP_CLOCK_GETCAPS");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("capabilities:\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0%d maxi=
mum frequency adjustment (PPB)\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0%d prog=
rammable alarms\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0%d exte=
rnal time stamp channels\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0%d prog=
rammable periodic signals\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0" =A0%d puls=
e per second\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0caps.max_adj,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0caps.n_alarm,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0caps.n_ext_t=
s,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0caps.n_per_o=
ut,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0caps.pps);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (0x7fffffff !=3D adjfreq) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioctl(fd, PTP_CLOCK_ADJFREQ, adjfreq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("PTP_CLOCK_ADJFREQ");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 puts("frequency adjustment =
okay");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (adjtime) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ts.tv_sec =3D adjtime;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ts.tv_nsec =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioctl(fd, PTP_CLOCK_ADJTIME, &ts)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("PTP_CLOCK_ADJTIME");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 puts("time shift okay");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (gettime) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioctl(fd, PTP_CLOCK_GETTIME, &ts)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("PTP_CLOCK_GETTIME");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("clock time: %ld.%09=
ld or %s",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ts.tv_sec, t=
s.tv_nsec, ctime(&ts.tv_sec));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (settime) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock_gettime(CLOCK_REALTIME, &ts);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioctl(fd, PTP_CLOCK_SETTIME, &ts)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("PTP_CLOCK_SETTIME");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 puts("set time okay");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (extts) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&request, 0, sizeof(request));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 request.type =3D PTP_REQUEST_EXTTS;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 request.index =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 request.flags =3D PTP_ENABLE_FEATURE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioctl(fd, PTP_FEATURE_REQUEST, &request=
)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("PTP_FEATURE_REQUEST=
");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 extts =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 puts("set timer okay");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (; extts; extts--) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cnt =3D read(fd, &event, si=
zeof(event));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cnt !=3D sizeof(event))=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("rea=
d");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printf("event index %d at %=
ld.%09ld\n", event.index,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0event.ts.tv_=
sec, event.ts.tv_nsec);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Disable the feature again. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 request.flags =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioctl(fd, PTP_FEATURE_REQUEST, &request=
)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("PTP_FEATURE_REQUEST=
");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (oneshot) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 install_handler(SIGALRM, handle_alarm);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&timer, 0, sizeof(timer));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 timer.signum =3D SIGALRM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 timer.tsp.it_value.tv_sec =3D oneshot;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioctl(fd, PTP_CLOCK_SETTIMER, &timer)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("PTP_CLOCK_SETTIMER"=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 puts("set timer okay");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pause();
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (periodic) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 install_handler(SIGALRM, handle_alarm);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&timer, 0, sizeof(timer));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 timer.signum =3D SIGALRM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 timer.tsp.it_value.tv_sec =3D periodic;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 timer.tsp.it_interval.tv_sec =3D periodic;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioctl(fd, PTP_CLOCK_SETTIMER, &timer)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 perror("PTP_CLOCK_SETTIMER"=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 puts("set timer okay");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pause();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 close(fd);
> + =A0 =A0 =A0 return 0;
> +}
> diff --git a/Documentation/ptp/testptp.mk b/Documentation/ptp/testptp.mk
> new file mode 100644
> index 0000000..4ef2d97
> --- /dev/null
> +++ b/Documentation/ptp/testptp.mk
> @@ -0,0 +1,33 @@
> +# PTP 1588 clock support - User space test program
> +#
> +# Copyright (C) 2010 OMICRON electronics GmbH
> +#
> +# =A0This program is free software; you can redistribute it and/or modify
> +# =A0it under the terms of the GNU General Public License as published by
> +# =A0the Free Software Foundation; either version 2 of the License, or
> +# =A0(at your option) any later version.
> +#
> +# =A0This program is distributed in the hope that it will be useful,
> +# =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> +# =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
> +# =A0GNU General Public License for more details.
> +#
> +# =A0You should have received a copy of the GNU General Public License
> +# =A0along with this program; if not, write to the Free Software
> +# =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> +
> +CC =A0 =A0 =A0 =A0=3D $(CROSS_COMPILE)gcc
> +INC =A0 =A0 =A0 =3D -I$(KBUILD_OUTPUT)/usr/include
> +CFLAGS =A0 =A0=3D -Wall $(INC)
> +LDLIBS =A0 =A0=3D -lrt
> +PROGS =A0 =A0 =3D testptp
> +
> +all: $(PROGS)
> +
> +testptp: testptp.o
> +
> +clean:
> + =A0 =A0 =A0 rm -f testptp.o
> +
> +distclean: clean
> + =A0 =A0 =A0 rm -f $(PROGS)
> diff --git a/drivers/Kconfig b/drivers/Kconfig
> index a2b902f..774fbd7 100644
> --- a/drivers/Kconfig
> +++ b/drivers/Kconfig
> @@ -52,6 +52,8 @@ source "drivers/spi/Kconfig"
>
> =A0source "drivers/pps/Kconfig"
>
> +source "drivers/ptp/Kconfig"
> +
> =A0source "drivers/gpio/Kconfig"
>
> =A0source "drivers/w1/Kconfig"
> diff --git a/drivers/Makefile b/drivers/Makefile
> index 91874e0..6d12b48 100644
> --- a/drivers/Makefile
> +++ b/drivers/Makefile
> @@ -76,6 +76,7 @@ obj-$(CONFIG_I2O) =A0 =A0 =A0 =A0 =A0 =A0 +=3D message/
> =A0obj-$(CONFIG_RTC_LIB) =A0 =A0 =A0 =A0 =A0+=3D rtc/
> =A0obj-y =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0+=3D i2c/ med=
ia/
> =A0obj-$(CONFIG_PPS) =A0 =A0 =A0 =A0 =A0 =A0 =A0+=3D pps/
> +obj-$(CONFIG_PTP_1588_CLOCK) =A0 +=3D ptp/
> =A0obj-$(CONFIG_W1) =A0 =A0 =A0 =A0 =A0 =A0 =A0 +=3D w1/
> =A0obj-$(CONFIG_POWER_SUPPLY) =A0 =A0 +=3D power/
> =A0obj-$(CONFIG_HWMON) =A0 =A0 =A0 =A0 =A0 =A0+=3D hwmon/
> diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
> new file mode 100644
> index 0000000..c80a25b
> --- /dev/null
> +++ b/drivers/ptp/Kconfig
> @@ -0,0 +1,26 @@
> +#
> +# PTP clock support configuration
> +#
> +
> +menu "PTP clock support"
> +
> +config PTP_1588_CLOCK
> + =A0 =A0 =A0 tristate "PTP clock support"
> + =A0 =A0 =A0 depends on EXPERIMENTAL
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 The IEEE 1588 standard defines a method to precisely
> + =A0 =A0 =A0 =A0 synchronize distributed clocks over Ethernet networks. =
The
> + =A0 =A0 =A0 =A0 standard defines a Precision Time Protocol (PTP), which=
 can
> + =A0 =A0 =A0 =A0 be used to achieve synchronization within a few dozen
> + =A0 =A0 =A0 =A0 microseconds. In addition, with the help of special har=
dware
> + =A0 =A0 =A0 =A0 time stamping units, it can be possible to achieve
> + =A0 =A0 =A0 =A0 synchronization to within a few hundred nanoseconds.
> +
> + =A0 =A0 =A0 =A0 This driver adds support for PTP clocks as character
> + =A0 =A0 =A0 =A0 devices. If you want to use a PTP clock, then you should
> + =A0 =A0 =A0 =A0 also enable at least one clock driver as well.
> +
> + =A0 =A0 =A0 =A0 To compile this driver as a module, choose M here: the =
module
> + =A0 =A0 =A0 =A0 will be called ptp_clock.
> +
> +endmenu
> diff --git a/drivers/ptp/Makefile b/drivers/ptp/Makefile
> new file mode 100644
> index 0000000..b86695c
> --- /dev/null
> +++ b/drivers/ptp/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for PTP 1588 clock support.
> +#
> +
> +obj-$(CONFIG_PTP_1588_CLOCK) =A0 =A0 =A0 =A0 =A0 +=3D ptp_clock.o
> diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
> new file mode 100644
> index 0000000..4753bf3
> --- /dev/null
> +++ b/drivers/ptp/ptp_clock.c
> @@ -0,0 +1,514 @@
> +/*
> + * PTP 1588 clock support
> + *
> + * Partially adapted from the Linux PPS driver.
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or modi=
fy
> + * =A0it under the terms of the GNU General Public License as published =
by
> + * =A0the Free Software Foundation; either version 2 of the License, or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public License
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#include <linux/bitops.h>
> +#include <linux/cdev.h>
> +#include <linux/device.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/list.h>
> +#include <linux/module.h>
> +#include <linux/poll.h>
> +#include <linux/sched.h>
> +#include <linux/slab.h>
> +#include <linux/uaccess.h>
> +
> +#include <linux/ptp_clock_kernel.h>
> +#include <linux/ptp_clock.h>
> +
> +#define PTP_MAX_ALARMS 4
> +#define PTP_MAX_CLOCKS BITS_PER_LONG
> +#define PTP_MAX_TIMESTAMPS 128
> +
> +struct alarm {
> + =A0 =A0 =A0 struct pid *pid;
> + =A0 =A0 =A0 int sig;
> +};
> +
> +struct timestamp_event_queue {
> + =A0 =A0 =A0 struct ptp_extts_event buf[PTP_MAX_TIMESTAMPS];
> + =A0 =A0 =A0 int head;
> + =A0 =A0 =A0 int tail;
> + =A0 =A0 =A0 int overflow;
> +};
> +
> +struct ptp_clock {
> + =A0 =A0 =A0 struct list_head list;
> + =A0 =A0 =A0 struct cdev cdev;
> + =A0 =A0 =A0 struct device *dev;
> + =A0 =A0 =A0 struct ptp_clock_info *info;
> + =A0 =A0 =A0 dev_t devid;
> + =A0 =A0 =A0 int index; /* index into clocks.map, also the minor number =
*/
> +
> + =A0 =A0 =A0 struct alarm alarm[PTP_MAX_ALARMS];
> + =A0 =A0 =A0 struct mutex alarm_mux; /* one process at a time setting an=
 alarm */
> +
> + =A0 =A0 =A0 struct timestamp_event_queue tsevq; /* simple fifo for time=
 stamps */
> + =A0 =A0 =A0 struct mutex tsevq_mux; /* one process at a time reading th=
e fifo */
> + =A0 =A0 =A0 wait_queue_head_t tsev_wq;
> +};
> +
> +/* private globals */
> +
> +static const struct file_operations ptp_fops;
> +static dev_t ptp_devt;
> +static struct class *ptp_class;
> +
> +static struct {
> + =A0 =A0 =A0 struct list_head list;
> + =A0 =A0 =A0 DECLARE_BITMAP(map, PTP_MAX_CLOCKS);
> +} clocks;
> +static DEFINE_SPINLOCK(clocks_lock); /* protects 'clocks' */
> +
> +/* time stamp event queue operations */
> +
> +static inline int queue_cnt(struct timestamp_event_queue *q)
> +{
> + =A0 =A0 =A0 int cnt =3D q->tail - q->head;
> + =A0 =A0 =A0 return cnt < 0 ? PTP_MAX_TIMESTAMPS + cnt : cnt;
> +}
> +
> +static inline int queue_free(struct timestamp_event_queue *q)
> +{
> + =A0 =A0 =A0 return PTP_MAX_TIMESTAMPS - queue_cnt(q) - 1;
> +}
> +
> +static void enqueue_external_timestamp(struct timestamp_event_queue *que=
ue,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0struct ptp_clock_event *src)
> +{
> + =A0 =A0 =A0 struct ptp_extts_event *dst;
> + =A0 =A0 =A0 u32 remainder;
> +
> + =A0 =A0 =A0 dst =3D &queue->buf[queue->tail];
> +
> + =A0 =A0 =A0 dst->index =3D src->index;
> + =A0 =A0 =A0 dst->ts.tv_sec =3D div_u64_rem(src->timestamp, 1000000000, =
&remainder);
> + =A0 =A0 =A0 dst->ts.tv_nsec =3D remainder;
> +
> + =A0 =A0 =A0 if (!queue_free(queue))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue->overflow++;
> +
> + =A0 =A0 =A0 queue->tail =3D (queue->tail + 1) % PTP_MAX_TIMESTAMPS;
> +}
> +
> +/* public interface */
> +
> +struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp;
> + =A0 =A0 =A0 int err =3D 0, index, major =3D MAJOR(ptp_devt);
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 if (info->n_alarm > PTP_MAX_ALARMS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EINVAL);
> +
> + =A0 =A0 =A0 /* Find a free clock slot and reserve it. */
> + =A0 =A0 =A0 err =3D -EBUSY;
> + =A0 =A0 =A0 spin_lock_irqsave(&clocks_lock, flags);
> + =A0 =A0 =A0 index =3D find_first_zero_bit(clocks.map, PTP_MAX_CLOCKS);
> + =A0 =A0 =A0 if (index < PTP_MAX_CLOCKS) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(index, clocks.map);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&clocks_lock, flags);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&clocks_lock, flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_clock;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* Initialize a clock structure. */
> + =A0 =A0 =A0 err =3D -ENOMEM;
> + =A0 =A0 =A0 ptp =3D kzalloc(sizeof(struct ptp_clock), GFP_KERNEL);
> + =A0 =A0 =A0 if (ptp =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_memory;
> +
> + =A0 =A0 =A0 ptp->info =3D info;
> + =A0 =A0 =A0 ptp->devid =3D MKDEV(major, index);
> + =A0 =A0 =A0 ptp->index =3D index;
> + =A0 =A0 =A0 mutex_init(&ptp->alarm_mux);
> + =A0 =A0 =A0 mutex_init(&ptp->tsevq_mux);
> + =A0 =A0 =A0 init_waitqueue_head(&ptp->tsev_wq);
> +
> + =A0 =A0 =A0 /* Create a new device in our class. */
> + =A0 =A0 =A0 ptp->dev =3D device_create(ptp_class, NULL, ptp->devid, ptp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"ptp_clo=
ck_%d", ptp->index);
> + =A0 =A0 =A0 if (IS_ERR(ptp->dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_device;
> +
> + =A0 =A0 =A0 dev_set_drvdata(ptp->dev, ptp);
> +
> + =A0 =A0 =A0 /* Register a character device. */
> + =A0 =A0 =A0 cdev_init(&ptp->cdev, &ptp_fops);
> + =A0 =A0 =A0 ptp->cdev.owner =3D info->owner;
> + =A0 =A0 =A0 err =3D cdev_add(&ptp->cdev, ptp->devid, 1);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_cdev;
> +
> + =A0 =A0 =A0 /* Clock is ready, add it into the list. */
> + =A0 =A0 =A0 spin_lock_irqsave(&clocks_lock, flags);
> + =A0 =A0 =A0 list_add(&ptp->list, &clocks.list);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&clocks_lock, flags);
> +
> + =A0 =A0 =A0 return ptp;
> +
> +no_cdev:
> + =A0 =A0 =A0 device_destroy(ptp_class, ptp->devid);
> +no_device:
> + =A0 =A0 =A0 mutex_destroy(&ptp->alarm_mux);
> + =A0 =A0 =A0 mutex_destroy(&ptp->tsevq_mux);
> + =A0 =A0 =A0 kfree(ptp);
> +no_memory:
> + =A0 =A0 =A0 spin_lock_irqsave(&clocks_lock, flags);
> + =A0 =A0 =A0 clear_bit(index, clocks.map);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&clocks_lock, flags);
> +no_clock:
> + =A0 =A0 =A0 return ERR_PTR(err);
> +}
> +EXPORT_SYMBOL(ptp_clock_register);
> +
> +int ptp_clock_unregister(struct ptp_clock *ptp)
> +{
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 /* Release the clock's resources. */
> + =A0 =A0 =A0 cdev_del(&ptp->cdev);
> + =A0 =A0 =A0 device_destroy(ptp_class, ptp->devid);
> + =A0 =A0 =A0 mutex_destroy(&ptp->alarm_mux);
> + =A0 =A0 =A0 mutex_destroy(&ptp->tsevq_mux);
> +
> + =A0 =A0 =A0 /* Remove the clock from the list. */
> + =A0 =A0 =A0 spin_lock_irqsave(&clocks_lock, flags);
> + =A0 =A0 =A0 list_del(&ptp->list);
> + =A0 =A0 =A0 clear_bit(ptp->index, clocks.map);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&clocks_lock, flags);
> +
> + =A0 =A0 =A0 kfree(ptp);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +EXPORT_SYMBOL(ptp_clock_unregister);
> +
> +void ptp_clock_event(struct ptp_clock *ptp, struct ptp_clock_event *even=
t)
> +{
> + =A0 =A0 =A0 switch (event->type) {
> +
> + =A0 =A0 =A0 case PTP_CLOCK_ALARM:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kill_pid(ptp->alarm[event->index].pid,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->alarm[event->index]=
.sig, 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_EXTTS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enqueue_external_timestamp(&ptp->tsevq, eve=
nt);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up_interruptible(&ptp->tsev_wq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_PPS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> +}
> +EXPORT_SYMBOL(ptp_clock_event);
> +
> +/* character device operations */
> +
> +static int ptp_ioctl(struct inode *node, struct file *fp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int cmd, unsigned long=
 arg)
> +{
> + =A0 =A0 =A0 struct ptp_clock_caps caps;
> + =A0 =A0 =A0 struct ptp_clock_request req;
> + =A0 =A0 =A0 struct ptp_clock_timer timer;
> + =A0 =A0 =A0 struct ptp_clock *ptp =3D fp->private_data;
> + =A0 =A0 =A0 struct ptp_clock_info *ops =3D ptp->info;
> + =A0 =A0 =A0 void *priv =3D ops->priv;
> + =A0 =A0 =A0 struct timespec ts;
> + =A0 =A0 =A0 int flags, index;
> + =A0 =A0 =A0 int err =3D 0;
> +
> + =A0 =A0 =A0 switch (cmd) {
> +
> + =A0 =A0 =A0 case PTP_CLOCK_APIVERS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D put_user(PTP_CLOCK_VERSION, (u32 __=
user *)arg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_ADJFREQ:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!capable(CAP_SYS_TIME))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->adjfreq(priv, arg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_ADJTIME:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!capable(CAP_SYS_TIME))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&ts, (void __user *)arg,=
 sizeof(ts)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->adjtime(priv, =
&ts);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_GETTIME:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->gettime(priv, &ts);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D copy_to_user((void __user *)arg, &t=
s, sizeof(ts));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_SETTIME:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!capable(CAP_SYS_TIME))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&ts, (void __user *)arg,=
 sizeof(ts)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->settime(priv, =
&ts);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_GETCAPS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&caps, 0, sizeof(caps));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caps.max_adj =3D ptp->info->max_adj;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caps.n_alarm =3D ptp->info->n_alarm;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caps.n_ext_ts =3D ptp->info->n_ext_ts;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caps.n_per_out =3D ptp->info->n_per_out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 caps.pps =3D ptp->info->pps;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D copy_to_user((void __user *)arg, &c=
aps, sizeof(caps));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_GETTIMER:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&timer, (void __user *)a=
rg, sizeof(timer))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index =3D timer.alarm_index;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (index < 0 || index >=3D ptp->info->n_al=
arm) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->gettimer(priv, index, &timer.t=
sp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D copy_to_user((void __user *)arg, &t=
imer, sizeof(timer));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_CLOCK_SETTIMER:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&timer, (void __user *)a=
rg, sizeof(timer))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index =3D timer.alarm_index;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (index < 0 || index >=3D ptp->info->n_al=
arm) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!valid_signal(timer.signum))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags =3D timer.flags;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (flags & (flags !=3D TIMER_ABSTIME)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mutex_lock_interruptible(&ptp->alarm_mu=
x))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ERESTARTSYS;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ptp->alarm[index].pid)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_pid(ptp->alarm[index].p=
id);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp->alarm[index].pid =3D get_pid(task_pid(=
current));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp->alarm[index].sig =3D timer.signum;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->settimer(priv, index, flags, &=
timer.tsp);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&ptp->alarm_mux);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 case PTP_FEATURE_REQUEST:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&req, (void __user *)arg=
, sizeof(req))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (req.type) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PTP_REQUEST_EXTTS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PTP_REQUEST_PEROUT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PTP_REQUEST_PPS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!capable(CAP_SYS_TIME))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPE=
RM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ops->enable(priv, &req,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 req.fla=
gs & PTP_ENABLE_FEATURE ? 1 : 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOTTY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int ptp_open(struct inode *inode, struct file *fp)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp;
> + =A0 =A0 =A0 ptp =3D container_of(inode->i_cdev, struct ptp_clock, cdev);
> +
> + =A0 =A0 =A0 fp->private_data =3D ptp;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static unsigned int ptp_poll(struct file *fp, poll_table *wait)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp =3D fp->private_data;
> +
> + =A0 =A0 =A0 poll_wait(fp, &ptp->tsev_wq, wait);
> +
> + =A0 =A0 =A0 return queue_cnt(&ptp->tsevq) ? POLLIN : 0;
> +}
> +
> +static ssize_t ptp_read(struct file *fp, char __user *buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t cnt, loff_t *off)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp =3D fp->private_data;
> + =A0 =A0 =A0 struct timestamp_event_queue *queue =3D &ptp->tsevq;
> + =A0 =A0 =A0 struct ptp_extts_event *event;
> + =A0 =A0 =A0 size_t qcnt;
> +
> + =A0 =A0 =A0 if (mutex_lock_interruptible(&ptp->tsevq_mux))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ERESTARTSYS;
> +
> + =A0 =A0 =A0 cnt =3D cnt / sizeof(struct ptp_extts_event);
> +
> + =A0 =A0 =A0 if (wait_event_interruptible(ptp->tsev_wq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
(qcnt =3D queue_cnt(&ptp->tsevq)))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&ptp->tsevq_mux);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ERESTARTSYS;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (cnt > qcnt)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cnt =3D qcnt;
> +
> + =A0 =A0 =A0 event =3D &queue->buf[queue->head];
> +
> + =A0 =A0 =A0 if (copy_to_user(buf, event, cnt * sizeof(struct ptp_extts_=
event))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&ptp->tsevq_mux);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 queue->head =3D (queue->head + cnt) % PTP_MAX_TIMESTAMPS;
> +
> + =A0 =A0 =A0 mutex_unlock(&ptp->tsevq_mux);
> +
> + =A0 =A0 =A0 return cnt * sizeof(struct ptp_extts_event);
> +}
> +
> +static int ptp_release(struct inode *inode, struct file *fp)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp;
> + =A0 =A0 =A0 struct itimerspec ts =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 {0, 0}, {0, 0}
> + =A0 =A0 =A0 };
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 ptp =3D container_of(inode->i_cdev, struct ptp_clock, cdev);
> +
> + =A0 =A0 =A0 for (i =3D 0; i < ptp->info->n_alarm; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ptp->alarm[i].pid) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp->info->settimer(ptp->in=
fo->priv, i, 0, &ts);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_pid(ptp->alarm[i].pid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptp->alarm[i].pid =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static const struct file_operations ptp_fops =3D {
> + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,
> + =A0 =A0 =A0 .ioctl =A0 =A0 =A0 =A0 =A0=3D ptp_ioctl,
> + =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D ptp_open,
> + =A0 =A0 =A0 .poll =A0 =A0 =A0 =A0 =A0 =3D ptp_poll,
> + =A0 =A0 =A0 .read =A0 =A0 =A0 =A0 =A0 =3D ptp_read,
> + =A0 =A0 =A0 .release =A0 =A0 =A0 =A0=3D ptp_release,
> +};
> +
> +/* sysfs */
> +
> +static ssize_t ptp_show_status(struct device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct devic=
e_attribute *attr, char *buf)
> +{
> + =A0 =A0 =A0 struct ptp_clock *ptp =3D dev_get_drvdata(dev);
> + =A0 =A0 =A0 return sprintf(buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"maximum adjustment: =A0%d\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"programmable alarms: %d\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"external timestamps: %d\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"periodic outputs: =A0 =A0%d=
\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"has pps: =A0 =A0 =A0 =A0 =
=A0 =A0 %d\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"device index: =A0 =A0 =A0 =
=A0%d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->info->max_adj,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->info->n_alarm,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->info->n_ext_ts,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->info->n_per_out,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->info->pps,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ptp->index);
> +}
> +
> +struct device_attribute ptp_attrs[] =3D {
> + =A0 =A0 =A0 __ATTR(capabilities, S_IRUGO, ptp_show_status, NULL),
> + =A0 =A0 =A0 __ATTR_NULL,
> +};
> +
> +/* module operations */
> +
> +static void __exit ptp_exit(void)
> +{
> + =A0 =A0 =A0 class_destroy(ptp_class);
> + =A0 =A0 =A0 unregister_chrdev_region(ptp_devt, PTP_MAX_CLOCKS);
> +}
> +
> +static int __init ptp_init(void)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 INIT_LIST_HEAD(&clocks.list);
> +
> + =A0 =A0 =A0 ptp_class =3D class_create(THIS_MODULE, "ptp");
> + =A0 =A0 =A0 if (!ptp_class) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "ptp: failed to allocate cl=
ass\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 ptp_class->dev_attrs =3D ptp_attrs;
> +
> + =A0 =A0 =A0 err =3D alloc_chrdev_region(&ptp_devt, 0, PTP_MAX_CLOCKS, "=
ptp");
> + =A0 =A0 =A0 if (err < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "ptp: failed to allocate ch=
ar device region\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto no_region;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 pr_info("PTP clock support registered\n");
> + =A0 =A0 =A0 return 0;
> +
> +no_region:
> + =A0 =A0 =A0 class_destroy(ptp_class);
> + =A0 =A0 =A0 return err;
> +}
> +
> +subsys_initcall(ptp_init);
> +module_exit(ptp_exit);
> +
> +MODULE_AUTHOR("Richard Cochran <richard.cochran@omicron.at>");
> +MODULE_DESCRIPTION("PTP clocks support");
> +MODULE_LICENSE("GPL");
> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
> index 2fc8e14..9959fe4 100644
> --- a/include/linux/Kbuild
> +++ b/include/linux/Kbuild
> @@ -140,6 +140,7 @@ header-y +=3D pkt_sched.h
> =A0header-y +=3D posix_types.h
> =A0header-y +=3D ppdev.h
> =A0header-y +=3D prctl.h
> +header-y +=3D ptp_clock.h
> =A0header-y +=3D qnxtypes.h
> =A0header-y +=3D qnx4_fs.h
> =A0header-y +=3D radeonfb.h
> diff --git a/include/linux/ptp_clock.h b/include/linux/ptp_clock.h
> new file mode 100644
> index 0000000..5a509c5
> --- /dev/null
> +++ b/include/linux/ptp_clock.h
> @@ -0,0 +1,79 @@
> +/*
> + * PTP 1588 clock support - user space interface
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or modi=
fy
> + * =A0it under the terms of the GNU General Public License as published =
by
> + * =A0the Free Software Foundation; either version 2 of the License, or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public License
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +
> +#ifndef _PTP_CLOCK_H_
> +#define _PTP_CLOCK_H_
> +
> +#include <linux/ioctl.h>
> +#include <linux/types.h>
> +
> +#define PTP_ENABLE_FEATURE (1<<0)
> +#define PTP_RISING_EDGE =A0 =A0(1<<1)
> +#define PTP_FALLING_EDGE =A0 (1<<2)
> +
> +enum ptp_request_types {
> + =A0 =A0 =A0 PTP_REQUEST_EXTTS,
> + =A0 =A0 =A0 PTP_REQUEST_PEROUT,
> + =A0 =A0 =A0 PTP_REQUEST_PPS,
> +};
> +
> +struct ptp_clock_caps {
> + =A0 =A0 =A0 __s32 max_adj; /* Maximum frequency adjustment, parts per b=
illon. */
> + =A0 =A0 =A0 int n_alarm; =A0 /* Number of programmable alarms. */
> + =A0 =A0 =A0 int n_ext_ts; =A0/* Number of external time stamp channels.=
 */
> + =A0 =A0 =A0 int n_per_out; /* Number of programmable periodic signals. =
*/
> + =A0 =A0 =A0 int pps; =A0 =A0 =A0 /* Whether the clock supports a PPS ca=
llback. */
> +};
> +
> +struct ptp_clock_timer {
> + =A0 =A0 =A0 int alarm_index; =A0 =A0 =A0 /* Which alarm to query or con=
figure. */
> + =A0 =A0 =A0 int signum; =A0 =A0 =A0 =A0 =A0 =A0/* Requested signal. */
> + =A0 =A0 =A0 int flags; =A0 =A0 =A0 =A0 =A0 =A0 /* Zero or TIMER_ABSTIME=
, see TIMER_SETTIME(2) */
> + =A0 =A0 =A0 struct itimerspec tsp; /* See TIMER_SETTIME(2) */
> +};
> +
> +struct ptp_clock_request {
> + =A0 =A0 =A0 int type; =A0/* One of the ptp_request_types enumeration va=
lues. */
> + =A0 =A0 =A0 int index; /* Which channel to configure. */
> + =A0 =A0 =A0 struct timespec ts; /* For period signals, the desired peri=
od. */
> + =A0 =A0 =A0 int flags; /* Bit field for PTP_ENABLE_FEATURE or other fla=
gs. */
> +};
> +
> +struct ptp_extts_event {
> + =A0 =A0 =A0 int index;
> + =A0 =A0 =A0 struct timespec ts;
> +};
> +
> +#define PTP_CLOCK_VERSION 0x00000001
> +
> +#define PTP_CLK_MAGIC '=3D'
> +
> +#define PTP_CLOCK_APIVERS _IOR (PTP_CLK_MAGIC, 1, __u32)
> +#define PTP_CLOCK_ADJFREQ _IO =A0(PTP_CLK_MAGIC, 2)
> +#define PTP_CLOCK_ADJTIME _IOW (PTP_CLK_MAGIC, 3, struct timespec)
> +#define PTP_CLOCK_GETTIME _IOR (PTP_CLK_MAGIC, 4, struct timespec)
> +#define PTP_CLOCK_SETTIME _IOW (PTP_CLK_MAGIC, 5, struct timespec)
> +
> +#define PTP_CLOCK_GETCAPS =A0 _IOR =A0(PTP_CLK_MAGIC, 6, struct ptp_cloc=
k_caps)
> +#define PTP_CLOCK_GETTIMER =A0_IOWR (PTP_CLK_MAGIC, 7, struct ptp_clock_=
timer)
> +#define PTP_CLOCK_SETTIMER =A0_IOW =A0(PTP_CLK_MAGIC, 8, struct ptp_cloc=
k_timer)
> +#define PTP_FEATURE_REQUEST _IOW =A0(PTP_CLK_MAGIC, 9, struct ptp_clock_=
request)
> +
> +#endif
> diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_k=
ernel.h
> new file mode 100644
> index 0000000..d6cc158
> --- /dev/null
> +++ b/include/linux/ptp_clock_kernel.h
> @@ -0,0 +1,137 @@
> +/*
> + * PTP 1588 clock support
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + *
> + * =A0This program is free software; you can redistribute it and/or modi=
fy
> + * =A0it under the terms of the GNU General Public License as published =
by
> + * =A0the Free Software Foundation; either version 2 of the License, or
> + * =A0(at your option) any later version.
> + *
> + * =A0This program is distributed in the hope that it will be useful,
> + * =A0but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * =A0MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. =A0See the
> + * =A0GNU General Public License for more details.
> + *
> + * =A0You should have received a copy of the GNU General Public License
> + * =A0along with this program; if not, write to the Free Software
> + * =A0Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +
> +#ifndef _PTP_CLOCK_KERNEL_H_
> +#define _PTP_CLOCK_KERNEL_H_
> +
> +#include <linux/ptp_clock.h>
> +
> +/**
> + * struct ptp_clock_info - decribes a PTP hardware clock
> + *
> + * @owner: =A0 =A0 The clock driver should set to THIS_MODULE.
> + * @name: =A0 =A0 =A0A short name to identify the clock.
> + * @max_adj: =A0 The maximum possible frequency adjustment, in parts per=
 billon.
> + * @n_alarm: =A0 The number of programmable alarms.
> + * @n_ext_ts: =A0The number of external time stamp channels.
> + * @n_per_out: The number of programmable periodic signals.
> + * @pps: =A0 =A0 =A0 Indicates whether the clock supports a PPS callback.
> + * @priv: =A0 =A0 =A0Passed to the clock operations, for the driver's pr=
ivate use.
> + *
> + * clock operations
> + *
> + * @adjfreq: =A0Adjusts the frequency of the hardware clock.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter delta: Desired period change in part=
s per billion.
> + *
> + * @adjtime: =A0Shifts the time of the hardware clock.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter ts: Desired change in seconds and na=
noseconds.
> + *
> + * @gettime: =A0Reads the current time from the hardware clock.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter ts: Holds the result.
> + *
> + * @settime: =A0Set the current time on the hardware clock.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter ts: Time value to set.
> + *
> + * @gettimer: Reads the time remaining from the given timer.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter index: Which alarm to query.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter ts: Holds the result.
> + *
> + * @settimer: Arms the given timer for periodic or one shot operation.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter index: Which alarm to set.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter abs: TIMER_ABSTIME, or zero for rela=
tive timer.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter ts: Alarm time and period to set.
> + *
> + * @enable: =A0 Request driver to enable or disable an ancillary feature.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter request: Desired resource to enable =
or disable.
> + * =A0 =A0 =A0 =A0 =A0 =A0parameter on: Caller passes one to enable or z=
ero to disable.
> + *
> + * The callbacks must all return zero on success, non-zero otherwise.
> + */
> +
> +struct ptp_clock_info {
> + =A0 =A0 =A0 struct module *owner;
> + =A0 =A0 =A0 char name[16];
> + =A0 =A0 =A0 s32 max_adj;
> + =A0 =A0 =A0 int n_alarm;
> + =A0 =A0 =A0 int n_ext_ts;
> + =A0 =A0 =A0 int n_per_out;
> + =A0 =A0 =A0 int pps;
> + =A0 =A0 =A0 void *priv;
> + =A0 =A0 =A0 int (*adjfreq)(void *priv, s32 delta);
> + =A0 =A0 =A0 int (*adjtime)(void *priv, struct timespec *ts);
> + =A0 =A0 =A0 int (*gettime)(void *priv, struct timespec *ts);
> + =A0 =A0 =A0 int (*settime)(void *priv, struct timespec *ts);
> + =A0 =A0 =A0 int (*gettimer)(void *priv, int index, struct itimerspec *t=
s);
> + =A0 =A0 =A0 int (*settimer)(void *priv, int index, int abs, struct itim=
erspec *ts);
> + =A0 =A0 =A0 int (*enable)(void *priv, struct ptp_clock_request *request=
, int on);
> +};
> +
> +struct ptp_clock;
> +
> +/**
> + * ptp_clock_register() - register a PTP hardware clock driver
> + *
> + * @info: =A0Structure describing the new clock.
> + */
> +
> +extern struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info);
> +
> +/**
> + * ptp_clock_unregister() - unregister a PTP hardware clock driver
> + *
> + * @ptp: =A0The clock to remove from service.
> + */
> +
> +extern int ptp_clock_unregister(struct ptp_clock *ptp);
> +
> +
> +enum ptp_clock_events {
> + =A0 =A0 =A0 PTP_CLOCK_ALARM,
> + =A0 =A0 =A0 PTP_CLOCK_EXTTS,
> + =A0 =A0 =A0 PTP_CLOCK_PPS,
> +};
> +
> +/**
> + * struct ptp_clock_event - decribes a PTP hardware clock event
> + *
> + * @type: =A0One of the ptp_clock_events enumeration values.
> + * @index: Identifies the source of the event.
> + * @timestamp: When the event occured.
> + */
> +
> +struct ptp_clock_event {
> + =A0 =A0 =A0 int type;
> + =A0 =A0 =A0 int index;
> + =A0 =A0 =A0 u64 timestamp;
> +};
> +
> +/**
> + * ptp_clock_event() - notify the PTP layer about an event
> + *
> + * This function should only be called from interrupt context.
> + *
> + * @ptp: =A0 =A0The clock obtained from ptp_clock_register().
> + * @event: =A0Message structure describing the event.
> + */
> +
> +extern void ptp_clock_event(struct ptp_clock *ptp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ptp_clock_ev=
ent *event);
> +
> +#endif
> --
> 1.6.3.3
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
