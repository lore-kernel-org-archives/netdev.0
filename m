From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Thu, 8 Jul 2010 18:34:25 -0700
Message-ID: <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
References: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Jens Axboe <axboe@kernel.dk>, DRI <dri-devel@lists.sourceforge.net>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Patrick McHardy <kaber@trash.net>,
        Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jesse Barnes <jbarnes@virtuousgeek.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Frederic Weisbecker <fweisbec@gmail.com>,
        Dave Airlie <airlied@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Shawn Starr <shawn.starr@rogers.com>,
        Linux PM List <linux-pm@lists.linux-foundation.org>,
        Maciej Rutecki <maciej.rutecki@gmail.c
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 8, 2010 at 4:33 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> Unresolved regressions
> ----------------------
>
> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16353
> Subject =A0 =A0 =A0 =A0 : 2.6.35 regression
> Submitter =A0 =A0 =A0 : Zeev Tarantov <zeev.tarantov@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-07-05 13:04 (4 days old)
> Message-ID =A0 =A0 =A0: <loom.20100705T144459-919@post.gmane.org>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1278360027=
02522&w=3D2

This is a gcc-4.5 issue. Whether it's also something that we should
change in the kernel is unclear, but at least as of now, the rule is
that you cannot compile the kernel with gcc-4.5. No idea whether the
compiler is just entirely broken, or whether it's just that it
triggers something iffy by being overly clever.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16346
> Subject =A0 =A0 =A0 =A0 : 2.6.35-rc3-git8 - include/linux/fdtable.h:88 in=
voked rcu_dereference_check() without protection!
> Submitter =A0 =A0 =A0 : Miles Lane <miles.lane@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-07-04 22:04 (5 days old)
> Message-ID =A0 =A0 =A0: <AANLkTinof0k28rk4rMr66aubxcRL2rFa5ZEArj1lqD3o@ma=
il.gmail.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1278281078=
15930&w=3D2

I'm not entirely sure if these RCU proving things should count as regressio=
ns.

Sure, the option to enable RCU proving is new, but the things it
reports about generally are not new - and they are usually not even
bugs in the sense that they necessarily cause any real problems.

That particular one is in the single-thread optimizated case for fget_light=
, ie

        if (likely((atomic_read(&files->count) =3D=3D 1))) {
                file =3D fcheck_files(files, fd);

where I think it should be entirely safe in all ways without any
locking. So I think it's a false positive too.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16334
> Subject =A0 =A0 =A0 =A0 : reiserfs locking (v2)
> Submitter =A0 =A0 =A0 : Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-07-02 9:34 (7 days old)
> Message-ID =A0 =A0 =A0: <20100702093451.GA3973@swordfish.minsk.epam.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1278063063=
03590&w=3D2

Frederic? Al? I assume this is some late fallout from the BKL removal
ages ago.. It's the old filldir-vs-mmap crud, but normally it should
be impossible to trigger because the inode for a directory should
never be mmap'able, so we should never have the same i_mutex lock used
for both mmap and for filldir protection.

We saw some of that oddity long ago, I wonder if it's lockdep being
confused about some inodes.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16333
> Subject =A0 =A0 =A0 =A0 : iwl3945: HARDWARE GONE??
> Submitter =A0 =A0 =A0 : Priit Laes <plaes@plaes.org>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-07-02 16:02 (7 days old)
> Message-ID =A0 =A0 =A0: <1278086575.2889.8.camel@chi>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1278086597=
05983&w=3D2

This either got fixed, or will be practically impossible to debug. The
reporter ends up being unable to reproduce the issue.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16332
> Subject =A0 =A0 =A0 =A0 : Kernel crashes in tty code (tty_open)
> Submitter =A0 =A0 =A0 : werner@guyane.yi.org
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-07-02 3:34 (7 days old)
> Message-ID =A0 =A0 =A0: <1278041650.12788@guyane.yi.org>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1278041675=
11930&w=3D2

This seems to be due to CONFIG_MRST (Moorestown).

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16330
> Subject =A0 =A0 =A0 =A0 : Dynamic Debug broken on 2.6.35-rc3?
> Submitter =A0 =A0 =A0 : Thomas Renninger <trenn@suse.de>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-07-01 15:44 (8 days old)
> Message-ID =A0 =A0 =A0: <201007011744.19564.trenn@suse.de>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1277999072=
18877&w=3D2

There's a suggested patch in

  http://marc.info/?l=3Dlinux-kernel&m=3D127862524404291&w=3D2

but no reply to it yet.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16329
> Subject =A0 =A0 =A0 =A0 : 2.6.35-rc3: Load average climbing to 3+ with no=
 apparent reason: CPU 98% idle, with hardly no I/O
> Submitter =A0 =A0 =A0 : T=F6r=F6k Edwin <edwintorok@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-07-01 7:40 (8 days old)
> Message-ID =A0 =A0 =A0: <20100701104022.404410d6@debian>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1277970050=
30536&w=3D2

This seems to be partly a confusion about what "load average" is. It's
not a CPU load, it's a system load average, and disk-wait processes
count towards it. He has some problem with his CD-ROM, and it sounds
like it might be hardware on the verge of going bad.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16324
> Subject =A0 =A0 =A0 =A0 : Oops while running fs_racer test on a POWER6 bo=
x against latest git
> Submitter =A0 =A0 =A0 : divya <dipraksh@linux.vnet.ibm.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-30 11:34 (9 days old)
> Message-ID =A0 =A0 =A0: <4C2B28F3.7000006@linux.vnet.ibm.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1277896973=
03061&w=3D2

I wonder if this is the writeback problem. That POWER crash dump is
unreadable, so it's hard to tell, but the load in question makes that
at least likely.

If so, it should hopefully be fixed in today's git (commit
83ba7b071f30f7c01f72518ad72d5cd203c27502 and friends).

