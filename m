From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Thu, 7 Aug 2008 18:23:01 +0200
Message-ID: <200808071823.02364.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <200808061933.25631.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:45188 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751653AbYHGQXG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 12:23:06 -0400
In-Reply-To: <20080806201401.GA607@linux-os.sc.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 6. August 2008 22:14 schrieb Suresh Siddha:
> On Wed, Aug 06, 2008 at 10:33:25AM -0700, Wolfgang Walter wrote:
> > Hello Herbert,
> >
> > I think I finally found the problem.
> >
> > Here a short description again: all our routers with a via C3 using
> > padlock for AES-encryption are crashing with 2.6.26 while they work=
 fine
> > with 2.6.25. Not using padlock (i.e. using the i386 assembler versi=
on of
> > AES) they just work fine.
>
> Both the padlock version or asm version don't use FP/math registers, =
right?
> It is interesting that you don't see the problem with asm version
> but see the problem with padlock version.
>
> Does disabling CONFIG_PREEMPT in 2.6.26 change anything? And also,

Didn't check that yet as I'm still running my modified 2.6.26. It now r=
uns
almost one day flawlessly.

But yesterday I tried the following patch on top of a vanilla 2.6.26:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
diff -ur ../linux-2.6.26/drivers/crypto/padlock-aes.c ./drivers/crypto/=
padlock-aes.c
--- ../linux-2.6.26/drivers/crypto/padlock-aes.c	2008-07-15 11:29:32.00=
0000000 +0200
+++ ./drivers/crypto/padlock-aes.c	2008-08-07 17:46:55.000000000 +0200
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <asm/byteorder.h>
+#include <asm/i387.h>
 #include "padlock.h"
=20
 /* Control word. */
@@ -144,9 +145,11 @@
 static inline void padlock_xcrypt(const u8 *input, u8 *output, void *k=
ey,
 				  void *control_word)
 {
+	kernel_fpu_begin();
 	asm volatile (".byte 0xf3,0x0f,0xa7,0xc8"	/* rep xcryptecb */
 		      : "+S"(input), "+D"(output)
 		      : "d"(control_word), "b"(key), "c"(1));
+	kernel_fpu_end();
 }
=20
 static void aes_crypt_copy(const u8 *in, u8 *out, u32 *key, struct cwo=
rd *cword)
@@ -179,6 +182,7 @@
 		return;
 	}
=20
+	kernel_fpu_begin();
 	asm volatile ("test $1, %%cl;"
 		      "je 1f;"
 		      "lea -1(%%ecx), %%eax;"
@@ -190,15 +194,18 @@
 		      : "+S"(input), "+D"(output)
 		      : "d"(control_word), "b"(key), "c"(count)
 		      : "ax");
+	kernel_fpu_end();
 }
=20
 static inline u8 *padlock_xcrypt_cbc(const u8 *input, u8 *output, void=
 *key,
 				     u8 *iv, void *control_word, u32 count)
 {
 	/* rep xcryptcbc */
+	kernel_fpu_begin();
 	asm volatile (".byte 0xf3,0x0f,0xa7,0xd0"
 		      : "+S" (input), "+D" (output), "+a" (iv)
 		      : "d" (control_word), "b" (key), "c" (count));
+	kernel_fpu_end();
 	return iv;
 }
=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

I found that kernel_fpu_begin(); kernel_fpu_begin(); is used with
MMX and/or SSE:

include/asm/xor_32.h
drivers/md/raid6mmx.c
drivers/md/raid6sse1.c
drivers/md/raid6sse2.c


With this change I its a little bit more stable, I needed more then 5
minutes to crash the kernel (repeated it several times). If I read
the code correctly this disables preemption for the time the padlock cm=
d
is executing.


