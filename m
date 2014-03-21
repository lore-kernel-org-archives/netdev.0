From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Fri, 21 Mar 2014 05:50:50 -0700
Message-ID: <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cknwk4.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>, "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87a9cknwk4.fsf@tassilo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-20 at 18:56 -0700, Andi Kleen wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> >
> > I saw csum_partial() consuming 1% of cpu cycles in a GRO workload, that
> > is insane...
> 
> 
> Couldn't it just be the cache miss?

Or the fact that we mix 16 bit stores and 32bit loads ?

iph->tot_len = newlen;
iph->check = 0;
iph->check = ip_fast_csum(iph, 5);

-> following perf annotation :

         :      ffffffff81538e70 <inet_gro_complete>:
    0.49 :      ffffffff81538e70:       callq  ffffffff81578c80 <__entry_text_start>
    0.49 :      ffffffff81538e75:       push   %rbp
    1.46 :      ffffffff81538e76:       movzwl 0x60(%rdi),%edx
    0.00 :      ffffffff81538e7a:       movslq %esi,%rax
    0.00 :      ffffffff81538e7d:       add    0xc8(%rdi),%rax
    1.46 :      ffffffff81538e84:       mov    %rsp,%rbp
    0.00 :      ffffffff81538e87:       sub    %esi,%edx
    0.00 :      ffffffff81538e89:       rol    $0x8,%dx
    0.00 :      ffffffff81538e8d:       movzbl 0x9(%rax),%ecx
    0.98 :      ffffffff81538e91:       mov    %dx,0x2(%rax)     iph->tot_len = newlen;
    0.49 :      ffffffff81538e95:       xor    %edx,%edx
    0.00 :      ffffffff81538e97:       mov    %dx,0xa(%rax)     iph->check = 0;
    0.00 :      ffffffff81538e9b:       mov    (%rax),%edx       // 32bit load  -> stall 
   86.34 :      ffffffff81538e9d:       add    0x4(%rax),%edx
    0.49 :      ffffffff81538ea0:       adc    0x8(%rax),%edx
    0.49 :      ffffffff81538ea3:       adc    0xc(%rax),%edx
    0.98 :      ffffffff81538ea6:       adc    0x10(%rax),%edx
    0.49 :      ffffffff81538ea9:       adc    $0x0,%edx
    0.00 :      ffffffff81538eac:       mov    %edx,%r8d
    0.49 :      ffffffff81538eaf:       xor    %dx,%dx
    0.00 :      ffffffff81538eb2:       shl    $0x10,%r8d
    0.98 :      ffffffff81538eb6:       add    %r8d,%edx
    0.98 :      ffffffff81538eb9:       adc    $0xffff,%edx
    0.98 :      ffffffff81538ebf:       not    %edx
    0.00 :      ffffffff81538ec1:       shr    $0x10,%edx
    0.49 :      ffffffff81538ec4:       mov    %dx,0xa(%rax)
    0.00 :      ffffffff81538ec8:       movslq %ecx,%rax
    0.00 :      ffffffff81538ecb:       mov    -0x7e734f40(,%rax,8),%rax
    0.00 :      ffffffff81538ed3:       test   %rax,%rax
    0.00 :      ffffffff81538ed6:       je     ffffffff81538ef0 <inet_gro_complete+0x80>

BTW, any idea why ip_fast_csum() on x86 contains a "memory" constraint ?
It looks like a barrier() would be more appropriate.

Following patch seems to help, but the stall seems to be the fact that
we write on iph->check (16bits) before doing the checksum using 32bit
loads.

Note that we could share same ip_fast_csum() implementation between x86
32/64 bits...

diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
index e6fd8a026c7b..a81cc3a5facc 100644
--- a/arch/x86/include/asm/checksum_64.h
+++ b/arch/x86/include/asm/checksum_64.h
@@ -46,6 +46,24 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 {
 	unsigned int sum;
 
+	/*
+	 * Callers might clear iph->check before calling us, make sure
+	 * compiler wont mess things...
+	 */
+	barrier();
+
+	if (__builtin_constant_p(ihl) && ihl == 5) {
+		asm("  movl (%[iph]), %[sum]\n"
+		    "  addl 4(%[iph]), %[sum]\n"
+		    "  adcl 8(%[iph]), %[sum]\n"
+		    "  adcl 12(%[iph]), %[sum]\n"
+		    "  adcl 16(%[iph]), %[sum]\n"
+		    "  adcl $0, %[sum]\n"
+		    : [sum] "=r" (sum)
+		    : [iph] "r" (iph)
+		    );
+		return csum_fold(sum);
+	}
 	asm("  movl (%1), %0\n"
 	    "  subl $4, %2\n"
 	    "  jbe 2f\n"
@@ -68,7 +86,7 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 	   will assume they contain their original values. */
 	    : "=r" (sum), "=r" (iph), "=r" (ihl)
 	    : "1" (iph), "2" (ihl)
-	    : "memory");
+	    );
 	return (__force __sum16)sum;
 }
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8c54870db792..90aa562dfbf5 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1434,8 +1434,9 @@ static int inet_gro_complete(struct sk_buff *skb, int nhoff)
 	int proto = iph->protocol;
 	int err = -ENOSYS;
 
-	csum_replace2(&iph->check, iph->tot_len, newlen);
 	iph->tot_len = newlen;
+	iph->check = 0;
+	iph->check = ip_fast_csum((u8 *)iph, 5);
 
 	rcu_read_lock();
 	ops = rcu_dereference(inet_offloads[proto]);
