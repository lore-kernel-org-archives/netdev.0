From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, PATCH 3/5]: netfilter+ipsec - input hooks
Date: Fri, 19 Mar 2004 17:29:45 +0100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <405B1FF9.1020504@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF0E.3050708@trash.net> <20040319114644.GC29066@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,  netdev@oss.sgi.com,
 netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040319114644.GC29066@gondor.apana.org.au>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Mar 18, 2004 at 05:32:14PM +0100, Patrick McHardy wrote:
> 
>>diff -Nru a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
>>--- a/net/ipv4/ip_input.c	Thu Mar 18 16:45:35 2004
>>+++ b/net/ipv4/ip_input.c	Thu Mar 18 16:45:35 2004
>>@@ -224,6 +224,12 @@
>> 	resubmit:
>> 		hash = protocol & (MAX_INET_PROTOS - 1);
>> 		raw_sk = sk_head(&raw_v4_htable[hash]);
>>+		ipprot = inet_protos[hash];
>>+		smp_read_barrier_depends();
>>+
>>+		if (skb->sp && !ipprot->xfrm_prot)
>>+			if (nf_postxfrm_input(skb))
>>+				goto out;
> 
> 
> Just an idea: what if we reinject the packet just as we do in tunnel mode?

If we also have a possibility to determine when decapsulation is done
we could avoid the nf_postxfrm_* hacks. Without that, I don't think it
helps.

> 
> 
>>@@ -346,6 +351,10 @@
>> 		}
>> 	}
>> 
>>+	if (skb->sp && !(((struct rtable *)skb->dst)->rt_flags&RTCF_LOCAL))
>>+		if (nf_postxfrm_nonlocal(skb))
>>+			goto drop;
>>+
> 
> 
> What if the PRE_ROUTING turns it into a local address again?

You have good eyes ;) The packet needs to be rerouted in
nf_postxfrm_nonlocal and needs to be special-cased in nf_postxfrm_input
so it doesn't traverse PRE_ROUTING twice.

Thanks for your other suggestions as well, I'm going to make these
changes.

Regards
Patrick