> can you provide the complete kernel log till the point of failure(oop=
s
> that you sent doesn't have the call trace info)
>

Here are some of the oopses (all with unmodified 2.6.26):

##################################################################

BUG: unable to handle kernel NULL pointer dereference at 000001f0
IP: [<c010280c>] __switch_to+0x23/0x103
*pde =3D 00000000
Oops: 0002 [#1] PREEMPT
Modules linked in:

Pid: 2014, comm: date Not tainted (2.6.26 #3)
EIP: 0060:[<c010280c>] EFLAGS: 00010002 CPU: 0
EIP is at __switch_to+0x23/0x103
EAX: 00000000 EBX: dc4e2dc0 ECX: 0000015f EDX: dc4e2dc0
ESI: de9634a0 EDI: dc4e2fe8 EBP: de9636c8 ESP: cee9deec
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process date (pid: 2014, ti=3Dcee9c000 task=3Dde9634a0 task.ti=3Dd13c60=
00)
Stack: dc4e2dc0 00000000 cee81300 de9634a0 c039bf41 dc4e2dc0 00000082 d=
e9634a0
       00000000 dc4e2f2c 00000046 00000000 ffffffea 00000001 dc4e2db8 0=
0000000
       c011e766 0000000e 00000000 00000003 dc4e2dc0 00000001 00000010 d=
c4e2dc0
Call Trace:
 [<c039bf41>] schedule+0x257/0x2bf
 [<c011e766>] do_wait+0x88e/0x963
 [<c01480c5>] handle_mm_fault+0x441/0x4aa
 [<c023698d>] tty_ioctl+0x0/0x877
 [<c0119205>] default_wake_function+0x0/0x8
 [<c011e8ba>] sys_wait4+0x7f/0x92
 [<c011e8e0>] sys_waitpid+0x13/0x17
 [<c01037a2>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 00 90 5d 5b 5e 5f 5d c3 55 57 56 89 c6 53 89 d3 8d a8 28 02 00 00=
 8b 40 04 8d ba 28 02 00 00 f6 40 0c 01 74 31 8b 86 7c 02 00 00 <0f> ae=
 00 0f ba 60 02 07 73 02 db e2 8d 76 00 90 8d b4 26 00 00
EIP: [<c010280c>] __switch_to+0x23/0x103 SS:ESP 0068:cee9deec
---[ end trace 55bd4c8258a0a1eb ]---
=46ixing recursive fault but reboot is needed!
BUG: scheduling while atomic: bash/1363/0x00000003
Pid: 2014, comm: date Tainted: G      D   2.6.26 #3
 [<c039bd42>] schedule+0x58/0x2bf
 [<c011cea8>] printk+0x14/0x18
 [<c011ea08>] do_exit+0x9f/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d4da>] error_code+0x6a/0x70
 [<c010280c>] __switch_to+0x23/0x103
 [<c039bf41>] schedule+0x257/0x2bf
 [<c011e766>] do_wait+0x88e/0x963
 [<c01480c5>] handle_mm_fault+0x441/0x4aa
 [<c023698d>] tty_ioctl+0x0/0x877
 [<c0119205>] default_wake_function+0x0/0x8
 [<c011e8ba>] sys_wait4+0x7f/0x92
 [<c011e8e0>] sys_waitpid+0x13/0x17
 [<c01037a2>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
note: bash[1363] exited with preempt_count 2
BUG: unable to handle kernel NULL pointer dereference at 00000028
IP: [<c011a900>] mm_release+0x39/0x64
*pde =3D 00000000
Oops: 0000 [#2] PREEMPT
Modules linked in:

Pid: 1363, comm: bash Tainted: G      D   (2.6.26 #3)
EIP: 0060:[<c011a900>] EFLAGS: 00010246 CPU: 0
EIP is at mm_release+0x39/0x64
EAX: 00000000 EBX: de9634a0 ECX: b7e306f8 EDX: 00000000
ESI: 00000000 EDI: de9634a0 EBP: c041e382 ESP: cee9de34
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process bash (pid: 1363, ti=3Dcee9c000 task=3Ddc4e2dc0 task.ti=3Dcee9c0=
00)
Stack: 00000000 de9634a0 c011d7d1 00000002 de9634a0 0000000b c011eb01 0=
0000000
       c041e382 c011cea8 c041ebdc cee9de70 cee9de70 cee9deb4 00000006 0=
0000002
       c041e382 c010500f 00000000 000001f0 de9634a0 00000038 c01123d8 0=
0000002
Call Trace:
 [<c011d7d1>] exit_mm+0x12/0xb4
 [<c011eb01>] do_exit+0x198/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d4da>] error_code+0x6a/0x70
 [<c010280c>] __switch_to+0x23/0x103
 [<c039bf41>] schedule+0x257/0x2bf
 [<c011e766>] do_wait+0x88e/0x963
 [<c01480c5>] handle_mm_fault+0x441/0x4aa
 [<c023698d>] tty_ioctl+0x0/0x877
 [<c0119205>] default_wake_function+0x0/0x8
 [<c011e8ba>] sys_wait4+0x7f/0x92
 [<c011e8e0>] sys_waitpid+0x13/0x17
 [<c01037a2>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 8e e8 85 d2 74 11 c7 83 40 01 00 00 00 00 00 00 89 d0 e8 42 f2 ff=
 ff 8b 8b 48 01 00 00 85 c9 74 32 8b 43 0c 25 00 04 00 00 75 28 <83> 7e=
 28 01 7e 22 c7 83 48 01 00 00 00 00 00 00 e8 4b 41 0e 00
EIP: [<c011a900>] mm_release+0x39/0x64 SS:ESP 0068:cee9de34
---[ end trace 55bd4c8258a0a1eb ]---


##################################################################

BUG: unable to handle kernel NULL pointer dereference at 000001f0
IP: [<c010280c>] __switch_to+0x23/0x103
*pde =3D 00000000
Oops: 0002 [#1] PREEMPT
Modules linked in:

Pid: 1569, comm: date Not tainted (2.6.26 #7)
EIP: 0060:[<c010280c>] EFLAGS: 00010002 CPU: 0
EIP is at __switch_to+0x23/0x103
EAX: 00000000 EBX: de978000 ECX: 00000091 EDX: de978000
ESI: de979810 EDI: de978228 EBP: de979a38 ESP: d13ddeec
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process date (pid: 1569, ti=3Dd13dc000 task=3Dde979810 task.ti=3Dd185e0=
00)
Stack: de978000 00000000 cfdbe780 de979810 c039c229 de978000 00000082 d=
e979810
       00000000 de97816c 00000046 00000000 ffffffea 00000001 de977ff8 0=
0000000
       c011e766 0000000e 00000000 00000003 de978000 00000001 00000010 d=
e978000
Call Trace:
 [<c039c229>] schedule+0x257/0x2bf
 [<c011e766>] do_wait+0x88e/0x963
 [<c01480c5>] handle_mm_fault+0x441/0x4aa
 [<c023698d>] tty_ioctl+0x0/0x877
 [<c0119205>] default_wake_function+0x0/0x8
 [<c011e8ba>] sys_wait4+0x7f/0x92
 [<c011e8e0>] sys_waitpid+0x13/0x17
 [<c01037a2>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 00 90 5d 5b 5e 5f 5d c3 55 57 56 89 c6 53 89 d3 8d a8 28 02 00 00=
 8b 40 04 8d ba 28 02 00 00 f6 40 0c 01 74 31 8b 86 7c 02 00 00 <0f> ae=
 00 0f ba 60 02 07 73 02 db e2 8d 76 00 90 8d b4 26 00 00
EIP: [<c010280c>] __switch_to+0x23/0x103 SS:ESP 0068:d13ddeec
---[ end trace 8061cb3e89ac8fe5 ]---
=46ixing recursive fault but reboot is needed!
BUG: scheduling while atomic: bash/1374/0x00000003
Pid: 1569, comm: date Tainted: G      D   2.6.26 #7
 [<c039c02a>] schedule+0x58/0x2bf
 [<c011cea8>] printk+0x14/0x18
 [<c011ea08>] do_exit+0x9f/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d7ba>] error_code+0x6a/0x70
 [<c010280c>] __switch_to+0x23/0x103
 [<c039c229>] schedule+0x257/0x2bf
 [<c011e766>] do_wait+0x88e/0x963
 [<c01480c5>] handle_mm_fault+0x441/0x4aa
 [<c023698d>] tty_ioctl+0x0/0x877
 [<c0119205>] default_wake_function+0x0/0x8
 [<c011e8ba>] sys_wait4+0x7f/0x92
 [<c011e8e0>] sys_waitpid+0x13/0x17
 [<c01037a2>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
note: bash[1374] exited with preempt_count 2
BUG: unable to handle kernel NULL pointer dereference at 00000028
IP: [<c011a900>] mm_release+0x39/0x64
*pde =3D 00000000
Oops: 0000 [#2] PREEMPT
Modules linked in:

Pid: 1374, comm: bash Tainted: G      D   (2.6.26 #7)
EIP: 0060:[<c011a900>] EFLAGS: 00010246 CPU: 0
EIP is at mm_release+0x39/0x64
EAX: 00000000 EBX: de979810 ECX: b7e316f8 EDX: 00000000
ESI: 00000000 EDI: de979810 EBP: c041e382 ESP: d13dde34
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process bash (pid: 1374, ti=3Dd13dc000 task=3Dde978000 task.ti=3Dd13dc0=
00)
Stack: 00000000 de979810 c011d7d1 00000002 de979810 0000000b c011eb01 0=
0000000
       c041e382 c011cea8 c041ebdc d13dde70 d13dde70 d13ddeb4 00000006 0=
0000002
       c041e382 c010500f 00000000 000001f0 de979810 00000038 c01123d8 0=
0000002
Call Trace:
 [<c011d7d1>] exit_mm+0x12/0xb4
 [<c011eb01>] do_exit+0x198/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d7ba>] error_code+0x6a/0x70
 [<c010280c>] __switch_to+0x23/0x103
 [<c039c229>] schedule+0x257/0x2bf
 [<c011e766>] do_wait+0x88e/0x963
 [<c01480c5>] handle_mm_fault+0x441/0x4aa
 [<c023698d>] tty_ioctl+0x0/0x877
 [<c0119205>] default_wake_function+0x0/0x8
 [<c011e8ba>] sys_wait4+0x7f/0x92
 [<c011e8e0>] sys_waitpid+0x13/0x17
 [<c01037a2>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 8e e8 85 d2 74 11 c7 83 40 01 00 00 00 00 00 00 89 d0 e8 42 f2 ff=
 ff 8b 8b 48 01 00 00 85 c9 74 32 8b 43 0c 25 00 04 00 00 75 28 <83> 7e=
 28 01 7e 22 c7 83 48 01 00 00 00 00 00 00 e8 4b 41 0e 00
EIP: [<c011a900>] mm_release+0x39/0x64 SS:ESP 0068:d13dde34
---[ end trace 8061cb3e89ac8fe5 ]---
note: bash[1374] exited with preempt_count 2

##################################################################

BUG: unable to handle kernel NULL pointer dereference at 000001f0
IP: [<c010280c>] __switch_to+0x23/0x103
*pde =3D 00000000
Oops: 0002 [#1] PREEMPT
Modules linked in:

Pid: 1591, comm: date Not tainted (2.6.26 #8)
EIP: 0060:[<c010280c>] EFLAGS: 00010002 CPU: 0
EIP is at __switch_to+0x23/0x103
EAX: 00000000 EBX: dc4e3b80 ECX: 000000e6 EDX: dc4e3b80
ESI: dc42bb80 EDI: dc4e3da8 EBP: dc42bda8 ESP: cc8d5eec
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process date (pid: 1591, ti=3Dcc8d4000 task=3Ddc42bb80 task.ti=3Dcf5420=
00)
Stack: dc4e3b80 00000000 dc4b8000 dc42bb80 c039bbc9 dc4e3b80 00000082 d=
c42bb80
       00000000 dc4e3cec 00000046 00000000 ffffffea 00000001 dc4e3b78 0=
0000000
       c011e766 0000000e 00000000 00000003 dc4e3b80 00000001 00000010 d=
c4e3b80
Call Trace:
 [<c039bbc9>] schedule+0x257/0x2bf
 [<c011e766>] do_wait+0x88e/0x963
 [<c01480c5>] handle_mm_fault+0x441/0x4aa
 [<c02365dd>] tty_ioctl+0x0/0x877
 [<c0119205>] default_wake_function+0x0/0x8
 [<c011e8ba>] sys_wait4+0x7f/0x92
 [<c011e8e0>] sys_waitpid+0x13/0x17
 [<c01037a2>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 00 90 5d 5b 5e 5f 5d c3 55 57 56 89 c6 53 89 d3 8d a8 28 02 00 00=
 8b 40 04 8d ba 28 02 00 00 f6 40 0c 01 74 31 8b 86 7c 02 00 00 <0f> ae=
 00 0f ba 60 02 07 73 02 db e2 8d 76 00 90 8d b4 26 00 00
EIP: [<c010280c>] __switch_to+0x23/0x103 SS:ESP 0068:cc8d5eec
---[ end trace fa9f688d2faab2aa ]---
=46ixing recursive fault but reboot is needed!
BUG: scheduling while atomic: bash/1374/0x00000003
Pid: 1591, comm: date Tainted: G      D   2.6.26 #8
 [<c039b9ca>] schedule+0x58/0x2bf
 [<c011cea8>] printk+0x14/0x18
 [<c011ea08>] do_exit+0x9f/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d15a>] error_code+0x6a/0x70
 [<c010280c>] __switch_to+0x23/0x103
 [<c039bbc9>] schedule+0x257/0x2bf
 [<c011e766>] do_wait+0x88e/0x963
 [<c01480c5>] handle_mm_fault+0x441/0x4aa
 [<c02365dd>] tty_ioctl+0x0/0x877
 [<c0119205>] default_wake_function+0x0/0x8
 [<c011e8ba>] sys_wait4+0x7f/0x92
 [<c011e8e0>] sys_waitpid+0x13/0x17
 [<c01037a2>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
note: bash[1374] exited with preempt_count 2
BUG: unable to handle kernel NULL pointer dereference at 00000028
IP: [<c011a900>] mm_release+0x39/0x64
*pde =3D 00000000
Oops: 0000 [#2] PREEMPT
Modules linked in:

Pid: 1374, comm: bash Tainted: G      D   (2.6.26 #8)
EIP: 0060:[<c011a900>] EFLAGS: 00010246 CPU: 0
EIP is at mm_release+0x39/0x64
EAX: 00000000 EBX: dc42bb80 ECX: b7e4a6f8 EDX: 00000000
ESI: 00000000 EDI: dc42bb80 EBP: c041e216 ESP: cc8d5e34
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process bash (pid: 1374, ti=3Dcc8d4000 task=3Ddc4e3b80 task.ti=3Dcc8d40=
00)
Stack: 00000000 dc42bb80 c011d7d1 00000002 dc42bb80 0000000b c011eb01 0=
0000000
       c041e216 c011cea8 c041ea70 cc8d5e70 cc8d5e70 cc8d5eb4 00000006 0=
0000002
       c041e216 c010500f 00000000 000001f0 dc42bb80 00000038 c01123d8 0=
0000002
Call Trace:
 [<c011d7d1>] exit_mm+0x12/0xb4
 [<c011eb01>] do_exit+0x198/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d15a>] error_code+0x6a/0x70
 [<c010280c>] __switch_to+0x23/0x103
 [<c039bbc9>] schedule+0x257/0x2bf
 [<c011e766>] do_wait+0x88e/0x963
 [<c01480c5>] handle_mm_fault+0x441/0x4aa
 [<c02365dd>] tty_ioctl+0x0/0x877
 [<c0119205>] default_wake_function+0x0/0x8
 [<c011e8ba>] sys_wait4+0x7f/0x92
 [<c011e8e0>] sys_waitpid+0x13/0x17
 [<c01037a2>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 8e e8 85 d2 74 11 c7 83 40 01 00 00 00 00 00 00 89 d0 e8 42 f2 ff=
 ff 8b 8b 48 01 00 00 85 c9 74 32 8b 43 0c 25 00 04 00 00 75 28 <83> 7e=
 28 01 7e 22 c7 83 48 01 00 00 00 00 00 00 e8 9b 3d 0e 00
EIP: [<c011a900>] mm_release+0x39/0x64 SS:ESP 0068:cc8d5e34
---[ end trace fa9f688d2faab2aa ]---
note: bash[1374] exited with preempt_count 2
BUG: scheduling while atomic: bash/1374/0x10000003
Pid: 1374, comm: bash Tainted: G      D   2.6.26 #8
 [<c039b9ca>] schedule+0x58/0x2bf
 [<c0165ec2>] dput+0x15/0xfc
 [<c01f9ae8>] _atomic_dec_and_lock+0x30/0x38
 [<c016a0e5>] mntput_no_expire+0x11/0xd2
 [<c01184b4>] __cond_resched+0x13/0x2f
 [<c039bf4c>] _cond_resched+0x21/0x2a
 [<c011daf2>] put_files_struct+0x63/0xa6
 [<c011eb0f>] do_exit+0x1a6/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d15a>] error_code+0x6a/0x70
 [<c011a900>] mm_release+0x39/0x64
 [<c011d7d1>] exit_mm+0x12/0xb4
 [<c011eb01>] do_exit+0x198/0x54a
 [<c011cea8>] printk+0x14/0x18
 [<c010500f>] die+0xfd/0x102
 [<c01123d8>] do_page_fault+0x488/0x53c
 [<c0111f50>] do_page_fault+0x0/0x53c
 [<c039d15a>] error_code+0x6a/0x70
 [<c010280c>] __switch_to+0x23/0x103
 [<c039bbc9>] schedule+0x257/0x2bf
 [<c011e766>] do_wait+0x88e/0x963
 [<c01480c5>] handle_mm_fault+0x441/0x4aa
 [<c02365dd>] tty_ioctl+0x0/0x877
 [<c0119205>] default_wake_function+0x0/0x8
 [<c011e8ba>] sys_wait4+0x7f/0x92
 [<c011e8e0>] sys_waitpid+0x13/0x17
 [<c01037a2>] syscall_call+0x7/0xb
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

##################################################################

BUG: unable to handle kernel NULL pointer dereference at 000001f0
IP: [<c01028c5>] __switch_to+0x30/0x117
*pde =3D 00000000
Oops: 0002 [#1] PREEMPT
Modules linked in:

Pid: 2071, comm: sleep Not tainted (2.6.26 #11)
EIP: 0060:[<c01028c5>] EFLAGS: 00010002 CPU: 0
EIP is at __switch_to+0x30/0x117
EAX: 00000000 EBX: c0493300 ECX: dc48dd00 EDX: c0493300
ESI: dc48dd00 EDI: c0493530 EBP: c04cff8c ESP: c04cff7c
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Process sleep (pid: 2071, ti=3Dc04ce000 task=3Ddc48dd00 task.ti=3Dd2fe6=
000)
Stack: dc48df30 c0493300 00000000 00000000 d2fe7f44 c03b5b43 c04cffc8 0=
0000046
       c0131856 0000005a dc472d3c c0493300 c0493470 d983ae00 00002696 0=
0000000
       c0239f54 00000000 c04c4000 c04cffd8 c01025fe c04f3740 00049800 c=
04cffe0
Call Trace:
 [<c03b5b43>] ? schedule+0x285/0x2ff
 [<c0131856>] ? pm_qos_requirement+0x3c/0x53
 [<c0239f54>] ? acpi_processor_idle+0x0/0x434
 [<c01025fe>] ? cpu_idle+0x73/0x7f
 [<c03a4dcd>] ? rest_init+0x61/0x63
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Code: 89 c6 53 89 d3 83 ec 04 8d 80 30 02 00 00 89 45 f0 8d ba 30 02 00=
 00 e8 a2 bd 10 00 8b 46 04 f6 40 0c 01 74 31 8b 86 84 02 00 00 <0f> ae=
 00 0f ba 60 02 07 73 02 db e2 8d 76 00 90 8d b4 26 00 00
EIP: [<c01028c5>] __switch_to+0x30/0x117 SS:ESP 0068:c04cff7c
---[ end trace 042daf7e67838617 ]---
note: sleep[2071] exited with preempt_count 2
BUG: scheduling while atomic: swapper/0/0x00000004
Pid: 2071, comm: sleep Tainted: G      D   2.6.26 #11
 [<c0118c95>] __schedule_bug+0x42/0x47
 [<c03b5923>] schedule+0x65/0x2ff
 [<c011f8d8>] ? put_fs_struct+0x39/0x3c
 [<c0120dc2>] do_exit+0x54e/0x55d
 [<c011de9e>] ? print_oops_end_marker+0x1e/0x23
 [<c010522a>] die+0x104/0x10c
 [<c0112553>] do_page_fault+0x477/0x52c
 [<c01120dc>] ? do_page_fault+0x0/0x52c
 [<c03b729a>] error_code+0x6a/0x70
 [<c01028c5>] ? __switch_to+0x30/0x117
 [<c03b5b43>] schedule+0x285/0x2ff
 [<c0131856>] ? pm_qos_requirement+0x3c/0x53
 [<c0239f54>] ? acpi_processor_idle+0x0/0x434
 [<c01025fe>] ? cpu_idle+0x73/0x7f
 [<c03a4dcd>] ? rest_init+0x61/0x63

##################################################################


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
