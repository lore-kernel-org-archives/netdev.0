From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Fri, 17 Mar 2017 09:13:16 -0700
Message-ID: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489678147-21404-8-git-send-email-elena.reshetova@intel.com>
	<1489683534.28631.231.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAGXu5jJpFwiDR_o=oarN_2vDr56cwQ=Bg-5NikUmDtxtzWnAcQ@mail.gmail.com>
	<20170316.121032.405930218798336643.davem@davemloft.net>
	<2236FBA76BA1254E88B949DDB74E612B41C5A53B@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "keescook@chromium.org" <keescook@chromium.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"ishkamiel@gmail.com" <ishkamiel@gmail.com>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>,
	"dwindsor@gmail.com" <dwindsor@gmail.com>
To: "Reshetova, Elena" <elena.reshetova@intel.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612B41C5A53B@IRSMSX102.ger.corp.intel.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-03-17 at 07:42 +0000, Reshetova, Elena wrote:

> Should we then first measure the actual numbers to understand what we
> are talking here about? 
> I would be glad to do it if you suggest what is the correct way to do
> measurements here to actually reflect the real life use cases. 

How have these patches been tested in real life exactly ?

Can you quantify number of added cycles per TCP packet, where I expect
we have maybe 20 atomic operations in all layers ...


(sk refcnt, skb->users, page refcounts, sk->sk_wmem_alloc,
sk->sk_rmem_alloc, qdisc ...)

Once we 'protect' all of them, cost will be quite high.

This translates to more fossil fuel being burnt.

one atomic_inc() used to be a single x86 instruction.

Rough estimate of refcount_inc() :

0000000000000140 <refcount_inc>:
 140:	55                   	push   %rbp
 141:	48 89 e5             	mov    %rsp,%rbp
 144:	e8 00 00 00 00       	callq  refcount_inc_not_zero
 149:	84 c0                	test   %al,%al
 14b:	74 02                	je     14f <refcount_inc+0xf>
 14d:	5d                   	pop    %rbp
 14e:	c3                   	retq   

00000000000000e0 <refcount_inc_not_zero>:
  e0:	8b 17                	mov    (%rdi),%edx
  e2:	eb 10                	jmp    f4 <refcount_inc_not_zero+0x14>
  e4:	85 c9                	test   %ecx,%ecx
  e6:	74 1b                	je     103 <refcount_inc_not_zero+0x23>
  e8:	89 d0                	mov    %edx,%eax
  ea:	f0 0f b1 0f          	lock cmpxchg %ecx,(%rdi)
  ee:	39 d0                	cmp    %edx,%eax
  f0:	74 0c                	je     fe <refcount_inc_not_zero+0x1e>
  f2:	89 c2                	mov    %eax,%edx
  f4:	85 d2                	test   %edx,%edx
  f6:	8d 4a 01             	lea    0x1(%rdx),%ecx
  f9:	75 e9                	jne    e4 <refcount_inc_not_zero+0x4>
  fb:	31 c0                	xor    %eax,%eax
  fd:	c3                   	retq   
  fe:	83 f9 ff             	cmp    $0xffffffff,%ecx
 101:	74 06                	je     109 <refcount_inc_not_zero+0x29>
 103:	b8 01 00 00 00       	mov    $0x1,%eax
 108:	c3                   	retq   

This is simply bloat for most cases.

Again, I believe this infrastructure makes sense for debugging kernels.

If some vendors are willing to run fully enabled debug kernels,
that is their choice. Probably many devices wont show any difference.

Have we forced KASAN being enabled in linux kernel, just because
it found ~400 bugs so far ?

I believe refcount_t infra is not mature enough to be widely used
right now.

Maybe in few months when we have more flexibility, like existing
debugging facilities (CONFIG_DEBUG_PAGEALLOC, CONFIG_DEBUG_PAGE_REF,
LOCKDEP, KMEMLEAK, KASAN, ...)
