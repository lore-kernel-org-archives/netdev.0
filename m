From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Tue, 20 Feb 2007 13:42:42 -0500
Message-ID: <20070220184242.GA30077@filer.fsl.cs.sunysb.edu>
References: <20070219231447.GA4400@outpost.ds9a.nl> <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl> <20070220164124.GA24930@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bert hubert <bert.hubert@netherlabs.nl>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2]:41632 "EHLO
	filer.fsl.cs.sunysb.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030301AbXBTSn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 13:43:29 -0500
Content-Disposition: inline
In-Reply-To: <20070220164124.GA24930@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 07:41:25PM +0300, Evgeniy Polyakov wrote:
> On Tue, Feb 20, 2007 at 05:27:14PM +0100, bert hubert (bert.hubert@netherlabs.nl) wrote:
> > I've done so, with some interesting results. Source on
> > http://ds9a.nl/tmp/recvtimings.c - be careful to adjust the '3000' divider
> > to your CPU frequency if you care about absolute numbers!
> > 
> > These are two groups, each consisting of 10 consecutive nonblocking UDP
> > recvfroms, with 10 packets preloaded. Reported is the number of microseconds
> > per recvfrom call which yielded a packet:
> > 
> > $ ./recvtimings
> > 4.142333
> 
> It can be recvfrom only problem - syscall overhead on my p4 (core duo,
> debian testing) is bout 300 usec - to test I ran 
> read('dev/zero', &data, 0)
> in a loop.
 
A better thing would be to use getuid - it turns into just a return with a
memory dereference). I ran it on my 3.06GHz P4 (HT, but only UP kernel),
PREEMPT, HZ=1000...

3.290196 0.470588 0.402614 0.396078 0.393464 0.396078 0.386928 0.386928 0.386928 0.386928
0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928
0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928
0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928 0.386928

I used the rdtsc instruction to measure the time for the getuid syscall (see
bellow for source to the test app).
 
---8<-------------
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>

/* CPU speed in MHz */
#define CPUFREQ 3060

#define rdtscll(val) \
      __asm__ __volatile__("rdtsc" : "=A" (val))

int main()
{
	unsigned long long start, end;
	int i;

	for(i=0;i<10000;i++) {
		rdtscll(start);
		getuid();
		rdtscll(end);

		printf("delta for syscall: %llu cycles = %f us\n", end-start, (end-start)/(float)CPUFREQ);
	}

	return 0;
}
---8<-------------

Josef "Jeff" Sipek.

-- 
Research, n.:
  Consider Columbus:
    He didn't know where he was going.
    When he got there he didn't know where he was.
    When he got back he didn't know where he had been.
    And he did it all on someone else's money.
