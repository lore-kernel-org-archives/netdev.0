From: James Greenhalgh <james.greenhalgh@arm.com>
Subject: Re: [PATCH net-next] ipv6: Implement optimized IPv6 masked address
 comparison for ARM64
Date: Fri, 17 Mar 2017 12:22:52 +0000
Message-ID: <20170317122252.GA32449@arm.com>
References: <1489725772-7571-1-git-send-email-subashab@codeaurora.org>
 <bfa8020c-bd12-8de1-5be5-a3408c293600@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <luke.starrett@broadcom.com>, <catalin.marinas@arm.com>,
        <nd@arm.com>
To: Robin Murphy <robin.murphy@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0041.outbound.protection.outlook.com ([104.47.0.41]:48736
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751018AbdCQMXH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 08:23:07 -0400
Content-Disposition: inline
In-Reply-To: <bfa8020c-bd12-8de1-5be5-a3408c293600@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 17, 2017 at 12:00:42PM +0000, Robin Murphy wrote:
> On 17/03/17 04:42, Subash Abhinov Kasiviswanathan wrote:
> > Android devices use multiple ip[6]tables for statistics, UID matching
> > and other functionality. Perf output indicated that ip6_do_table
> > was taking a considerable amount of CPU and more that ip_do_table
> > for an equivalent rate. ipv6_masked_addr_cmp was chosen for
> > optimization as there are more instructions required than the
> > equivalent operation in ip_packet_match.
> > 
> > Using 128 bit operations helps to reduce the number of instructions
> > for the match on an ARM64 system. This helps to improve UDPv6 DL
> > performance by 40Mbps (860Mbps -> 900Mbps) on a CPU limited system.
> 
> After trying to have a look at the codegen difference it makes, I think
> I may have found why it's faster ;)
> 
> ----------
> [root@space-channel-5 ~]# cat > ip.c
> #include <stdbool.h>
> #include <netinet/in.h>
> 	
> bool
> ipv6_masked_addr_cmp(const struct in6_addr *a1, const struct in6_addr *m,
> 		     const struct in6_addr *a2)
> {
> 	const unsigned long *ul1 = (const unsigned long *)a1;
> 	const unsigned long *ulm = (const unsigned long *)m;
> 	const unsigned long *ul2 = (const unsigned long *)a2;
> 
> 	return !!(((ul1[0] ^ ul2[0]) & ulm[0]) |
> 		  ((ul1[1] ^ ul2[1]) & ulm[1]));
> }
> 
> bool
> ipv6_masked_addr_cmp_new(const struct in6_addr *a1, const struct
> in6_addr *m,
> 		     const struct in6_addr *a2)
> {
> 	const __uint128_t *ul1 = (const __uint128_t *)a1;
> 	const __uint128_t *ulm = (const __uint128_t *)m;
> 	const __uint128_t *ul2 = (const __uint128_t *)a1;
> 
> 	return !!((*ul1 ^ *ul2) & *ulm);
> }

<snip>

> That's clearly not right - I'm not sure quite what undefined behaviour
> assumption convinces GCC to optimise the whole thing away>

While the pointer casting is a bit ghastly, I don't actually think that
GCC is taking advantage of undefined behaviour here, rather it looks like
you have a simple typo on line 3:

> 	const __uint128_t *ul1 = (const __uint128_t *)a1;
> 	const __uint128_t *ulm = (const __uint128_t *)m;
> 	const __uint128_t *ul2 = (const __uint128_t *)a1;

ul2 = a2, surely?

As it is (stripping casts) you have a1 ^ a1, which will get you to 0
pretty quickly. Fixing that up for you;

  bool
  ipv6_masked_addr_cmp_new(const struct in6_addr *a1, const struct
  in6_addr *m,
  		     const struct in6_addr *a2)
  {
  	const __uint128_t *ul1 = (const __uint128_t *)a1;
  	const __uint128_t *ulm = (const __uint128_t *)m;
  	const __uint128_t *ul2 = (const __uint128_t *)a2;

  	return !!((*ul1 ^ *ul2) & *ulm);
  }

$ gcc -O2

  ipv6_masked_addr_cmp_new:
	ldp	x4, x3, [x0]
	ldp	x5, x2, [x2]
	ldp	x0, x1, [x1]
	eor	x4, x4, x5
	eor	x2, x3, x2
	and	x0, x0, x4
	and	x1, x1, x2
	orr	x0, x0, x1
	cmp	x0, 0
	cset	w0, ne
	ret

Which at least looks like it might calculate something useful :-)

Cheers,
James
