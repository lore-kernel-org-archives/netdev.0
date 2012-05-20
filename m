From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun
 Fire X4150(x86) and e1000e
Date: Sun, 20 May 2012 20:13:58 +0200
Message-ID: <1337537638.24892.6.camel@edumazet-glaptop>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, davem@davemloft.net, therbert@google.com
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 2012-05-18 at 17:04 +0300, Denys Fedoryshchenko wrote:
> It seems logic in BQL has serious issues. The most bad thing, if 

> and it is empty. So in result, instead of eliminating latency, it is 
> adding it.

There is maybe a misunderstanding here. BQL by itself only reduce amount
of buffering in TX ring. Now there's still the Qdisc layer.

On my laptop (e1000e NIC), and default pfifo_fast I can immediately see
the difference in ping results if I launch a single netperf TCP_STREAM
in another window :

1480 bytes from 172.30.42.1: icmp_seq=5047 ttl=64 time=0.185 ms
1480 bytes from 172.30.42.1: icmp_seq=5048 ttl=64 time=0.198 ms
1480 bytes from 172.30.42.1: icmp_seq=5049 ttl=64 time=0.255 ms
1480 bytes from 172.30.42.1: icmp_seq=5050 ttl=64 time=0.182 ms
1480 bytes from 172.30.42.1: icmp_seq=5051 ttl=64 time=0.182 ms
1480 bytes from 172.30.42.1: icmp_seq=5052 ttl=64 time=0.226 ms
1480 bytes from 172.30.42.1: icmp_seq=5053 ttl=64 time=0.186 ms
1480 bytes from 172.30.42.1: icmp_seq=5054 ttl=64 time=0.190 ms
1480 bytes from 172.30.42.1: icmp_seq=5055 ttl=64 time=0.223 ms
1480 bytes from 172.30.42.1: icmp_seq=5056 ttl=64 time=0.178 ms
1480 bytes from 172.30.42.1: icmp_seq=5057 ttl=64 time=0.191 ms
1480 bytes from 172.30.42.1: icmp_seq=5058 ttl=64 time=0.229 ms
1480 bytes from 172.30.42.1: icmp_seq=5059 ttl=64 time=0.229 ms
1480 bytes from 172.30.42.1: icmp_seq=5060 ttl=64 time=0.213 ms
1480 bytes from 172.30.42.1: icmp_seq=5061 ttl=64 time=0.187 ms
1480 bytes from 172.30.42.1: icmp_seq=5062 ttl=64 time=0.944 ms
1480 bytes from 172.30.42.1: icmp_seq=5063 ttl=64 time=4.67 ms
1480 bytes from 172.30.42.1: icmp_seq=5064 ttl=64 time=8.55 ms
1480 bytes from 172.30.42.1: icmp_seq=5065 ttl=64 time=12.8 ms
1480 bytes from 172.30.42.1: icmp_seq=5066 ttl=64 time=16.9 ms
1480 bytes from 172.30.42.1: icmp_seq=5067 ttl=64 time=20.5 ms
1480 bytes from 172.30.42.1: icmp_seq=5068 ttl=64 time=24.3 ms
1480 bytes from 172.30.42.1: icmp_seq=5069 ttl=64 time=27.0 ms
1480 bytes from 172.30.42.1: icmp_seq=5070 ttl=64 time=26.8 ms
1480 bytes from 172.30.42.1: icmp_seq=5071 ttl=64 time=26.7 ms
1480 bytes from 172.30.42.1: icmp_seq=5072 ttl=64 time=26.0 ms
1480 bytes from 172.30.42.1: icmp_seq=5073 ttl=64 time=27.0 ms
1480 bytes from 172.30.42.1: icmp_seq=5074 ttl=64 time=25.6 ms
1480 bytes from 172.30.42.1: icmp_seq=5075 ttl=64 time=26.7 ms
1480 bytes from 172.30.42.1: icmp_seq=5076 ttl=64 time=26.9 ms
1480 bytes from 172.30.42.1: icmp_seq=5077 ttl=64 time=25.0 ms


Now if I replace pfifo_fast by fq_codel : (still TSO and GSO are on)

1480 bytes from 172.30.42.1: icmp_seq=37 ttl=64 time=0.197 ms
1480 bytes from 172.30.42.1: icmp_seq=38 ttl=64 time=0.283 ms
1480 bytes from 172.30.42.1: icmp_seq=39 ttl=64 time=0.183 ms
1480 bytes from 172.30.42.1: icmp_seq=40 ttl=64 time=0.182 ms
1480 bytes from 172.30.42.1: icmp_seq=41 ttl=64 time=0.207 ms
1480 bytes from 172.30.42.1: icmp_seq=42 ttl=64 time=0.202 ms
1480 bytes from 172.30.42.1: icmp_seq=43 ttl=64 time=0.244 ms
1480 bytes from 172.30.42.1: icmp_seq=44 ttl=64 time=0.200 ms
1480 bytes from 172.30.42.1: icmp_seq=45 ttl=64 time=0.212 ms
1480 bytes from 172.30.42.1: icmp_seq=46 ttl=64 time=0.215 ms
1480 bytes from 172.30.42.1: icmp_seq=47 ttl=64 time=0.178 ms
1480 bytes from 172.30.42.1: icmp_seq=48 ttl=64 time=0.215 ms
1480 bytes from 172.30.42.1: icmp_seq=49 ttl=64 time=0.238 ms
1480 bytes from 172.30.42.1: icmp_seq=50 ttl=64 time=0.210 ms
1480 bytes from 172.30.42.1: icmp_seq=51 ttl=64 time=0.974 ms   
1480 bytes from 172.30.42.1: icmp_seq=52 ttl=64 time=1.93 ms
1480 bytes from 172.30.42.1: icmp_seq=53 ttl=64 time=1.71 ms
1480 bytes from 172.30.42.1: icmp_seq=54 ttl=64 time=3.07 ms
1480 bytes from 172.30.42.1: icmp_seq=55 ttl=64 time=3.47 ms
1480 bytes from 172.30.42.1: icmp_seq=56 ttl=64 time=2.53 ms
1480 bytes from 172.30.42.1: icmp_seq=57 ttl=64 time=3.24 ms
1480 bytes from 172.30.42.1: icmp_seq=58 ttl=64 time=3.11 ms
1480 bytes from 172.30.42.1: icmp_seq=59 ttl=64 time=3.03 ms
1480 bytes from 172.30.42.1: icmp_seq=60 ttl=64 time=2.96 ms
1480 bytes from 172.30.42.1: icmp_seq=61 ttl=64 time=2.90 ms
1480 bytes from 172.30.42.1: icmp_seq=62 ttl=64 time=2.97 ms



------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
