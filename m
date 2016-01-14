From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Thu, 14 Jan 2016 09:53:13 -0800
Message-ID: <1452793993.1223.102.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
	 <20160110.172558.367101858392871618.davem@davemloft.net>
	 <BN1PR0301MB07701A189AABFBF664B5775BCACB0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"vkuznets@redhat.com" <vkuznets@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN1PR0301MB07701A189AABFBF664B5775BCACB0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-01-13 at 23:10 +0000, Haiyang Zhang wrote:

> I have done a comparison of the Toeplitz v.s. Jenkins Hash algorithms, 
> and found that the Toeplitz provides much better distribution of the 
> connections into send-indirection-table entries. See the data below -- 
> showing how many TCP connections are distributed into each of the 
> sixteen table entries. The Toeplitz hash distributes the connections 
> almost perfectly evenly, but the Jenkins hash distributes them unevenly. 
> For example, in case of 64 connections, some entries are 0 or 1, some 
> other entries are 8. This could cause too many connections in one VMBus 
> channel and slow down the throughput.

So a VMBus channel has a limit of number of flows ? Why is it so ?

What happens with 1000 flows ?

>  This is consistent to our test 
> which showing slower performance while using the generic skb_get_hash 
> (Jenkins) than using Toeplitz hash (see perf numbers below).
> 
> 
> #connections:32:
> Toeplitz:2,2,2,2,2,1,2,2,2,2,2,3,2,2,2,2,
> Jenkins:3,2,2,4,1,1,0,2,1,1,4,3,2,5,1,0,
> #connections:64:
> Toeplitz:4,4,5,4,4,3,4,4,4,4,4,4,4,4,4,4,
> Jenkins:4,5,4,6,3,5,0,6,1,2,8,3,6,8,2,1,
> #connections:128:
> Toeplitz:8,8,8,8,8,7,9,8,8,8,8,8,8,8,8,8,
> Jenkins:8,12,10,9,7,8,3,10,6,8,9,8,10,11,6,3,
> 
> Throughput (Gbps) comparison:
> #conn		Toeplitz	Jenkins
> 32		26.6		23.2
> 64		32.1		23.4
> 128		29.1		24.1
> 
> For long term solution, I think we should put the Toeplitz hash as 
> another option to the generic hash function in kernel... But, for the 
> time being, can you accept this patch to fix the assumptions on 
> struct flow_keys layout?


I find your Toeplitz distribution has an anomaly.

Having 128 connections distributed almost _perfectly_ into 16 buckets is
telling something how the source/destination ports where allocated
maybe, knowing the RSS key or something ?

It looks too _perfect_ to be true.

Here what I get here from 20 runs of 128 sessions using 
prandom_u32() hash, distributed to 16 buckets (hash % 16)

: 6,9,9,6,11,8,9,7,7,7,9,8,8,7,9,8
: 6,9,6,6,6,9,8,5,12,10,7,7,9,7,13,8
: 7,4,9,9,10,9,8,7,15,4,8,8,11,10,2,7
: 12,5,10,6,7,4,10,10,6,5,10,14,8,8,5,8
: 4,8,5,13,7,4,7,9,7,6,6,9,6,11,17,9
: 10,10,8,5,7,4,5,14,6,9,9,7,8,9,7,10
: 6,4,9,10,13,8,8,7,6,5,8,9,7,5,15,8
: 11,13,7,4,8,6,6,9,10,8,8,5,6,6,11,10
: 8,8,11,7,12,13,5,8,9,6,8,10,5,4,9,5
: 13,5,5,4,5,11,8,8,11,8,9,10,10,6,9,6
: 13,6,12,6,6,7,4,9,5,14,9,12,9,4,4,8
: 4,9,10,12,10,4,8,6,8,5,14,10,5,8,8,7
: 7,7,6,6,12,13,8,12,7,6,8,9,6,5,12,4
: 4,12,9,10,2,12,10,13,5,8,4,6,8,10,4,11
: 5,6,10,10,10,9,16,8,8,7,4,10,7,6,6,6
: 9,13,10,11,6,9,4,7,7,9,7,6,9,9,7,5
: 8,7,4,8,6,9,9,8,7,10,8,10,17,7,5,5
: 10,5,10,8,9,5,9,6,12,8,5,8,7,9,7,10
: 8,10,10,7,10,7,13,3,9,5,7,2,10,9,12,6
: 4,6,13,6,6,6,12,9,11,5,7,10,9,8,11,5

This looks more 'random' to me, and _if_ I use Jenkins hash I have the
same distribution.

Sure, it is not 'perfectly spread', but who said that all flows are
sending the same amount of traffic in the real world ?

Using Toeplitz hash is adding a cost of 300 ns per IPV6 packet.

TCP_RR (small RPC) workload would certainly not like to compute Toeplitz
for every packet.

I would like we do not add complexity just to make some benchmark
better.
