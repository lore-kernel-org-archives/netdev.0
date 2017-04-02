From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Sun, 02 Apr 2017 15:25:06 +0300
Message-ID: <4442718191e17f0ff91bf1359da6d631@nuclearcat.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
 <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170402114545.GA31804@breakpoint.cc>
 <1491134084.10124.6.camel@edumazet-glaptop3.roam.corp.google.com>
 <1491135593.10124.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1491135593.10124.9.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-04-02 15:19, Eric Dumazet wrote:
> On Sun, 2017-04-02 at 04:54 -0700, Eric Dumazet wrote:
>> On Sun, 2017-04-02 at 13:45 +0200, Florian Westphal wrote:
>> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > > -	for (i = sizeof(struct tcphdr); i <= tcp_hdrlen - TCPOLEN_MSS; i += optlen(opt, i)) {
>> > > +	for (i = sizeof(struct tcphdr); i < tcp_hdrlen - TCPOLEN_MSS; i += optlen(opt, i)) {
>> > >  		if (opt[i] == TCPOPT_MSS && opt[i+1] == TCPOLEN_MSS) {
>> > >  			u_int16_t oldmss;
>> >
>> > maybe I am low on caffeeine but this looks fine, for tcp header with
>> > only tcpmss this boils down to "20 <= 24 - 4" so we acccess offsets 20-23 which seems ok.
>> 
>> I am definitely low on caffeine ;)
>> 
>> An issue in this function is that we might add the missing MSS option,
>> without checking that TCP options are already full.
>> 
>> But this should not cause a KASAN splat, only some malformed TCP 
>> packet
>> 
>> (tcph->doff would wrap)
> 
> Something like that maybe.
> 
> diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
> index
> 27241a767f17b4b27d24095a31e5e9a2d3e29ce4..1465aaf0e3a15d69d105d0a50b0429b11b6439d3
> 100644
> --- a/net/netfilter/xt_TCPMSS.c
> +++ b/net/netfilter/xt_TCPMSS.c
> @@ -151,7 +151,9 @@ tcpmss_mangle_packet(struct sk_buff *skb,
>  	 */
>  	if (len > tcp_hdrlen)
>  		return 0;
> -
> +	/* tcph->doff is 4 bits wide, do not wrap its value to 0 */
> +	if (tcp_hdrlen >= 15 * 4)
> +		return 0;
>  	/*
>  	 * MSS Option not found ?! add it..
>  	 */
I will add also WARN_ON_ONCE(tcp_hdrlen >= 15 * 4) before, for 
curiosity, if this condition are triggered. Is it fine like that?
