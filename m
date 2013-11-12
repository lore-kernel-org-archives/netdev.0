From: Joe Perches <joe@perches.com>
Subject: Re: [Fwd: Re: [PATCH v2 2/2] x86: add prefetching to do_csum]
Date: Tue, 12 Nov 2013 09:33:35 -0800
Message-ID: <1384277615.3665.10.camel@joe-AO722>
References: <1384220542.4771.23.camel@joe-AO722>
	 <20131112171239.GC19780@hmsreliant.think-freely.org>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0041.hostedemail.com ([216.40.44.41]:50670 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754337Ab3KLRda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 12:33:30 -0500
In-Reply-To: <20131112171239.GC19780@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-12 at 12:12 -0500, Neil Horman wrote:
> On Mon, Nov 11, 2013 at 05:42:22PM -0800, Joe Perches wrote:
> > Hi again Neil.
> > 
> > Forwarding on to netdev with a concern as to how often
> > do_csum is used via csum_partial for very short headers
> > and what impact any prefetch would have there.
> > 
> > Also, what changed in your test environment?
> > 
> > Why are the new values 5+% higher cycles/byte than the
> > previous values?
> > 
> > And here is the new table reformatted:
> > 
> > len	set	iterations	Readahead cachelines vs cycles/byte
> > 			1	2	3	4	6	10	20
> > 1500B	64MB	1000000	1.4342	1.4300	1.4350	1.4350	1.4396	1.4315	1.4555
> > 1500B	128MB	1000000	1.4312	1.4346	1.4271	1.4284	1.4376	1.4318	1.4431
> > 1500B	256MB	1000000	1.4309	1.4254	1.4316	1.4308	1.4418	1.4304	1.4367
> > 1500B	512MB	1000000	1.4534	1.4516	1.4523	1.4563	1.4554	1.4644	1.4590
> > 9000B	64MB	1000000	0.8921	0.8924	0.8932	0.8949	0.8952	0.8939	0.8985
> > 9000B	128MB	1000000	0.8841	0.8856	0.8845	0.8854	0.8861	0.8879	0.8861
> > 9000B	256MB	1000000	0.8806	0.8821	0.8813	0.8833	0.8814	0.8827	0.8895
> > 9000B	512MB	1000000	0.8838	0.8852	0.8841	0.8865	0.8846	0.8901	0.8865
> > 64KB	64MB	1000000	0.8132	0.8136	0.8132	0.8150	0.8147	0.8149	0.8147
> > 64KB	128MB	1000000	0.8013	0.8014	0.8013	0.8020	0.8041	0.8015	0.8033
> > 64KB	256MB	1000000	0.7956	0.7959	0.7956	0.7976	0.7981	0.7967	0.7973
> > 64KB	512MB	1000000	0.7934	0.7932	0.7937	0.7951	0.7954	0.7943	0.7948
> > 
> 
> 
> There we go, thats better:
> len   set     iterations      Readahead cachelines vs cycles/byte
> 			1	2	3	4	5	10	20
> 1500B 64MB	1000000	1.3638	1.3288	1.3464	1.3505	1.3586	1.3527	1.3408
> 1500B 128MB	1000000	1.3394	1.3357	1.3625	1.3456	1.3536	1.3400	1.3410
> 1500B 256MB	1000000 1.3773	1.3362	1.3419	1.3548	1.3543	1.3442	1.4163
> 1500B 512MB	1000000 1.3442	1.3390	1.3434	1.3505	1.3767	1.3513	1.3820
> 9000B 64MB	1000000 0.8505	0.8492	0.8521	0.8593	0.8566	0.8577	0.8547
> 9000B 128MB	1000000 0.8507	0.8507	0.8523	0.8627	0.8593	0.8670	0.8570
> 9000B 256MB	1000000 0.8516	0.8515	0.8568	0.8546	0.8549	0.8609	0.8596
> 9000B 512MB	1000000 0.8517	0.8526	0.8552	0.8675	0.8547	0.8526	0.8621
> 64KB  64MB	1000000 0.7679	0.7689	0.7688	0.7716	0.7714	0.7722	0.7716
> 64KB  128MB	1000000 0.7683	0.7687	0.7710	0.7690	0.7717	0.7694	0.7703
> 64KB  256MB	1000000 0.7680	0.7703	0.7688	0.7689	0.7726	0.7717	0.7713
> 64KB  512MB	1000000 0.7692	0.7690	0.7701	0.7705	0.7698	0.7693	0.7735
> 
> 
> So, the numbers are correct now that I returned my hardware to its previous
> interrupt affinity state, but the trend seems to be the same (namely that there
> isn't a clear one).  We seem to find peak performance around a readahead of 2
> cachelines, but its very small (about 3%), and its inconsistent (larger set
> sizes fall to either side of that stride).  So I don't see it as a clear win.  I
> still think we should probably scrap the readahead for now, just take the perf
> bits, and revisit this when we can use the vector instructions or the
> independent carry chain instructions to improve this more consistently.
> 
> Thoughts

Perhaps a single prefetch, not of the first addr but of
the addr after PREFETCH_STRIDE would work best but only
if length is > PREFETCH_STRIDE.

I'd try:

	if (len > PREFETCH_STRIDE)
		prefetch(buf + PREFETCH_STRIDE);
	while (count64) {
		etc...
	}

I still don't know how much that impacts very short lengths.

Can you please add a 20 byte length to your tests?
