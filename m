From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: skb_warn_bad_offload warnings with FreeBSD guests
Date: Wed, 27 Aug 2014 13:24:21 -0400
Message-ID: <53FE1445.9060206@gmail.com>
References: <53F76D7E.4030307@gameservers.com> <53FB4775.8020507@gmail.com> <53FE02CC.50501@gameservers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Brian Rak <brak@gameservers.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:61774 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbaH0RY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 13:24:26 -0400
Received: by mail-qg0-f50.google.com with SMTP id z107so576617qgd.9
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 10:24:25 -0700 (PDT)
In-Reply-To: <53FE02CC.50501@gameservers.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2014 12:09 PM, Brian Rak wrote:
> 
> On 8/25/2014 10:25 AM, Vlad Yasevich wrote:
>> On 08/22/2014 12:19 PM, Brian Rak wrote:
>>> We have a number of machines running qemu with bridged networking. We have noticed that
>>> *sometimes* FreeBSD guests cause this warning to flood the host "WARNING: CPU: 5 PID: 3705
>>> at net/core/dev.c:2238 skb_warn_bad_offload+0xc3/0xd0()".  I haven't been able to come up
>>> with any sort of reproduction steps, it just seems to happen to some FreeBSD guests, but
>>> not others.
>>>
>>> A full stack trace looks like this:
>>>
>>> ------------[ cut here ]------------
>>> WARNING: CPU: 1 PID: 7147 at net/core/dev.c:2233 skb_warn_bad_offload+0xc3/0xd0()
>>> igb: caps=(0x0000000190114bb3, 0x0000000000000000) len=2962 data_len=0 gso_size=1448
>>> gso_type=5 ip_summed=0
>>> Modules linked in: dm_snapshot dm_bufio ipmi_devintf xt_physdev ebt_arp ebt_ip ebtable_nat
>>> ebtables cls_fw sch_sfq sch_htb tun kvm_intel kvm 8021q garp nfnetlink_queue nfnetlink_log
>>> nfnetlink bluetooth rfkill bridge stp llc xt_CHECKSUM iptable_mangle ipt_REJECT
>>> iptable_filter ip
>>> _tables ip6t_REJECT ip6table_filter ip6_tables ipv6 iTCO_wdt iTCO_vendor_support ipmi_si
>>> ipmi_msghandler microcode pcspkr i2c_i801 joydev sg lpc_ich shpchp igb dca ptp pps_core
>>> hwmon ext4 jbd2 mbcache sd_mod crc_t10dif crct10dif_common video ahci libahci xhci_hcd ast
>>> ttm drm_kms
>>> _helper sysimgblt sysfillrect syscopyarea dm_mirror dm_region_hash dm_log dm_mod
>>> CPU: 1 PID: 7147 Comm: qemu-kvm Tainted: G        W 3.15.5-1.el6.elrepo.x86_64 #1
>>> Hardware name: Supermicro X10SLE-F/HF/X10SLE, BIOS 1.1 07/19/2013
>>>   00000000000008b9 ffff88081fc435d8 ffffffff8163ba90 00000000000008b9
>>>   ffff88081fc43628 ffff88081fc43618 ffffffff8106c30c ffffc90007a06e30
>>>   0000000000000000 ffff8807f2b64000 ffff8807f2b64000 0000000000000000
>>> Call Trace:
>>>   <IRQ>  [<ffffffff8163ba90>] dump_stack+0x49/0x61
>>>   [<ffffffff8106c30c>] warn_slowpath_common+0x8c/0xc0
>>>   [<ffffffff8106c3f6>] warn_slowpath_fmt+0x46/0x50
>>>   [<ffffffff8156ce93>] skb_warn_bad_offload+0xc3/0xd0
>>>   [<ffffffff81574a29>] ? dev_hard_start_xmit+0x339/0x640
>>>   [<ffffffff81574699>] __skb_gso_segment+0x89/0xe0
>>>   [<ffffffff81574876>] dev_hard_start_xmit+0x186/0x640
>>>   [<ffffffff81594f5a>] sch_direct_xmit+0xfa/0x1d0
>>>   [<ffffffff81574f2f>] __dev_queue_xmit+0x1ff/0x4f0
>>>   [<ffffffff81575240>] dev_queue_xmit+0x10/0x20
>>>   [<ffffffffa02e6612>] br_dev_queue_push_xmit+0x82/0xb0 [bridge]
>>>   [<ffffffffa02ee680>] br_nf_dev_queue_xmit+0x20/0x90 [bridge]
>>>   [<ffffffffa02ef4b8>] br_nf_post_routing+0x2d8/0x300 [bridge]
>>>   [<ffffffffa02e6590>] ? deliver_clone+0x60/0x60 [bridge]
>>>   [<ffffffff815a357e>] nf_iterate+0x8e/0xc0
>>>   [<ffffffffa02e6590>] ? deliver_clone+0x60/0x60 [bridge]
>>>   [<ffffffff815a37ad>] nf_hook_slow+0x7d/0x150
>>>   [<ffffffffa02e6590>] ? deliver_clone+0x60/0x60 [bridge]
>>>   [<ffffffffa02ee6f0>] ? br_nf_dev_queue_xmit+0x90/0x90 [bridge]
>>>   [<ffffffffa02e6b43>] br_forward_finish+0x43/0x60 [bridge]
>>>   [<ffffffffa02ee8a8>] br_nf_forward_finish+0x1b8/0x1d0 [bridge]
>>>   [<ffffffffa02ef178>] br_nf_forward_ip+0x3a8/0x410 [bridge]
>>>   [<ffffffffa02e6b00>] ? br_flood_deliver+0x20/0x20 [bridge]
>>>   [<ffffffff815a357e>] nf_iterate+0x8e/0xc0
>>>   [<ffffffffa02e6b00>] ? br_flood_deliver+0x20/0x20 [bridge]
>>>   [<ffffffff815a37ad>] nf_hook_slow+0x7d/0x150
>>>   [<ffffffffa02e6b00>] ? br_flood_deliver+0x20/0x20 [bridge]
>>>   [<ffffffffa02e66e4>] __br_forward+0xa4/0x100 [bridge]
>>>   [<ffffffffa02e7800>] ? NF_HOOK.clone.0+0x70/0x70 [bridge]
>>>   [<ffffffffa02e67d6>] br_forward+0x96/0xb0 [bridge]
>>>   [<ffffffffa02e7800>] ? NF_HOOK.clone.0+0x70/0x70 [bridge]
>>>   [<ffffffffa02e7997>] br_handle_frame_finish+0x197/0x3f0 [bridge]
>>>   [<ffffffffa02e7800>] ? NF_HOOK.clone.0+0x70/0x70 [bridge]
>>>   [<ffffffffa02ef790>] br_nf_pre_routing_finish+0x2b0/0x370 [bridge]
>>>   [<ffffffffa02ef4e0>] ? br_nf_post_routing+0x300/0x300 [bridge]
>>>   [<ffffffffa02ed986>] NF_HOOK_THRESH+0x56/0x60 [bridge]
>>>   [<ffffffffa02eed2b>] br_nf_pre_routing+0x2fb/0x3a0 [bridge]
>>>   [<ffffffff815a357e>] nf_iterate+0x8e/0xc0
>>>   [<ffffffffa02e7800>] ? NF_HOOK.clone.0+0x70/0x70 [bridge]
>>>   [<ffffffff815a37ad>] nf_hook_slow+0x7d/0x150
>>>   [<ffffffffa02e7800>] ? NF_HOOK.clone.0+0x70/0x70 [bridge]
>>>   [<ffffffffa02e7d8c>] br_handle_frame+0x19c/0x240 [bridge]
>>>   [<ffffffffa02e7bf0>] ? br_handle_frame_finish+0x3f0/0x3f0 [bridge]
>>>   [<ffffffff81572fa5>] __netif_receive_skb_core+0x1e5/0x620
>>>   [<ffffffff81573407>] __netif_receive_skb+0x27/0x70
>>>   [<ffffffff81573553>] process_backlog+0x103/0x200
>>>   [<ffffffff81573d62>] net_rx_action+0x112/0x2a0
>>>   [<ffffffff8107111c>] __do_softirq+0xfc/0x2b0
>>>   [<ffffffff810713cd>] ? irq_exit+0xad/0xd0
>>>   [<ffffffff8164a81c>] do_softirq_own_stack+0x1c/0x30
>>>   <EOI>  [<ffffffff81070e75>] do_softirq+0x55/0x60
>>>   [<ffffffff81571e19>] netif_rx_ni+0x39/0x70
>>>   [<ffffffffa03e84e0>] tun_get_user+0x310/0x6c0 [tun]
>>>   [<ffffffffa03e8995>] tun_chr_aio_write+0x85/0xa0 [tun]
>>>   [<ffffffff811beb9d>] do_sync_readv_writev+0x4d/0x80
>>>   [<ffffffff811c0128>] do_readv_writev+0xc8/0x2c0
>>>   [<ffffffff811bebd0>] ? do_sync_readv_writev+0x80/0x80
>>>   [<ffffffff811d2c45>] ? poll_select_set_timeout+0x95/0xb0
>>>   [<ffffffff811c0357>] vfs_writev+0x37/0x50
>>>   [<ffffffff811c0496>] SyS_writev+0x56/0xf0
>>>   [<ffffffff81648ee9>] system_call_fastpath+0x16/0x1b
>>> ---[ end trace d26e70ba037ab631 ]---
>>>
>>>
>>> gso_type=5 and ip_summed=0 are always the same (though len, data_len, and gso_size vary).
>>>
>>> What is causing this?
>> The reason that the warning is triggered is ip_summed = 0 which means there is not
>> checksum already in the packet and it needs to be calculated.  If the packet is GSO,
>> then it needs to have partial checksum set (ip_summed == 3).
>>
>> You might try using systemtap or instrumenting tun and bridge to see what the
>> ip_summed value is when this happens.
> Who needs systemtap when you have strace ;)
> 
> I managed to intercept the raw packet + headers being delivered to the tun device, though
> I'm having some trouble making sense of it. I've got this call:
> 
> writev(33, [{"\x00\x01\x42\x00\xa0\x05\x00\x00\x00\x00\x00\x00", 12}, .... ], 4) = 4258
> 
> If I ignore the first 12 bytes that were written, I end up with a 4246 byte packet, which
> matches the warning message:
> 
> kernel: igb: caps=(0x0000000390114bb3, 0x0000000000000000) len=4246 data_len=4180
> gso_size=1440 gso_type=5 ip_summed=0
> 
> Looking at the code (
> https://github.com/torvalds/linux/blob/68e370289c29e3beac99d59c6d840d470af9dfcf/drivers/net/tun.c#L1037
> ) it seems that the tun device is expecting a virtio_net_hdr, but that structure is only
> 10 bytes long ( http://lxr.free-electrons.com/source/include/uapi/linux/virtio_net.h#L73
> ).  I'm assuming the last two bytes are padding, because then the rest of the structure
> decodes okay:
> 
> flags =  0
> gso_type = VIRTIO_NET_HDR_GSO_TCPV4
> hdr_len = 66
> gso_size =  1440
> csum_start = 0
> csum_offset = 0

