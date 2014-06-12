From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/2] ip_tunnel: GSO: Add check for nested encap.
Date: Thu, 12 Jun 2014 08:32:15 -0700
Message-ID: <CALnjE+pGAyj=iT5uzV1QqPUuDOAzA1_zwKQ7pvZML3V5g+UhDw@mail.gmail.com>
References: <1401017972-1544-1-git-send-email-pshelar@nicira.com>
	<CA+mtBx9aGBv0arWRdtZbDJpSuzBcan9FEJVRqW5NxJghJrCSVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:39524 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756214AbaFLPcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 11:32:16 -0400
Received: by mail-vc0-f171.google.com with SMTP id id10so989192vcb.16
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 08:32:15 -0700 (PDT)
In-Reply-To: <CA+mtBx9aGBv0arWRdtZbDJpSuzBcan9FEJVRqW5NxJghJrCSVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 10, 2014 at 8:34 AM, Tom Herbert <therbert@google.com> wrote:
> On Sun, May 25, 2014 at 4:39 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> Current networking stack can only handle single encap packet
>> for GSO.  Following patch adds check for already encapsulated
>> packet so that we can drop it.
>>
> We're going to need double encap to support UDP/GRE. The software
> stack should be able to mostly work with multiple encapsulations (one
> exception would be if there were multiple UDP encapsulations with
> mixed enabling of checksums).  We could add GSO_SKB_SW for arbitrary
> encapsulation combinations that  we know HW doesn't implement.
>
I do not think it is trivial to support double encap.
Next patch adds support for tunnel offload for ovs bridge. We need
check to avoid following assert failure. I got following assert by
enabling offload on GRE device.
Anyways once double encap start working we can remove the check.

---------8<--------

[  237.934357] WARNING: CPU: 4 PID: 1602 at net/core/dev.c:2239
skb_warn_bad_offload+0xcd/0xda()

[  237.934361] : caps=(0x0000000600dbc8e9, 0x0000000600dbc8e9)
len=6820 data_len=5220 gso_size=1348 gso_type=65 ip_summed=3

[  237.934363] Modules linked in: ipip(E) ip_gre(E) xfrm4_tunnel
tunnel4 gre(E) ip_tunnel(E) x86_pkg_temp_thermal intel_powerclamp
coretemp kvm_intel kvm crct10dif_pclmul crc32_pclmul
ghash_clmulni_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper
shpchp ablk_helper cryptd ipmi_si dcdbas wmi acpi_power_meter joydev
lpc_ich lp acpi_pad parport hid_generic usbhid hid ses enclosure
usb_storage tg3 megaraid_sas ptp ahci libahci pps_core

