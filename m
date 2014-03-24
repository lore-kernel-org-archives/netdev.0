From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [RFC] csum experts, csum_replace2() is too expensive
Date: Mon, 24 Mar 2014 07:13:42 -0700
Message-ID: <1395670422.12610.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cknwk4.fsf@tassilo.jf.intel.com>
	 <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140321.145229.1026128975151125729.davem@davemloft.net>
	 <1395629410.9117.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6E77A4@AcuExch.aculab.com>
	 <1395667063.12610.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"andi@firstfloor.org" <andi@firstfloor.org>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"hkchu@google.com" <hkchu@google.com>,
	"mwdalton@google.com" <mwdalton@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395667063.12610.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-03-24 at 06:17 -0700, Eric Dumazet wrote:
> On Mon, 2014-03-24 at 10:30 +0000, David Laight wrote:

> > ip_fast_csum() either needs an explicit "m" constraint for the actual
> > buffer (and target) bytes, or the stronger "memory" constraint.
> > The 'volatile' is then not needed.

I am testing the following :

diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
index e6fd8a026c7b..89d7fa8837b5 100644
--- a/arch/x86/include/asm/checksum_64.h
+++ b/arch/x86/include/asm/checksum_64.h
@@ -45,6 +45,9 @@ static inline __sum16 csum_fold(__wsum sum)
 static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 {
 	unsigned int sum;
+	struct full_ip_header {
+		unsigned int w[ihl];
+	};
 
 	asm("  movl (%1), %0\n"
 	    "  subl $4, %2\n"
@@ -67,8 +70,9 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 	   are modified, we must also specify them as outputs, or gcc
 	   will assume they contain their original values. */
 	    : "=r" (sum), "=r" (iph), "=r" (ihl)
-	    : "1" (iph), "2" (ihl)
-	    : "memory");
+	    : "1" (iph), "2" (ihl),
+	      "m" (*(struct full_ip_header *) iph)
+	);
 	return (__force __sum16)sum;
 }
 
