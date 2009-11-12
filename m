From: Dave Airlie <airlied@gmail.com>
Subject: Re: [patch] Fix: 'return -ENOMEM' instead of 'return ENOMEM'
Date: Thu, 12 Nov 2009 18:43:26 +1000
Message-ID: <21d7e9970911120043v42c57acyecf07b4bc002ae12@mail.gmail.com>
References: <4AFB2C0B.50605@gmail.com>
	<20091111134730.a0da9e38.akpm@linux-foundation.org>
	<20091112081043.GA25345@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	"Stephen M. Cameron" <scameron@beardog.cca.cpqcorp.net>,
	Mike Christie <michaelc@cs.wisc.edu>, David Airlie <airlied@linux.ie>,
	Jens Axboe <jens.axboe@oracle.com>, Evgeniy Polyakov <zbr@ioremap.net>,
	Mike Miller <mike.miller@hp.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	Joel Becker <joel.becker@oracle.com>, Jeff Liu <jeff.liu@oracle.com>,
	Andy Whitcroft <apw@shadowen.org>, Dave Airlie <airlied@redhat.com>,
	Hannes Eder <hannes@hanneseder.net>, dri-devel@lists.sourceforge.net,
	Alexey Dobriyan <adobriyan@gmail.com>, iss_storagedev@hp.com,
	Mark Fasheh <mfasheh@suse.com>,
	Keith Packard <keithp@keithp.com>, rostedt@goodmis.org,
	Karen Xie <kxie@chelsio.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
	Hannes Reinecke <hare@suse.de>, Andreas Eversberg <andreas@eversberg.eu>,
To: Ingo Molnar <mingo@elte.hu>
Return-path: <dri-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20091112081043.GA25345@elte.hu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=dri-devel>
List-Post: <mailto:dri-devel@lists.sourceforge.net>
List-Help: <mailto:dri-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: dri-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2009 at 6:10 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> > @@ -3730,7 +3730,7 @@ tracing_stats_read(struct file *filp, char __use=
r *ubuf,
>> >
>> > =A0 =A0 s =3D kmalloc(sizeof(*s), GFP_KERNEL);
>> > =A0 =A0 if (!s)
>> > - =A0 =A0 =A0 =A0 =A0 return ENOMEM;
>> > + =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> >
>> > =A0 =A0 trace_seq_init(s);
>> >
>>
>> lol, there we go again.
>>
>> Andy, can we have a checkpatch rule please?
>
> Note, that will upset creative uses of error codes i guess, such as
> fs/xfs/.
>
> But yeah, +1 from me too.
>
> Ob'post'mortem - looked for similar patterns in the kernel and there's
> quite a few bugs there:
>
> =A0include/net/inet_hashtables.h: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retu=
rn ENOMEM; =A0 =A0 =A0 =A0 # bug
> =A0drivers/scsi/aic7xxx/aic7xxx_osm.c: =A0 =A0 =A0 =A0 =A0 =A0 return ENO=
MEM; =A0 =A0 =A0 =A0 # works but weird
> =A0drivers/scsi/cxgb3i/cxgb3i_offload.c: =A0 =A0 =A0 =A0 =A0 return ENOME=
M; =A0 =A0 =A0 =A0 # works but weird
> =A0fs/ocfs2/dlm/dlmrecovery.c: =A0 =A0 =A0 =A0 =A0 =A0return EAGAIN; =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# bug
> =A0drivers/block/cciss_scsi.c: =A0 =A0 =A0 =A0 =A0 =A0 return ENXIO; =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# works but weird
> =A0drivers/gpu/drm/radeon/radeon_irq.c: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0return EINVAL; # bug
> =A0drivers/gpu/drm/radeon/radeon_irq.c: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0return EINVAL; # bug
> =A0drivers/isdn/hardware/mISDN/hfcmulti.c: =A0 =A0 =A0 =A0 return EINVAL;=
 =A0 =A0 =A0 =A0 # bug
>
> 5 out of 8 places look buggy - i.e. more than 60% - a checkpatch warning
> would avoid real bugs here. (even ignoring the cleanliness effects of
> using proper error propagation)
>
> Cc:-ed affected maintainers. The rightmost column are my observations.
> Below is the patch fixing these.
>
> =A0 =A0 =A0 =A0Ingo
>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>

Looks good to me for radeon bits.

Acked-by: Dave Airlie <airlied@redhat.com>

Dave.

---------------------------------------------------------------------------=
---
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day =

trial. Simplify your report design, integration and deployment - and focus =
on =

what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
--