> Bug-entry    : http://bugzilla.kernel.org/show_bug.cgi?id=3D16323
> Subject =A0 =A0 =A0 =A0 : 2.6.35-rc3-git4 - kernel/sched.c:616 invoked rc=
u_dereference_check() without protection!
> Submitter =A0 =A0 =A0 : Miles Lane <miles.lane@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-07-01 12:21 (8 days old)
> Message-ID =A0 =A0 =A0: <AANLkTini6hz2LFeZi8CMUmY3xw1MU7NxmyesuxZ4oCdo@ma=
il.gmail.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1277986931=
25541&w=3D2

See earlier about these being marked as regressions, but it should be
fixed by commit dc61b1d6 ("sched: Fix PROVE_RCU vs cpu_cgroup").

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16322
> Subject =A0 =A0 =A0 =A0 : WARNING: at /arch/x86/include/asm/processor.h:1=
005 read_measured_perf_ctrs+0x5a/0x70()
> Submitter =A0 =A0 =A0 : boris64 <bugzilla.kernel.org@boris64.net>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-07-01 13:54 (8 days old)
> Handled-By =A0 =A0 =A0: H. Peter Anvin <hpa@zytor.com>

Magic. Strange and dark magic.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16311
> Subject =A0 =A0 =A0 =A0 : [REGRESSION][SUSPEND] 2.6.35-rcX won't suspend =
Lenovo W500 laptop
> Submitter =A0 =A0 =A0 : Shawn Starr <shawn.starr@rogers.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-28 0:45 (11 days old)
> Message-ID =A0 =A0 =A0: <201006272045.17004.shawn.starr@rogers.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1277686337=
05286&w=3D2

I think this might be usefully bisected. Shawn?

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16309
> Subject =A0 =A0 =A0 =A0 : 2.6.35-rc3 oops trying to suspend.
> Submitter =A0 =A0 =A0 : Andrew Hendry <andrew.hendry@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-27 12:40 (12 days old)
> Message-ID =A0 =A0 =A0: <AANLkTinUH2p33-AWxOVDrLsNkn9rgEVrlwn5mfK7P8NH@ma=
il.gmail.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1277642499=
26781&w=3D2

I'm pretty sure this was fixed by Nick in commit 57439f878afa ("fs:
fix superblock iteration race").

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16307
> Subject =A0 =A0 =A0 =A0 : i915 in kernel 2.6.35-rc3, high number of wakeu=
ps
> Submitter =A0 =A0 =A0 : Enrico Bandiello <enban@postal.uv.es>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-26 16:57 (13 days old)
> Message-ID =A0 =A0 =A0: <4C26317A.5070309@postal.uv.es>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1277574034=
04259&w=3D2

