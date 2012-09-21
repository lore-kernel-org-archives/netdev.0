From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: mlx4: dropping multicast packets at promisc leave
Date: Fri, 21 Sep 2012 15:32:29 -0300
Message-ID: <505CB2BD.4080402@redhat.com>
References: <505A66CC.8010701@redhat.com> <505B1874.3040904@mellanox.com> <505B3088.7090908@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58802 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757349Ab2IUScl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2012 14:32:41 -0400
In-Reply-To: <505B3088.7090908@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2012 12:04 PM, Marcelo Ricardo Leitner wrote:
> On 09/20/2012 10:21 AM, Or Gerlitz wrote:
>> On 20/09/2012 03:43, Marcelo Ricardo Leitner wrote:
>>> I have a report that our mlx4 driver (RHEL 6.3) is dropping multicast
>>> packets when NIC leaves promisc mode. It seems this is being cause due
>>> to the new steering mode that took place near by commit
>>> 1679200f91da6a054b06954c9bd3eeed29b6731f. As it seems, the new
>>> steering mode needs more commands/time to leave the promisc mode,
>>> which may be leading to packet drops.
>>
>> Marcelo,
>>
>> The commit you point on below 6d19993 "net/mlx4_en: Re-design multicast
>> attachments flow" makes sure to avoid
>> doing extra firmware comments and not leave a window in time where
>> "correct" addresses are not attached. Its hard to say what's the case on
>> that RHEL 6.3 system, it would be very helpful through if you manage to
>> reproduce the problem on an upstream kernel -- BTW you didn't say on
>
> Okay, I understand that the commit prevents a window. I may be missing
> something, but isn't there another one in there? Between:
> mlx4_SET_MCAST_FLTR MLX4_MCAST_DISABLE and
> mlx4_SET_MCAST_FLTR MLX4_MCAST_ENABLE
> because mlx4_multicast_promisc_remove() was called just before those.
> Otherwise I don't how is the NIC would be receiving multicast packets in
> there.
>
....
> And then I tried 3 additional patches applied at once:
> - 60d31c1475f2 "net/mlx4_core: Looking for promiscuous entries on the
> correct port"
> - f1f75f0 - mlx4: attach multicast with correct flag
> - Yes, this one wasn't in 2.6.32-279.el6.
> - 6d19993 - net/mlx4_en: Re-design multicast attachments flow
>
> And they still reported drops.

Hi, updates on this. In summary, I couldn't reproduce it when using 
upstream kernel, even on a machine which I've seen the drops.

Checking with customer, they could reproduce the issue once when using 
commit 6d19993 but cannot reproduce it anymore.

I also could reproduce it but it gets much harder to trigger when using 
commit 6d19993.

I could run some tests with net tree kernel (up to 8ea853fd) and I 
didn't see any drops so far. More bellow.

>>> It takes 300ms to perform the change there against my 600us. Hitting
>>> something like tcpdump -c 10 in a loop helps triggering it.
>>
>> Do you have any insight for this huge difference?
>
> No idea. Couldn't track it yet.

Now I might have. ksoftirqd/0 is being triggered when running 500Mbit 
multicast traffic via iperf and is hitting 90% CPU usage. Seems it is 
blocking the execution of mlx4_en_do_set_multicast() sometimes.

This happens at my reproducer only. It does not happen on the other 
server. Customer also doesn't see it, but see the delays. They just see 
mlx4_en thread running when running tcpdump in cycles, but that is expected.

Upstream (net tree) kernel doesn't do this, even at my reproducer box.

Simple perf record/report gave me:

# Overhead      Command      Shared Object     Symbol
# ........  ...........  .................     .....................
#
      98.16%  ksoftirqd/0  [kernel.kallsyms]  [k]
  fix_small_imbalance
              |
              --- fix_small_imbalance
                  find_busiest_group
                  rebalance_domains
                  run_rebalance_domains
                  __do_softirq
                  call_softirq
                  ksoftirqd
                  kthread
                  child_rip

I could see:
[60315.574258] mlx4_core 0000:01:00.0: remove_promisc_qp 483
[60315.579652] mlx4_core 0000:01:00.0: remove_promisc_qp 485

And that was:
  482         /*remove from list of promisc qps */
  483         mlx4_warn(dev, "%s %d\n", __FUNCTION__, __LINE__);
  484         list_del(&pqp->list);
  485         mlx4_warn(dev, "%s %d\n", __FUNCTION__, __LINE__);

That really shouldn't take that long, and it doesn't when it's idle. 
Might that weird behavior open some window where NIC is configured in a 
such way that it doesn't receive the packets?

But well, this may be causing the drops somewhere else. I still have to 
check that.

Many thanks,
Marcelo.
