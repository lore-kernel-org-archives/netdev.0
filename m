From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: ping6 is sent out from wrong interface
Date: Wed, 25 Jun 2008 16:02:10 +0900
Message-ID: <4861ED72.6080100@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:3474 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbYFYHCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 03:02:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi YOSHIFUJI-san

Thank you for your reply.

> -I does not specify interface strictly but source address.
> Which means, if you just specify an address, interface is unspecified.
> You can give "-I eth1", too.

I'm not convinced yet.
I don't think it's correct that kernel or ping6 arbitrarily decides outgoing interface.

Is this really an expected behaviour?
Could you explain to me the reason of it, too?

I think the behavior should be similar to IPv4.

The following is my image. ipv6_dev_find() is an imaginary function, which
finds the interface with a given source address.

How do you think?



--- linux-2.6.25/net/ipv6/raw.c.orig    2008-04-17 11:49:44.000000000 +0900
+++ linux-2.6.25/net/ipv6/raw.c 2008-06-25 15:20:27.000000000 +0900
@@ -875,8 +875,13 @@ static int rawv6_sendmsg(struct kiocb *i
                final_p = &final;
        }

-       if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
-               fl.oif = np->mcast_oif;
+       if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst)) {
+               if (np->mcast_oif)
+                       fl.oif = np->mcast_oif;
+               else
+                       fl.oif = ipv6_dev_find(oldflp->fl6_src);
+       }
+
        security_sk_classify_flow(sk, &fl);

        err = ip6_dst_lookup(sk, &dst, &fl);




