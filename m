From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH V8 09/13] posix clocks: introduce dynamic clocks
Date: Thu, 6 Jan 2011 20:56:22 +0100
Message-ID: <201101062056.22423.arnd@arndb.de>
References: <cover.1293820862.git.richard.cochran@omicron.at> <c28004fc5d121c1dd5f842550663fc9d6f55a114.1293820862.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <c28004fc5d121c1dd5f842550663fc9d6f55a114.1293820862.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 31 December 2010, Richard Cochran wrote:
> This patch adds support for adding and removing posix clocks. The
> clock lifetime cycle is patterned after usb devices. Each clock is
> represented by a standard character device. In addition, the driver
> may optionally implemented custom character device operations.
> 
> The posix clock and timer system calls listed below now work with
> dynamic posix clocks, as well as the traditional static clocks.
> For the performance critical calls (eg clock_gettime) the code path
> from the traditional static clocks is preserved.

Combining the operations structures and using container_of as you did
looks much better than before, but I had something slightly different
in mind:

The way that other subsystems do this is to pass a pointer to the
actual low-level object (struct posix_clock in your case) to the
abstracted functions, while you pass a pointer to the operations
structure. This has the advantage of keeping the definition of
posix_clock private to posix-clock.c, but it is something we do
very rarely.

I can see disadvantages with your approach: You still need to dynamically
allocate the posix_clock in posix_clock_create(), and the operations
structure cannot be const, which is a theoretical security problem
if there is a hole that can replace one of the pointers with a
reference to user memory.

I would recommend changing this to the more common model, where you
passs the (publically defined) struct posix_clock to all operations
and can do something like:

struct my_posix_clock {
	...
	struct posix_clock pclk;
} this_clock = {
	...
	.pclk = {
		.ops = &my_posix_clock_operations,
	}
};

int my_init(void)
{
	return posix_clock_operations_register(&my_posix_clock.pclk);
}

void my_exit(void)
{
	posix_clock_operations_unregister(&my_posix_clock.pclk);
}

It should be just a trivial change and just affect how easy it is for
other people to understand the code if they are already familiar
with other kernel code.

Overall, your series looks really good now, it would be nice if this
could still make it into 2.6.38.

	Arnd
