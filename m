From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Wed, 13 Jan 2016 23:10:57 +0000
Message-ID: <BN1PR0301MB07701A189AABFBF664B5775BCACB0@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>
 <20160110.172558.367101858392871618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>, "vkuznets@redhat.com"
 <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160110.172558.367101858392871618.davem@davemloft.net>
Content-Language: en-US
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



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Sunday, January 10, 2016 5:26 PM
> To: vkuznets@redhat.com
> Cc: netdev@vger.kernel.org; KY Srinivasan <kys@microsoft.com>; Haiyang
> Zhang <haiyangz@microsoft.com>; devel@linuxdriverproject.org; linux-
> kernel@vger.kernel.org; eric.dumazet@gmail.com
> Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on
> struct flow_keys layout
> 
> From: Vitaly Kuznetsov <vkuznets@redhat.com>
> Date: Thu,  7 Jan 2016 10:33:09 +0100
> 
> > Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net:
> Add
> >  VLAN ID to flow_keys")) introduced a performance regression in netvsc
> > driver. Is problem is, however, not the above mentioned commit but the
> > fact that netvsc_set_hash() function did some assumptions on the
> struct
> > flow_keys data layout and this is wrong. We need to extract the data
> we
> > need (src/dst addresses and ports) after the dissect.
> >
> > The issue could also be solved in a completely different way: as
> suggested
> > by Eric instead of our own homegrown netvsc_set_hash() we could use
> > skb_get_hash() which does more or less the same. Unfortunately, the
> > testing done by Simon showed that Hyper-V hosts are not happy with our
> > Jenkins hash, selecting the output queue with the current algorithm
> based
> > on Toeplitz hash works significantly better.
> >
> > Tested-by: Simon Xiao <sixiao@microsoft.com>
> > Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> 
> Stop using this Toeplitz thing and just use the proper hash the stack
> is already calculating for you.
> 
> There is no way this is faster, and the continued attempts to
> shoe-horn Toeplitz usage into this driver is resulting in incredibly
> ugly and rediculous code.
> 
> I'm not applying any patches that further the use of Toeplitz as the
> hash function in this driver.  You must use the clean,
> efficient, facilities the kernel has already for packet hashing.
> 
> If every driver did what you guys are doing, we'd be in a heap of
> trouble, and I'm simply not going to allow this to continue any
> longer.
> 
> Thanks.

I have done a comparison of the Toeplitz v.s. Jenkins Hash algorithms, 
and found that the Toeplitz provides much better distribution of the 
connections into send-indirection-table entries. See the data below -- 
showing how many TCP connections are distributed into each of the 
sixteen table entries. The Toeplitz hash distributes the connections 
almost perfectly evenly, but the Jenkins hash distributes them unevenly. 
For example, in case of 64 connections, some entries are 0 or 1, some 
other entries are 8. This could cause too many connections in one VMBus 
channel and slow down the throughput. This is consistent to our test 
which showing slower performance while using the generic skb_get_hash 
(Jenkins) than using Toeplitz hash (see perf numbers below).


#connections:32:
Toeplitz:2,2,2,2,2,1,2,2,2,2,2,3,2,2,2,2,
Jenkins:3,2,2,4,1,1,0,2,1,1,4,3,2,5,1,0,
#connections:64:
Toeplitz:4,4,5,4,4,3,4,4,4,4,4,4,4,4,4,4,
Jenkins:4,5,4,6,3,5,0,6,1,2,8,3,6,8,2,1,
#connections:128:
Toeplitz:8,8,8,8,8,7,9,8,8,8,8,8,8,8,8,8,
Jenkins:8,12,10,9,7,8,3,10,6,8,9,8,10,11,6,3,

Throughput (Gbps) comparison:
#conn		Toeplitz	Jenkins
32		26.6		23.2
64		32.1		23.4
128		29.1		24.1

For long term solution, I think we should put the Toeplitz hash as 
another option to the generic hash function in kernel... But, for the 
time being, can you accept this patch to fix the assumptions on 
struct flow_keys layout?

Thanks,
- Haiyang
