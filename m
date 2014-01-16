From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] reciprocal_divide: correction/update of
 the algorithm
Date: Wed, 15 Jan 2014 19:07:26 -0800
Message-ID: <1389841646.31367.391.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389828228-30312-1-git-send-email-dborkman@redhat.com>
	 <1389828228-30312-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Austin S Hemmelgarn <ahferroin7@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Matt Mackall <mpm@selenic.com>,
	Pekka Enberg <penberg@kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389828228-30312-3-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-01-16 at 00:23 +0100, Daniel Borkmann wrote:

> Also, reciprocal_value() and reciprocal_divide() always return 0
> for divisions by 1. This is a bit worrisome as those functions
> also get used in mm/slab.c and lib/flex_array.c, apparently for
> index calculation to access array slots. 

Hi Daniel

This off-by-one limitation is a known one,
and mm/slab.c does not have an issue with it because :

- Minimal object size is not 1 byte, but 8 (or maybe 4)
- We always divide a multiple of the divisor,
  so there is no off-by-one effect.

Little attached prog does a brute force check if needed.

So far, the only relevant issue was about BPF, and a better
documentation of reciprocal_divide() use cases.

(I let Jesse comment on the flex_array case)

I am unsure we want to 'fix' things, we tried hard in the past to avoid
divides, so the ones we use are usually because the divisor is not
constant, so the reciprocal doesn't help.

(BPF is fixed in David tree)

Thanks !

#include <stdio.h>

typedef unsigned int u32;
typedef unsigned long long u64;

static u32 reciprocal_value(u32 k)
{
	u64 val = (1LL << 32) + (k - 1);
	val /= k;
	return (u32)val;
}

static inline u32 reciprocal_divide(u32 A, u32 R)
{
	return (u32)(((u64)A * R) >> 32);
}

#define LIMIT 1000*1000*1000

int main()
{
	u32 divisor, dividend, reciprocal, next;
	int res = 0;

	for (divisor = 2; divisor < LIMIT; divisor++) {
		reciprocal = reciprocal_value(divisor);
		for (dividend = 0; ; dividend = next) {
			if (reciprocal_divide(dividend, reciprocal) != (dividend / divisor)) {
				printf("Arg: %u/%u was not properly computed (%u/%u)\n",
					dividend, divisor,
					reciprocal_divide(dividend, reciprocal),
					dividend / divisor);
				res = 1;
				break;
			}
			next = dividend + divisor;
			if (next < dividend)
				break;
		}
	}
	return res;
}
