From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next PATCH v4 3/3] net: reserve ports for applications using
 fixed port numbers
Date: Thu, 18 Feb 2010 00:07:08 +0800
Message-ID: <4B7C142C.9040707@redhat.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <201002161306.29708.opurdila@ixiacom.com> <4B7A9852.5020105@redhat.com> <201002161625.22495.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201002161625.22495.opurdila@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Octavian Purdila wrote:
> On Tuesday 16 February 2010 15:06:26 you wrote:
>> Octavian Purdila wrote:
>>> On Tuesday 16 February 2010 11:37:04 you wrote:
>>>>>  	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb));
>>>>>
>>>>> +	sysctl_local_reserved_ports = kzalloc(65536 / 8, GFP_KERNEL);
>>>>> +	if (!sysctl_local_reserved_ports)
>>>>> +		goto out;
>>>>> +
>>>> I think we should also consider the ports in ip_local_port_range,
>>>> since we can only reserve the ports in that range.
>>> That is subject to changes at runtime, which means we will have to
>>> readjust the bitmap at runtime which introduces the need for additional
>>> synchronization operations which I would rather avoid.
>> Why? As long as the bitmap is global, this will not be hard.
>>
> 
> For the more important point see bellow, but with regard to reallocation, this 
> means we need to at least use rcu_read_lock() in the fast path to avoid races 
> between freeing the old bitmap and doing a read in progress. 
> 
> Granted, that is a light operation, but would it makes things so much more 
> complicated just so that we save one memory page (assuming the range is the 
> default [32000 64000] one).


Why not just allocate the bitmap for all ports? 65535/8 bytes are
needed.

> 
>> Consider that if one user writes a port number which is beyond
>> the ip_local_port_range into ip_local_reserved_ports, we should
>> not accept this, because it doesn't make any sense. But with your
>> patch, we do.
>>
> 
> I think it should be allowed. I see ip_local_reserved_ports and ip_local_range 
> as independent settings that can be change at any time.


According to the original purpose, they are not.

> 
> That way I can flag port 8080 even if the current range is [32000, 64000] and 
> then later I can expand the range to [1024, 64000] without loosing the 8080 
> reservation.

Then its meaning is changed, bind(0) will never have chance to get 8080,
thus reserving 8080 for this purpose fails.

I want to always keep its original meaning, if the local_port_range goes
out, then local_reserved_port should be empty at the same time, you have
to reset it after changing local_port_range.
