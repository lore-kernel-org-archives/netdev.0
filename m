From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: ioremap_uc() followed by set_memory_wc() - burrying MTRR
Date: Thu, 16 Apr 2015 01:58:16 +0200
Message-ID: <20150415235816.GG5622@wotan.suse.de>
References: <CALCETrUG=RiG8S9Gpiqm_0CxvxurxLTNKyuyPoFNX46EAauA+g@mail.gmail.com>
 <CAB=NE6XgNgu7i2OiDxFVJLWiEjbjBY17-dV7L3yi2+yzgMhEbw@mail.gmail.com>
 <1428695379.6646.69.camel@misato.fc.hp.com>
 <20150410210538.GB5622@wotan.suse.de>
 <1428699490.21794.5.camel@misato.fc.hp.com>
 <CALCETrUP688aNjckygqO=AXXrNYvLQX6F0=b5fjmsCqqZU78+Q@mail.gmail.com>
 <20150411012938.GC5622@wotan.suse.de>
 <CALCETrXd19C6pARde3pv-4pt-i52APtw5xs20itwROPq9VmCfg@mail.gmail.com>
 <20150413174938.GE5622@wotan.suse.de>
 <1429137531.1899.28.camel@palomino.walls.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@amacapital.net>,
	Toshi Kani <toshi.kani@hp.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
	linux-kernel@vger.kernel.org,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Suresh Siddha <sbsiddha@gmail.com>,
	Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Roland Dreier <roland@purestorage.com>,
	Juergen Gross <jgross@suse.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Borislav Petkov <bp@suse.de>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Davidlohr Bueso <dbueso@suse.de>, dave.hansen@linux.intel.com,
	plagnioj@jcrosoft.com, tglx@linutronix.de,
	Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <syrjala@sci.fi>,
	linux-fbdev@vger.kernel.org, linux-media@vger.kernel.org,
	x86@kernel.org
To: Andy Walls <awalls@md.metrocast.net>,
	Hyong-Youb Kim <hykim@myri.com>, netdev@vger.kernel.org
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429137531.1899.28.camel@palomino.walls.org>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey Andy, thanks for your review,  adding Hyong-Youb Kim for  review of the
full range ioremap_wc() idea below.

On Wed, Apr 15, 2015 at 06:38:51PM -0400, Andy Walls wrote:
> Hi All,
> 
> On Mon, 2015-04-13 at 19:49 +0200, Luis R. Rodriguez wrote:
> > From the beginning it seems only framebuffer devices used MTRR/WC,
> [snip]
> >  The ivtv device is a good example of the worst type of
> > situations and these days. So perhap __arch_phys_wc_add() and a
> > ioremap_ucminus() might be something more than transient unless hardware folks
> > get a good memo or already know how to just Do The Right Thing (TM).
> 
> Just to reiterate a subtle point, use of the ivtvfb is *optional*.  A
> user may or may not load it.  When the user does load the ivtvfb driver,
> the ivtv driver has already been initialized and may have functions of
> the card already in use by userspace.

I suspected this and its why I note that a rewrite to address a clean
split with separate ioremap seems rather difficult in this case.

> Hopefully no one is trying to use the OSD as framebuffer and the video
> decoder/output engine for video display at the same time. 

Worst case concern I have also is the implications of having overlapping
ioremap() calls (as proposed in my last reply) for different memory types
and having the different virtual memory addresse used by different parts
of the driver. Its not clear to me what the hardware implications of this
are.

>  But the video
> decoder/output device nodes may already be open for performing ioctl()
> functions so unmapping the decoder IO space out from under them, when
> loading the ivtvfb driver module, might not be a good thing. 

Using overlapping ioremap() calls with different memory types would address
this concern provided hardware won't barf both on the device and CPU. Hardware
folks could provide feedback or an ivtvfb user could test the patch supplied
on both non-PAT and PAT systems. Even so, who knows,  this might work on some
systems while not on others, only hardware folks would know.

An alternative... is to just ioremap_wc() the entire region, including
MMIO registers for these old devices. I see one ethernet driver that does
this, myri10ge, and am curious how and why they ended up deciding this
and if they have run into any issues. I wonder if this is a reasonable
comrpomise for these 2 remaining corner cases.

  Luis
