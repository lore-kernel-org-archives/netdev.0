From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [2.6.12-rc1-mm4] swapped memset arguments
Date: Tue, 5 Apr 2005 18:37:39 +0300
Message-ID: <200504051837.39561.vda@ilport.com.ua>
References: <74334709.20050402233007@dns.toxicfilms.tv> <Pine.LNX.4.62.0504030035190.2525@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_DDrUCrdYI+wi3NI"
Cc: "James P. Ketrenos" <ipw2100-admin@linux.intel.com>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesper Juhl <juhl-lkml@dif.dk>, Maciej Soltysiak <solt2@dns.toxicfilms.tv>
In-Reply-To: <Pine.LNX.4.62.0504030035190.2525@dragon.hyggekrogen.localhost>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_DDrUCrdYI+wi3NI
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sunday 03 April 2005 01:38, Jesper Juhl wrote:
> On Sat, 2 Apr 2005, Maciej Soltysiak wrote:
> 
> > Hi,
> > 
> > out of boredom I grepped 2.6.12-rc1-mm4 for swapped memset arguments.
> > I found one:
> > 
> > # grep -nr "memset.*\,\(\ \|\)0\(\ \|\));" *
> > net/ieee80211/ieee80211_tx.c:226:       memset(txb, sizeof(struct ieee80211_txb), 0);  
> > 
> And here's a patch : 
> 
> 
> Fix swapped memset() arguments in  net/ieee80211/ieee80211_tx.c  
> found by Maciej Soltysiak.

This one will stop these from happening again.
(Well, at least on i386)...
--
vda

--Boundary-00=_DDrUCrdYI+wi3NI
Content-Type: text/x-diff;
  charset="koi8-r";
  name="string.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="string.diff"

--- linux-2.6.11.src/include/asm-i386/string.h.orig	Thu Mar  3 09:31:08 2005
+++ linux-2.6.11.src/include/asm-i386/string.h	Tue Apr  5 18:34:28 2005
@@ -316,8 +345,16 @@ __asm__ __volatile__(
 return s;
 }
 
-/* we might want to write optimized versions of these later */
-#define __constant_count_memset(s,c,count) __memset_generic((s),(c),(count))
+/*
+ * we might want to write optimized versions of this later
+ * for mow, just prevent common mistake of memset(a,c,0)
+ */
+void BUG_memset_with_zero_length(void);
+static inline void * __constant_count_memset(void * s, int c, size_t count)
+{
+	if(!count) BUG_memset_with_zero_length();
+	return __memset_generic(s,c,count);
+}
 
 /*
  * memset(x,0,y) is a reasonably common thing to do, so we want to fill
@@ -376,6 +413,7 @@ static inline void * __constant_c_and_co
 {
 	switch (count) {
 		case 0:
+			BUG_memset_with_zero_length();
 			return s;
 		case 1:
 			*(unsigned char *)s = pattern;

--Boundary-00=_DDrUCrdYI+wi3NI--