I don't think anybody noticed this one. Jesse?

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16304
> Subject =A0 =A0 =A0 =A0 : i915 - high number of wakeups
> Submitter =A0 =A0 =A0 : Enrico Bandiello <enban@postal.uv.es>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-27 09:52 (12 days old)

Duplicate of that 16307 one.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16284
> Subject =A0 =A0 =A0 =A0 : Hitting WARN_ON in hw_breakpoint code
> Submitter =A0 =A0 =A0 : Paul Mackerras <paulus@samba.org>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-23 12:57 (16 days old)
> Message-ID =A0 =A0 =A0: <20100623125740.GA3368@brick.ozlabs.ibm.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1277297891=
13432&w=3D2

This has "I have a fix, will post it very soon." in the thread from
Frederic, but I'm not seeing anything else. Frederic?

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16265
> Subject =A0 =A0 =A0 =A0 : Why is kslowd accumulating so much CPU time?
> Submitter =A0 =A0 =A0 : Theodore Ts'o <tytso@mit.edu>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-09 18:36 (30 days old)
> First-Bad-Commit: http://git.kernel.org/linus/fbf81762e385d3d45acad057b65=
4d56972acf58c
> Message-ID =A0 =A0 =A0: <E1OMQ88-0002a1-Gb@closure.thunk.org>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1276108578=
19033&w=3D4

Dave, Jesse?

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16234
> Subject =A0 =A0 =A0 =A0 : [2.6.35-rc3] reboot mutex 'bug'...
> Submitter =A0 =A0 =A0 : Daniel J Blueman <daniel.blueman@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-14 15:16 (25 days old)
> Message-ID =A0 =A0 =A0: <AANLkTimDcTnyEPmt2ZcCM1UWtn4AYKotiqyjobJApkO7@ma=
il.gmail.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1276528611=
18933&w=3D2

Ok, this is definitely harmless. Whether we should silence the warning
somehow is a separate question.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16230
> Subject =A0 =A0 =A0 =A0 : inconsistent IN-HARDIRQ-W -> HARDIRQ-ON-W usage=
: fasync, 2.6.35-rc3
> Submitter =A0 =A0 =A0 : Dominik Brodowski <linux@dominikbrodowski.net>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-13 9:53 (26 days old)
> Message-ID =A0 =A0 =A0: <20100613095305.GA13231@comet.dominikbrodowski.ne=
t>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1276422822=
08277&w=3D2

Fixed by commit f4985dc714d7.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16228
> Subject =A0 =A0 =A0 =A0 : BUG/boot failure on Dell Precision T3500 (pci/a=
hci_stop_engine)
> Submitter =A0 =A0 =A0 : Brian Bloniarz <phunge0@hotmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-16 17:57 (23 days old)
> Handled-By =A0 =A0 =A0: Bjorn Helgaas <bjorn.helgaas@hp.com>

This has a butt-ugly suggested patch that certainly won't be applied.
I saw the thread, but lost sight of it. Jesse, did that end up with
some resolution?

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16221
> Subject =A0 =A0 =A0 =A0 : 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR*=
 invalid framebuffer id
> Submitter =A0 =A0 =A0 : Miles Lane <miles.lane@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-11 20:31 (28 days old)
> Message-ID =A0 =A0 =A0: <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG@ma=
il.gmail.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1276288281=
19623&w=3D2

I dunno. Old, and apparently seen by two people. Dave?

Might be helped by bisection.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16205
> Subject =A0 =A0 =A0 =A0 : acpi: freeing invalid memtype bf799000-bf79a000
> Submitter =A0 =A0 =A0 : Marcin Slusarz <marcin.slusarz@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-09 20:09 (30 days old)
> Message-ID =A0 =A0 =A0: <20100609200910.GA2876@joi.lan>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1276114270=
29914&w=3D2
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0http://marc.info/?l=3Dlinux-kernel&m=
=3D127688398513862&w=3D2

