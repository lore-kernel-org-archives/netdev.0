From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Fwd: Re: [PATCH v2 2/2] x86: add prefetching to do_csum]
Date: Tue, 12 Nov 2013 08:59:07 -0500
Message-ID: <20131112135907.GB19780@hmsreliant.think-freely.org>
References: <1384220542.4771.23.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Dave Jones <davej@redhat.com>,
	linux-kernel@vger.kernel.org, sebastien.dugue@bull.net,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1384220542.4771.23.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 11, 2013 at 05:42:22PM -0800, Joe Perches wrote:
> Hi again Neil.
> 
> Forwarding on to netdev with a concern as to how often
> do_csum is used via csum_partial for very short headers
> and what impact any prefetch would have there.
> 
> Also, what changed in your test environment?
> 
> Why are the new values 5+% higher cycles/byte than the
> previous values?
> 
Hmm, thank you, I didn't notice the increase.  I think I rebooted my system and
failed to reset my irq affinity to avoid the processor I was testing on.  Let me
rerun.
Neil

> And here is the new table reformatted:
> 
> len	set	iterations	Readahead cachelines vs cycles/byte
> 			1	2	3	4	6	10	20
> 1500B	64MB	1000000	1.4342	1.4300	1.4350	1.4350	1.4396	1.4315	1.4555
> 1500B	128MB	1000000	1.4312	1.4346	1.4271	1.4284	1.4376	1.4318	1.4431
> 1500B	256MB	1000000	1.4309	1.4254	1.4316	1.4308	1.4418	1.4304	1.4367
> 1500B	512MB	1000000	1.4534	1.4516	1.4523	1.4563	1.4554	1.4644	1.4590
> 9000B	64MB	1000000	0.8921	0.8924	0.8932	0.8949	0.8952	0.8939	0.8985
> 9000B	128MB	1000000	0.8841	0.8856	0.8845	0.8854	0.8861	0.8879	0.8861
> 9000B	256MB	1000000	0.8806	0.8821	0.8813	0.8833	0.8814	0.8827	0.8895
> 9000B	512MB	1000000	0.8838	0.8852	0.8841	0.8865	0.8846	0.8901	0.8865
> 64KB	64MB	1000000	0.8132	0.8136	0.8132	0.8150	0.8147	0.8149	0.8147
> 64KB	128MB	1000000	0.8013	0.8014	0.8013	0.8020	0.8041	0.8015	0.8033
> 64KB	256MB	1000000	0.7956	0.7959	0.7956	0.7976	0.7981	0.7967	0.7973
> 64KB	512MB	1000000	0.7934	0.7932	0.7937	0.7951	0.7954	0.7943	0.7948
> 
> -------- Forwarded Message --------
> From: Neil Horman <nhorman@tuxdriver.com>
> To: Joe Perches <joe@perches.com>
> Cc: Dave Jones <davej@redhat.com>, linux-kernel@vger.kernel.org,
> sebastien.dugue@bull.net, Thomas Gleixner <tglx@linutronix.de>, Ingo
> Molnar <mingo@redhat.com>, H. Peter Anvin <hpa@zytor.com>,
> x86@kernel.org
> Subject: Re: [PATCH v2 2/2] x86: add prefetching to do_csum
> 
> On Fri, Nov 08, 2013 at 12:29:07PM -0800, Joe Perches wrote:
> > On Fri, 2013-11-08 at 15:14 -0500, Neil Horman wrote:
> > > On Fri, Nov 08, 2013 at 11:33:13AM -0800, Joe Perches wrote:
> > > > On Fri, 2013-11-08 at 14:01 -0500, Neil Horman wrote:
> > > > > On Wed, Nov 06, 2013 at 09:19:23AM -0800, Joe Perches wrote:
> > > > > > On Wed, 2013-11-06 at 10:54 -0500, Neil Horman wrote:
> > > > > > > On Wed, Nov 06, 2013 at 10:34:29AM -0500, Dave Jones wrote:
> > > > > > > > On Wed, Nov 06, 2013 at 10:23:19AM -0500, Neil Horman wrote:
> > > > > > > >  > do_csum was identified via perf recently as a hot spot when doing
> > > > > > > >  > receive on ip over infiniband workloads.  After alot of testing and
> > > > > > > >  > ideas, we found the best optimization available to us currently is to
> > > > > > > >  > prefetch the entire data buffer prior to doing the checksum
> > > > > > []
> > > > > > > I'll fix this up and send a v3, but I'll give it a day in case there are more
> > > > > > > comments first.
> > > > > > 
> > > > > > Perhaps a reduction in prefetch loop count helps.
> > > > > > 
> > > > > > Was capping the amount prefetched and letting the
> > > > > > hardware prefetch also tested?
> > > > > > 
> > > > > > 	prefetch_lines(buff, min(len, cache_line_size() * 8u));
> > > > > > 
> > > > > 
> > > > > Just tested this out:
> > > > 
> > > > Thanks.
> > > > 
> > > > Reformatting the table so it's a bit more
> > > > readable/comparable for me:
> > > > 
> > > > len	SetSz	Loops	cycles/byte
> > > > 			limited	unlimited
> > > > 1500B	64MB	1M	1.3442	1.3605
> > > > 1500B	128MB	1M	1.3410	1.3542
> > > > 1500B	256MB	1M	1.3536	1.3710
> > > > 1500B	512MB	1M	1.3463	1.3536
> > > > 9000B	64MB	1M	0.8522	0.8504
> > > > 9000B	128MB	1M	0.8528	0.8536
> > > > 9000B	256MB	1M	0.8532	0.8520
> > > > 9000B	512MB	1M	0.8527	0.8525
> > > > 64KB	64MB	1M	0.7686	0.7683
> > > > 64KB	128MB	1M	0.7695	0.7686
> > > > 64KB	256MB	1M	0.7699	0.7708
> > > > 64KB	512MB	1M	0.7799	0.7694
> > > > 
> > > > This data appears to show some value
> > > > in capping for 1500b lengths and noise
> > > > for shorter and longer lengths.
> > > > 
> > > > Any idea what the actual distribution of
> > > > do_csum lengths is under various loads?
> > > > 
> > > I don't have any hard data no, sorry.
> > 
> > I think you should before you implement this.
> > You might find extremely short lengths.
> > 
> > > I'll cap the prefetch at 1500B for now, since it
> > > doesn't seem to hurt or help beyond that
> > 
> > The table data has a max prefetch of
> > 8 * boot_cpu_data.x86_cache_alignment so
> > I believe it's always less than 1500 but
> > perhaps 4 might be slightly better still.
> > 
> 
> 
> So, you appear to be correct, I reran my test set with different prefetch
> ceilings and got the results below.  There are some cases in which there is a
> performance gain, but the gain is small, and occurs at different spots depending
> on the input buffer size (though most peak gains appear around 2 cache lines).
> I'm guessing it takes about 2 prefetches before hardware prefetching catches up,
> at which point we're just spending time issuing instructions that get discarded.
> Given the small prefetch limit, and the limited gains (which may also change on
> different hardware), I think we should probably just drop the prefetch idea
> entirely, and perhaps just take the perf patch so that we can revisit this area
> when hardware that supports the avx extensions and/or adcx/adox becomes
> available.
> 
> Ingo, does that seem reasonable to you?
> Neil
> 
> 
> 
> 1 cache line:
> len	| set	| iterations	| cycles/byte
> ========|=======|===============|=============
> 1500B   | 64MB  | 1000000       | 1.434190
> 1500B   | 128MB | 1000000       | 1.431216
> 1500B   | 256MB | 1000000       | 1.430888
> 1500B   | 512MB | 1000000       | 1.453422
> 9000B   | 64MB  | 1000000       | 0.892055
> 9000B   | 128MB | 1000000       | 0.884050
> 9000B   | 256MB | 1000000       | 0.880551
> 9000B   | 512MB | 1000000       | 0.883848
> 64KB    | 64MB  | 1000000       | 0.813187
> 64KB    | 128MB | 1000000       | 0.801326
> 64KB    | 256MB | 1000000       | 0.795643
> 64KB    | 512MB | 1000000       | 0.793400
> 
> 
> 2 cache lines:
> len	| set	| iterations	| cycles/byte
> ========|=======|===============|=============
> 1500B   | 64MB  | 1000000       | 1.430030
> 1500B   | 128MB | 1000000       | 1.434589
> 1500B   | 256MB | 1000000       | 1.425430
> 1500B   | 512MB | 1000000       | 1.451570
> 9000B   | 64MB  | 1000000       | 0.892369
> 9000B   | 128MB | 1000000       | 0.885577
> 9000B   | 256MB | 1000000       | 0.882091
> 9000B   | 512MB | 1000000       | 0.885201
> 64KB    | 64MB  | 1000000       | 0.813629
> 64KB    | 128MB | 1000000       | 0.801377
> 64KB    | 256MB | 1000000       | 0.795861
> 64KB    | 512MB | 1000000       | 0.793242
> 
> 3 cache lines:
> len	| set	| iterations	| cycles/byte
> ========|=======|===============|=============
> 1500B   | 64MB  | 1000000       | 1.435048
> 1500B   | 128MB | 1000000       | 1.427103
> 1500B   | 256MB | 1000000       | 1.431558
> 1500B   | 512MB | 1000000       | 1.452250
> 9000B   | 64MB  | 1000000       | 0.893162
> 9000B   | 128MB | 1000000       | 0.884488
> 9000B   | 256MB | 1000000       | 0.881314
> 9000B   | 512MB | 1000000       | 0.884060
> 64KB    | 64MB  | 1000000       | 0.813185
> 64KB    | 128MB | 1000000       | 0.801280
> 64KB    | 256MB | 1000000       | 0.795554
> 64KB    | 512MB | 1000000       | 0.793670
> 
> 4 cache lines:
> len	| set	| iterations	| cycles/byte
> ========|=======|===============|=============
> 1500B   | 64MB  | 1000000       | 1.435013
> 1500B   | 128MB | 1000000       | 1.428434
> 1500B   | 256MB | 1000000       | 1.430780
> 1500B   | 512MB | 1000000       | 1.456285
> 9000B   | 64MB  | 1000000       | 0.894877
> 9000B   | 128MB | 1000000       | 0.885387
> 9000B   | 256MB | 1000000       | 0.883293
> 9000B   | 512MB | 1000000       | 0.886462
> 64KB    | 64MB  | 1000000       | 0.815036
> 64KB    | 128MB | 1000000       | 0.801962
> 64KB    | 256MB | 1000000       | 0.797618
> 64KB    | 512MB | 1000000       | 0.795138
> 
> 6 cache lines:
> len	| set	| iterations	| cycles/byte
> ========|=======|===============|=============
> 1500B   | 64MB  | 1000000       | 1.439609
> 1500B   | 128MB | 1000000       | 1.437569
> 1500B   | 256MB | 1000000       | 1.441776
> 1500B   | 512MB | 1000000       | 1.455362
> 9000B   | 64MB  | 1000000       | 0.895242
> 9000B   | 128MB | 1000000       | 0.886149
> 9000B   | 256MB | 1000000       | 0.881375
> 9000B   | 512MB | 1000000       | 0.884610
> 64KB    | 64MB  | 1000000       | 0.814658
> 64KB    | 128MB | 1000000       | 0.804124
> 64KB    | 256MB | 1000000       | 0.798143
> 64KB    | 512MB | 1000000       | 0.795377
> 
> 10 cache lines:
> len	| set	| iterations	| cycles/byte
> ========|=======|===============|=============
> 1500B   | 64MB  | 1000000       | 1.431512
> 1500B   | 128MB | 1000000       | 1.431805
> 1500B   | 256MB | 1000000       | 1.430388
> 1500B   | 512MB | 1000000       | 1.464370
> 9000B   | 64MB  | 1000000       | 0.893922
> 9000B   | 128MB | 1000000       | 0.887852
> 9000B   | 256MB | 1000000       | 0.882711
> 9000B   | 512MB | 1000000       | 0.890067
> 64KB    | 64MB  | 1000000       | 0.814890
> 64KB    | 128MB | 1000000       | 0.801470
> 64KB    | 256MB | 1000000       | 0.796658
> 64KB    | 512MB | 1000000       | 0.794266
> 
> 20 cache lines:
> len	| set	| iterations	| cycles/byte
> ========|=======|===============|=============
> 1500B   | 64MB  | 1000000       | 1.455539
> 1500B   | 128MB | 1000000       | 1.443117
> 1500B   | 256MB | 1000000       | 1.436739
> 1500B   | 512MB | 1000000       | 1.458973
> 9000B   | 64MB  | 1000000       | 0.898470
> 9000B   | 128MB | 1000000       | 0.886110
> 9000B   | 256MB | 1000000       | 0.889549
> 9000B   | 512MB | 1000000       | 0.886547
> 64KB    | 64MB  | 1000000       | 0.814665
> 64KB    | 128MB | 1000000       | 0.803252
> 64KB    | 256MB | 1000000       | 0.797268
> 64KB    | 512MB | 1000000       | 0.794830
> 
> 
> 
> 
