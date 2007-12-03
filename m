From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Tue, 4 Dec 2007 00:17:23 +1100
Message-ID: <20071203131723.GA30312@gondor.apana.org.au>
References: <474F7EE8.2040009@cn.fujitsu.com> <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com> <20071203113935.GA25124@gondor.apana.org.au> <20071203114912.GA4425@ms2.inr.ac.ru> <20071203115435.GA4202@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>,
	Ingo Molnar <mingo@elte.hu>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2099 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752375AbXLCNSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 08:18:12 -0500
Content-Disposition: inline
In-Reply-To: <20071203115435.GA4202@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2007 at 10:54:35PM +1100, Herbert Xu wrote:
>
> Hmm, wasn't someone else talking about a non-atomic version of atomic
> ops lately (i.e., atomic with respect to the local CPU only)? Perhaps
> this is the killer app for it :)

Never mind, we already have that in local_t and as Alexey correctly
points out, USER is still going to be the expensive variant with the
preempt_disable (well until BH gets threaded).  So how about this patch?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/snmp.h b/include/net/snmp.h
index ea206bf..9444b54 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -23,6 +23,7 @@
 
 #include <linux/cache.h>
 #include <linux/snmp.h>
+#include <linux/smp.h>
 
 /*
  * Mibs are stored in array of unsigned long.
@@ -137,7 +138,10 @@ struct linux_mib {
 #define SNMP_INC_STATS_OFFSET_BH(mib, field, offset)	\
 	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field + (offset)]++)
 #define SNMP_INC_STATS_USER(mib, field) \
-	(per_cpu_ptr(mib[1], raw_smp_processor_id())->mibs[field]++)
+	do { \
+		per_cpu_ptr(mib[1], get_cpu())->mibs[field]++; \
+		put_cpu(); \
+	} while (0)
 #define SNMP_INC_STATS(mib, field) 	\
 	(per_cpu_ptr(mib[!in_softirq()], raw_smp_processor_id())->mibs[field]++)
 #define SNMP_DEC_STATS(mib, field) 	\
@@ -145,6 +149,9 @@ struct linux_mib {
 #define SNMP_ADD_STATS_BH(mib, field, addend) 	\
 	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field] += addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend) 	\
-	(per_cpu_ptr(mib[1], raw_smp_processor_id())->mibs[field] += addend)
+	do { \
+		per_cpu_ptr(mib[1], get_cpu())->mibs[field] += addend; \
+		put_cpu(); \
+	} while (0)
 
 #endif
