From: Ling Ma <ling.ma.program@gmail.com>
Subject: Re: [PATCH v2 net-next] inet: Get critical word in first 64bit of
 cache line
Date: Mon, 4 Feb 2013 10:53:06 +0800
Message-ID: <CAOGi=dO-_MedVNvNy=+VyKXG2D=Mat8=Vyr-CttxcrNFO0Vt5Q@mail.gmail.com>
References: <1353900555-5966-1-git-send-email-ling.ma.program@gmail.com>
	<1359817435.30177.70.camel@edumazet-glaptop>
	<20130203.160855.1118626925419072868.davem@davemloft.net>
	<1359937109.30177.128.camel@edumazet-glaptop>
	<1359937509.30177.131.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b6d88da48859404d4dd311f
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	maze@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:38385 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753822Ab3BDCxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Feb 2013 21:53:10 -0500
Received: by mail-qa0-f54.google.com with SMTP id hg5so1082420qab.13
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 18:53:09 -0800 (PST)
In-Reply-To: <1359937509.30177.131.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b6d88da48859404d4dd311f
Content-Type: text/plain; charset=ISO-8859-1

I attached my test program(we force all cpu loads issue one by one ,
and avoid cpu hardwre prefetch cc -o test-cwf test-cwf.c.) and
cpu-info, the result from ./test-cwf  indicates as below:
looking-up aligned time 157000272, looking-up unaligned time 162652724
If I was wrong please correct me.

Thanks
Ling


