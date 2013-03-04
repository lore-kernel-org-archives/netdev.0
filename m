From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [RFC PATCH 1/5] net: implement support for low latency socket
 polling
Date: Mon, 04 Mar 2013 10:43:36 +0200
Message-ID: <51345EB8.9050309@linux.intel.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>  <20130227175555.10611.42794.stgit@gitlad.jf.intel.com> <1362335704.15793.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362335704.15793.81.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/03/2013 20:35, Eric Dumazet wrote:
> On Wed, 2013-02-27 at 09:55 -0800, Eliezer Tamir wrote:
>
>> index 821c7f4..d1d1016 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -408,6 +408,10 @@ struct sk_buff {
>>   	struct sock		*sk;
>>   	struct net_device	*dev;
>>
>> +#ifdef CONFIG_INET_LL_RX_POLL
>> +	struct napi_struct	*dev_ref; /* where this skb came from */
>> +#endif
>> +
>>   	/*
>>   	 * This is the control buffer. It is free to use for every
>>   	 * layer. Please put your private variables there. If you
>
> Yes, thats the killer, because :
>
> 1) It adds 8 bytes per skb, and we are going to reach the 256 bytes per
> sk_buff boundary. cloned skbs will use an extra cache line.
>
> It might make sense to union this on dma_cookie, as dma_cookie is only
> used on TX path.

I will try this out.

> 2) We need to reference count napi structs.
>
> For 2) , we would need to add a percpu ref counter (a bit like struct
> netdevice -> pcpu_refcnt)
>
> Alternative to 2) would be to use a generation id, incremented every
> time a napi used in spin polling enabled driver is dismantled (and freed
> after RCU grace period)

I like this option, because one would assume that the life expectancy of 
a napi is rather long. We can just increment the generation id any time 
any napi is disabled, which simplifies things.

There could be other configuration changes that would make our notion on 
where to poll outdated, for example, someone may have reprogrammed an RX 
filter. This is not as catastrophic as a napi going away but still.

Would it make sense to make this a generic mechanism?
One could for example increment the generation id every time the RTNL is 
taken. or is this too much?

Thanks,
Eliezer
