From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: [PATCH 5/5] tun: vringfd xmit support.
Date: Fri, 18 Apr 2008 09:24:27 -0700
Message-ID: <2c0942db0804180924n2ee701e5w7166a203569fc669@mail.gmail.com>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804181443.24812.rusty@rustcorp.com.au>
	<20080418043120.ff78eab5.akpm@linux-foundation.org>
	<200804190115.15983.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>,
        virtualization@lists.linux-foundation.org
To: "Rusty Russell" <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200804190115.15983.rusty@rustcorp.com.au>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 18, 2008 at 8:15 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> On Friday 18 April 2008 21:31:20 Andrew Morton wrote:
>  > On Fri, 18 Apr 2008 14:43:24 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:
>
> > > +           /* How many pages will this take? */
>  > > +           npages = 1 + (base + len - 1)/PAGE_SIZE - base/PAGE_SIZE;
>  >
>  > Brain hurts.  I hope you got that right.
>
>  I tested it when I wrote it, but just wrote a tester again:
>
>  base            len     npages
>  0               1       1
>  0xfff           1       1
>  0x1000          1       1
>  0               4096    1
>  0x1             4096    2
>  0xfff           4096    2
>  0x1000          4096    1
>  0xfffff000      4096    1
>  0xfffff000      4097    4293918722

Picky, picky :-).

If base were always page aligned, we'd want

    npages = (len + PAGE_SIZE - 1) / PAGE_SIZE;

which is simply rounding len up to the next largest page size. So when
base is not page aligned, increase len by the left-over space at the
beginning, and then do the same calculation as above. (ie, pretend
base is page aligned, and instead count the excess at the beginning as
part of len.)

    npages = ( (base & PAGE_MASK) + len + PAGE_SIZE - 1) / PAGE_SIZE;

As long as len < PAGE_MASK - PAGE_SIZE, we're safe from overflows.

(The above gives a different answer when len=0, but you guard for that.)
