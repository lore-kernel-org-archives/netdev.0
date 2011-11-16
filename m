From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [v2 PATCH 1/2] NETFILTER module xt_hmark new target
	for HASH based fw
Date: Wed, 16 Nov 2011 16:56:28 +0100 (CET)
Message-ID: <lpt7rqm.25b7ea16278f503bce365f813ce861db@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "Hans Schillstrom" <hans.schillstrom@ericsson.com>,
	kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



>---- Original Message ----
>From: Pablo Neira Ayuso <pablo@netfilter.org>
>To: "Hans Schillstrom" <hans@schillstrom.com>
>Cc: "Hans Schillstrom" <hans.schillstrom@ericsson.com>, kaber@trash.net, jengelh@medozas.de, netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
>Sent: Wed, Nov 16, 2011, 11:50 AM
>Subject: Re: [v2 PATCH 1/2] NETFILTER module xt_hmark new target for HASH based fw
>
>On Wed, Nov 16, 2011 at 10:28:42AM +0100, Hans Schillstrom wrote:
>> I have some problems with the generator...,
>> so I did some simple iperf tcp test with KVM:s i.e. standart tcp setup
>
>I have some simple http traffic generator in case that you want to use
>it:
>
>http://1984.lsi.us.es/git/?p=http-client-benchmark/.git;a=summary
>
>You have to use it with willy tarreau's httpterm in the server side.
>Iperf is fine, I just wanted to share with you what I use it for
>generating traffic.
>
>It allows more interesting evaluation like making experiments with
>very short flows and long ones. I think iperf doesn't allow that?
>Well, I didn't look at it since long time ago but I remember that it
>didn't fit with my needs. Evaluating only throught was not enough for
>me. Sessions per seconds are also an interesting value to take into
>account in my case.

Thanks  this was a nice tool.


>
>> iptables just one rule 
>> -A PREROUTING -d 10.0.0.10/32 -j HMARK --hmark-mod 0x2 --hmark-offs 0x64
>> 
>> Some typical values shows ~8% degradation with conntrack loaded
>> 
>> 
>> a) Without conntrack loaded
>> 
>>  [  3]  0.0-10.0 sec  83.5 MBytes  70.0 Mbits/sec
>> 
>> 
>> b) With conntrack loaded (no iptable rules in use --ctstate or -m conntrack)
>> 
>> [  3]  0.0-10.0 sec  78.0 MBytes  65.4 Mbits/sec
>> 
>> c) With iptables rule in use
>> iptables -t mangle -A PREROUTING -d 10.0.0.10 -m conntrack --ctstate NEW -j HMARK --mod 2 --offs 100
>> iptables -t mangle -A PREROUTING -d 10.0.0.10 -m conntrack --ctstate ESTABLISHED,RELATED  -j HMARK --mod 2 --offs 100
>> iptables -t mangle -A PREROUTING -d 10.0.0.10 -m conntrack --ctstate INVALID -j DROP
>
>You have to use connmark so we can skip the hashing in the
>established case, otherwise conntrack is a clear loser :-). The point
>of this experiment is to see if hashing every single packet is more
>performance than hashing only the first one and using the ctmark for
>established connections (so we only hash once!).

I played around with that scenario initially but couldn't see any advantage in performance. 
But now I've made some testing with both iperf & httpclient

Hashing is 6 - 10% faster in any combination. 
There was no significant difference by using save and restore mark < 0.6 Mbit/s

>
>Eric Leblond wrote a nice documentation on connmark in his blog:
>
>http://home.regit.org/netfilter-en/netfilter-connmark/
>
>BTW, that related in the NEW rule. related is similar to New but for
>the first packet of a related connection.
>
>> [  3]  0.0-10.0 sec  77.4 MBytes  64.9 Mbits/sec
>> 
>> 
>> A clean KVM with 3.2.0-rc1 kernel with virt-io 
>> Module                  Size  Used by    Not tainted
>> nf_conntrack_ipv4      16731  1 
>> nf_defrag_ipv4         12436  1 nf_conntrack_ipv4
>> xt_conntrack           12390  1 
>> xt_hmark               12390  1 
>> iptable_mangle         12390  1 
>> ip_tables              20755  1 iptable_mangle
>> ipip                   16515  0 
>> tunnel4                12484  1 ipip
>
>Thanks for taking the time to evaluate this. If you can repeat the
>experiments with my comments, we can get interesting conclusions like
>demystifying the fact that at conntrack is not that bad in terms of
>throughput if you take advantage appropriately of what it provides ;-)

