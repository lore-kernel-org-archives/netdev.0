From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Fri, 21 Mar 2014 06:47:05 -0700
Message-ID: <1395409625.6441.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87a9cknwk4.fsf@tassilo.jf.intel.com>
	 <1395406250.9114.142.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1395408778.6441.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:47419 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaCUNrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 09:47:09 -0400
In-Reply-To: <1395408778.6441.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-21 at 06:32 -0700, Eric Dumazet wrote:
> On Fri, 2014-03-21 at 05:50 -0700, Eric Dumazet wrote:
> 
> > Or the fact that we mix 16 bit stores and 32bit loads ?
> > 
> > iph->tot_len = newlen;
> > iph->check = 0;
> > iph->check = ip_fast_csum(iph, 5);
> 
> Yep definitely. Using 16 bit loads in ip_fast_csum() totally removes the
> stall. I no longer see inet_gro_complete() in perf top...
> 
> +       if (__builtin_constant_p(ihl) && ihl == 5) {
> +               asm("  movw (%[iph]), %w[sum]\n"        /* ihl/version/tos */
> +                   "  addw 2(%[iph]), %w[sum]\n"       /* tot_len      */
> +                   "  adcw 8(%[iph]), %w[sum]\n"       /* ttl/protocol */
> +                   "  adcw 10(%[iph]), %w[sum]\n"      /* check        */
> +                   "  adcl 4(%[iph]), %[sum]\n"        /* id/frag_off  */
> +                   "  adcl 12(%[iph]), %[sum]\n"       /* saddr        */
> +                   "  adcl 16(%[iph]), %[sum]\n"       /* daddr        */
> +                   "  adcl $0, %[sum]\n"
> +                   : [sum] "=r" (sum)
> +                   : [iph] "r" (iph)
> +                   );
> +               return csum_fold(sum);
> 

Another idea would be to move the ip_fast_csum() call at the end of
inet_gro_complete()

I'll try this :

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8c54870db792..0ca8f350a532 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1434,8 +1434,8 @@ static int inet_gro_complete(struct sk_buff *skb, int nhoff)
        int proto = iph->protocol;
        int err = -ENOSYS;
 
-       csum_replace2(&iph->check, iph->tot_len, newlen);
        iph->tot_len = newlen;
+       iph->check = 0;
 
        rcu_read_lock();
        ops = rcu_dereference(inet_offloads[proto]);
@@ -1447,6 +1447,7 @@ static int inet_gro_complete(struct sk_buff *skb, int nhoff)
         * inet_gro_receive().
         */
        err = ops->callbacks.gro_complete(skb, nhoff + sizeof(*iph));
+       iph->check = ip_fast_csum((u8 *)iph, 5);
 
 out_unlock:
        rcu_read_unlock();
