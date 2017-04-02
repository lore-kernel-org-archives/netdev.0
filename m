From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Sun, 02 Apr 2017 10:14:28 -0700
Message-ID: <1491153268.10124.12.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
         <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170402114545.GA31804@breakpoint.cc>
         <1491134084.10124.6.camel@edumazet-glaptop3.roam.corp.google.com>
         <1491135593.10124.9.camel@edumazet-glaptop3.roam.corp.google.com>
         <4442718191e17f0ff91bf1359da6d631@nuclearcat.com>
         <1491136344.10124.10.camel@edumazet-glaptop3.roam.corp.google.com>
         <f005315a672d82fae34f932f4a7f3d5f@nuclearcat.com>
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <f005315a672d82fae34f932f4a7f3d5f@nuclearcat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2017-04-02 at 19:52 +0300, Denys Fedoryshchenko wrote:
> On 2017-04-02 15:32, Eric Dumazet wrote:
> > On Sun, 2017-04-02 at 15:25 +0300, Denys Fedoryshchenko wrote:
> >> >  	 */
> >> I will add also WARN_ON_ONCE(tcp_hdrlen >= 15 * 4) before, for
> >> curiosity, if this condition are triggered. Is it fine like that?
> > 
> > Sure.
> 
> It didnt triggered WARN_ON, and with both patches here is one more 
> KASAN.
> What i noticed also after this KASAN, there is many others start to 
> trigger in TCPMSS and locking up server by flood.
> There is heavy netlink activity, it is pppoe server with lot of shapers.
> I noticed there left sfq by mistake, usually i am removing it, because 
> it may trigger kernel panic too (and hard to trace reason).
> I will try with pfifo instead, after 6 hours.
> 
> Here is full log with others: https://nuclearcat.com/kasan.txt
> 


Could that be that netfilter does not abort earlier if TCP header is
completely wrong ?

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 27241a767f17b4b27d24095a31e5e9a2d3e29ce4..dd64bff38ba8074e6feb2e6e305eacb30ce4c2da 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -104,7 +104,7 @@ tcpmss_mangle_packet(struct sk_buff *skb,
 	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
 	tcp_hdrlen = tcph->doff * 4;
 
-	if (len < tcp_hdrlen)
+	if (len < tcp_hdrlen || tcp_hdrlen < sizeof(struct tcphdr))
 		return -1;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {



