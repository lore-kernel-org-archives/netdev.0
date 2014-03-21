From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] csum experts, csum_replace2() is too expensive
Date: Thu, 20 Mar 2014 17:54:17 -0700
Message-ID: <1395363257.9114.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395341341.9114.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140321001303.GB20397@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Michael Dalton <mwdalton@google.com>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59282 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965308AbaCUAyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 20:54:20 -0400
Received: by mail-pa0-f46.google.com with SMTP id kp14so1701104pab.33
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 17:54:19 -0700 (PDT)
In-Reply-To: <20140321001303.GB20397@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-21 at 08:13 +0800, Herbert Xu wrote:

> Your patch makes sense to me.  However does it actually help
> your 1% in the GRO profile?

Well, I caught this strange csum_partial() presence in a profile,
but my question was more general than the GRO use case.

(BTW the patch didn't even compile ;) )

I guess that in GRO case, the following would be even faster...

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8c54870db792..b8fe5e8a02dd 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1361,6 +1361,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	if (!ops || !ops->callbacks.gro_receive)
 		goto out_unlock;
 
+	/* GRO is limited to IPv4 with no options : ihl = 5 */
 	if (*(u8 *)iph != 0x45)
 		goto out_unlock;
 
@@ -1434,8 +1435,10 @@ static int inet_gro_complete(struct sk_buff *skb, int nhoff)
 	int proto = iph->protocol;
 	int err = -ENOSYS;
 
-	csum_replace2(&iph->check, iph->tot_len, newlen);
+	/* GRO is limited to IPv4 with no options : ihl = 5 */
 	iph->tot_len = newlen;
+	iph->check = 0;
+	iph->check = ip_fast_csum((u8 *)iph, 5);
 
 	rcu_read_lock();
 	ops = rcu_dereference(inet_offloads[proto]);
