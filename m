From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: mlx4: dropping multicast packets at promisc leave
Date: Thu, 20 Sep 2012 12:04:40 -0300
Message-ID: <505B3088.7090908@redhat.com>
References: <505A66CC.8010701@redhat.com> <505B1874.3040904@mellanox.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755941Ab2ITPEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 11:04:48 -0400
In-Reply-To: <505B1874.3040904@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2012 10:21 AM, Or Gerlitz wrote:
> On 20/09/2012 03:43, Marcelo Ricardo Leitner wrote:
>> I have a report that our mlx4 driver (RHEL 6.3) is dropping multicast
>> packets when NIC leaves promisc mode. It seems this is being cause due
>> to the new steering mode that took place near by commit
>> 1679200f91da6a054b06954c9bd3eeed29b6731f. As it seems, the new
>> steering mode needs more commands/time to leave the promisc mode,
>> which may be leading to packet drops.
>
> Marcelo,
>
> The commit you point on below 6d19993 "net/mlx4_en: Re-design multicast
> attachments flow" makes sure to avoid
> doing extra firmware comments and not leave a window in time where
> "correct" addresses are not attached. Its hard to say what's the case on
> that RHEL 6.3 system, it would be very helpful through if you manage to
> reproduce the problem on an upstream kernel -- BTW you didn't say on

Okay, I understand that the commit prevents a window. I may be missing 
something, but isn't there another one in there? Between:
mlx4_SET_MCAST_FLTR MLX4_MCAST_DISABLE and
mlx4_SET_MCAST_FLTR MLX4_MCAST_ENABLE
because mlx4_multicast_promisc_remove() was called just before those.
Otherwise I don't how is the NIC would be receiving multicast packets in 
there.

I understand the difficulty about the kernel version, I am sorry for 
that. As I'm unable to reproduce the issue by myself, I couldn't run a 
test in a plain upstream kernel so far or experiment much.

I was holding this email: I just access to a server that seems to 
reproduce the issue. It has a MT27500 ConnectX-3 NIC. Only tried our 
RHEL 6.3 stock so far. Keep you posted on further tests!

This was the result of ifconfig mlx4_2 -promisc:
[  3] 34.0-35.0 sec  61.7 MBytes   517 Mbits/sec   0.024 ms  274/43502 
(0.63%)
[  3] 34.0-35.0 sec  756 datagrams received out-of-order

> which kernel you are trying to reproduce this, note that upstream has
> also commit 60d31c1475f2 "net/mlx4_core: Looking for promiscuous entries
> on the correct port" (reported by you...) , so if somehow this commit
> makes the diff you could use it also on their system.

Sorry, that would be 2.6.32-279.el6. It has additional commits up to 
somewhere near commit
58a3de0 - mlx4_core: fix race on comm channel
but maybe not all before that one. Can't tell you for sure.

And then I tried 3 additional patches applied at once:
- 60d31c1475f2 "net/mlx4_core: Looking for promiscuous entries on the 
correct port"
- f1f75f0 - mlx4: attach multicast with correct flag
   - Yes, this one wasn't in 2.6.32-279.el6.
- 6d19993 - net/mlx4_en: Re-design multicast attachments flow

And they still reported drops.

>> It takes 300ms to perform the change there against my 600us. Hitting
>> something like tcpdump -c 10 in a loop helps triggering it.
>
> Do you have any insight for this huge difference?

No idea. Couldn't track it yet.

Thanks,
Marcelo.
