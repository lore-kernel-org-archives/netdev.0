From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Mon, 26 Oct 2009 18:37:31 +0530
Message-ID: <OF703F980D.0971407E-ON6525765B.00458CCA-6525765B.00481976@in.ibm.com>
References: <200910252158.53921.opurdila@ixiacom.com> <4AE4C1FA.7000002@gmail.com> <200910252355.32640.opurdila@ixiacom.com> <20091025224153.GB20987@nuttenaction> <4AE53382.8020308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:36480 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754389AbZJZNIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 09:08:24 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9QD8Q7j013080
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2009 18:38:26 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9QD8QIw1851408
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2009 18:38:26 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9QD8PHO008152
	for <netdev@vger.kernel.org>; Tue, 27 Oct 2009 00:08:26 +1100
In-Reply-To: <4AE53382.8020308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote on 10/26/2009 10:58:34 AM:

> In fact, new10 should be the 'perfect' hash for the "eth%d"
> netdev use, not jhash (way more expensive in cpu cycles BTW)
>
> Most linux machines in the world have less than 10 interfaces, jhash
> would be really overkill.
>
>
> Thanks
>
>
> [PATCH net-next-2.6] netdev: better dev_name_hash

Changing Eric's test program to pass a multiplier to string_hash()
and calling string_hash with multipler=<2 - 63> confirms that 10
is almost always the best number for varying netdev names. I print
the number of times perfect 64 was scored, and for most passed
device names, the best is for n=10, followed by n=5 and others.
Almost the worst was n=31, slightly better was n=17.

But other variables matter too, like fewer entries (4K or 1K) but
above values for are still better compared to n=31.

Thanks,

- KK

#include <stdio.h>
#include <string.h>

#define NUM_ENTRIES 1024

static inline unsigned int
string_hash_n(const unsigned char *name, unsigned int len, int n)
{
        unsigned hash = 0;
        int i;

        for (i = 0; i < len; ++i)
                hash = n * hash + name[i];
        return hash;
}

int best_n = -1, best_n_val = -1;

void print_dist(unsigned int *dist, int n)
{
        unsigned int i;
        int perfect = 0;


printf("-----------------------------------------------------------\n");
        printf("n=%d[] = {\n", n);
        for (i = 0; i < 256; i++) {
                if (dist[i] == NUM_ENTRIES/256)
                        perfect++;
                printf("%d, ", dist[i]);
                if ((i & 15) == 15) putchar('\n');
        }
        if (perfect > best_n_val) {
                best_n_val = perfect;
                best_n = n;
        }
        printf("}; (PERFECT = %d (n=%d))\n", perfect, n);
}

int main(int argc, char *argv[])
{
        int n, i;
        char *str, name[16];
        unsigned int hash, hashdist[256];

        if (argc == 1)
                str="eth";
        else
                str=argv[1];

        for (n = 2; n < 63; n++) {
                memset(hashdist, 0, 256*sizeof(int));
                for (i = 0; i < NUM_ENTRIES; i++) {
                        unsigned int len = sprintf(name, "%s%d", str, i);

                        hash = string_hash_n(name, len, n);
                        hashdist[hash & 255]++;
                }
                print_dist(hashdist, n);
        }
        printf("Best N was %d, and perfect entries: %d\n",
                best_n, best_n_val);
        return 0;
}

