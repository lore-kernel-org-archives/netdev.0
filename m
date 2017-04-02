From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Sun, 02 Apr 2017 10:26:12 -0700
Message-ID: <1491153972.10124.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
         <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170402114545.GA31804@breakpoint.cc>
         <1491134084.10124.6.camel@edumazet-glaptop3.roam.corp.google.com>
         <1491135593.10124.9.camel@edumazet-glaptop3.roam.corp.google.com>
         <4442718191e17f0ff91bf1359da6d631@nuclearcat.com>
         <1491136344.10124.10.camel@edumazet-glaptop3.roam.corp.google.com>
         <f005315a672d82fae34f932f4a7f3d5f@nuclearcat.com>
         <1491153268.10124.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, netdev-owner@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33069 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751155AbdDBR0P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 13:26:15 -0400
In-Reply-To: <1491153268.10124.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-02 at 10:14 -0700, Eric Dumazet wrote:

> Could that be that netfilter does not abort earlier if TCP header is
> completely wrong ?
> 

Yes, I wonder if this patch would be better, unless we replicate the
th->doff sanity check in all netfilter modules dissecting TCP frames.

diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index ade024c90f4f129a7c384e9e1cbfdb8ffe73065f..8cb4eadd5ba1c20e74bc27ee52a0bc36a5b26725 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -103,11 +103,11 @@ static bool tcp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (!NF_INVF(tcpinfo, XT_TCP_INV_FLAGS,
 		     (((unsigned char *)th)[13] & tcpinfo->flg_mask) == tcpinfo->flg_cmp))
 		return false;
+	if (th->doff * 4 < sizeof(_tcph)) {
+		par->hotdrop = true;
+		return false;
+	}
 	if (tcpinfo->option) {
-		if (th->doff * 4 < sizeof(_tcph)) {
-			par->hotdrop = true;
-			return false;
-		}
 		if (!tcp_find_option(tcpinfo->option, skb, par->thoff,
 				     th->doff*4 - sizeof(_tcph),
 				     tcpinfo->invflags & XT_TCP_INV_OPTION,
