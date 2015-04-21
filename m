From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: ioremap_uc() followed by set_memory_wc() - burrying MTRR
Date: Wed, 22 Apr 2015 01:14:56 +0200
Message-ID: <20150421231456.GZ5622@wotan.suse.de>
References: <20150411012938.GC5622@wotan.suse.de>
 <CALCETrXd19C6pARde3pv-4pt-i52APtw5xs20itwROPq9VmCfg@mail.gmail.com>
 <20150413174938.GE5622@wotan.suse.de>
 <1429137531.1899.28.camel@palomino.walls.org>
 <20150415235816.GG5622@wotan.suse.de>
 <1429146457.1899.99.camel@palomino.walls.org>
 <20150421220219.GX5622@wotan.suse.de>
 <CAB=NE6UFOi_CYbrgYGCfU3Uki30iGdPPL2+V5RLYww=NS7G0GA@mail.gmail.com>
 <CALCETrXMJNvd0zTjgyM6GF=xm7aL-K2ERX-A0p=46msh54AA7g@mail.gmail.com>
 <5536d47a.95968c0a.1d12.ffffbf85@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@amacapital.net>,
	Hyong-Youb Kim <hykim@myri.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	infinipath@intel.com, jgunthorpe@obsidianresearch.com,
	mike.marciniszyn@intel.com, Toshi Kani <toshi.kani@hp.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Suresh Siddha <sbsiddha@gmail.com>,
	Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Roland Dreier <roland@purestorage.com>,
	Juergen Gross <jgross@suse.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Borislav Petkov <bp@suse.de>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Davidlohr Bueso <dbueso@suse.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj
To: Andy Walls <andy@silverblocksystems.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5536d47a.95968c0a.1d12.ffffbf85@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2015 at 06:51:26PM -0400, Andy Walls wrote:
> Sorry for the top post; mobile work email account.
> 
> Luis,
> 
> You do the changes to remove MTTR and point me to your dev repo and branch.
> Also point me to the new functions/primitives I'll need.

There is nothing new actually needed for ivtv, unless of course
the ivtv driver is bounded to use a large MTRR that includes
the non-framebuffer region, if so then the ioremap_uc() would
be needed, and you can just cherry pick that patch:

https://marc.info/?l=linux-kernel&m=142964809110516&w=1

I'll bounce that patch to you as well. Might help reading this
patch too:

https://marc.info/?l=linux-kernel&m=142964809710517&w=1

If your write-combining area is not restricted by size constraints
so that it also include the non-framebuffer areas then you can just
do a simple conversion of the driver to use ioremap_wc() on the
framebuffer followed by arch_phys_wc_add().

An example driver that required changes to split this with size
contraints is atyfb, here are the changes for it:

https://marc.info/?l=linux-kernel&m=142964818810539&w=1
https://marc.info/?l=linux-kernel&m=142964813610531&w=1
https://marc.info/?l=linux-kernel&m=142964811010524&w=1
https://marc.info/?l=linux-kernel&m=142964814810532&w=1

If you are not constrained by MTRR's limitation on size then
a simple trivial driver conversion is sufficient. For example:

https://marc.info/?l=linux-kernel&m=142964744610286&w=1

I should also note that we are strivoing to also not use overlapping ioremap()
calls as we want to avoid that mess. Overlapping iroemap() calls with different
types could in theory work but its best we just design clean drivers and avoid
this.

As per Andy Lutomirski, what we'd need done on ivtv likely is
for it to ioremap() for an initial bring up of the device, then
infer the framebuffer offset, and only when that is being used
then iounmap and then ioremap() again split areas on the driver,
one with ioremap.

> I'll do the changes to add write-combining back into ivtv and ivtvfb, test
> them with my hardware and push them to my linuxtv.org git repo.

Great! The above sounded like a complexity you did not wish to
take on, but if you're up for the change, that'd be awesome!

> I know there is at least one English speaking user in India using ivtv with
> old PVR hardware, and probably folks in less developed places also using it.

If the above is too much work for that few amount of users I'd hope
we can just have them use older kernels, for the sake of sane APIs and
clean driver architecture.

  Luis
