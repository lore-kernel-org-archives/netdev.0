From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Thu, 14 Jan 2016 09:14:12 -0800
Message-ID: <CALx6S35PbTHF7nY0ugtxCUkc5kUmMYAyuy6ZM34bZ9v42nDudg@mail.gmail.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
 <20160110.172558.367101858392871618.davem@davemloft.net>
 <BN1PR0301MB07701A189AABFBF664B5775BCACB0@BN1PR0301MB0770.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <BN1PR0301MB07701A189AABFBF664B5775BCACB0@BN1PR0301MB0770.namprd03.prod.outlook.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> I have done a comparison of the Toeplitz v.s. Jenkins Hash algorithms,
> and found that the Toeplitz provides much better distribution of the
> connections into send-indirection-table entries. See the data below --
> showing how many TCP connections are distributed into each of the
> sixteen table entries. The Toeplitz hash distributes the connections
> almost perfectly evenly, but the Jenkins hash distributes them unevenly.
> For example, in case of 64 connections, some entries are 0 or 1, some
> other entries are 8. This could cause too many connections in one VMBus
> channel and slow down the throughput. This is consistent to our test
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
These results for Toeplitz are not plausible. Given random input you
cannot expect any hash function to produce such uniform results. I
suspect either your input data is biased or how your applying the hash
is.

When I run 64 random IPv4 3-tuples through Toeplitz and Jenkins I get
something more reasonable:

Toeplitz
Buckets: 3 7 4 5 3 6 2 6 2 4 4 5 4 3 2 4

Jenkins
Buckets: 6 7 4 4 3 2 6 3 1 4 3 5 5 4 4 3

> Throughput (Gbps) comparison:
> #conn           Toeplitz        Jenkins
> 32              26.6            23.2
> 64              32.1            23.4
> 128             29.1            24.1
>
> For long term solution, I think we should put the Toeplitz hash as
> another option to the generic hash function in kernel... But, for the
> time being, can you accept this patch to fix the assumptions on
> struct flow_keys layout?
>
Toeplitz is about a 100x more expensive to compute in the CPU than
Jenkins, we can get that down to 50x by precomputing a bunch of lookup
tables for a given key but that is at the expense of memory. Besides
that, there is a fair amount of analysis already showing that Jenkins
hash provides a good distribution and has good enough (though not
great) Avalanche effect. Probably the only reason we would need
Toeplitz in SW is if we wanted to match a computation being done by
HW.

One hash that might be better than Jenkins is CRC. This seems to have
good uniformity and Avalanche effect, and by using crc32 instruction
it seems be a little faster than running Jenkins hash.

Tom

> Thanks,
> - Haiyang
>
