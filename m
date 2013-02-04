From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] inet: Get critical word in first 64bit of
 cache line
Date: Sun, 03 Feb 2013 16:18:29 -0800
Message-ID: <1359937109.30177.128.camel@edumazet-glaptop>
References: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com>
	 <1359817435.30177.70.camel@edumazet-glaptop>
	 <20130203.160855.1118626925419072868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ling.ma.program@gmail.com, netdev@vger.kernel.org, maze@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:34370 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928Ab3BDASc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 19:18:32 -0500
Received: by mail-da0-f41.google.com with SMTP id e20so2392571dak.14
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 16:18:31 -0800 (PST)
In-Reply-To: <20130203.160855.1118626925419072868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-02-03 at 16:08 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 02 Feb 2013 07:03:55 -0800
> 
> > From: Ma Ling <ling.ma.program@gmail.com>
> > 
> > In order to reduce memory latency when last level cache miss occurs,
> > modern CPUs i.e. x86 and arm introduced Critical Word First(CWF) or
> > Early Restart(ER) to get data ASAP. For CWF if critical word is first
> > member
> > in cache line, memory feed CPU with critical word, then fill others
> > data in cache line one by one, otherwise after critical word it must
> > cost more cycle to fill the remaining cache line. For Early First CPU
> > will restart until critical word in cache line reaches.
> > 
> > Hash value is critical word, so in this patch we place it as first
> > member in cache line (sock address is cache-line aligned), and it is
> > also good for Early Restart platform as well .
> > 
> > [edumazet: respin on net-next after commit ce43b03e8889]
> > 
> > Signed-off-by: Ma Ling <ling.ma.program@gmail.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> I completely agree with the other response to this patch in that
> the description is bogus.
> 
> If CWF is implemented in the cpu, it should exactly relieve us from
> having to move things around in structures so carefully like this.
> 
> Either the patch should be completely dropped (modern cpus don't
> need this) or the commit message changed to reflect reality.
> 
> It really makes a terrible impression upon me when the patch says
> something which in fact is 180 degrees from reality.

Hmm. 

Maybe the changelog is misleading, or maybe all the performance gains I
have from this patch are probably some artifact or old/bad hardware, or
something else.



(Intel(R) Xeon(R) CPU           X5660  @ 2.80GHz)
# ./cwf
looking-up aligned time 108712072, 
looking-up unaligned time 113268256
looking-up aligned time 108677032, 
looking-up unaligned time 113297636


(Intel(R) Xeon(R) CPU           X5679  @ 3.20GHz)
# ./cwf
looking-up aligned time 139193589, 
looking-up unaligned time 144307821
looking-up aligned time 139136787, 
looking-up unaligned time 144277752

My laptop : Intel(R) Core(TM) i5-2520M CPU @ 2.50GHz
# ./cwf
looking-up aligned time 84869203, 
looking-up unaligned time 86843462
looking-up aligned time 84253003, 
looking-up unaligned time 86227675

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define CACHELINE_SZ 64L

#define BIGBUFFER_SZ (64<<20)

# define HP_TIMING_NOW(Var) \
 ({ unsigned long long _hi, _lo; \
  asm volatile ("rdtsc" : "=a" (_lo), "=d" (_hi)); \
  (Var) = _hi << 32 | _lo; })

#define repeat_times  20

char *bufzap;

static void zap_cache(void)
{
	memset(bufzap, 2, BIGBUFFER_SZ);
	memset(bufzap, 3, BIGBUFFER_SZ);
	memset(bufzap, 4, BIGBUFFER_SZ);
}

static char *init_buf(void)
{
	void *res;

	if (posix_memalign(&res, CACHELINE_SZ, BIGBUFFER_SZ)) {
		fprintf(stderr, "malloc() failed");
	        exit(1);
	}

	memset(res, 1, BIGBUFFER_SZ);
	return res;
}

unsigned long total;

static unsigned long random_access(void *buffer,
				   unsigned int off1,
				   unsigned int off2,
				   unsigned int off3)
{
	int i;
	unsigned int n;
	unsigned long sum = 0;
	unsigned long *ptr;

	srandom(7777);
	for (i = 0; i < 1000000; i++) {
		n = random() % (BIGBUFFER_SZ/CACHELINE_SZ);
		ptr = buffer + n*CACHELINE_SZ;
		if (ptr[off1])
			sum++;
		if (ptr[off2])
			sum++;
//		if (ptr[off3])
//			sum++;
	}
	total += sum;
	return sum;
}

static unsigned long test_lookup_time(void *buf, 
				unsigned int off1,
				unsigned int off2,
				unsigned int off3)
{
        unsigned long i, start, end, best_time = ~0;

        for (i = 0; i < repeat_times; i++) {
		zap_cache();
                HP_TIMING_NOW(start);
                random_access(buf, off1, off2, off3);
                HP_TIMING_NOW(end);
                if (best_time > (end - start))
                        best_time = (end - start);
        }

        return best_time;

}

int main(int argc, char *argv[])
{
        char *buf;
        unsigned long aligned_time, unaligned_time;

        buf = init_buf();
        bufzap = init_buf();

        aligned_time = test_lookup_time(buf, 0, 2, 4);
        unaligned_time = test_lookup_time(buf, 4, 2, 0);

        printf("looking-up aligned time %lu, \nlooking-up unaligned time %lu\n", aligned_time, unaligned_time);

        aligned_time = test_lookup_time(buf, 0, 2, 4);
        unaligned_time = test_lookup_time(buf, 4, 2, 0);

        printf("looking-up aligned time %lu, \nlooking-up unaligned time %lu\n", aligned_time, unaligned_time);
}
