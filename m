From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] tun: make sure interface usage can not overflow
Date: Tue, 30 Sep 2014 14:29:21 +0300
Message-ID: <20140930112921.GD7089@redhat.com>
References: <20140928232753.GA31180@www.outflux.net>
 <20140929114849.GA913@redhat.com>
 <CAGXu5j+x5pg6-9y72o=mE9TiNEyFqTTE=o8ETh1Ao8R20KNRwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Tom Herbert <therbert@google.com>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5j+x5pg6-9y72o=mE9TiNEyFqTTE=o8ETh1Ao8R20KNRwA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 29, 2014 at 12:48:47PM -0700, Kees Cook wrote:
> On Mon, Sep 29, 2014 at 4:48 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Sun, Sep 28, 2014 at 04:27:53PM -0700, Kees Cook wrote:
> >> This makes the size argument a const, since it is always populated by
> >> the caller. Additionally double-checks to make sure the copy_from_user
> >> can never overflow, keeping CONFIG_DEBUG_STRICT_USER_COPY_CHECKS happy:
> >>
> >>    In function 'copy_from_user',
> >>        inlined from '__tun_chr_ioctl' at drivers/net/tun.c:1871:7:
> >>        ... copy_from_user() buffer size is not provably correct
> >>
> >> Signed-off-by: Kees Cook <keescook@chromium.org>
> >
> > What exactly is the issue here?
> > __tun_chr_ioctl is called with sizeof(struct compat_ifreq)
> > or  sizeof (struct ifreq) as the last argument.
> 
> Correct. There is no vulnerability here; I am attempting to both make
> the code more defensive to future changes, and to keep
> CONFIG_DEBUG_STRICT_USER_COPY_CHECKS happy.
> 
> > So this looks like a false positive, but
> > CONFIG_DEBUG_STRICT_USER_COPY_CHECKS machinery is supposed
> > to avoid false positives.
> 
> The support in GCC is currently a bit faulty, and it seems that it
> didn't notice the two callers were static values, so instead, adding
> an explicit test keeps it happy.
> 
> > On which architecture is this?
> 
> This is on x86, but with CONFIG_DEBUG_STRICT_USER_COPY_CHECKS
> correctly enabled (gcc after 4.6 broke its ability to correctly
> optimize), which I've been playing with trying to get gcc working
> again. I sent the patch because it seems like it's a reasonable
> defensive change to make.

For the BUG_ON - I guess it's reasonable but we'll just break it again
by random code changes in the future. And when we do, I don't cherish
the thought of using trial and error to find a way to shut up the
warning again.
If gcc can't be fixed, something explicit like the uninitialized_var
is needed.

For const as an argument - is it also about gcc bugs?
We don't usually do this in kernel so if it's useful,
it has to be documented.

Finally, why are you switching the type from int to size_t?
Pls document the reason in the commit log.

> If you want to look more deeply, there's some background here:
> https://code.google.com/p/chromium/issues/detail?id=371036
> 
> https://git.kernel.org/cgit/linux/kernel/git/kees/linux.git/commit/?h=gcc-bug&id=92dd7154932d8775a05dfd3de5564124c05a4150
> 
> Thanks,
> 
> -Kees

I think what you are trying to do is really useful, but
I doubt making random code changes that happen to make a
specific gcc version happy is maintainable.

HTH
Thanks!

> -- 
> Kees Cook
> Chrome OS Security