This should be fixed by commit b945d6b2554d ("rbtree: Undo augmented
trees performance damage and regression").

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16199
> Subject =A0 =A0 =A0 =A0 : 2.6.35-rc2-git1 - include/linux/cgroup.h:534 in=
voked rcu_dereference_check() without protection!
> Submitter =A0 =A0 =A0 : Miles Lane <miles.lane@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-07 18:14 (32 days old)
> Message-ID =A0 =A0 =A0: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@ma=
il.gmail.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1275934478=
12015&w=3D2

Another RCU proving thing.  And this one looks the same as the 16323
one above, and fixed by the same commit as that one.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16197
> Subject =A0 =A0 =A0 =A0 : [BUG on 2.6.35-rc2] sysfs: cannot create duplic=
ate filename '/devices/pci0000:00/0000:00:11.0/0000:02:03.0/slot'
> Submitter =A0 =A0 =A0 : Ryan Wang <openspace.wang@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-07 0:23 (32 days old)
> Message-ID =A0 =A0 =A0: <AANLkTincwMZPnYW3S4uz4k2GOn52RpgBIBRfzyD010Yo@ma=
il.gmail.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1275870222=
19378&w=3D2

These should all be gone. See commit 3be434f0244ee by Jesse ('Revert
"PCI: create function symlinks in /sys/bus/pci/slots/N/"').

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16187
> Subject =A0 =A0 =A0 =A0 : Carrier detection failed in dhcpcd when link is=
 up
> Submitter =A0 =A0 =A0 : Christian Casteyde <casteyde.christian@free.fr>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-12 15:15 (27 days old)
> First-Bad-Commit: http://git.kernel.org/linus/10708f37ae729baba9b67bd134c=
3720709d4ae62
> Handled-By =A0 =A0 =A0: Andrew Morton <akpm@linux-foundation.org>

David? This bisects to a networking commit. Doesn't look sensible, but
what do I know?

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16184
> Subject =A0 =A0 =A0 =A0 : Container, X86-64, i386, iptables rule
> Submitter =A0 =A0 =A0 : Jean-Marc Pigeon <jmp@safe.ca>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-12 04:17 (27 days old)
> Handled-By =A0 =A0 =A0: Patrick McHardy <kaber@trash.net>

Patrick, Davem? Ping?

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16179
> Subject =A0 =A0 =A0 =A0 : 2.6.35-rc2 completely hosed on intel gfx?
> Submitter =A0 =A0 =A0 : Norbert Preining <preining@logic.at>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-06 11:55 (33 days old)
> Message-ID =A0 =A0 =A0: <20100606115534.GA9399@gamma.logic.tuwien.ac.at>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1275825349=
31581&w=3D2

Hmm. That one is the vt.c bug coupled with another problem, which in
turn got opened as a separate bugzilla entry:

   http://bugzilla.kernel.org/show_bug.cgi?id=3D16252

which in turn then got closed. I dunno.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16175
> Subject =A0 =A0 =A0 =A0 : 2.6.35-rc1 system oom, many processes killed bu=
t memory not free
> Submitter =A0 =A0 =A0 : andrew hendry <andrew.hendry@gmail.com>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-05 0:46 (34 days old)
> Message-ID =A0 =A0 =A0: <AANLkTim7CiW-yfugZUAHZCqLvXKgt9CwolCvbLGdCLAk@ma=
il.gmail.com>
> References =A0 =A0 =A0: http://marc.info/?l=3Dlinux-kernel&m=3D1275698777=
14937&w=3D2

Not a regression or a kernel bug at all. See the thread. Big ramdisk
filled up all of memory when it was filled by the builds.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16145
> Subject =A0 =A0 =A0 =A0 : Unable to boot unless "notsc" or "clocksource=
=3Dhpet", or acpi_pad disabling the TSC
> Submitter =A0 =A0 =A0 : Tom Gundersen <teg@jklm.no>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-07 13:11 (32 days old)
> Handled-By =A0 =A0 =A0: Venkatesh Pallipadi <venki@google.com>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Len Brown <lenb@kernel.org>

This is not a regression. See the full bugzilla details. The same
problem persists at least back to 2.6.30 with his config. So it's
somehow specific to his particular config use that requires "notsc" to
boot.

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D16122
> Subject =A0 =A0 =A0 =A0 : 2.6.35-rc1: WARNING at fs/fs-writeback.c:1142 _=
_mark_inode_dirty+0x103/0x170
> Submitter =A0 =A0 =A0 : Larry Finger <Larry.Finger@lwfinger.net>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-04 13:18 (35 days old)
> Handled-By =A0 =A0 =A0: Jens Axboe <axboe@kernel.dk>

This looks like a duplicate of that 16312 bugzilla entry. Jens, has
this been resolved?

                               Linus
