From: Andrew Morton <akpm@osdl.org>
Subject: Re: Kernel crash in 2.6.0-test9-mm3
Date: Tue, 18 Nov 2003 18:02:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118180208.55eb0a14.akpm@osdl.org>
References: <6.0.1.1.2.20031118232152.01ae5728@tornado.reub.net>
	<20031118110139.45f2be60.akpm@osdl.org>
	<20031118164944.54544c39.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: reuben-linux@reub.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031118164944.54544c39.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> wrote:
>
> On Tue, 18 Nov 2003 11:01:39 -0800
> Andrew Morton <akpm@osdl.org> wrote:
> 
> > It's one for the networking guys.
> > 
> > The mm kernels have a patch which detects when atomic_dec_and_test
> > takes an atomic_t negative - it is assumed that this is a bug so
> > a warning is generated.
> 
> Andrew I've analyzed this a bit.  This is incredible evidence in
> these dumps that either there is a bug in Linus's atomic_dec_and_test()
> debugging hack or GCC is miscompiling it in certain cases with certain
> versions of the compiler.
> 
> Look at this:
> 
> > > Nov 18 23:09:00 tornado kernel:  [<c029203c>] skb_release_data+0x14c/0x160
> > > Nov 18 23:09:00 tornado kernel:  [<c0292063>] kfree_skbmem+0x13/0x30
> > > Nov 18 23:09:00 tornado kernel:  [<c0292138>] __kfree_skb+0xb8/0x1b0
> > > Nov 18 23:09:00 tornado kernel:  [<c0218815>] e100intr+0x1e5/0x290
> 
> Ok, releasing an SKB data area twice.
> 
> > > Nov 18 23:09:00 tornado kernel: BUG: dst underflow 0: c02921ef
> 
> Freeing a 'dst' entry one too many times.
> 
> > > Nov 18 23:09:00 tornado kernel: Attempt to release alive inet socket dfd4c780
> 
> A socket refcount dropping to zero too early, before it's marked dead.
> 
> These last two problems are very serious errors, and would have
> printed out debugging messages before the atomic_dec_and_test() patch.
> If these last two messages don't show up without the
> atomic_dec_and_test() debugging patch applied, well there you
> go... :-)
> 
> In that debugging patch, I'm wondering something about x86.
> When one goes "sete %reg; sets %reg" does the first 'sete' modify
> the condition codes by chance?  Probably not...

Beats me David.  This is the only time where the correctness of that patch
has been questioned.

Reuben, can you please do a patch -R of

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test9/2.6.0-test9-mm3/broken-out/atomic_dec-debug.patch

and see if the problem goes away?
