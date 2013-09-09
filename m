From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large
 packets
Date: Mon, 09 Sep 2013 14:56:55 -0700
Message-ID: <1378763815.26319.39.camel@edumazet-glaptop>
References: <20130906101635.GI14104@zion.uk.xensource.com>
	  <1378472268.31445.15.camel@edumazet-glaptop> <522A049A.7000105@citrix.com>
	  <1378486840.31445.36.camel@edumazet-glaptop>
	 <1378574494.26319.14.camel@edumazet-glaptop> <522E4080.2050802@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f179.google.com ([209.85.213.179]:39655 "EHLO
	mail-ye0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755603Ab3IIV5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 17:57:00 -0400
Received: by mail-ye0-f179.google.com with SMTP id r6so2220339yen.24
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 14:57:00 -0700 (PDT)
In-Reply-To: <522E4080.2050802@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-09 at 22:41 +0100, Zoltan Kiss wrote:
> On 07/09/13 18:21, Eric Dumazet wrote:
> > On Fri, 2013-09-06 at 10:00 -0700, Eric Dumazet wrote:
> >> On Fri, 2013-09-06 at 17:36 +0100, Zoltan Kiss wrote:
> >>
> >>> So I guess it would be good to revisit the default value of this
> >>> setting.
> >>
> >> If ixgbe requires 3 TSO packets in TX ring to get line rate, you also
> >> can tweak dev->gso_max_size from 65535 to 64000.
> >
> > Another idea would be to no longer use tcp_limit_output_bytes but
> >
> > max(sk_pacing_rate / 1000, 2*MSS)
> 
> I've tried this on a freshly updated upstream, and it solved my problem 
> on ixgbe:
> 
> -               if (atomic_read(&sk->sk_wmem_alloc) >= 
> sysctl_tcp_limit_output_bytes) {
> +               if (atomic_read(&sk->sk_wmem_alloc) >= 
> max(sk->sk_pacing_rate / 1000, 2 * mss_now) ){
> 
> Now I can get proper line rate. Btw. I've tried to decrease 
> dev->gso_max_size to 60K or 32K, both was ineffective.

Yeah, my own test was more like the following


diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7c83cb8..07dc77a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1872,7 +1872,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		/* TSQ : sk_wmem_alloc accounts skb truesize,
 		 * including skb overhead. But thats OK.
 		 */
-		if (atomic_read(&sk->sk_wmem_alloc) >= sysctl_tcp_limit_output_bytes) {
+		if (atomic_read(&sk->sk_wmem_alloc) >= max(2 * mss_now,
+							   sk->sk_pacing_rate >> 8)) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
 			break;
 		}


Note that it also seems to make Hystart happier.

I will send patches when all tests are green.