This isn't right.  Like Eric said, the flags should be set VIRTIO_NET_HDR_F_NEEDS_CSUM
(1), and the csum_start and csum_offset should be set.
> 
> This matches what the warning message says, so I'm fairly confident in it.  If I decode
> the remainder of the write call (ignoring the 2 bytes after the header), I'm left with a
> perfectly normal looking TCP packet (with a 4180 byte payload).
> 
> Looking at the packet itself, I see a valid IP checksum, and a valid TCP checksum.  So, it
> seems like FreeBSD is calculating the packet checksums correctly, but I'm unsure of why
> Linux isn't noticing that.  I thought it might be related to VIRTIO_NET_HDR_F_DATA_VALID,
> but I can't seem to find any uses of this that seem relevant (not that FreeBSD sets it
> anyway).

Linux is looking at the flags to see what it needs to do.  With flags = 0, it means
Linux will have to compute the whole checksum all by itself.

When the code hits the linux segmentation to break the 4K packet into MSS chunks,
it seem that there is no partial checksum computed and thus throws the warning you see.

It is rather pointless for BSD to compute the TCP checksum for the whole 4K
packet, only to have linux host recompute it for every segment.

Looks like these are some bugs in the BSD virio-net implementation.

> 
> Shouldn't the tun code be setting ip_summed after receiving a packet with a valid
> checksum?  It's not clear to me where ip_summed should be getting set.

tun code with set the value of ip_summed based on the flags passed it.

-vlad
