From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Flow cache flush oops
Date: Fri, 20 Jun 2003 08:43:08 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619224308.GA32165@gondor.apana.org.au>
References: <OFF5CE2037.3D4C9104-ON86256D49.007EAEAD-86256D49.007F5519@pok.ibm.com> <20030619000704.GA25135@gondor.apana.org.au> <20030619093518.GA27025@gondor.apana.org.au> <20030619.121108.21920417.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Cc: toml@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030619.121108.21920417.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 19, 2003 at 12:11:08PM -0700, David S. Miller wrote:
> 
> Reviewing this made me notice that we don't check the
> __get_free_pages() return value.  I'll fix that.

Thanks.  Perhaps we should check that in the init function as well.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- x/net/core/flow.c.orig	2003-06-20 08:35:54.000000000 +1000
+++ x/net/core/flow.c	2003-06-20 08:41:37.000000000 +1000
@@ -388,11 +388,14 @@
 	add_timer(&flow_hash_rnd_timer);
 
 	register_cpu_notifier(&flow_cache_cpu_nb);
-	for (i = 0; i < NR_CPUS; i++)
-		if (cpu_online(i)) {
-			flow_cache_cpu_prepare(i);
-			flow_cache_cpu_online(i);
-		}
+	for (i = 0; i < NR_CPUS; i++) {
+		if (!cpu_online(i))
+			continue;
+		if (flow_cache_cpu_prepare(i) == NOTIFY_OK &&
+		    flow_cache_cpu_online(i) == NOTIFY_OK)
+			continue;
+		panic("NET: failed to initialise flow cache hash table\n");
+	}
 
 	return 0;
 }

--vtzGhvizbBRQ85DL--
