From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] net: fix incorrect counting in __scm_destroy()
Date: Tue, 10 Nov 2009 14:12:49 +0800
Message-ID: <4AF90461.5090800@redhat.com>
References: <20091104100717.4785.57149.sendpatchset@localhost.localdomain>	<4AF15771.8060204@gmail.com> <20091104.044116.37320720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751688AbZKJGJ4@vger.kernel.org>
In-Reply-To: <20091104.044116.37320720.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 04 Nov 2009 11:29:05 +0100
> 
>> Given we kfree(fpl) at the end of loop, we cannot recursively call
>> __scm_destroy() on same fpl, it would be a bug anyway ?
>>
>> So you probably need something better, like testing fpl->list being
>> not re-included in current->scm_work_list before kfree() it
> 
> I can't even see what the problem is.
> 
> The code is designed such that the ->count only matters for
> the top level.
> 
> If we recursively fput() and get back here, we'll see that
> there is someone higher in the call chain already running
> the fput() loop and we'll just list_add_tail().
> 
> The inner while() loop will make sure we process such
> entries once we get back to the top level and exit the
> for() loop.
> 
> Amerigo, please show us the problematic code path where the counts go
> wrong and this causes problems.

Hi, all.

Thanks for your replies.

I met a soft lockup around this code on ia64, something like:

  [<a0000001006394e0>] unix_gc+0x240/0x760
                                 sp=e0000260f002fd70 bsp=e0000260f0029560
  [<a000000100634500>] unix_release_sock+0x440/0x460
                                 sp=e0000260f002fdb0 bsp=e0000260f0029508
  [<a000000100634560>] unix_release+0x40/0x60
                                 sp=e0000260f002fdb0 bsp=e0000260f00294e8
  [<a00000010051fba0>] sock_release+0x80/0x1c0
                                 sp=e0000260f002fdb0 bsp=e0000260f00294c0
  [<a00000010051fd60>] sock_close+0x80/0xa0
                                 sp=e0000260f002fdc0 bsp=e0000260f0029498
  [<a000000100172280>] __fput+0x1a0/0x420
                                 sp=e0000260f002fdc0 bsp=e0000260f0029458
  [<a000000100172540>] fput+0x40/0x60
                                 sp=e0000260f002fdc0 bsp=e0000260f0029438
  [<a000000100534a30>] __scm_destroy+0x130/0x1e0
                                 sp=e0000260f002fdc0 bsp=e0000260f0029410
  [<a000000100636370>] unix_destruct_fds+0x70/0xa0
                                 sp=e0000260f002fdd0 bsp=e0000260f00293e8
  [<a00000010052da30>] __kfree_skb+0x1f0/0x320
                                 sp=e0000260f002fe00 bsp=e0000260f00293c0
  [<a00000010052dbf0>] kfree_skb+0x90/0xc0
                                 sp=e0000260f002fe00 bsp=e0000260f00293a0
  [<a000000100634420>] unix_release_sock+0x360/0x460
                                 sp=e0000260f002fe00 bsp=e0000260f0029348
  [<a000000100634560>] unix_release+0x40/0x60
                                 sp=e0000260f002fe00 bsp=e0000260f0029328
  [<a00000010051fba0>] sock_release+0x80/0x1c0
                                 sp=e0000260f002fe00 bsp=e0000260f0029300
  [<a00000010051fd60>] sock_close+0x80/0xa0
                                 sp=e0000260f002fe10 bsp=e0000260f00292d8
  [<a000000100172280>] __fput+0x1a0/0x420
                                 sp=e0000260f002fe10 bsp=e0000260f0029298
  [<a000000100172540>] fput+0x40/0x60
                                 sp=e0000260f002fe10 bsp=e0000260f0029278


Yes, this even happens after commit f8d570a47.

But after doing a bisect, we found another hrtimer patch fixes this
problem, so it's not a bug of __scm_destroy().

Sorry for the noise.

Thanks.
