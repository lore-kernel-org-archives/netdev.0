From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage.
Date: Mon, 13 Aug 2007 15:03:02 +0400
Message-ID: <20070813110302.GA28360@2ka.mipt.ru>
References: <20070731171347.GA14267@2ka.mipt.ru> <200708130208.57542.phillips@phunq.net> <20070813091856.GA5503@2ka.mipt.ru> <200708130312.33903.phillips@phunq.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Peter Zijlstra <peterz@infradead.org>
To: Daniel Phillips <phillips@phunq.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200708130312.33903.phillips@phunq.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 13, 2007 at 03:12:33AM -0700, Daniel Phillips (phillips@phunq.net) wrote:
> > This is not a very good solution, since it requires all users of the
> > bios to know how to free it.
> 
> No, only the specific ->endio needs to know that, which is set by the 
> bio owner, so this knowledge lies in exactly the right place.  A small 
> handful of generic endios all with the same destructor are used nearly 
> everywhere.

That is what I meant - there will be no way to just alloc a bio and put
it, helpers for generic bio sets must be exported and each and every
bi_end_io() must be changed to check reference counter and they must
know how they were allocated.

> > Right now it is hidden. 
> > And adds additional atomic check (although reading is quite fast) in
> > the end_io.
> 
> Actual endio happens once in the lifetime of the transfer, this read 
> will be entirely lost in the noise.

Not always. Sometimes it is called multiple times, but all bi_end_io()
callbacks I checked (I believe all in mainline tree) tests if bi_size is
zero or not.

Endio callback is of course quite rare and additional atomic
reading will not kill the system, but why introduce another read?
It is possible to provide a flag for endio callback that it is last, but
it still requires to change every single callback - why do we want this?

> > And for what purpose? To eat 8 bytes on 64bit platform? 
> > This will not reduce its size noticebly, so the same number of bios
> > will be in the cache's page, so what is a gain? All this cleanups and
> > logic complicatins should be performed only if after size shring
> > increased number of bios can fit into cache's page, will it be done
> > after such cleanups?
> 
> Well, exactly,   My point from the beginning was that the size of struct 
> bio is not even close to being a problem and adding a few bytes to it 
> in the interest of doing the cleanest fix to a core kernel bug is just 
> not a dominant issue.

So, I'm a bit lost...

You say it is too big and some parts can be removed or combined, and
then that size does not matter. Last/not-last checks in the code is not
clear design, so I do not see why it is needed at all if not for size
shrinking.

> I suppose that leaving out the word "bloated" and skipping straight to 
> the "doesn't matter" proof would have saved some bandwidth.

:) Likely it will.

-- 
	Evgeniy Polyakov
