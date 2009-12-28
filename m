From: Mark Bergsma <mark@wikimedia.org>
Subject: Re: [PATCH] IPVS: Allow boot time change of hash size.
Date: Mon, 28 Dec 2009 19:49:38 +0100
Message-ID: <4B38FDC2.9000507@wikimedia.org>
References: <54783.91.201.80.240.1228232062.squirrel@mail.embedromix.ro>	<20081202.145129.06176881.davem@davemloft.net>	<49597.86.34.32.157.1228259764.squirrel@mail.embedromix.ro> <20081202.163729.158874214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tilia.nedworks.org ([82.94.225.218]:49395 "EHLO
	tilia.nedworks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbZL1Tae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 14:30:34 -0500
Received: from 35-19-ftth.onsnetstudenten.nl ([145.120.19.35]:60122 helo=[192.168.20.11])
	by tilia.nedworks.org with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <mark@wikimedia.org>)
	id 1NPKex-0007rY-3k
	for netdev@vger.kernel.org; Mon, 28 Dec 2009 19:49:39 +0100
In-Reply-To: <20081202.163729.158874214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-12-08 01:37, David Miller wrote:
> From: "Catalin(ux) M. BOIE" <catab@embedromix.ro>
> Date: Tue, 2 Dec 2008 16:16:04 -0700 (MST)
>> I was looking for anything that could get me past of 88.000 request per
>> seconds.
>> The help text told me to raise that value if I have big number of
>> connections. I just needed an easy way to test.
> 
> You're just repeating what I said, you "think" it should be
> changed and as a result you are wasting everyones time.
> 
> You don't actually "know", you're just guessing using random
> snippets from documentation rather than good hard evidence of
> a need.

Hello,

I just found this year-old thread about a patch allowing the IPVS
connection hash table size to be set at load time by a module parameter.
Apparently the conclusion reached was that allowing this configuration
setting to be changed would be useless, and that the poster's
performance problems would likely lie elsewhere, since he had no
evidence it was caused by the hash table size.

We do however run into the same problem with the default setting (2^12 =
4096 entries), as most of our LVS balancers handle around a million
connections/SLAB entries at any point in time (around 100-150 kpps
load). With only 4096 hash table entries this implies that each entry
consists of a linked list of 256 connections *on average*.

To provide some statistics, I did an oprofile run on an 2.6.31 kernel,
with both the default 4096 table size, and the same kernel recompiled
with IP_VS_CONN_TAB_BITS set to 18 (2^18 = 262144 entries). I built a
quick test setup with a part of Wikimedia/Wikipedia's live traffic
mirrored by the switch to the test host.

With the default setting, at ~ 120 kpps packet load we saw a typical %si
CPU usage of around 30-35%, and oprofile reported a hot spot in
ip_vs_conn_in_get:

samples  %        image name               app name
symbol name
1719761  42.3741  ip_vs.ko                 ip_vs.ko
ip_vs_conn_in_get
302577    7.4554  bnx2                     bnx2                     /bnx2
181984    4.4840  vmlinux                  vmlinux
__ticket_spin_lock
128636    3.1695  vmlinux                  vmlinux
ip_route_input
74345     1.8318  ip_vs.ko                 ip_vs.ko
ip_vs_conn_out_get
68482     1.6874  vmlinux                  vmlinux
mwait_idle

After loading the recompiled kernel with 2^18 entries, %si CPU usage
dropped in half to around 12-18%, and oprofile looks much healthier,
with only 7% spent in ip_vs_conn_in_get:

samples  %        image name               app name
symbol name
265641   14.4616  bnx2                     bnx2                     /bnx2
143251    7.7986  vmlinux                  vmlinux
__ticket_spin_lock
140661    7.6576  ip_vs.ko                 ip_vs.ko
ip_vs_conn_in_get
94364     5.1372  vmlinux                  vmlinux
mwait_idle
86267     4.6964  vmlinux                  vmlinux
ip_route_input

So yes, having the table size as an ip_vs module parameter would be
*very* welcome. Perhaps not as convenient as a dynamically resizing
table, but it would be a lot less work and much more maintainable in
production than compiling a kernel with every security update...

-- 
Mark Bergsma <mark@wikimedia.org>
Operations Engineer, Wikimedia Foundation
