From: Arkadiusz Miskiewicz <misiek@pld.ORG.PL>
Subject: 2.4.21+O(1) scheduler and eepro100 driver
Date: Thu, 21 Aug 2003 02:55:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308210255.50357.misiek@pld.ORG.PL>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm having problems with my 2.4.21 SMP kernel patched to use O(1). It=20
sometimes segfault somewhere in networking code.

Note that this happens only when I have two processors in machine. Two da=
ys=20
ago and before I had this SMP kernel on that machine (Intel SMRK2 server=20
platform) but only one processor. Yesterday we added second CPU and such=20
things started to happen. Three oopses so far in about 12 hours.

[root@gucio root]# cat /proc/version
Linux version 2.4.21 (builder@ep09) (gcc version 2.95.4 20010319 (prerele=
ase))=20
#1 SMP Wed Aug 13 06:27:47 UTC 2003
[root@gucio root]# lsmod
Module                  Size  Used by    Not tainted
softdog                 1732   1
cls_u32                 5124   1  (autoclean)
sch_htb                19328   1  (autoclean)
sch_sfq                 3680   3  (autoclean)
iptable_filter          1792   1  (autoclean)
ip_tables              12128   1  [iptable_filter]
eepro100               18636   2  (autoclean)
mii                     2480   0  (autoclean) [eepro100]
ext2                   46176   1  (autoclean)
usb-ohci               18528   0  (unused)
usbcore                63776   1  (autoclean) [usb-ohci]
unix                   16516  30  (autoclean)
reiserfs              191552   6  (autoclean)
sd_mod                 11040  22  (autoclean)
aic7xxx               153708  11  (autoclean)
scsi_mod               92784   2  (autoclean) [sd_mod aic7xxx]

