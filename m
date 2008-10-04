From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 00/32] Swap over NFS - v19
Date: Sun,  5 Oct 2008 00:05:05 +0900 (JST)
Message-ID: <20081004232549.CE53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081002124748.638c95ff.akpm@linux-foundation.org> <20081003153810.5dd0a33e@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
To: Rik van Riel <riel@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:52137 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbYJDPFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 11:05:09 -0400
In-Reply-To: <20081003153810.5dd0a33e@bree.surriel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

> Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Thu, 02 Oct 2008 15:05:04 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > 
> > > Let's get this ball rolling...
> > 
> > I don't think we're really able to get any MM balls rolling until we
> > get all the split-LRU stuff landed.  Is anyone testing it?  Is it good?
> 
> I've done some testing on it on my two test systems and have not
> found performance regressions against the mainline VM.
> 
> As for stability, I think we have done enough testing to conclude
> that it is stable by now.

Also my experience doesn't found any regression.
and in my experience, split-lru patch increase performance stability.

What is performance stability?
example, HPC parallel compution use many process and communication
each other.
Then, the system performance is decided by most slow process.

So, peek and average performance isn't only important, but also
worst case performance is important.

Especially, split-lru outperform mainline in anon and file mixed workload.


example, I ran himeno benchmark.
(this is one of most famous hpc benchmark in japan, this benchmark
 do matrix calculation on large memory (= use anon only))

machine
-------------
CPU IA64 x8
MEM 8G

benchmark setting
----------------
# of parallel: 4
use mem:  1.7G x4 (used nealy total mem)


first:
result of when other process stoped  (Unit: MFLOPS)
               
              each process
              result
               1    2    3    4    worst average
---------------------------------------------------------
2.6.27-rc8:   217  213  217  154   154   200
mmotm 02 Oct: 217  214  217  217   214   216

ok, these are the almost same


next:
result of when another io process running (Unit: MFLOPS)
(*) infinite loop of dd command used

               each process
               result
               1    2    3    4    worst  average
---------------------------------------------------------
2.6.27-rc8:    34  205   69  196    34     126
mmotm 02 Oct: 162  179  146  178   146     166


Wow, worst case is significant difference.
(this result is reprodusable)

because reclaim processing of mainline VM is too slow.
then, the process of calling direct reclaim is decreased performance largely.


this characteristics is not useful for hpc, but also useful for desktop.
because if X server (or another critical process) call direct reclaim, 
it can strike end-user-experience easily.


yup,
I know many people want to other benchmark result too.
I'll try to mesure other bench at next week.



