From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Sat, 15 Dec 2007 18:03:19 +0100
Message-ID: <476408D7.50205@cosmosbay.com>
References: <474F7EE8.2040009@cn.fujitsu.com> <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com> <20071203113935.GA25124@gondor.apana.org.au> <20071203114912.GA4425@ms2.inr.ac.ru> <20071203115435.GA4202@gondor.apana.org.au> <20071203131723.GA30312@gondor.apana.org.au> <20071215135851.GA29063@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Wang Chen <wangchen@cn.fujitsu.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>,
	Ingo Molnar <mingo@elte.hu>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:36673 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755947AbXLORHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 12:07:34 -0500
In-Reply-To: <20071215135851.GA29063@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu a =E9crit :
> Ob Tue, Dec 04, 2007 at 12:17:23AM +1100, Herbert Xu wrote:
>> Never mind, we already have that in local_t and as Alexey correctly
>> points out, USER is still going to be the expensive variant with the
>> preempt_disable (well until BH gets threaded).  So how about this pa=
tch?
>=20
> I didn't hear any objections so here is the patch again.
>=20
> [SNMP]: Fix SNMP counters with PREEMPT
>=20
> The SNMP macros use raw_smp_processor_id() in process context
> which is illegal because the process may be preempted and then
> migrated to another CPU.
>=20
> This patch makes it use get_cpu/put_cpu to disable preemption.
>=20
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20
> Cheers,
  #define SNMP_INC_STATS_USER(mib, field) \
-	(per_cpu_ptr(mib[1], raw_smp_processor_id())->mibs[field]++)
+	do { \
+		per_cpu_ptr(mib[1], get_cpu())->mibs[field]++; \
+		put_cpu(); \
+	} while (0)
  #define SNMP_INC_STATS(mib, field) 	\
  	(per_cpu_ptr(mib[!in_softirq()], raw_smp_processor_id())->mibs[field=
]++)


How come you change SNMP_INC_STATS_USER() but not SNMP_INC_STATS() ?


