From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: BUG: dst underflow (again)
Date: Sat, 06 Nov 2004 06:17:19 -0200
Message-ID: <418C888F.3060509@conectiva.com.br>
References: <4178AB0D.6060107@pobox.com> <20041022.155159.98771450.yoshfuji@linux-ipv6.org> <20041022075947.GA15795@xi.wantstofly.org> <1099577717.1039.155.camel@jzny.localdomain> <20041104221801.584c8f11.davem@davemloft.net> <20041105091427.GB28112@xi.wantstofly.org> <418B4B1A.8@conectiva.com.br> <20041105101513.GA28779@xi.wantstofly.org> <20041105162319.6e2917c5.davem@davemloft.net> <20041106090211.GA8106@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        yoshfuji@linux-ipv6.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041106090211.GA8106@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Lennert Buytenhek wrote:
> On Fri, Nov 05, 2004 at 04:23:19PM -0800, David S. Miller wrote:
> 
> 
>>>>>IPSEC.. not that I know of.  So unless my distro does stuff behind
>>>>>my back, no.  How do I make sure?
>>>>
>>>>setkey -DP
>>>
>>>Thanks.  Both machines I'm seeing this problem on have:
>>>
>>># setkey -DP
>>>No SPD entries.
>>># 
>>
>>Well, xfrm_lookup() is returning an error somehow, that's the only
>>way to execute dst_release() in udpv6_sendmsg().  And xfrm_lookup()
>>only returns errors if IPSEC policies have been configured either
>>globally or locally for the socket.
> 
> 
> Please note that my traces were made on the Fedora Core 2 kernel
> ('2.6.8-1.521smp'), where these codepaths all look a bit different.
> 
> I'm hoping to try a mainline kernel on one of these boxes soon.
> 


Lennert, could you try to reproduce what I observed at Jeff Garzik's
ipv6 gateway, running first:

[acme@pretzel network-scripts]$ for a in $(seq 1 10) ; do dmesg | grep 
'^BUG: dst underf' | md5sum ; ping6 -c 1 www.linux-ipv6.org | head -2 ; 
sleep 2 ; done
edc1a887cbd8ec99257c5b00a2b95b1e  -
PING www.linux-ipv6.org(pc14.fujisawa.wide.ad.jp) 56 data bytes
64 bytes from pc14.fujisawa.wide.ad.jp: icmp_seq=0 ttl=61 time=302 ms
4b422fb5ef1abd2a9d7c0d2eac16ed95  -
PING www.linux-ipv6.org(pc14.fujisawa.wide.ad.jp) 56 data bytes
64 bytes from pc14.fujisawa.wide.ad.jp: icmp_seq=0 ttl=61 time=308 ms
337774afcf7944ca6f8769b021890bfc  -
PING www.linux-ipv6.org(pc14.fujisawa.wide.ad.jp) 56 data bytes
64 bytes from pc14.fujisawa.wide.ad.jp: icmp_seq=0 ttl=60 time=309 ms
bfb23793729c27093f51f478ce524a15  -
PING www.linux-ipv6.org(pc14.fujisawa.wide.ad.jp) 56 data bytes
64 bytes from pc14.fujisawa.wide.ad.jp: icmp_seq=0 ttl=61 time=308 ms
1fbef3369bdca718e6f59e9ec8ddb540  -
PING www.linux-ipv6.org(pc14.fujisawa.wide.ad.jp) 56 data bytes
64 bytes from pc14.fujisawa.wide.ad.jp: icmp_seq=0 ttl=61 time=308 ms
bd93a08ff06688789ab4e94b761571d6  -
PING www.linux-ipv6.org(pc14.fujisawa.wide.ad.jp) 56 data bytes
64 bytes from pc14.fujisawa.wide.ad.jp: icmp_seq=0 ttl=60 time=308 ms
cdc166d49c07b98a6668af21b7808107  -
PING www.linux-ipv6.org(pc14.fujisawa.wide.ad.jp) 56 data bytes
64 bytes from pc14.fujisawa.wide.ad.jp: icmp_seq=0 ttl=61 time=308 ms
b10df2f221b0a6b9cb80d511ddf0034f  -
PING www.linux-ipv6.org(pc14.fujisawa.wide.ad.jp) 56 data bytes
64 bytes from pc14.fujisawa.wide.ad.jp: icmp_seq=0 ttl=61 time=307 ms
38748d154ea1cce6097221fa442daf57  -
PING www.linux-ipv6.org(pc14.fujisawa.wide.ad.jp) 56 data bytes
64 bytes from pc14.fujisawa.wide.ad.jp: icmp_seq=0 ttl=61 time=307 ms
0d9ee97a76410ed20b2cb0dc958cd146  -
PING www.linux-ipv6.org(pc14.fujisawa.wide.ad.jp) 56 data bytes
64 bytes from pc14.fujisawa.wide.ad.jp: icmp_seq=0 ttl=60 time=308 ms
[acme@pretzel network-scripts]$


then:


[acme@pretzel network-scripts]$ for a in $(seq 1 10) ; do dmesg | grep 
'^BUG: dst underf' | md5sum ; sleep 2 ; done
3079d6c2a8c9be8b97fa31e91f8f37df  -
3079d6c2a8c9be8b97fa31e91f8f37df  -
3079d6c2a8c9be8b97fa31e91f8f37df  -
3079d6c2a8c9be8b97fa31e91f8f37df  -
3079d6c2a8c9be8b97fa31e91f8f37df  -
3079d6c2a8c9be8b97fa31e91f8f37df  -
3079d6c2a8c9be8b97fa31e91f8f37df  -
3079d6c2a8c9be8b97fa31e91f8f37df  -
3079d6c2a8c9be8b97fa31e91f8f37df  -
3079d6c2a8c9be8b97fa31e91f8f37df  -
[acme@pretzel network-scripts]$

The md5sum is just a trick, using wc-l gives a false impression because
the dmesg output wraps around and stays with just BUG underflow...
messages.

Another thing: can you try with IPv6 privacy extensions not built into
the kernel/ipv6 module? I couldn't reproduce it here at home, not sure
why, but I tried with 2.6.9-final (like Jeff's machine) and with latest
Linus BK tree, couldn't reproduce.

The problem (or part of it ;) ) lies in net/ipv6/datagram.c,
ip6_datagram_connect and the functions it calls that end up calling
dst_release, but I don't know that much this code and I'm almost falling
asleep here.

Thanks,

- Arnaldo
