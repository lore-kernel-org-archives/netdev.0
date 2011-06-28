From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH V7 2/4 net-next] skbuff: Add userspace zero-copy	buffers
 in skb
Date: Tue, 28 Jun 2011 10:19:48 -0700
Message-ID: <4E0A0D34.2070507@hp.com>
References: <1306610588.5180.87.camel@localhost.localdomain>	<1309189510.21764.1.camel@localhost.localdomain>	<20110627.155426.51839633424542723.davem@davemloft.net> <1309279892.3559.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	eric.dumazet@gmail.com, avi@redhat.com, arnd@arndb.de,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1309279892.3559.6.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/28/2011 09:51 AM, Shirley Ma wrote:
> On Mon, 2011-06-27 at 15:54 -0700, David Miller wrote:
>> From: Shirley Ma<mashirle@us.ibm.com>
>> Date: Mon, 27 Jun 2011 08:45:10 -0700
>>
>>> To support skb zero-copy, a pointer is needed to add to skb share
>> info.
>>> Do you agree with this approach? If not, do you have any other
>>> suggestions?
>>
>> I really can't form an opinion unless I am shown the complete
>> implementation, what this give us in return, what the impact is, etc.
>
> zero-copy skb buffers can save significant CPUs. Right now, I only
> implements macvtap/vhost zero-copy between KVM guest and host. The
> performance is as follow:
>
> Single TCP_STREAM 120 secs test results 2.6.39-rc3 over ixgbe 10Gb NIC
> results:
>
> Message BW(Gb/s)qemu-kvm (NumCPU)vhost-net(NumCPU) PerfTop irq/s
> 4K      7408.57         92.1%           22.6%           1229
> 4K(Orig)4913.17         118.1%          84.1%           2086
>
> 8K      9129.90         89.3%           23.3%           1141
> 8K(Orig)7094.55         115.9%          84.7%           2157
>
> 16K     9178.81         89.1%           23.3%           1139
> 16K(Orig)8927.1         118.7%          83.4%           2262
>
> 64K     9171.43         88.4%           24.9%           1253
> 64K(Orig)9085.85        115.9%          82.4%           2229
>
> You can see the overall CPU saved 50% w/i zero-copy.

While this isn't the copy between netperf and the stack, at some point 
you may want to enable netperf's "DIRTY" mode (./configure 
--enable-dirty) to cause it to start either dirtying buffers before 
send, or reading from buffers after receive.  I cannot guarantee that 
there hasn't been bitrot in that area of netperf though :)  Particularly 
in a TCP_MAERTS test.  The "DIRTY" mode code will not do anything in a 
TCP_SENDFILE test.

A simple sanity check of the effect of the changes on a TCP_RR test 
would probably be goodness as well.

happy benchmarking,

rick jones
one of these days I'll have to find a good way to get accurate overall 
CPU utilization from within a guest and teach netperf about it.

>
> The impact is every skb allocation consumed one more pointer in skb
> share info, and a pointer check in skb release when last reference is
> gone.
>
> For skb clone, skb expand private head and skb copy, it still keeps copy
> the buffers to kernel, so we can avoid user application, like tcpdump to
> hold the user-space buffers too long.
>
> Thanks
> Shirley
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
