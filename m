From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: gigaset: memory leak in gigaset_initcshw
Date: Thu, 4 Feb 2016 15:54:02 +0100
Message-ID: <CACT4Y+b2z0NHVPQbyYP1CA_80hXxhk+VOG6dzduMEsi+27Pi7Q@mail.gmail.com>
References: <CACT4Y+Y+P7-pM0D4HTz4ZF6i+Rya22eOkPdnrv_OmDCMB7eQtg@mail.gmail.com>
 <1454516189.14366.8.camel@tiscali.nl> <1454526665.14366.22.camel@tiscali.nl>
 <CACT4Y+aDi8L_GELzVv7QM8YdtMD7q-wH4uO7LhioeSvaEU5PJg@mail.gmail.com>
 <1454591389.14366.49.camel@tiscali.nl> <CACT4Y+aXo83LjyOjVG2ihyR94kex-z+=Of+x8o4i+0q8964-1g@mail.gmail.com>
 <1454593604.14366.65.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33651 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965228AbcBDOyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 09:54:23 -0500
Received: by mail-wm0-f46.google.com with SMTP id g62so8156994wme.0
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 06:54:22 -0800 (PST)
In-Reply-To: <1454593604.14366.65.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 4, 2016 at 2:46 PM, Paul Bolle <pebolle@tiscali.nl> wrote:
> Hi Dmitry,
>
> On do, 2016-02-04 at 14:15 +0100, Dmitry Vyukov wrote:
>> On Thu, Feb 4, 2016 at 2:09 PM, Paul Bolle <pebolle@tiscali.nl> wrote:
>> > What are you seeing here?
>>
>> I see that active_objs is slowly, constantly growing.
>>
>> I've attached my config file, please try with it. You mentioned that
>> "16 is N_GIGASET_M101, while 7 is N_6PACK", probably one of these ttys
>> is not enabled in your config,
>
> Both are. (A 6pack module is loaded when I run the reproducer. I have no
> idea what 6pack is good for. ser_gigaset is familiar, to me.)
>
>>  and so the reproducer is not doing
>> anything useful.
>
> I actually wonder whether N_6PACK is relevant. Do you also see this
> issue with another line discipline in the second TIOCSETD ioctl?
>
> Maybe it even triggers with two totally different line disciplines in
> both calls? A (slightly edited) copy of tty.h is pasted below. It lists
> the useful values for the TIOCSETD ioctl.
>
> Would you mind testing a few combinations?
>
> Thanks,
>
>
> Paul Bolle
>
> /* line disciplines */
> #define N_TTY           0
> #define N_SLIP          1
> #define N_MOUSE         2
> #define N_PPP           3
>                                 /* 4 is obsolete */
> #define N_AX25          5
> #define N_X25           6       /* X.25 async */
> #define N_6PACK         7
>                                 /* 8 is obsolete */
> #define N_R3964         9       /* Simatic R3964 */
>                                 /* 10 is obsolete */
> #define N_IRDA          11      /* Linux IrDa - http://irda.sourceforge.net/ */
>                                 /* 12 is obsolete */
> #define N_HDLC          13      /* synchronous HDLC */
> #define N_SYNC_PPP      14      /* synchronous PPP */
> #define N_HCI           15      /* Bluetooth HCI UART */
> #define N_GIGASET_M101  16      /* Siemens Gigaset M101 serial DECT adapter */
> #define N_SLCAN         17      /* Serial / USB serial CAN Adaptors */
> #define N_PPS           18      /* Pulse per Second */
> #define N_V253          19      /* Codec control over voice modem */
> #define N_CAIF          20      /* CAIF protocol for talking to modems */
> #define N_GSM0710       21      /* GSM 0710 Mux */
> #define N_TI_WL         22      /* for TI's WL BT, FM, GPS combo chips */
> #define N_TRACESINK     23      /* Trace data routing for MIPI P1149.7 */
> #define N_TRACEROUTER   24      /* Trace data routing for MIPI P1149.7 */
> #define N_NCI           25      /* NFC NCI UART */


One TIOCSETD is enough to trigger the leak.
I've tested with different line disciplines and only N_GIGASET_M101
triggers the leak.
The program prints:

ioctl failed with 19
ioctl failed with 19
ioctl failed with 19
ioctl failed with 19
ioctl failed with 19
ioctl failed with 19
ioctl failed with 19
ioctl failed with 19

And console output looks as follows:

[  107.311623] driver: 'ser_gigaset': driver_bound: bound to device
'ser_gigaset.0'
[  107.312502] bus: 'platform': really_probe: bound device
ser_gigaset.0 to driver ser_gigaset
[  107.313789] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.314335] gigaset: maximum number of devices exceeded
[  107.318272] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.318794] gigaset: maximum number of devices exceeded
[  107.319541] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.320072] gigaset: maximum number of devices exceeded
[  107.320792] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.321834] gigaset: maximum number of devices exceeded
[  107.322782] kcapi: controller [001] "ser_gigaset" ready.
[  107.324414] kcapi: controller [001] down.
[  107.327864] bus: 'platform': remove device ser_gigaset.0
[  107.328733] kcapi: controller [001]: ser_gigaset unregistered
[  107.331246] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.331934] kcapi: controller [001]: ser_gigaset attached
[  107.337741] Registering platform device 'ser_gigaset.0'. Parent at platform
[  107.340149] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.340664] gigaset: maximum number of devices exceeded
[  107.341470] bus: 'platform': add device ser_gigaset.0
[  107.342189] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.342702] gigaset: maximum number of devices exceeded
[  107.344661] bus: 'platform': driver_probe_device: matched device
ser_gigaset.0 with driver ser_gigaset
[  107.345420] bus: 'platform': really_probe: probing driver
ser_gigaset with device ser_gigaset.0
[  107.346185] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.346187] gigaset: maximum number of devices exceeded
[  107.351893] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.352888] gigaset: maximum number of devices exceeded
[  107.359171] devices_kset: Moving ser_gigaset.0 to end of list
[  107.359867] driver: 'ser_gigaset': driver_bound: bound to device
'ser_gigaset.0'
[  107.366296] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.366794] gigaset: maximum number of devices exceeded
[  107.367198] ser_gigaset: Serial Driver for Gigaset 307x using Siemens M101
[  107.367778] gigaset: maximum number of devices exceeded
[  107.391643] bus: 'platform': really_probe: bound device
ser_gigaset.0 to driver ser_gigaset
[  107.402270] kcapi: controller [001] "ser_gigaset" ready.
[  107.404980] kcapi: controller [001] down.
[  107.407644] bus: 'platform': remove device ser_gigaset.0
[  107.408554] kcapi: controller [001]: ser_gigaset unregistered



Here is updated program:

// autogenerated by syzkaller (http://github.com/google/syzkaller)
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <errno.h>

int r;

void work()
{
  int fd;

  fd = open("/dev/ptmx", O_RDWR);
  if (fd == -1)
    exit(printf("open failed with %d\n", errno));
  if (ioctl(fd, TIOCSETD, &r))
    exit(printf("ioctl failed with %d\n", errno));
}

int main(int argc, char **argv) {
  int running, status;

  if (argc != 2)
    return;
  r = atoi(argv[1]);
  running = 0;
  for (;;) {
    while (running < 32) {
      if (fork() == 0) {
        work();
        exit(0);
      }
      running++;
    }
    if (wait(&status) > 0)
      running--;
  }
}