cpu: 0, clocks: 1330022, slice: 443340
cpu: 1, clocks: 1330022, slice: 443340
Unable to handle kernel NULL pointer dereference at virtual address 00000=
000
00000000
*pde =3D 10619067
Oops: 0000
CPU:    1
EIP:    0010:[<00000000>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010246
eax: 00000000   ebx: 00000000   ecx: 00000000   edx: 000005b4
esi: 00000000   edi: 00000000   ebp: 00000000   esp: dc641e64
ds: 0018   es: 0018   ss: 0018
Process httpd (pid: 14357, stackpage=3Ddc641000)
Stack: 00000000 00000000 00000000 c021770b 00000000 000005b4 cc290910 d37=
72180=20
       c01d7114 49064af1 cc290910 000005b4 00000000 dc641f08 00000000 cfa=
bb580=20
       dc641f80 dc641f48 d1fa54a4 d1d2f800 d1d2f800 d328e300 cfabb6bc cfa=
bb5b8=20
Call Trace:    [<c021770b>] [<c01d7114>] [<c01cea8a>] [<c01f4226>]=20
[<c01b1568>]
  [<c01b1784>] [<c013d3c6>] [<c01089b3>]
Code:  Bad EIP value.


>>EIP; 00000000 Before first symbol

>>esp; dc641e64 <___strtok+1c2eb1fc/204a9398>

Trace; c021770b <csum_partial_copy_generic+6b/a0>
Trace; c01d7114 <tcp_sendmsg+474/155c>
Trace; c01cea8a <inet_del_protocol+426/430>
Trace; c01f4226 <inet_sendmsg+3a/40>
Trace; c01b1568 <sock_sendmsg+6c/8c>
Trace; c01b1784 <sock_recvmsg+1fc/7e4>
Trace; c013d3c6 <default_llseek+40e/c10>
Trace; c01089b3 <__read_lock_failed+10d7/148c>

Unable to handle kernel paging request at virtual address 6f7020ea
6f7020ea
*pde =3D 00000000
Oops: 0000
CPU:    1
EIP:    0010:[<6f7020ea>]    Not tainted
EFLAGS: 00010246
eax: 00000000   ebx: 6973206f   ecx: 00000000   edx: 000005a8
esi: 75616e20   edi: 6e6f7a63   ebp: 79646767   esp: c6e79e64
ds: 0018   es: 0018   ss: 0018
Process httpd (pid: 5889, stackpage=3Dc6e79000)
Stack: 6b656c77 7020e661 6569776f c021770b 00000000 000005a8 c8a84910 c46=
330c0=20
       c01d7114 01a3bb44 c8a84910 000005a8 00000000 c6e79f08 00000000 d95=
a8560=20
       c6e79f80 c6e79f48 d6cf07a4 0000002b deafac20 00000070 d95a869c d95=
a8598=20
Call Trace:    [<c021770b>] [<c01d7114>] [<c01f4226>] [<c01b1568>]=20
[<c01b1784>]
  [<c013d3c6>] [<c01089b3>]
Code:  Bad EIP value.


>>EIP; 6f7020ea Before first symbol   <=3D=3D=3D=3D=3D

>>esp; c6e79e64 <___strtok+6b231fc/204a9398>

Trace; c021770b <csum_partial_copy_generic+6b/a0>
Trace; c01d7114 <tcp_sendmsg+474/155c>
Trace; c01f4226 <inet_sendmsg+3a/40>
Trace; c01b1568 <sock_sendmsg+6c/8c>
Trace; c01b1784 <sock_recvmsg+1fc/7e4>
Trace; c013d3c6 <default_llseek+40e/c10>
Trace; c01089b3 <__read_lock_failed+10d7/148c>

Unable to handle kernel paging request at virtual address 1a477479
1a477479
*pde =3D 00000000
Oops: 0000
CPU:    1
EIP:    0010:[<1a477479>]    Not tainted
EFLAGS: 00010246
eax: 00000000   ebx: a645b3b6   ecx: 00000000   edx: 000005a8
esi: da0b845d   edi: fb15b864   ebp: b485ba05   esp: d6b31e64
ds: 0018   es: 0018   ss: 0018
Process httpd (pid: 29083, stackpage=3Dd6b31000)
Stack: 2b8fb8fb 30bb3cb0 e87f032f c021770b 00000000 000005a8 cc074110 d5a=
b1480=20
       c01d7114 49d6cb64 cc074110 000005a8 00000000 d6b31f08 00000000 d38=
b8060=20
       d6b31f80 d6b31f48 ddc5d604 dfc32818 00000000 dfcb6600 d38b819c d38=
b8098=20
Call Trace:    [<c021770b>] [<c01d7114>] [<e0807f6f>] [<c01f4226>]=20
[<c01b1568>]
  [<c01b1784>] [<c013d3c6>] [<c01089b3>]
Code:  Bad EIP value.


>>EIP; 1a477479 Before first symbol   <=3D=3D=3D=3D=3D

>>esi; da0b845d <___strtok+19d617f5/204a9398>
>>esp; d6b31e64 <___strtok+167db1fc/204a9398>

Trace; c021770b <csum_partial_copy_generic+6b/a0>
Trace; c01d7114 <tcp_sendmsg+474/155c>
Trace; e0807f6f <[scsi_mod]scsi_io_completion+1e7/3ec>
Trace; c01f4226 <inet_sendmsg+3a/40>
Trace; c01b1568 <sock_sendmsg+6c/8c>
Trace; c01b1784 <sock_recvmsg+1fc/7e4>
Trace; c013d3c6 <default_llseek+40e/c10>
Trace; c01089b3 <__read_lock_failed+10d7/148c>

If you need anything else let me known. Config is similar to this one:
http://cvs.pld-linux.org/cgi-bin/cvsweb/SOURCES/kernel-ia32-smp.config?re=
v=3D1.37

--=20
Arkadiusz Mi=B6kiewicz    CS at FoE, Wroclaw University of Technology
arekm.pld-linux.org AM2-6BONE, 1024/3DB19BBD, arekm(at)ircnet, PLD/Linux
