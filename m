From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: KASAN, xt_TCPMSS  finally found nasty use-after-free bug? 4.10.8
Date: Sun, 02 Apr 2017 14:51:25 +0300
Message-ID: <ddb4ab6cee309a79f4d8e7b8597e5a8f@nuclearcat.com>
References: <6c6e2f7505f969d8c2998efff24063ba@nuclearcat.com>
 <1491132259.10124.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170402114545.GA31804@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170402114545.GA31804@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-04-02 14:45, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> -	for (i = sizeof(struct tcphdr); i <= tcp_hdrlen - TCPOLEN_MSS; i += 
>> optlen(opt, i)) {
>> +	for (i = sizeof(struct tcphdr); i < tcp_hdrlen - TCPOLEN_MSS; i += 
>> optlen(opt, i)) {
>>  		if (opt[i] == TCPOPT_MSS && opt[i+1] == TCPOLEN_MSS) {
>>  			u_int16_t oldmss;
> 
> maybe I am low on caffeeine but this looks fine, for tcp header with
> only tcpmss this boils down to "20 <= 24 - 4" so we acccess offsets
> 20-23 which seems ok.
It seems some non-standard(or corrupted) packets are passing, because 
even on ~1G server it might cause corruption once per several days, 
KASAN seems need less time to trigger.

I am not aware how things working, but:
[25181.875696] Memory state around the buggy address:
[25181.875919]  ffff8802975fff80: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00
[25181.876275]  ffff880297600000: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00
[25181.876628] >ffff880297600080: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00
[25181.876984]
^
[25181.877203]  ffff880297600100: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00
[25181.877569]  ffff880297600180: 00 00 00 00 00 00 00 00 00 00 00 00 00
00 00 00

Why all data here is zero? I guess it should be some packet data?
