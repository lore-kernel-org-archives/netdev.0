From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH -next 2/3] batman-adv: Use seq_overflow
Date: Wed, 11 Dec 2013 08:38:04 +0000
Message-ID: <20131211083804.GV10323@ZenIV.linux.org.uk>
References: <cover.1386738050.git.joe@perches.com>
 <e7104b35287b1e1ec456734c1b5e1aa98dac99f8.1386738050.git.joe@perches.com>
 <20131211075526.GR10323@ZenIV.linux.org.uk>
 <20131211080504.GT10323@ZenIV.linux.org.uk>
 <1386750377.8168.37.camel@joe-AO722>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1386750377.8168.37.camel@joe-AO722>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Wed, Dec 11, 2013 at 12:26:17AM -0800, Joe Perches wrote:
> On Wed, 2013-12-11 at 08:05 +0000, Al Viro wrote:
> > On Wed, Dec 11, 2013 at 07:55:26AM +0000, Al Viro wrote:
> > 
> > > This sucker should return 0.  Insufficiently large buffer will be handled
> > > by caller, TYVM, if you give that caller a chance to do so.  Returning 1
> > > from ->show() is a bug in almost all cases, and definitely so in this one.
> > > 
> > > Just in case somebody decides that above is worth copying: It Is Not.
> > > Original code is buggy, plain and simple.  This one trades the older
> > > bug ("fail with -EINVAL whenever the buffer is too small") with just as buggy
> > > "silently skip an entry entirely whenever the buffer is too small".
> > > 
> > > Don't Do That.
> > 
> > Pardon - Joe has made seq_overflow return -1 instead of true.  Correction
> > to the above, then - s/This trades.*\./This is just as buggy./
> 
> Yeah, I started to use true/false, 0/1, but thought
> I needed to match what seq_printf/seq_vprintf does.
> 
> > Conclusion is still the same - Don't Do That.  Returning -1 on insufficiently
> > large buffer is a bug, plain and simple.
> 
> int seq_vprintf(struct seq_file *m, const char *f, va_list args)
> {
> 	int len;
> 
> 	if (m->count < m->size) {
> 		len = vsnprintf(m->buf + m->count, m->size - m->count, f, args);
> 		if (m->count + len < m->size) {
> 			m->count += len;
> 			return 0;
> 		}
> 	}
> 	seq_set_overflow(m);
> 	return -1;
> }
> EXPORT_SYMBOL(seq_vprintf);
> 
> int seq_printf(struct seq_file *m, const char *f, ...)
> {
> 	int ret;
> 	va_list args;
> 
> 	va_start(args, f);
> 	ret = seq_vprintf(m, f, args);
> 	va_end(args);
> 
> 	return ret;
> }
> EXPORT_SYMBOL(seq_printf);
> 
> > And this patch series is completely misguided - it doesn't fix any bugs
> > *and* it provides a misleading example for everyone.  See the reaction
> > right in this thread, proposing to spread the same bug to currently
> > working iterators.
> 
> Anyway, changing seq_overflow is easy enough
> 
> You prefer this?
> 
> bool seq_overflow(struct seq_file *seq)
> {
> 	return m->count == m->size;
> }

I prefer a series that starts with fixing the obvious bugs (i.e. places
where we return seq_printf/seq_puts/seq_putc return value from ->show()).
All such places should return 0.  Then we need to look at the remaining
places that check return value of seq_printf() et.al.  And decide whether
the callers really care about it.

Theoretically, there is a legitimate case when we want to look at that
return value.  Namely,
	seq_print(...)
	if (!overflowed)
		do tons of expensive calculations
		generate more output
	return 0
That is the reason why those guys hadn't been returning void to start with.
And yes, it was inviting bugs with ->show() returning -1 on overflows.
Bad API design, plain and simple.

I'm not sure we actually have any instances of that legitimate case, TBH.
_IF_ we do, we ought to expose seq_overflow() (with saner name - this one
invites the same "it's an error, need to report it" kind of bugs) and use
it in such places.  But that needs to be decided on per-caller basis.  And
I'd expect that there would be few enough such places after we kill the
obvious bugs.
