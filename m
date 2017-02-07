From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] igmp: address pmc kmemleak from on igmpv3_del_delrec()
Date: Mon, 06 Feb 2017 22:35:12 -0500 (EST)
Message-ID: <20170206.223512.698362451560656620.davem@davemloft.net>
References: <20170203212047.31653-1-mcgrof@kernel.org>
        <CAM_iQpXDk5SOX3sM32M+DdLG=J0mKZ9JZ9gdVDLkLxVzaSGprA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcgrof@kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@kyup.com, liuhangbin@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXDk5SOX3sM32M+DdLG=J0mKZ9JZ9gdVDLkLxVzaSGprA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 6 Feb 2017 16:32:14 -0800

> On Fri, Feb 3, 2017 at 1:20 PM, Luis R. Rodriguez <mcgrof@kernel.org> wrote:
>> When we igmpv3_add_delrec() we kzalloc the pmc, but when users
>> call    igmpv3_del_delrec() we never free the pmc. This was caught
>> by the following kmemleak splat:
>>
>> unreferenced object 0xffff99666ff43b40 (size 192):
>>   comm "systemd-resolve", pid 1258, jiffies 4309905600 (age 2138.352s)
>>   hex dump (first 32 bytes):
>>     00 6a 64 72 66 99 ff ff e0 00 00 fc 00 00 00 00  .jdrf...........
>>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>>   backtrace:
>>     [<ffffffffb3a5f7ea>] kmemleak_alloc+0x4a/0xa0
>>     [<ffffffffb36044e7>] kmem_cache_alloc_trace+0x107/0x240
>>     [<ffffffffb39ddbed>] igmp_group_dropped+0xfd/0x270
>>     [<ffffffffb39de5cf>] ip_mc_dec_group+0xaf/0x110
>>     [<ffffffffb39de6e6>] ip_mc_leave_group+0xb6/0x140
>>     [<ffffffffb39a55d7>] do_ip_setsockopt.isra.13+0x4c7/0xed0
>>     [<ffffffffb39a6014>] ip_setsockopt+0x34/0xb0
>>     [<ffffffffb39ced9b>] udp_setsockopt+0x1b/0x30
>>     [<ffffffffb393f064>] sock_common_setsockopt+0x14/0x20
>>     [<ffffffffb393dd10>] SyS_setsockopt+0x80/0xe0
>>     [<ffffffffb3403b4b>] do_syscall_64+0x5b/0xc0
>>     [<ffffffffb3a6b3af>] return_from_SYSCALL_64+0x0/0x6a
>>     [<ffffffffffffffff>] 0xffffffffffffffff
>>
>> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
>> ---
>>
>> I can reproduce this over time on a qemu box running next-20170125.
>> After running this for a while I no longer see the splat. This needs
>> confirmation form folks more familiar with the code, hence RFC. If
>> this is a real fix we need appropriate tags for the patch.
> 
> 
> Looks good to me. Adding some people who recent touched it to CC.

The kfree() was removed in commit:

====================
commit 24803f38a5c0b6c57ed800b47e695f9ce474bc3a
Author: Hangbin Liu <liuhangbin@gmail.com>
Date:   Mon Nov 14 16:16:28 2016 +0800

    igmp: do not remove igmp souce list info when set link down
====================

But I don't see what could possibly continue to reference this
pmc after we unlink it from the list.
