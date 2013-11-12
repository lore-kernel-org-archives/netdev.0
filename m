From: Joe Perches <joe@perches.com>
Subject: Re: [Fwd: Re: [PATCH v2 2/2] x86: add prefetching to do_csum]
Date: Tue, 12 Nov 2013 12:38:01 -0800
Message-ID: <1384288681.3665.22.camel@joe-AO722>
References: <1384220542.4771.23.camel@joe-AO722>
	 <20131112171239.GC19780@hmsreliant.think-freely.org>
	 <1384277615.3665.10.camel@joe-AO722>
	 <20131112195005.GD19780@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131112195005.GD19780@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-11-12 at 14:50 -0500, Neil Horman wrote:
> On Tue, Nov 12, 2013 at 09:33:35AM -0800, Joe Perches wrote:
> > On Tue, 2013-11-12 at 12:12 -0500, Neil Horman wrote:
[]
> > > So, the numbers are correct now that I returned my hardware to its previous
> > > interrupt affinity state, but the trend seems to be the same (namely that there
> > > isn't a clear one).  We seem to find peak performance around a readahead of 2
> > > cachelines, but its very small (about 3%), and its inconsistent (larger set
> > > sizes fall to either side of that stride).  So I don't see it as a clear win.  I
> > > still think we should probably scrap the readahead for now, just take the perf
> > > bits, and revisit this when we can use the vector instructions or the
> > > independent carry chain instructions to improve this more consistently.
> > > 
> > > Thoughts
> > 
> > Perhaps a single prefetch, not of the first addr but of
> > the addr after PREFETCH_STRIDE would work best but only
> > if length is > PREFETCH_STRIDE.
> > 
> > I'd try:
> > 
> > 	if (len > PREFETCH_STRIDE)
> > 		prefetch(buf + PREFETCH_STRIDE);
> > 	while (count64) {
> > 		etc...
> > 	}
> > 
> > I still don't know how much that impacts very short lengths.
> > Can you please add a 20 byte length to your tests?
> Sure, I modified the code so that we only prefetched 2 cache lines ahead, but
> only if the overall length of the input buffer is more than 2 cache lines.
> Below are the results (all counts are the average of 1000000 iterations of the
> csum operation, as previous tests were, I just omitted that column).
> 
> len	set	cycles/byte	cycles/byte	improvement
> 		no prefetch	prefetch
> ===========================================================
> 20B	64MB	45.014989	44.402432	1.3%
> 20B	128MB	44.900317	46.146447	-2.7%
> 20B	256MB	45.303223	48.193623	-6.3%
> 20B	512MB	45.615301	44.486872	2.2%
[]
> I'm still left thinking we should just abandon the prefetch at this point and
> keep the perf code until we have new instructions to help us with this further,
> unless you see something I dont.

I tend to agree but perhaps the 3% performance
increase with a prefetch for longer lengths is
actually significant and desirable.

It doesn't seem you've done the test I suggested
where prefetch is done only for
"len > PREFETCH_STRIDE".

Is it ever useful to do a prefetch of the
address/data being accessed by the next
instruction?

Anyway, thanks for doing all the work.

Joe
