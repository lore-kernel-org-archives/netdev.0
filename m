From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Fri, 19 Mar 2004 17:34:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405B2132.6060403@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF17.8090907@trash.net> <20040319115130.GE29066@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040319115130.GE29066@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Mar 18, 2004 at 05:32:23PM +0100, Patrick McHardy wrote:
> 
>>@@ -635,7 +636,6 @@
>> #ifdef CONFIG_IP_ROUTE_FWMARK
>> 		fl.nl_u.ip4_u.fwmark = (*pskb)->nfmark;
>> #endif
>>-		fl.proto = iph->protocol;
> 
> 
> Better call __ip_route_output_key rather than not setting proto because
> you'll need proto in xfrm_lookup.
> 
> 
>> 		if (ip_route_output_key(&rt, &fl) != 0)
>> 			return -1;
>> 
> 
> 
>>@@ -661,6 +661,20 @@
>> 	
>> 	if ((*pskb)->dst->error)
>> 		return -1;
>>+
>>+#ifdef CONFIG_XFRM
>>+	if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED)) {
>>+		struct xfrm_policy_afinfo *afinfo;
>>+
>>+		afinfo = xfrm_policy_get_afinfo(AF_INET);
>>+		if (afinfo != NULL) {
>>+			afinfo->decode_session(*pskb, &fl);
>>+			xfrm_policy_put_afinfo(afinfo);
>>+			if (xfrm_lookup(&(*pskb)->dst, &fl, (*pskb)->sk, 0) != 0)
>>+				return -1;
>>+		}
>>+	}
>>+#endif
> 
> 
> If we can reinject transport packets then we can move this back into
> the if clause.

I don't understand the relationship to transport mode packets. I used an
explicit call to xfrm_lookup so packets with non-local source are also
handled. We also need to protect against loops, packets which are
already transformed should not be transformed again.

Regards
Patrick
