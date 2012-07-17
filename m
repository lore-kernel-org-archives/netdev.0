From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: That's pretty much it for 3.5.0
Date: Tue, 17 Jul 2012 12:26:25 -0700
Message-ID: <5005BC61.3010209@intel.com>
References: <20120717.090142.125145009944045241.davem@davemloft.net> <997C449C-D599-4F46-A0A3-A2B869DEE36E@intel.com> <DD369258-0958-4965-8E75-F6939892072D@intel.com> <5005B643.2080009@intel.com> <5005B881.8010505@intel.com> <5005BA4C.2000602@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
	"<netfilter-devel@vger.kernel.org>" <netfilter-devel@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2651 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756507Ab2GQT00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 15:26:26 -0400
In-Reply-To: <5005BA4C.2000602@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/17/2012 12:17 PM, John Fastabend wrote:
> On 7/17/2012 12:09 PM, John Fastabend wrote:
>> On 7/17/2012 12:00 PM, John Fastabend wrote:
>>> On 7/17/2012 11:48 AM, Rustad, Mark D wrote:
>>>> On Jul 17, 2012, at 10:41 AM, Rustad, Mark D wrote:
>>>>
>>>>> On Jul 17, 2012, at 9:01 AM, David Miller wrote:
>>>>>
>>>>>> Linus was _extremely_ generous and took in all the stuff that was
>>>>>> pending in the net tree just now.
>>>>>
>>>>> Maybe *too* generous. :-) I just updated and when I boot I get an
>>>>> early crash in update_netdev_tables which is in netprio_cgroup.c.
>>>>>
>>>>>> Besides very serious issues, I'm not willing to consider any more bug
>>>>>> fixes for the 'net' tree at this time.
>>>>>
>>>>> I think the above issue will have to be fixed, as it completely
>>>>> prevents booting for any kernel that includes the netprio_cgroup
>>>>> option.
>>>>>
>>>>>> Only one pending known bug qualifies, and that's the CIPSO ip option
>>>>>> processing OOPS'er.  And I'll work on that myself if Paul Moore
>>>>>> doesn't show a sign of life in the next day.
>>>>>>
>>>>>> Thanks.
>>>>>
>>>>>
>>>>> I can start taking a look at this if you like, but I see that Gao
>>>>> feng has two patches in the last set of patches that may be related.
>>>>>
>>>>> To give you an idea how early the crash is, here are a few log
>>>>> messages leading up to it:
>>>>>
>>>>> [    0.003455] Dentry cache hash table entries: 262144 (order: 9,
>>>>> 2097152 bytes)
>>>>> [    0.005550] Inode-cache hash table entries: 131072 (order: 8,
>>>>> 1048576 bytes)
>>>>> [    0.007165] Mount-cache hash table entries: 256
>>>>> [    0.010289] Initializing cgroup subsys net_cls
>>>>> [    0.010947] Initializing cgroup subsys net_prio
>>>>> [    0.011039] BUG: unable to handle kernel NULL pointer dereference
>>>>> at 0000000000000828
>>>>> [    0.011998] IP: [<ffffffff814202c8>] update_netdev_tables+0x68/0xe0
>>>>
>>>>
>>>> I found that I can avoid the crash by configuring the netprio_cgroup
>>>> as a module. I don't need to have it built in, I just happened to.
>>>> This finding may lower the temperature of this issue a lot from what I
>>>> had been feeling.
>>>>
>>>
>>> hmm looks like we access init_net here,
>>>
>>> static void update_netdev_tables(void)
>>> {
>>>          struct net_device *dev;
>>>          u32 max_len = atomic_read(&max_prioidx) + 1;
>>>          struct netprio_map *map;
>>>
>>>          rtnl_lock();
>>>          for_each_netdev(&init_net, dev) {
>>>                  map = rtnl_dereference(dev->priomap);
>>>                  if ((!map) ||
>>>                      (map->priomap_len < max_len))
>>>                          extend_netdev_table(dev, max_len);
>>>          }
>>>          rtnl_unlock();
>>> }
>>>
>>> but inet_net is initialized by pure_initcall(net_ns_init) and I
>>> gather pure_initcall's should not have any dependencies but it
>>> looks like we created one here with cgroup_init_early() in
>>> start_kernel().
>>>
>>> I'll poke around some more. Also had some off list help from
>>> Mark.
>>>
>>> .John
>>>
>>
>> although we don't have an early_init hook for netprio_cgroup so this
>> is probably not correct.
>
> Hey Mark,
>
> you have better timing then me (I can't make this fail). Can you try
> cgroup_init below rest_init() in start_kernel(). That's in init/main.c
>
> .John
>

ugh nevermind that was stupid... I'm going to stop hitting the lists
with useless noise and be back with a fix in awhile.