2013/2/4, Eric Dumazet <eric.dumazet@gmail.com>:
> On Sun, 2013-02-03 at 16:18 -0800, Eric Dumazet wrote:
>> On Sun, 2013-02-03 at 16:08 -0500, David Miller wrote:
>> > From: Eric Dumazet <eric.dumazet@gmail.com>
>> > Date: Sat, 02 Feb 2013 07:03:55 -0800
>> >
>> > > From: Ma Ling <ling.ma.program@gmail.com>
>> > >
>> > > In order to reduce memory latency when last level cache miss occurs,
>> > > modern CPUs i.e. x86 and arm introduced Critical Word First(CWF) or
>> > > Early Restart(ER) to get data ASAP. For CWF if critical word is first
>> > > member
>> > > in cache line, memory feed CPU with critical word, then fill others
>> > > data in cache line one by one, otherwise after critical word it must
>> > > cost more cycle to fill the remaining cache line. For Early First CPU
>> > > will restart until critical word in cache line reaches.
>> > >
>> > > Hash value is critical word, so in this patch we place it as first
>> > > member in cache line (sock address is cache-line aligned), and it is
>> > > also good for Early Restart platform as well .
>> > >
>> > > [edumazet: respin on net-next after commit ce43b03e8889]
>> > >
>> > > Signed-off-by: Ma Ling <ling.ma.program@gmail.com>
>> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> >
>> > I completely agree with the other response to this patch in that
>> > the description is bogus.
>> >
>> > If CWF is implemented in the cpu, it should exactly relieve us from
>> > having to move things around in structures so carefully like this.
>> >
>> > Either the patch should be completely dropped (modern cpus don't
>> > need this) or the commit message changed to reflect reality.
>> >
>> > It really makes a terrible impression upon me when the patch says
>> > something which in fact is 180 degrees from reality.
>>
>> Hmm.
>>
>> Maybe the changelog is misleading, or maybe all the performance gains I
>> have from this patch are probably some artifact or old/bad hardware, or
>> something else.
>>
>>
>>
>> (Intel(R) Xeon(R) CPU           X5660  @ 2.80GHz)
>> # ./cwf
>> looking-up aligned time 108712072,
>> looking-up unaligned time 113268256
>> looking-up aligned time 108677032,
>> looking-up unaligned time 113297636
>>
>>
>> (Intel(R) Xeon(R) CPU           X5679  @ 3.20GHz)
>> # ./cwf
>> looking-up aligned time 139193589,
>> looking-up unaligned time 144307821
>> looking-up aligned time 139136787,
>> looking-up unaligned time 144277752
>>
>> My laptop : Intel(R) Core(TM) i5-2520M CPU @ 2.50GHz
>> # ./cwf
>> looking-up aligned time 84869203,
>> looking-up unaligned time 86843462
>> looking-up aligned time 84253003,
>> looking-up unaligned time 86227675
>>
>> #include <stdio.h>
>> #include <string.h>
>> #include <stdlib.h>
>> #include <unistd.h>
>>
>> #define CACHELINE_SZ 64L
>>
>> #define BIGBUFFER_SZ (64<<20)
>>
>> # define HP_TIMING_NOW(Var) \
>>  ({ unsigned long long _hi, _lo; \
>>   asm volatile ("rdtsc" : "=a" (_lo), "=d" (_hi)); \
>>   (Var) = _hi << 32 | _lo; })
>>
>> #define repeat_times  20
>>
>> char *bufzap;
>>
>> static void zap_cache(void)
>> {
>> 	memset(bufzap, 2, BIGBUFFER_SZ);
>> 	memset(bufzap, 3, BIGBUFFER_SZ);
>> 	memset(bufzap, 4, BIGBUFFER_SZ);
>> }
>>
>> static char *init_buf(void)
>> {
>> 	void *res;
>>
>> 	if (posix_memalign(&res, CACHELINE_SZ, BIGBUFFER_SZ)) {
>> 		fprintf(stderr, "malloc() failed");
>> 	        exit(1);
>> 	}
>>
>> 	memset(res, 1, BIGBUFFER_SZ);
>> 	return res;
>> }
>>
>> unsigned long total;
>>
>> static unsigned long random_access(void *buffer,
>> 				   unsigned int off1,
>> 				   unsigned int off2,
>> 				   unsigned int off3)
>> {
>> 	int i;
>> 	unsigned int n;
>> 	unsigned long sum = 0;
>> 	unsigned long *ptr;
>>
>> 	srandom(7777);
>> 	for (i = 0; i < 1000000; i++) {
>> 		n = random() % (BIGBUFFER_SZ/CACHELINE_SZ);
>> 		ptr = buffer + n*CACHELINE_SZ;
>> 		if (ptr[off1])
>> 			sum++;
>> 		if (ptr[off2])
>> 			sum++;
>> //		if (ptr[off3])
>> //			sum++;
>
> Hmm, I don't know why I left a comment on these two lines...
>
> Of course, results are a bit different removing the comments :
>
> looking-up aligned time 113601316,
> looking-up unaligned time 115964760
> looking-up aligned time 113698636,
> looking-up unaligned time 115986072
>
> More testing is probably needed.
>
>
>

--047d7b6d88da48859404d4dd311f
Content-Type: text/plain; charset=US-ASCII; name=cpu-info
Content-Disposition: attachment; filename=cpu-info
Content-Transfer-Encoding: base64
X-Attachment-Id: file2

cHJvY2Vzc29yCTogMAp2ZW5kb3JfaWQJOiBHZW51aW5lSW50ZWwKY3B1IGZhbWlseQk6IDYKbW9k
ZWwJCTogNDQKbW9kZWwgbmFtZQk6IEludGVsKFIpIFhlb24oUikgQ1BVICAgICAgICAgICBFNTYy
MCAgQCAyLjQwR0h6CnN0ZXBwaW5nCTogMgptaWNyb2NvZGUJOiAweDEwCmNwdSBNSHoJCTogMjQw
MC4xNTMKY2FjaGUgc2l6ZQk6IDEyMjg4IEtCCnBoeXNpY2FsIGlkCTogMApzaWJsaW5ncwk6IDgK
Y29yZSBpZAkJOiAwCmNwdSBjb3Jlcwk6IDQKYXBpY2lkCQk6IDAKaW5pdGlhbCBhcGljaWQJOiAw
CmZwdQkJOiB5ZXMKZnB1X2V4Y2VwdGlvbgk6IHllcwpjcHVpZCBsZXZlbAk6IDExCndwCQk6IHll
cwpmbGFncwkJOiBmcHUgdm1lIGRlIHBzZSB0c2MgbXNyIHBhZSBtY2UgY3g4IGFwaWMgc2VwIG10
cnIgcGdlIG1jYSBjbW92IHBhdCBwc2UzNiBjbGZsdXNoIGR0cyBhY3BpIG1teCBmeHNyIHNzZSBz
c2UyIHNzIGh0IHRtIHBiZSBzeXNjYWxsIG54IHBkcGUxZ2IgcmR0c2NwIGxtIGNvbnN0YW50X3Rz
YyBhcmNoX3BlcmZtb24gcGVicyBidHMgcmVwX2dvb2Qgbm9wbCB4dG9wb2xvZ3kgbm9uc3RvcF90
c2MgYXBlcmZtcGVyZiBwbmkgcGNsbXVscWRxIGR0ZXM2NCBtb25pdG9yIGRzX2NwbCB2bXggc214
IGVzdCB0bTIgc3NzZTMgY3gxNiB4dHByIHBkY20gcGNpZCBkY2Egc3NlNF8xIHNzZTRfMiBwb3Bj
bnQgYWVzIGxhaGZfbG0gYXJhdCBlcGIgZHRoZXJtIHRwcl9zaGFkb3cgdm5taSBmbGV4cHJpb3Jp
dHkgZXB0IHZwaWQKYm9nb21pcHMJOiA0ODAwLjMwCmNsZmx1c2ggc2l6ZQk6IDY0CmNhY2hlX2Fs
aWdubWVudAk6IDY0CmFkZHJlc3Mgc2l6ZXMJOiA0MCBiaXRzIHBoeXNpY2FsLCA0OCBiaXRzIHZp
cnR1YWwKcG93ZXIgbWFuYWdlbWVudDoKCnByb2Nlc3Nvcgk6IDEKdmVuZG9yX2lkCTogR2VudWlu
ZUludGVsCmNwdSBmYW1pbHkJOiA2Cm1vZGVsCQk6IDQ0Cm1vZGVsIG5hbWUJOiBJbnRlbChSKSBY
ZW9uKFIpIENQVSAgICAgICAgICAgRTU2MjAgIEAgMi40MEdIegpzdGVwcGluZwk6IDIKbWljcm9j
b2RlCTogMHgxMApjcHUgTUh6CQk6IDI0MDAuMTUzCmNhY2hlIHNpemUJOiAxMjI4OCBLQgpwaHlz
aWNhbCBpZAk6IDAKc2libGluZ3MJOiA4CmNvcmUgaWQJCTogMQpjcHUgY29yZXMJOiA0CmFwaWNp
ZAkJOiAyCmluaXRpYWwgYXBpY2lkCTogMgpmcHUJCTogeWVzCmZwdV9leGNlcHRpb24JOiB5ZXMK
Y3B1aWQgbGV2ZWwJOiAxMQp3cAkJOiB5ZXMKZmxhZ3MJCTogZnB1IHZtZSBkZSBwc2UgdHNjIG1z
ciBwYWUgbWNlIGN4OCBhcGljIHNlcCBtdHJyIHBnZSBtY2EgY21vdiBwYXQgcHNlMzYgY2xmbHVz
aCBkdHMgYWNwaSBtbXggZnhzciBzc2Ugc3NlMiBzcyBodCB0bSBwYmUgc3lzY2FsbCBueCBwZHBl
MWdiIHJkdHNjcCBsbSBjb25zdGFudF90c2MgYXJjaF9wZXJmbW9uIHBlYnMgYnRzIHJlcF9nb29k
IG5vcGwgeHRvcG9sb2d5IG5vbnN0b3BfdHNjIGFwZXJmbXBlcmYgcG5pIHBjbG11bHFkcSBkdGVz
NjQgbW9uaXRvciBkc19jcGwgdm14IHNteCBlc3QgdG0yIHNzc2UzIGN4MTYgeHRwciBwZGNtIHBj
aWQgZGNhIHNzZTRfMSBzc2U0XzIgcG9wY250IGFlcyBsYWhmX2xtIGFyYXQgZXBiIGR0aGVybSB0
cHJfc2hhZG93IHZubWkgZmxleHByaW9yaXR5IGVwdCB2cGlkCmJvZ29taXBzCTogNDgwMC4zMApj
bGZsdXNoIHNpemUJOiA2NApjYWNoZV9hbGlnbm1lbnQJOiA2NAphZGRyZXNzIHNpemVzCTogNDAg
Yml0cyBwaHlzaWNhbCwgNDggYml0cyB2aXJ0dWFsCnBvd2VyIG1hbmFnZW1lbnQ6Cgpwcm9jZXNz
b3IJOiAyCnZlbmRvcl9pZAk6IEdlbnVpbmVJbnRlbApjcHUgZmFtaWx5CTogNgptb2RlbAkJOiA0
NAptb2RlbCBuYW1lCTogSW50ZWwoUikgWGVvbihSKSBDUFUgICAgICAgICAgIEU1NjIwICBAIDIu
NDBHSHoKc3RlcHBpbmcJOiAyCm1pY3JvY29kZQk6IDB4MTAKY3B1IE1IegkJOiAyNDAwLjE1Mwpj
YWNoZSBzaXplCTogMTIyODggS0IKcGh5c2ljYWwgaWQJOiAwCnNpYmxpbmdzCTogOApjb3JlIGlk
CQk6IDkKY3B1IGNvcmVzCTogNAphcGljaWQJCTogMTgKaW5pdGlhbCBhcGljaWQJOiAxOApmcHUJ
CTogeWVzCmZwdV9leGNlcHRpb24JOiB5ZXMKY3B1aWQgbGV2ZWwJOiAxMQp3cAkJOiB5ZXMKZmxh
Z3MJCTogZnB1IHZtZSBkZSBwc2UgdHNjIG1zciBwYWUgbWNlIGN4OCBhcGljIHNlcCBtdHJyIHBn
ZSBtY2EgY21vdiBwYXQgcHNlMzYgY2xmbHVzaCBkdHMgYWNwaSBtbXggZnhzciBzc2Ugc3NlMiBz
cyBodCB0bSBwYmUgc3lzY2FsbCBueCBwZHBlMWdiIHJkdHNjcCBsbSBjb25zdGFudF90c2MgYXJj
aF9wZXJmbW9uIHBlYnMgYnRzIHJlcF9nb29kIG5vcGwgeHRvcG9sb2d5IG5vbnN0b3BfdHNjIGFw
ZXJmbXBlcmYgcG5pIHBjbG11bHFkcSBkdGVzNjQgbW9uaXRvciBkc19jcGwgdm14IHNteCBlc3Qg
dG0yIHNzc2UzIGN4MTYgeHRwciBwZGNtIHBjaWQgZGNhIHNzZTRfMSBzc2U0XzIgcG9wY250IGFl
cyBsYWhmX2xtIGFyYXQgZXBiIGR0aGVybSB0cHJfc2hhZG93IHZubWkgZmxleHByaW9yaXR5IGVw
dCB2cGlkCmJvZ29taXBzCTogNDgwMC4zMApjbGZsdXNoIHNpemUJOiA2NApjYWNoZV9hbGlnbm1l
bnQJOiA2NAphZGRyZXNzIHNpemVzCTogNDAgYml0cyBwaHlzaWNhbCwgNDggYml0cyB2aXJ0dWFs
CnBvd2VyIG1hbmFnZW1lbnQ6Cgpwcm9jZXNzb3IJOiAzCnZlbmRvcl9pZAk6IEdlbnVpbmVJbnRl
bApjcHUgZmFtaWx5CTogNgptb2RlbAkJOiA0NAptb2RlbCBuYW1lCTogSW50ZWwoUikgWGVvbihS
KSBDUFUgICAgICAgICAgIEU1NjIwICBAIDIuNDBHSHoKc3RlcHBpbmcJOiAyCm1pY3JvY29kZQk6
IDB4MTAKY3B1IE1IegkJOiAyNDAwLjE1MwpjYWNoZSBzaXplCTogMTIyODggS0IKcGh5c2ljYWwg
aWQJOiAwCnNpYmxpbmdzCTogOApjb3JlIGlkCQk6IDEwCmNwdSBjb3Jlcwk6IDQKYXBpY2lkCQk6
IDIwCmluaXRpYWwgYXBpY2lkCTogMjAKZnB1CQk6IHllcwpmcHVfZXhjZXB0aW9uCTogeWVzCmNw
dWlkIGxldmVsCTogMTEKd3AJCTogeWVzCmZsYWdzCQk6IGZwdSB2bWUgZGUgcHNlIHRzYyBtc3Ig
cGFlIG1jZSBjeDggYXBpYyBzZXAgbXRyciBwZ2UgbWNhIGNtb3YgcGF0IHBzZTM2IGNsZmx1c2gg
ZHRzIGFjcGkgbW14IGZ4c3Igc3NlIHNzZTIgc3MgaHQgdG0gcGJlIHN5c2NhbGwgbnggcGRwZTFn
YiByZHRzY3AgbG0gY29uc3RhbnRfdHNjIGFyY2hfcGVyZm1vbiBwZWJzIGJ0cyByZXBfZ29vZCBu
b3BsIHh0b3BvbG9neSBub25zdG9wX3RzYyBhcGVyZm1wZXJmIHBuaSBwY2xtdWxxZHEgZHRlczY0
IG1vbml0b3IgZHNfY3BsIHZteCBzbXggZXN0IHRtMiBzc3NlMyBjeDE2IHh0cHIgcGRjbSBwY2lk
IGRjYSBzc2U0XzEgc3NlNF8yIHBvcGNudCBhZXMgbGFoZl9sbSBhcmF0IGVwYiBkdGhlcm0gdHBy
X3NoYWRvdyB2bm1pIGZsZXhwcmlvcml0eSBlcHQgdnBpZApib2dvbWlwcwk6IDQ4MDAuMzAKY2xm
bHVzaCBzaXplCTogNjQKY2FjaGVfYWxpZ25tZW50CTogNjQKYWRkcmVzcyBzaXplcwk6IDQwIGJp
dHMgcGh5c2ljYWwsIDQ4IGJpdHMgdmlydHVhbApwb3dlciBtYW5hZ2VtZW50OgoKcHJvY2Vzc29y
CTogNAp2ZW5kb3JfaWQJOiBHZW51aW5lSW50ZWwKY3B1IGZhbWlseQk6IDYKbW9kZWwJCTogNDQK
bW9kZWwgbmFtZQk6IEludGVsKFIpIFhlb24oUikgQ1BVICAgICAgICAgICBFNTYyMCAgQCAyLjQw
R0h6CnN0ZXBwaW5nCTogMgptaWNyb2NvZGUJOiAweDEwCmNwdSBNSHoJCTogMjQwMC4xNTMKY2Fj
aGUgc2l6ZQk6IDEyMjg4IEtCCnBoeXNpY2FsIGlkCTogMApzaWJsaW5ncwk6IDgKY29yZSBpZAkJ
OiAwCmNwdSBjb3Jlcwk6IDQKYXBpY2lkCQk6IDEKaW5pdGlhbCBhcGljaWQJOiAxCmZwdQkJOiB5
ZXMKZnB1X2V4Y2VwdGlvbgk6IHllcwpjcHVpZCBsZXZlbAk6IDExCndwCQk6IHllcwpmbGFncwkJ
OiBmcHUgdm1lIGRlIHBzZSB0c2MgbXNyIHBhZSBtY2UgY3g4IGFwaWMgc2VwIG10cnIgcGdlIG1j
YSBjbW92IHBhdCBwc2UzNiBjbGZsdXNoIGR0cyBhY3BpIG1teCBmeHNyIHNzZSBzc2UyIHNzIGh0
IHRtIHBiZSBzeXNjYWxsIG54IHBkcGUxZ2IgcmR0c2NwIGxtIGNvbnN0YW50X3RzYyBhcmNoX3Bl
cmZtb24gcGVicyBidHMgcmVwX2dvb2Qgbm9wbCB4dG9wb2xvZ3kgbm9uc3RvcF90c2MgYXBlcmZt
cGVyZiBwbmkgcGNsbXVscWRxIGR0ZXM2NCBtb25pdG9yIGRzX2NwbCB2bXggc214IGVzdCB0bTIg
c3NzZTMgY3gxNiB4dHByIHBkY20gcGNpZCBkY2Egc3NlNF8xIHNzZTRfMiBwb3BjbnQgYWVzIGxh
aGZfbG0gYXJhdCBlcGIgZHRoZXJtIHRwcl9zaGFkb3cgdm5taSBmbGV4cHJpb3JpdHkgZXB0IHZw
aWQKYm9nb21pcHMJOiA0ODAwLjMwCmNsZmx1c2ggc2l6ZQk6IDY0CmNhY2hlX2FsaWdubWVudAk6
IDY0CmFkZHJlc3Mgc2l6ZXMJOiA0MCBiaXRzIHBoeXNpY2FsLCA0OCBiaXRzIHZpcnR1YWwKcG93
ZXIgbWFuYWdlbWVudDoKCnByb2Nlc3Nvcgk6IDUKdmVuZG9yX2lkCTogR2VudWluZUludGVsCmNw
dSBmYW1pbHkJOiA2Cm1vZGVsCQk6IDQ0Cm1vZGVsIG5hbWUJOiBJbnRlbChSKSBYZW9uKFIpIENQ
VSAgICAgICAgICAgRTU2MjAgIEAgMi40MEdIegpzdGVwcGluZwk6IDIKbWljcm9jb2RlCTogMHgx
MApjcHUgTUh6CQk6IDI0MDAuMTUzCmNhY2hlIHNpemUJOiAxMjI4OCBLQgpwaHlzaWNhbCBpZAk6
IDAKc2libGluZ3MJOiA4CmNvcmUgaWQJCTogMQpjcHUgY29yZXMJOiA0CmFwaWNpZAkJOiAzCmlu
aXRpYWwgYXBpY2lkCTogMwpmcHUJCTogeWVzCmZwdV9leGNlcHRpb24JOiB5ZXMKY3B1aWQgbGV2
ZWwJOiAxMQp3cAkJOiB5ZXMKZmxhZ3MJCTogZnB1IHZtZSBkZSBwc2UgdHNjIG1zciBwYWUgbWNl
IGN4OCBhcGljIHNlcCBtdHJyIHBnZSBtY2EgY21vdiBwYXQgcHNlMzYgY2xmbHVzaCBkdHMgYWNw
aSBtbXggZnhzciBzc2Ugc3NlMiBzcyBodCB0bSBwYmUgc3lzY2FsbCBueCBwZHBlMWdiIHJkdHNj
cCBsbSBjb25zdGFudF90c2MgYXJjaF9wZXJmbW9uIHBlYnMgYnRzIHJlcF9nb29kIG5vcGwgeHRv
cG9sb2d5IG5vbnN0b3BfdHNjIGFwZXJmbXBlcmYgcG5pIHBjbG11bHFkcSBkdGVzNjQgbW9uaXRv
ciBkc19jcGwgdm14IHNteCBlc3QgdG0yIHNzc2UzIGN4MTYgeHRwciBwZGNtIHBjaWQgZGNhIHNz
ZTRfMSBzc2U0XzIgcG9wY250IGFlcyBsYWhmX2xtIGFyYXQgZXBiIGR0aGVybSB0cHJfc2hhZG93
IHZubWkgZmxleHByaW9yaXR5IGVwdCB2cGlkCmJvZ29taXBzCTogNDgwMC4zMApjbGZsdXNoIHNp
emUJOiA2NApjYWNoZV9hbGlnbm1lbnQJOiA2NAphZGRyZXNzIHNpemVzCTogNDAgYml0cyBwaHlz
aWNhbCwgNDggYml0cyB2aXJ0dWFsCnBvd2VyIG1hbmFnZW1lbnQ6Cgpwcm9jZXNzb3IJOiA2CnZl
bmRvcl9pZAk6IEdlbnVpbmVJbnRlbApjcHUgZmFtaWx5CTogNgptb2RlbAkJOiA0NAptb2RlbCBu
YW1lCTogSW50ZWwoUikgWGVvbihSKSBDUFUgICAgICAgICAgIEU1NjIwICBAIDIuNDBHSHoKc3Rl
cHBpbmcJOiAyCm1pY3JvY29kZQk6IDB4MTAKY3B1IE1IegkJOiAyNDAwLjE1MwpjYWNoZSBzaXpl
CTogMTIyODggS0IKcGh5c2ljYWwgaWQJOiAwCnNpYmxpbmdzCTogOApjb3JlIGlkCQk6IDkKY3B1
IGNvcmVzCTogNAphcGljaWQJCTogMTkKaW5pdGlhbCBhcGljaWQJOiAxOQpmcHUJCTogeWVzCmZw
dV9leGNlcHRpb24JOiB5ZXMKY3B1aWQgbGV2ZWwJOiAxMQp3cAkJOiB5ZXMKZmxhZ3MJCTogZnB1
IHZtZSBkZSBwc2UgdHNjIG1zciBwYWUgbWNlIGN4OCBhcGljIHNlcCBtdHJyIHBnZSBtY2EgY21v
diBwYXQgcHNlMzYgY2xmbHVzaCBkdHMgYWNwaSBtbXggZnhzciBzc2Ugc3NlMiBzcyBodCB0bSBw
YmUgc3lzY2FsbCBueCBwZHBlMWdiIHJkdHNjcCBsbSBjb25zdGFudF90c2MgYXJjaF9wZXJmbW9u
IHBlYnMgYnRzIHJlcF9nb29kIG5vcGwgeHRvcG9sb2d5IG5vbnN0b3BfdHNjIGFwZXJmbXBlcmYg
cG5pIHBjbG11bHFkcSBkdGVzNjQgbW9uaXRvciBkc19jcGwgdm14IHNteCBlc3QgdG0yIHNzc2Uz
IGN4MTYgeHRwciBwZGNtIHBjaWQgZGNhIHNzZTRfMSBzc2U0XzIgcG9wY250IGFlcyBsYWhmX2xt
IGFyYXQgZXBiIGR0aGVybSB0cHJfc2hhZG93IHZubWkgZmxleHByaW9yaXR5IGVwdCB2cGlkCmJv
Z29taXBzCTogNDgwMC4zMApjbGZsdXNoIHNpemUJOiA2NApjYWNoZV9hbGlnbm1lbnQJOiA2NAph
ZGRyZXNzIHNpemVzCTogNDAgYml0cyBwaHlzaWNhbCwgNDggYml0cyB2aXJ0dWFsCnBvd2VyIG1h
bmFnZW1lbnQ6Cgpwcm9jZXNzb3IJOiA3CnZlbmRvcl9pZAk6IEdlbnVpbmVJbnRlbApjcHUgZmFt
aWx5CTogNgptb2RlbAkJOiA0NAptb2RlbCBuYW1lCTogSW50ZWwoUikgWGVvbihSKSBDUFUgICAg
ICAgICAgIEU1NjIwICBAIDIuNDBHSHoKc3RlcHBpbmcJOiAyCm1pY3JvY29kZQk6IDB4MTAKY3B1
IE1IegkJOiAyNDAwLjE1MwpjYWNoZSBzaXplCTogMTIyODggS0IKcGh5c2ljYWwgaWQJOiAwCnNp
YmxpbmdzCTogOApjb3JlIGlkCQk6IDEwCmNwdSBjb3Jlcwk6IDQKYXBpY2lkCQk6IDIxCmluaXRp
YWwgYXBpY2lkCTogMjEKZnB1CQk6IHllcwpmcHVfZXhjZXB0aW9uCTogeWVzCmNwdWlkIGxldmVs
CTogMTEKd3AJCTogeWVzCmZsYWdzCQk6IGZwdSB2bWUgZGUgcHNlIHRzYyBtc3IgcGFlIG1jZSBj
eDggYXBpYyBzZXAgbXRyciBwZ2UgbWNhIGNtb3YgcGF0IHBzZTM2IGNsZmx1c2ggZHRzIGFjcGkg
bW14IGZ4c3Igc3NlIHNzZTIgc3MgaHQgdG0gcGJlIHN5c2NhbGwgbnggcGRwZTFnYiByZHRzY3Ag
bG0gY29uc3RhbnRfdHNjIGFyY2hfcGVyZm1vbiBwZWJzIGJ0cyByZXBfZ29vZCBub3BsIHh0b3Bv
bG9neSBub25zdG9wX3RzYyBhcGVyZm1wZXJmIHBuaSBwY2xtdWxxZHEgZHRlczY0IG1vbml0b3Ig
ZHNfY3BsIHZteCBzbXggZXN0IHRtMiBzc3NlMyBjeDE2IHh0cHIgcGRjbSBwY2lkIGRjYSBzc2U0
XzEgc3NlNF8yIHBvcGNudCBhZXMgbGFoZl9sbSBhcmF0IGVwYiBkdGhlcm0gdHByX3NoYWRvdyB2
bm1pIGZsZXhwcmlvcml0eSBlcHQgdnBpZApib2dvbWlwcwk6IDQ4MDAuMzAKY2xmbHVzaCBzaXpl
CTogNjQKY2FjaGVfYWxpZ25tZW50CTogNjQKYWRkcmVzcyBzaXplcwk6IDQwIGJpdHMgcGh5c2lj
YWwsIDQ4IGJpdHMgdmlydHVhbApwb3dlciBtYW5hZ2VtZW50OgoK
--047d7b6d88da48859404d4dd311f
Content-Type: text/x-csrc; charset=US-ASCII; name="test-cwf.c"
Content-Disposition: attachment; filename="test-cwf.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: file0

I2luY2x1ZGU8c3RkaW8uaD4KI2luY2x1ZGU8c3RyaW5nLmg+CiNpbmNsdWRlPHN0ZGxpYi5oPgoj
aW5jbHVkZTx1bmlzdGQuaD4KI2RlZmluZSBNQVhfQlVGX05VTSAoMSA8PCAyMCkKI2RlZmluZSBN
QVhfQlVGX1NJWkUgKDEgPDwgOCkKI2RlZmluZSBBQ0NFU1NfT0ZGU0VUICgweDM4KQoKIyBkZWZp
bmUgSFBfVElNSU5HX05PVyhWYXIpIFwKICh7IHVuc2lnbmVkIGxvbmcgbG9uZyBfaGksIF9sbzsg
XAogIGFzbSB2b2xhdGlsZSAoInJkdHNjIiA6ICI9YSIgKF9sbyksICI9ZCIgKF9oaSkpOyBcCiAg
KFZhcikgPSBfaGkgPDwgMzIgfCBfbG87IH0pCgojZGVmaW5lIHJlcGVhdF90aW1lcyAgKDY0KQoK
c3RhdGljIHZvaWQgaW5pdF9idWYoY2hhciAqKmJ1ZikKewoJaW50IGkgPSAwOwoJY2hhciAqc3Rh
cnQ7CgljaGFyICplbmQ7CglpbnQgcGFnZXNpemUgPSBnZXRwYWdlc2l6ZSgpOwoJKmJ1ZiA9IG1h
bGxvYyhNQVhfQlVGX1NJWkUgKiBNQVhfQlVGX05VTSArIHBhZ2VzaXplKTsKCWlmKCpidWYgPT0g
TlVMTCkgewoJCXByaW50ZigiXG5mYWl0IHRvIG1hbGxvYyBzcGFjZSFcbiIpOwoJCWV4aXQoMSk7
Cgl9IGVsc2UgIHsKCQkqYnVmID0gKmJ1ZiArIHBhZ2VzaXplOwoJCSpidWYgPSAoY2hhciAqKSgo
KHVuc2lnbmVkIGxvbmcpKmJ1ZikgJiAoLXBhZ2VzaXplKSk7Cgl9CgkKCXN0YXJ0ID0gKmJ1ZjsK
CWVuZCA9ICpidWYgKyAoTUFYX0JVRl9TSVpFICogTUFYX0JVRl9OVU0pIC0gTUFYX0JVRl9TSVpF
OwoKCXdoaWxlKDEpIHsKCQkqKCh1bnNpZ25lZCBjaGFyICoqKXN0YXJ0KSA9IGVuZDsKCQkqKCh1
bnNpZ25lZCBjaGFyICoqKShzdGFydCArIEFDQ0VTU19PRkZTRVQpKSA9IChlbmQgKyBBQ0NFU1Nf
T0ZGU0VUKTsKCQlzdGFydCA9IHN0YXJ0ICsgTUFYX0JVRl9TSVpFOwoJCWlmKHN0YXJ0ID09IGVu
ZCkKCQkJYnJlYWs7CgkJKigodW5zaWduZWQgY2hhciAqKillbmQpID0gc3RhcnQ7CgkJKigodW5z
aWduZWQgY2hhciAqKikoZW5kICsgQUNDRVNTX09GRlNFVCkpID0gc3RhcnQgKyBBQ0NFU1NfT0ZG
U0VUOwoJCWVuZCA9IGVuZCAtIE1BWF9CVUZfU0laRTsKCX0KCn0KCnVuc2lnbmVkIGxvbmcgbG9v
a2luZ3VwX21lbW1vcnkoY2hhciAqYWNjZXNzLCBpbnQgbnVtKQp7CglfX2FzbV9fKCJzdWIgJDEs
ICVyc2kiKTsKCV9fYXNtX18oInhvciAlcmF4LCAlcmF4Iik7CglfX2FzbV9fKCIxOiIpOwoJX19h
c21fXygibW92ICglcmRpKSwgJXI4Iik7CglfX2FzbV9fKCJhZGQgJXI4LCAlcmF4Iik7CglfX2Fz
bV9fKCJtb3YgJXI4LCAlcmRpIik7CglfX2FzbV9fKCJzdWIgJDEsICVyc2kiKTsKCV9fYXNtX18o
ImphZSAxYiIpOwp9CgpzdGF0aWMgdW5zaWduZWQgbG9uZyB0ZXN0X2xvb2t1cF90aW1lKGNoYXIg
KmJ1ZikKewoJdW5zaWduZWQgbG9uZyBpLCBzdGFydCwgZW5kLCBiZXN0X3RpbWUgPSB+MDsKCglm
b3IoaSA9IDA7IGkgPCByZXBlYXRfdGltZXM7IGkrKykgewoJCUhQX1RJTUlOR19OT1coc3RhcnQp
OwoJCWxvb2tpbmd1cF9tZW1tb3J5KGJ1ZiwgTUFYX0JVRl9OVU0pOwoJCUhQX1RJTUlOR19OT1co
ZW5kKTsKCQlpZihiZXN0X3RpbWUgPiAoZW5kIC0gc3RhcnQpKQoJCQliZXN0X3RpbWUgPSAoZW5k
IC0gc3RhcnQpOwoJfQoKCXJldHVybiBiZXN0X3RpbWU7Cgp9CnZvaWQgbWFpbiAodm9pZCkKewoJ
Y2hhciAqYnVmMSA9IE5VTEw7CgljaGFyICpidWYyID0gTlVMTDsKCXVuc2lnbmVkIGxvbmcgYWxp
Z25lZF90aW1lLCB1bmFsaWduZWRfdGltZTsKCQoKCWluaXRfYnVmKCZidWYxKTsKCWluaXRfYnVm
KCZidWYyKTsKCQoJdW5hbGlnbmVkX3RpbWUgPSB0ZXN0X2xvb2t1cF90aW1lKGJ1ZjIgKyBBQ0NF
U1NfT0ZGU0VUKTsKCWFsaWduZWRfdGltZSA9IHRlc3RfbG9va3VwX3RpbWUoYnVmMSk7CgoJcHJp
bnRmKCJsb29raW5nLXVwIGFsaWduZWQgdGltZSAlbGQsIGxvb2tpbmctdXAgdW5hbGlnbmVkIHRp
bWUgJWxkXG4iLCBhbGlnbmVkX3RpbWUsIHVuYWxpZ25lZF90aW1lKTsKfQoKCgoK
--047d7b6d88da48859404d4dd311f--
