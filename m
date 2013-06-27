From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH vxlan v2 1/8] vxlan: Fix module cleanup.
Date: Wed, 26 Jun 2013 22:15:22 -0700
Message-ID: <CALnjE+pjK6t5xeJCReesRBuJCG8vVdWSA4yM_y11zu-ohdXzBQ@mail.gmail.com>
References: <1372277609-17467-1-git-send-email-pshelar@nicira.com>
	<20130626144840.05ff8c80@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:41692 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750993Ab3F0FPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 01:15:24 -0400
Received: by mail-qa0-f51.google.com with SMTP id f11so297257qae.10
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 22:15:22 -0700 (PDT)
In-Reply-To: <20130626144840.05ff8c80@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 2:48 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Wed, 26 Jun 2013 13:13:29 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>> vxlan private per net object can be accessed in device unregister.
>> therefore unregister pernet device at the end.
>>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>>  drivers/net/vxlan.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 227b54a..0ba1e7e 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -1916,9 +1916,9 @@ late_initcall(vxlan_init_module);
>>
>>  static void __exit vxlan_cleanup_module(void)
>>  {
>> -     unregister_pernet_device(&vxlan_net_ops);
>>       rtnl_link_unregister(&vxlan_link_ops);
>>       destroy_workqueue(vxlan_wq);
>> +     unregister_pernet_device(&vxlan_net_ops);
>>       rcu_barrier();
>>  }
>>  module_exit(vxlan_cleanup_module);
>
> No. This won't work.
> The problem is that:
>   rtnl_link_unregister calls __rtnl_kill_links which calls
>   vxlan_dellink
>
> vxlan_dellink assumes link is last thing and that the vxlan
> device is already down. vxlan_dellink will unregister the device
> and schedule work queue for closing socket.
>
> When you call unregister_pernet_device last, nothing happens.
> Since all vxlan device's are unregistered, the per-net vxlan
> device list would be empty. And since vxlan_stop was never called.
> The age_timer would never be stopped, and the multicast group
> would never left, and the forwarding table will leak memory.
>
>
del-link will unregister device and that will invoke vxlan_stop() from
__dev_close_many(). That makes sure age_timer is stopped and grp is
released on device dellink and rmmod. So I am not sure why do you want
to call vxlan_stop again from per-net un-register.

Am I missing something?

btw, the patch fixes following crash.

BUG: unable to handle kernel paging request at ffff880826393000
IP: [<ffffffff812cbde9>] __list_del_entry+0x29/0xd0
PGD 2972067 PUD 2975067 PMD 83feaf067 PTE 8000000826393060
Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
Modules linked in: vxlan(F-) ipip(F) ip_gre gre(F) xfrm4_tunnel
tunnel4 ip_tunnel(F) netconsole configfs bnx2fc cnic uio fcoe libfcoe
libfc scsi_transport_fc 8021q scsi_tgt garp stp llc sunrpc ipt_REJECT
ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack
ip6table_filter ip6_tables ipv6 freq_table mperf kvm_intel kvm
crc32c_intel ghash_clmulni_intel aesni_intel ablk_helper cryptd lrw
gf128mul glue_helper aes_x86_64 microcode pcspkr bnx2x libcrc32c ses
enclosure shpchp sg lpc_ich mfd_core ixgbe mdio igb dca i2c_algo_bit
i2c_core ptp pps_core wmi ext4(F) jbd2(F) mbcache(F) sd_mod(F)
crc_t10dif(F) ahci(F) libahci(F) megaraid_sas(F) dm_mirror(F)
dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: vxlan]
CPU: 6 PID: 12843 Comm: rmmod Tainted: GF            3.10.0-rc6+ #4
Hardware name: Dell Inc. PowerEdge R620/0KCKR5, BIOS 1.4.8 10/25/2012
task: ffff88040ce34ec0 ti: ffff880413c78000 task.ti: ffff880413c78000
RIP: 0010:[<ffffffff812cbde9>]  [<ffffffff812cbde9>] __list_del_entry+0x29/0xd0
RSP: 0018:ffff880413c79e08  EFLAGS: 00010206
RAX: ffff880826393000 RBX: ffff880803602b10 RCX: dead000000200200
RDX: ffff880826393000 RSI: ffff880413c79e58 RDI: ffff880803602b10
RBP: ffff880413c79e08 R08: 0000000000000001 R09: 2222222222222222
R10: 2222222222222222 R11: 2222222222222222 R12: ffff880413c79e58
R13: ffffffffa0840840 R14: ffffffff81ae4800 R15: ffff880413c79e58
FS:  00007f404be92700(0000) GS:ffff88042e400000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffff880826393000 CR3: 000000080555a000 CR4: 00000000000407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
 ffff880413c79e28 ffffffff812cbea1 2222222222222222 ffff880803602000
 ffff880413c79e48 ffffffffa083b311 ffff880803602000 ffffffff81ae4908
 ffff880413c79e98 ffffffff81492122 ffff880413c79e58 ffff880413c79e58
Call Trace:
 [<ffffffff812cbea1>] list_del+0x11/0x40
 [<ffffffffa083b311>] vxlan_dellink+0x51/0x70 [vxlan]
 [<ffffffff81492122>] __rtnl_link_unregister+0xa2/0xb0
 [<ffffffff814935ee>] rtnl_link_unregister+0x1e/0x30
 [<ffffffffa083fb7c>] vxlan_cleanup_module+0x1c/0x2f [vxlan]
 [<ffffffff810c9a31>] SyS_delete_module+0x1d1/0x2c0
 [<ffffffff812b820e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff81581f42>] system_call_fastpath+0x16/0x1b
Code: eb 9f 55 48 8b 17 48 b9 00 01 10 00 00 00 ad de 48 8b 47 08 48
89 e5 48 39 ca 74 29 48 b9 00 02 20 00 00 00 ad de 48 39 c8 74 7a <4c>
8b 00 4c 39 c7 75 53 4c 8b 42 08 4c 39 c7 75 2b 48 89 42 08
RIP  [<ffffffff812cbde9>] __list_del_entry+0x29/0xd0
 RSP <ffff880413c79e08>
CR2: ffff880826393000
---[ end trace b28427d0fb168650 ]---


> commit b7153984074e51a50dad905871b705e0d67aa147
> Author: Stephen Hemminger <stephen@networkplumber.org>
> Date:   Mon Jun 17 14:16:09 2013 -0700
>
>     vxlan: fix out of order operation on module removal
>
>     If vxlan is removed with active vxlan's it would crash because
>     rtnl_link_unregister (which calls vxlan_dellink), was invoked
>     before unregister_pernet_device (which calls vxlan_stop).
>
>     Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 284c6c0..d3005d3 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1771,8 +1771,8 @@ late_initcall(vxlan_init_module);
>
>  static void __exit vxlan_cleanup_module(void)
>  {
> -       rtnl_link_unregister(&vxlan_link_ops);
>         unregister_pernet_device(&vxlan_net_ops);
> +       rtnl_link_unregister(&vxlan_link_ops);
>         rcu_barrier();
>  }
>  module_exit(vxlan_cleanup_module);
