From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Tue, 9 Feb 2016 10:48:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCDBCA5@AcuExch.aculab.com>
References: <20160208201234.8569.qmail@ns.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "mingo@kernel.org" <mingo@kernel.org>
To: 'George Spelvin' <linux@horizon.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tom@herbertland.com" <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160208201234.8569.qmail@ns.horizon.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Spelvin [mailto:linux@horizon.com]
> Sent: 08 February 2016 20:13
> David Laight wrote:
> > I'd need convincing that unrolling the loop like that gives any significant gain.
> > You have a dependency chain on the carry flag so have delays between the 'adcq'
> > instructions (these may be more significant than the memory reads from l1 cache).
> 
> If the carry chain is a bottleneck, on Broadwell+ (feature flag
> X86_FEATURE_ADX), there are the ADCX and ADOX instructions, which use
> separate flag bits for their carry chains and so can be interleaved.
> 
> I don't have such a machine to test on, but if someone who does
> would like to do a little benchmarking, that would be an interesting
> data point.
> 
> Unfortunately, that means yet another version of the main loop,
> but if there's a significant benefit...

Well, the only part actually worth writing in assembler is the 'adc' loop.
So run-time substitution of separate versions (as is done for memcpy())
wouldn't be hard.

Since adcx and adox must execute in parallel I clearly need to re-remember
how dependencies against the flags register work. I'm sure I remember
issues with 'false dependencies' against the flags.

However you still need a loop construct that doesn't modify 'o' or 'c'.
Using leal, jcxz, jmp might work.
(Unless broadwell actually has a fast 'loop' instruction.)

(I've not got a suitable test cpu.)

	David
