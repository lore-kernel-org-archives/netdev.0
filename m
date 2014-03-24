From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Sun, 23 Mar 2014 19:50:10 -0700
Message-ID: <1395629410.9117.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cknwk4.fsf@tassilo.jf.intel.com>
	 <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140321.145229.1026128975151125729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, hpa@zytor.com, kaber@trash.net,
	herbert@gondor.apana.org.au, hkchu@google.com, mwdalton@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140321.145229.1026128975151125729.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-03-21 at 14:52 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 21 Mar 2014 05:50:50 -0700
> 
> > It looks like a barrier() would be more appropriate.
> 
> barrier() == __asm__ __volatile__(:::"memory")

Indeed, but now you mention it, ip_fast_csum() do not uses volatile
keyword on x86_64, and has no "m" constraint either.

This means that for the following hypothetical networking code :

void foobar(struct iphdr *iph, __be16 newlen, __be16 newid)
{
        iph->tot_len = newlen;
        iph->check = 0;
        iph->check = ip_fast_csum((u8 *)iph, 5);

        pr_err("%p\n", iph);

        iph->id = newid;
        iph->check = 0;
        iph->check = ip_fast_csum((u8 *)iph, 5);
}


ip_fast_csum() is done _once_ only.

Following patch seems needed. Thats one another call for x86 code factorization ...

diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
index e6fd8a026c7b..c67778544880 100644
--- a/arch/x86/include/asm/checksum_64.h
+++ b/arch/x86/include/asm/checksum_64.h
@@ -46,7 +46,7 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 {
 	unsigned int sum;
 
-	asm("  movl (%1), %0\n"
+	asm volatile("  movl (%1), %0\n"
 	    "  subl $4, %2\n"
 	    "  jbe 2f\n"
 	    "  addl 4(%1), %0\n"
