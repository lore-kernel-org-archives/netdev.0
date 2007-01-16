From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH -mm 9/10][RFC] aio: usb gadget remove aio file ops
Date: Tue, 16 Jan 2007 10:36:42 -0800
Message-ID: <200701161036.45771.david-b@pacbell.net>
References: <20070116015450.9764.62432.patchbomb.py@nate-64.agami.com> <200701152205.46089.david-b@pacbell.net> <5c49b0ed0701160113i8866879y3a134461c4ae7974@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Nate Diller" <nate@agami.com>, "Andrew Morton" <akpm@osdl.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Benjamin LaHaise" <bcrl@kvack.org>,
	"Alexander Viro" <viro@zeniv.linux.org.uk>,
	"Suparna Bhattacharya" <suparna@in.ibm.com>,
	"Kenneth W Chen" <kenneth.w.chen@intel.com>,
	"David Brownell" <dbrownell@users.sourceforge.net>,
	"Christoph Hellwig" <hch@infradead.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, ocfs2-devel@oss.oracle.com,
	linux-aio@kvack.org, xfs-masters@oss.sgi.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "Nate Diller" <nate.diller@gmail.com>
In-Reply-To: <5c49b0ed0701160113i8866879y3a134461c4ae7974@mail.gmail.com>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 16 January 2007 1:13 am, Nate Diller wrote:
> On 1/15/07, David Brownell <david-b@pacbell.net> wrote:
> > What's needed is an async, non-sleeeping, interface ... with I/O
> > overlap.  That's antithetical to using read()/write() calls, so
> > your proposed approach couldn't possibly work.
> 
> haha, wow ok you convinced me :)

Good.  :)


> I got a bit impatient when I was working on this, it took some time
> just to figure out the intention of the code, and I'm trying to hold
> to a bit of a schedule here.  Without any clear (to me) reason, I
> didn't want to spend a lot of effort fixing this up.

Thing is, it's not OK to break other subsystems like that.

 
> There's really no big difference between the usb drivers here and the
> disk I/O scheduler queue, AFAICT,

The disk scheduler queue is more complex, as I understand things,
since it can combine operations.  For USB, "combining" would break
essential semantics relied on by both sides of the transaction.

Maybe the best way to view this is to accept that with USB, all
scheduler operations (e.g. for bandwidth reservation management)
are out of scope of the AIO request model.  AIO requests are no
more (or less) than "append this to the endpoint's I/O queue",
with the (host side) I/O scheduling handled separately.


> so it seems like the solution I want 
> is to do a kmap() on the user buffer and then do the I/O straight out
> of that.  That will eliminate the need for the bounce buffer.  I'll
> post a new version along with the iodesc changes later this week.

Sounds more complex, but it would be nice to have that code become
zero-copy instead of single-copy.  That'd let some platforms work
with high bandwidth ISO from userspace, which previously would not
have had enough CPU bandwidth.  ("High bandwidth" means sustained
8-24 MByte/sec data streaming.  Processing pixels at that rate may
require a companion DSP...)  Testing will be different issue though.

- Dave
