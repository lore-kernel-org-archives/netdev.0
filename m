From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Sun, 02 Apr 2017 04:54:44 -0700
Message-ID: <1491134084.10124.6.camel@edumazet-glaptop3.roam.corp.google.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
         <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170402114545.GA31804@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20170402114545.GA31804@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2017-04-02 at 13:45 +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > -	for (i = sizeof(struct tcphdr); i <= tcp_hdrlen - TCPOLEN_MSS; i += optlen(opt, i)) {
> > +	for (i = sizeof(struct tcphdr); i < tcp_hdrlen - TCPOLEN_MSS; i += optlen(opt, i)) {
> >  		if (opt[i] == TCPOPT_MSS && opt[i+1] == TCPOLEN_MSS) {
> >  			u_int16_t oldmss;
> 
> maybe I am low on caffeeine but this looks fine, for tcp header with
> only tcpmss this boils down to "20 <= 24 - 4" so we acccess offsets 20-23 which seems ok.

I am definitely low on caffeine ;)

An issue in this function is that we might add the missing MSS option,
without checking that TCP options are already full.

But this should not cause a KASAN splat, only some malformed TCP packet

(tcph->doff would wrap)



