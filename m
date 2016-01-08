From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
 flow_keys layout
Date: Thu, 07 Jan 2016 22:16:46 -0800
Message-ID: <568F544E.3010702@gmail.com>
References: <1452159189-11473-1-git-send-email-vkuznets@redhat.com>	<1452171150.8255.207.camel@edumazet-glaptop2.roam.corp.google.com>
 <877fjlfrid.fsf@vitty.brq.redhat.com> <568F0A90.8040109@gmail.com>
 <BY2PR0301MB1654E8D1527055DCF31139D2A0F60@BY2PR0301MB1654.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 David Miller <davem@davemloft.net>
To: KY Srinivasan <kys@microsoft.com>, Vitaly Kuznetsov <vkuznets@redhat.com>,
 Simon Xiao <sixiao@microsoft.com>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <BY2PR0301MB1654E8D1527055DCF31139D2A0F60@BY2PR0301MB1654.namprd03.prod.outlook.com>
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

On 16-01-07 07:49 PM, KY Srinivasan wrote:
> 
> 
>> -----Original Message-----
>> From: John Fastabend [mailto:john.fastabend@gmail.com]
>> Sent: Thursday, January 7, 2016 5:02 PM
>> To: Vitaly Kuznetsov <vkuznets@redhat.com>; Simon Xiao
>> <sixiao@microsoft.com>; Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Tom Herbert <tom@herbertland.com>; netdev@vger.kernel.org; KY
>> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>;
>> devel@linuxdriverproject.org; linux-kernel@vger.kernel.org; David Miller
>> <davem@davemloft.net>
>> Subject: Re: [PATCH net-next] hv_netvsc: don't make assumptions on struct
>> flow_keys layout
>>
>> On 16-01-07 05:28 AM, Vitaly Kuznetsov wrote:
>>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>>
>>>> On Thu, 2016-01-07 at 10:33 +0100, Vitaly Kuznetsov wrote:
>>>>> Recent changes to 'struct flow_keys' (e.g commit d34af823ff40 ("net: Add
>>>>>  VLAN ID to flow_keys")) introduced a performance regression in netvsc
>>>>> driver. Is problem is, however, not the above mentioned commit but the
>>>>> fact that netvsc_set_hash() function did some assumptions on the struct
>>>>> flow_keys data layout and this is wrong. We need to extract the data we
>>>>> need (src/dst addresses and ports) after the dissect.
>>>>>
>>>>> The issue could also be solved in a completely different way: as suggested
>>>>> by Eric instead of our own homegrown netvsc_set_hash() we could use
>>>>> skb_get_hash() which does more or less the same. Unfortunately, the
>>>>> testing done by Simon showed that Hyper-V hosts are not happy with our
>>>>> Jenkins hash, selecting the output queue with the current algorithm based
>>>>> on Toeplitz hash works significantly better.
>>>>
>>
>> Also can I ask the maybe naive question. It looks like the hypervisor
>> is populating some table via a mailbox msg and this is used to select
>> the queues I guess with some sort of weighting function?
>>
>> What happens if you just remove select_queue altogether? Or maybe just
>> what is this 16 entry table doing? How does this work on my larger
>> systems with 64+ cores can I only use 16 cores? Sorry I really have
>> no experience with hyperV and this got me curious.
> 
> We will limit the number of VRSS channels to the number of CPUs in
> a NUMA node. If the number of CPUs in a NUMA node exceeds 8, we
> will only open up 8 VRSS channels. On the host side currently traffic
> spreading is done in software and we have found that limiting to 8 CPUs
> gives us the best throughput. In Windows Server 2016, we will be 
> distributing traffic on the host in hardware; the heuristics in the guest
> may change.
> 
> Regards,
> 
> K. Y

I think a better way to do this would be to query the numa node when
the interface comes online via dev_to_node() and then use cpu_to_node()
or create/find some better variant to get a list of cpus on the numa
node.

At this point you can use the xps mapping interface
netif_set_xps_queue() to get the right queue to cpu binding. If you want
to cap it to max 8 queues that works as well. I don't think there is
any value to have more tx queues than number of cpus in use.

If you do it this way all the normal mechanisms to setup queue mappings
will work for users who are doing some special configuration and the
default will still be what you want.

I guess I should go do this numa mapping for ixgbe and friends now that
I mention it. Last perf numbers I had showed cross numa affinitizing
was pretty bad.

Thanks,
John