[  237.934407] CPU: 4 PID: 1602 Comm: netperf Tainted: G            E
3.15.0-rc8+ #4
[  237.934409] Hardware name: Dell Inc. PowerEdge T320/07C9XP, BIOS
2.1.2 01/20/2014
[  237.934412]  0000000000000009 ffff8807fdb1f628 ffffffff8171fd25
ffff8807fdb1f670
[  237.934416]  ffff8807fdb1f660 ffffffff8106821d ffff8807fda7e4e8
ffff8807e37df000
[  237.934420]  0000000000000041 0000000000000003 ffff8807fda7e4e8
ffff8807fdb1f6c0
[  237.934424] Call Trace:
[  237.934434]  [<ffffffff8171fd25>] dump_stack+0x45/0x56
[  237.934440]  [<ffffffff8106821d>] warn_slowpath_common+0x7d/0xa0
[  237.934444]  [<ffffffff8106828c>] warn_slowpath_fmt+0x4c/0x50
[  237.934450]  [<ffffffff81362b23>] ? ___ratelimit+0x93/0x100
[  237.934455]  [<ffffffff81722bb9>] skb_warn_bad_offload+0xcd/0xda
[  237.934463]  [<ffffffff81624b7c>] skb_checksum_help+0x17c/0x190
[  237.934468]  [<ffffffff81627e09>] dev_hard_start_xmit+0x4b9/0x5c0
[  237.934474]  [<ffffffff81628230>] __dev_queue_xmit+0x320/0x4a0
[  237.934481]  [<ffffffffa0162cb0>] ? ip_tunnel_xmit+0x2e0/0x963 [ip_tunnel]
[  237.934486]  [<ffffffff816283c0>] dev_queue_xmit+0x10/0x20
[  237.934491]  [<ffffffff8162efe1>] neigh_direct_output+0x11/0x20
[  237.934498]  [<ffffffff816622d0>] ip_finish_output+0x3e0/0x850
[  237.934503]  [<ffffffff81663ac8>] ip_output+0x58/0x90
[  237.934508]  [<ffffffff81663220>] ip_local_out_sk+0x30/0x40
[  237.934514]  [<ffffffff816a6300>] iptunnel_xmit+0x100/0x120
[  237.934536]  [<ffffffffa0162cb0>] ip_tunnel_xmit+0x2e0/0x963 [ip_tunnel]
[  237.934557]  [<ffffffff81610040>] ? sk_prot_alloc+0xd0/0x190
[  237.934574]  [<ffffffffa01922a1>] __gre_xmit+0x71/0x80 [ip_gre]
[  237.934591]  [<ffffffffa0192708>] ipgre_xmit+0xd8/0x1c0 [ip_gre]
[  237.934602]  [<ffffffff81627c66>] dev_hard_start_xmit+0x316/0x5c0
[  237.934607]  [<ffffffff81628230>] __dev_queue_xmit+0x320/0x4a0
[  237.934612]  [<ffffffff816283c0>] dev_queue_xmit+0x10/0x20
[  237.934616]  [<ffffffff8162efe1>] neigh_direct_output+0x11/0x20
[  237.934621]  [<ffffffff816622d0>] ip_finish_output+0x3e0/0x850
[  237.934626]  [<ffffffff81663ac8>] ip_output+0x58/0x90
[  237.934630]  [<ffffffff81663220>] ip_local_out_sk+0x30/0x40
[  237.934635]  [<ffffffff8166358f>] ip_queue_xmit+0x13f/0x3d0
[  237.934640]  [<ffffffff8167a53c>] tcp_transmit_skb+0x47c/0x900
[  237.934645]  [<ffffffff8167aafd>] tcp_write_xmit+0x13d/0xc80
[  237.934650]  [<ffffffff8167b970>] tcp_push_one+0x30/0x40
[  237.934654]  [<ffffffff8166d081>] tcp_sendmsg+0x491/0xd00
[  237.934661]  [<ffffffff81697124>] inet_sendmsg+0x64/0xb0
[  237.934664]  [<ffffffff8160c53b>] sock_sendmsg+0x8b/0xc0
[  237.934683]  [<ffffffff810ae7f8>] ? finish_wait+0x58/0x70
[  237.934697]  [<ffffffff81695d68>] ? __inet_stream_connect+0x208/0x320
[  237.934703]  [<ffffffff811df823>] ? __fdget+0x13/0x20
[  237.934707]  [<ffffffff8160ca52>] SYSC_sendto+0x112/0x190
[  237.934712]  [<ffffffff8109f154>] ? vtime_account_user+0x54/0x60
[  237.934725]  [<ffffffff81020365>] ? syscall_trace_enter+0x145/0x250
[  237.934732]  [<ffffffff8160d3de>] SyS_sendto+0xe/0x10
[  237.934736]  [<ffffffff81730e7f>] tracesys+0xe1/0xe6
[  237.934739] ---[ end trace ce97c114790dba2e ]---


>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>>  net/ipv4/ip_tunnel_core.c | 10 +++++++---
>>  1 file changed, 7 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
>> index f4c987b..b150546 100644
>> --- a/net/ipv4/ip_tunnel_core.c
>> +++ b/net/ipv4/ip_tunnel_core.c
>> @@ -122,12 +122,16 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
>>  {
>>         int err;
>>
>> -       if (likely(!skb->encapsulation)) {
>> +       if (skb_is_gso(skb)) {
>> +               if (unlikely(skb->encapsulation)) {
>> +                       /* Current networking GSO stack can handle
>> +                        * only one level of encapsulation. */
>> +                       err = -ENOSYS;
>> +                       goto error;
>> +               }
>>                 skb_reset_inner_headers(skb);
>>                 skb->encapsulation = 1;
>> -       }
>>
>> -       if (skb_is_gso(skb)) {
>>                 err = skb_unclone(skb, GFP_ATOMIC);
>>                 if (unlikely(err))
>>                         goto error;
>> --
>> 1.9.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
