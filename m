From: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Mon, 2 Aug 2004 12:57:41 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0408021234290.15888-100000@silmu.st.jyu.fi>
References: <20040731143330.A25736@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        H?ctor Mart?n <hector@marcansoft.com>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040731143330.A25736@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 31 Jul 2004, Francois Romieu wrote:

> Pasi Sjoholm <ptsjohol@cc.jyu.fi> :
> [interesting report]
>> The hardest part is to tell where the problem is but I think that=20
>> rtl8139_poll-function would be good place to start looking for the bug=
?
>> readprofile didn't tell much.. Where to go next? I'm not so good=20
>> programmer that I could find the right place to fix..

> In case it could make a difference: did you check if CONFIG_8139_OLD_RX=
_RESET
> changes the behavior or not ?

Yep, I tried that one also, didn't help a thing.
=20
> If it does not, I'd welcome a test report + log with the two attached p=
atch
> applied. The first one is just a placebo but the second one could help.

We are making some sort of a progress but not enough.=20

Patch r8139-20.patch didn't help. I made some printk(...)-debug messages
and that part of a code was never ran.

With both patch applied and RTL8139DEBUG =3D 1 I couldn't make the driver=
=20
crash but without DEBUG it did crash. I assume that it has something to=20
with fact that syslog did take so much io-bandwidth. (a couple of minutes=
 log=20
was ~1GB =3D))

But without:=20

--
@@ -2024,17 +2024,17 @@ static int rtl8139_rx(struct net_device

                cur_rx =3D (cur_rx + rx_size + 4 + 3) & ~3;
                RTL_W16 (RxBufPtr, (u16) (cur_rx - 16));
+       }

-               /* Clear out errors and receive interrupts */
-               status =3D RTL_R16 (IntrStatus) & RxAckBits;
-               if (likely(status !=3D 0)) {
-                       if (unlikely(status & (RxFIFOOver | RxOverflow)))=
=20
{
-                               tp->stats.rx_errors++;
 -                               if (status & RxFIFOOver)
-                                       tp->stats.rx_fifo_errors++;
-                       }
-                       RTL_W16_F (IntrStatus, RxAckBits);
+       /* Clear out errors and receive interrupts */
+       status =3D RTL_R16 (IntrStatus) & RxAckBits;
+       if (likely(status !=3D 0)) {
+               if (unlikely(status & (RxFIFOOver | RxOverflow))) {
+                       tp->stats.rx_errors++;
+                       if (status & RxFIFOOver)
+                               tp->stats.rx_fifo_errors++;
                }
+               RTL_W16_F (IntrStatus, RxAckBits);
        }

  done:
--

the driver crashed... even with debug-option was turned on.
Everytime the ksoftirqd started to take cpu-time there were this line in=20
the logs:

--
Aug  2 12:10:37 139_interrupt: eth0:.....
--

Notice the 139... it should read rtl8139_interrupt:



Here is a snapshot from the log file when driver is crashing:=20
Full logfile is available from:=20

http://www.cc.jyu.fi/~ptsjohol/syslog-debug.gz

--
Aug  2 12:10:37 rtl8139_rx: eth0: In rtl8139_rx(), current 03ac BufAddr 0=
36c, free to 039c, Cmd 0c.
Aug  2 12:10:37 rtl8139_interrupt: eth0: exiting interrupt, intr_status=3D=
0x0000.
Aug  2 12:10:37 rtl8139_interrupt: eth0: exiting interrupt, intr_status=3D=
0x0001.
Aug  2 12:10:37 rtl8139_rx: eth0: In rtl8139_rx(), current 0484 BufAddr 0=
444, free to 0474, Cmd 0c.
Aug  2 12:10:37 rtl8139_interrupt: eth0: exiting interrupt, intr_status=3D=
0x0000.
Aug  2 12:10:37 139_interrupt: eth0: exiting interrupt, intr_status=3D0x0=
010.
Aug  2 12:10:37 rtl8139_rx: eth0: In rtl8139_rx(), current 04d0 BufAddr 0=
4cc, free to 04c0, Cmd 0d.
Aug  2 12:10:37 rtl8139_interrupt: eth0: exiting interrupt, intr_status=3D=
0x0010.
Aug  2 12:10:37 rtl8139_rx: eth0: In rtl8139_rx(), current 04d0 BufAddr 0=
4cc, free to 04c0, Cmd 0d.
Aug  2 12:10:37 rtl8139_interrupt: eth0: exiting interrupt, intr_status=3D=
0x0010.
Aug  2 12:10:37 rtl8139_rx: eth0: In rtl8139_rx(), current 04d0 BufAddr 0=
4cc, free to 04c0, Cmd 0d.
......
......
Aug  2 12:12:11 rtl8139_rx: eth0: In rtl8139_rx(), current 04d0 BufAddr 0=
4cc, free to 04c0, Cmd 0d.
Aug  2 12:12:11 rtl8139_interrupt: eth0: exiting interrupt, intr_status=3D=
0x0050.
Aug  2 12:12:11 rtl8139_rx: eth0: In rtl8139_rx(), current 04d0 BufAddr 0=
4cc, free to 04c0, Cmd 0d.
Aug  2 12:12:11 rtl8139_interrupt: eth0: exiting interrupt, intr_status=3D=
0x0050.
Aug  2 12:12:11 rtl8139_rx: eth0: In rtl8139_rx(), current 04d0 BufAddr 0=
4cc, free to 04c0, Cmd 0d.
Aug  2 12:12:11 rtl8139_interrupt: eth0: exiting interrupt, intr_status=3D=
0x0050.
--


--
Pasi Sj=F6holm
