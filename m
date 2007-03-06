From: Sami Farin <7atbggg02@sneakemail.com>
Subject: Re: [RFC] div64_64 support
Date: Tue, 6 Mar 2007 23:53:49 +0200
Message-ID: <20070306215349.hquin7d6pfy2n5d2@m.safari.iki.fi>
References: <20070223170527.4ca695b2@freekitty> <20070305155714.3abe1b5e@freekitty> <20070306133404.GA864@one.firstfloor.org> <200703061519.20346.dada1@cosmosbay.com> <20070306144529.GA2004@one.firstfloor.org> <84C47260-4B57-4568-8197-58F438A6F737@e18.physik.tu-muenchen.de> <20070306102941.32471d57@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030266AbXCFVxx@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070306102941.32471d57@freekitty>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 10:29:41 -0800, Stephen Hemminger wrote:
> Don't count the existing Newton-Raphson out. It turns out that to get enough
> precision for 32 bits, only 4 iterations are needed. By unrolling those, it
> gets much better timing.
> 
> Slightly gross test program (with original cubic wraparound bug fixed).
...
> 	{~0, 2097151},
             ^^^^^^^
this should be 2642245.

Without serializing instruction before rdtsc and with one loop
I do not get very accurate results (104 for ncubic, > 1000 for others).

#define rdtscll_serialize(val) \
  __asm__ __volatile__("movl $0, %%eax\n\tcpuid\n\trdtsc\n" : "=A" (val) : : "ebx", "ecx")

Here Pentium D timings for 1000 loops. 

~0, 2097151

Function     clocks mean(us)  max(us)  std(us) total error
ocubic          912    0.306   20.317    0.730      545101
ncubic          777    0.261   14.799    0.486      576263
acbrt          1168    0.392   21.681    0.547      547562
hcbrt           827    0.278   15.244    0.387        2410

~0, 2642245

Function     clocks mean(us)  max(us)  std(us) total error
ocubic          908    0.305   20.210    0.656           7
ncubic          775    0.260   14.792    0.550       31169
acbrt          1176    0.395   22.017    0.970        2468
hcbrt           826    0.278   15.326    0.670      547504

And I found bug in gcc-4.1.2, it gave 0 for ncubic results
when doing 1000 loops test... gcc-4.0.3 works.

-- 
