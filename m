From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: DomU's network interface will hung when Dom0 running 32bit
Date: Wed, 16 Oct 2013 15:35:43 +0800
Message-ID: <525E41CF.7090008@oracle.com>
References: <52590DFE.6080203@oracle.com> <20131014111958.GE11739@zion.uk.xensource.com> <525CAC21.5040202@oracle.com> <1381826609.24708.135.camel@kazak.uk.xensource.com> <525D0C41.2080407@oracle.com> <20131015100624.GB29436@zion.uk.xensource.com> <525D2667.6040102@oracle.com> <20131015125802.GR11739@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050000090806030908000904"
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	ANNIE LI <annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:22594 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379Ab3JPHf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 03:35:58 -0400
In-Reply-To: <20131015125802.GR11739@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050000090806030908000904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


On 2013-10-15 20:58, Wei Liu wrote:
> On Tue, Oct 15, 2013 at 07:26:31PM +0800, jianhai luan wrote:
> [...]
>>>>> Can you propose a patch?
>>>> Because credit_timeout.expire always after jiffies, i judge the
>>>> value over the range of time_after_eq() by time_before(now,
>>>> vif->credit_timeout.expires). please check the patch.
>>> I don't think this really fix the issue for you. You still have chance
>>> that now wraps around and falls between expires and next_credit. In that
>>> case it's stalled again.
>> if time_before(now, vif->credit_timeout.expires) is true, time wrap
>> and do operation. Otherwise time_before(now,
>> vif->credit_timeout.expires) isn't true, now -
>> vif->credit_timeout.expires should be letter than ULONG_MAX/2.
>> Because next_credit large than vif->credit_timeout.expires
>> (next_crdit = vif->credit_timeout.expires +
>> msecs_to_jiffies(vif->credit_usec/1000)), the delta between now and
>> next_credit should be in range of time_after_eq().  So
>> time_after_eq() do correctly judge.
>>
> Not sure I understand you. Consider "now" is placed like this:
>
>     expires   now   next_credit
>     ----time increases this direction--->
>
> * time_after_eq(now, next_credit) -> false
> * time_before(now, expires) -> false
>
> Then it's stuck again. You're merely narrowing the window, not fixing
> the real problem.

The above environment isn't stack again. The netback will pending one 
timer to process the environment.

The attachment program will prove if !(time_after_eq(now, next_credit) 
|| time_before(now, vif->credit_timeout.expires)), now will only be 
placed in  above environment [ expires next_credit),  and the above 
environment will be processed by timer in soon.
>
> Wei.
>
>> Jason
>>> Wei.
Jason.

--------------050000090806030908000904
Content-Type: text/plain; charset=gb18030;
 name="main.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="main.c"

#include <stdio.h>

#define typecheck(type,x) \
({	type __dummy; \
	typeof(x) __dummy2; \
	(void)(&__dummy == &__dummy2); \
	1; \
})

#define time_after(a, b)		\
	(typecheck(unsigned char, a) && \
	 typecheck(unsigned char, b) && \
	 ((char)((b) - (a)) < 0))
#define time_before(a,b)	time_after(b,a)

#define time_after_eq(a,b)		\
	(typecheck(unsigned char, a) && \
	 typecheck(unsigned char, b) && \
	 ((char)((a) -(b)) >= 0))
#define time_before_eq(a, b) time_after_eq(b,a)

void do_nothing()
{
	return;
}

int main()
{
	unsigned char expire, now, next;
	unsigned char delta = 10;
	int i, j;

	for(i = 0; i < 256; i++) {
		expire = i;
		next = expire + delta;

		printf("\n\n\n[%u ... %u]\n", expire, next);
		now = expire;
		for(j=0; j < 1024; j++, now++) {	
			if(j%256 == 0) printf("\n");

			if (time_after_eq(now, next) ||
				time_before(now, expire)) {
				do_nothing();
			}
			else {
				printf("    now=%d\n", (char)now);
			}
		}
	}
	
	return 0;
}

--------------050000090806030908000904--
