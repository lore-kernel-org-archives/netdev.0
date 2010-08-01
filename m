From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: 2.6.35-rc6-git6: Reported regressions from 2.6.34
Date: Sun, 1 Aug 2010 11:01:04 -0700
Message-ID: <AANLkTimcH7+Bq1UEbaSU7SQpzArPgmSLegiqE13V8=CF@mail.gmail.com>
References: <2dWFdr9kTFM.A.P0D.spXVMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2dWFdr9kTFM.A.P0D.spXVMB@chimera>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 1, 2010 at 6:46 AM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrote:
>
> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D16400
> Subject         : 2.6.35-rc5 inconsistent lock state
> Submitter       : Martin Pirker <lkml.collector-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date            : 2010-07-14 20:33 (19 days old)
> Message-ID      : <AANLkTikDF0TL6OyPVCzPlUTwxFehcrETn3ysgSSeTq92@mail=
=2Egmail.com>
> References      : http://marc.info/?l=3Dlinux-kernel&m=3D127913961025=
267&w=3D2

This has a proposed patch. I don't know what the status of it is, thoug=
h. Jens?

   http://marc.info/?l=3Dlinux-kernel&m=3D127950018204029&w=3D2

> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D16393
> Subject         : kernel BUG at fs/block_dev.c:765!
> Submitter       : Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
> Date            : 2010-07-14 13:52 (19 days old)
> Message-ID      : <20100714135217.GA1797-joY5NpejW+Hx3b7vapvTcQ@public.gmane.org>
> References      : http://marc.info/?l=3Dlinux-kernel&m=3D127911564213=
748&w=3D2

This one is interesting. And I think I perhaps see where it's coming fr=
om.

bd_start_claiming() (through bd_prepare_to_claim()) has two separate
success cases: either there was no holder (bd_claiming is NULL) or the
new holder was already claiming it (bd_claiming =3D=3D holder).

Note in particular the case of the holder _already_ holding it. What ha=
ppens is:

 - bd_start_claiming() succeeds because we had _already_ claimed it
with the same holder

 - then some error happens, and we call bd_abort_claiming(), which
does whole->bd_claiming =3D NULL;

 - the original holder thinks it still holds the bd, but it has been re=
leased!

 - a new claimer comes in, and succeeds because bd_claiming is now NULL=
=2E

 - we now have two "owners" of the bd, but bd_claiming only points to
the second one.

I think bd_start_claiming() needs to do some kind of refcount for the
nested holder case, and bd_abort_claiming() needs to decrement the
refcount and only clear the bd_claiming field when it goes down to
zero.

I dunno. Maybe there's something else going on, but it does look
suspicious, and the above would explain the BUG_ON().

Tejun, Jens?

> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D16369
> Subject         : Yet another 2.6.35 regression (AGP)?
> Submitter       : Woody Suwalski <terraluna977-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date            : 2010-07-09 14:21 (24 days old)
> Message-ID      : <4C373084.8000503-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> References      : http://marc.info/?l=3Dlinux-kernel&m=3D127868797119=
254&w=3D2

Should hopefully be fixed by commit e7b96f28c58c ("agp/intel: Use the
correct mask to detect i830 aperture size.")

> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D16365
> Subject         : kernel BUG at fs/btrfs/extent-tree.c:1353
> Submitter       : Johannes Hirte <johannes.hirte-3kN+8DYepx7zMJDuovMtMLNAH6kLmebB@public.gmane.org>
> Date            : 2010-07-08 14:27 (25 days old)
> Message-ID      : <201007081627.24654.johannes.hirte-3kN+8DYepx7zMJDuovMtMA@public.gmane.org=
e>
> References      : http://marc.info/?l=3Dlinux-kernel&m=3D127859960725=
931&w=3D2

This one is reportedly fixed by commit 83ba7b071f30 ("writeback:
simplify the write back thread queue")

> Bug-Entry =A0 =A0 =A0 : http://bugzilla.kernel.org/show_bug.cgi?id=3D=
16215
> Subject =A0 =A0 =A0 =A0 : sysfs: cannot create duplicate filename '/c=
lass/net/bnep0'
> Submitter =A0 =A0 =A0 : Janusz Krzysztofik <jkrzyszt-NCk8gXQAEuFz6jiHbVrK7g@public.gmane.org>
> Date =A0 =A0 =A0 =A0 =A0 =A0: 2010-06-15 14:55 (48 days old)
> Handled-By =A0 =A0 =A0: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

=46ixed by commit 24b1442d01ae155ea716dfb94ed21605541c317d.

                             Linus
