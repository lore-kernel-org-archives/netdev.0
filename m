From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] skbuff: Fix skb checksum flag on skb pull
Date: Mon, 31 Aug 2015 20:25:28 -0700
Message-ID: <CALnjE+r4=S6RQmdU5Ske4UpcWmN1sN0zv7WxKo_Z6Nt=YGy8gA@mail.gmail.com>
References: <1441061746-1492-1-git-send-email-pshelar@nicira.com>
	<CALx6S36TQx_Z64ohLmo6z-N6NND0=9RraoS6Bt5HcaDxXxwNoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33092 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbbIADZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 23:25:29 -0400
Received: by igbuu8 with SMTP id uu8so60698075igb.0
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 20:25:29 -0700 (PDT)
In-Reply-To: <CALx6S36TQx_Z64ohLmo6z-N6NND0=9RraoS6Bt5HcaDxXxwNoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2015 at 4:44 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Aug 31, 2015 at 3:55 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
>> VXLAN device can receive skb with checksum partial. But the checksum
>> offset could be in outer header which is pulled on receive. Such skb
>> can cause the panic when checksum is calculated on skb. Following patch
>> fixes the bug by setting checksum unnecessary while pulling outer header.
>>
>> ---8<---
>> [ 13.800141] RIP: 0010:[<ffffffff81518034>] [<ffffffff81518034>] skb_checksum_help+0x144/0x150
>> [ 13.800141] RSP: 0000:ffff88011fd83940 EFLAGS: 00010292
>> [ 13.800141] RAX: 0000000000000042 RBX: ffff880114dd56c0 RCX: ffff8801188d9580
>> ...
>> ...
>> [ 13.852308] Call Trace:
>> [ 13.852308] <IRQ>
>> [ 13.852308] [<ffffffffa0164c28>] queue_userspace_packet+0x408/0x470 [openvswitch]
>> [ 13.852308] [<ffffffffa016614d>] ovs_dp_upcall+0x5d/0x60 [openvswitch]
>> [ 13.852308] [<ffffffffa0166236>] ovs_dp_process_packet_with_key+0xe6/0x100 [openvswitch]
>> [ 13.852308] [<ffffffffa016629b>] ovs_dp_process_received_packet+0x4b/0x80 [openvswitch]
>> [ 13.852308] [<ffffffffa016c51a>] ovs_vport_receive+0x2a/0x30 [openvswitch]
>> [ 13.852308] [<ffffffffa0171383>] vxlan_rcv+0x53/0x60 [openvswitch]
>> [ 13.852308] [<ffffffffa01734cb>] vxlan_udp_encap_recv+0x8b/0xf0 [openvswitch]
>> [ 13.852308] [<ffffffff8157addc>] udp_queue_rcv_skb+0x2dc/0x3b0
>> [ 13.852308] [<ffffffff8157b56f>] __udp4_lib_rcv+0x1cf/0x6c0
>> [ 13.852308] [<ffffffff8157ba7a>] udp_rcv+0x1a/0x20
>> [ 13.852308] [<ffffffff8154fdbd>] ip_local_deliver_finish+0xdd/0x280
>> [ 13.852308] [<ffffffff81550128>] ip_local_deliver+0x88/0x90
>> [ 13.852308] [<ffffffff8154fa7d>] ip_rcv_finish+0x10d/0x370
>> [ 13.852308] [<ffffffff81550365>] ip_rcv+0x235/0x300
>> [ 13.852308] [<ffffffff8151ba1d>] __netif_receive_skb+0x55d/0x620
>> [ 13.852308] [<ffffffff8151c360>] netif_receive_skb+0x80/0x90
>> [ 13.852308] [<ffffffff81459935>] virtnet_poll+0x555/0x6f0
>> [ 13.852308] [<ffffffff8151cd04>] net_rx_action+0x134/0x290
>> [ 13.852308] [<ffffffff810683d8>] __do_softirq+0xa8/0x210
>> [ 13.852308] [<ffffffff8162fe6c>] call_softirq+0x1c/0x30
>> [ 13.852308] [<ffffffff810161a5>] do_softirq+0x65/0xa0
>> [ 13.852308] [<ffffffff810687be>] irq_exit+0x8e/0xb0
>> [ 13.852308] [<ffffffff81630733>] do_IRQ+0x63/0xe0
>> [ 13.852308] [<ffffffff81625f2e>] common_interrupt+0x6e/0x6e
>> [ 13.852308] <EOI>
>> [ 13.852308] [<ffffffff8162dc02>] ? system_call_fastpath+0x16/0x1b
>>
>> Reported-by: Anupam Chanda <achanda@vmware.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ---
>>  include/linux/skbuff.h |    3 +++
>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 9b88536..6238e9f 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -2601,6 +2601,9 @@ static inline void skb_postpull_rcsum(struct sk_buff *skb,
>>  {
>>         if (skb->ip_summed == CHECKSUM_COMPLETE)
>>                 skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
>> +       else if (skb->ip_summed == CHECKSUM_PARTIAL &&
>> +                skb_checksum_start_offset(skb) <= len)
>> +               skb->ip_summed = CHECKSUM_UNNECESSARY;
>
> No, this isn't right. We should never be converting CHECKSUM_PARTIAL
> into CHECKSUM_UNNECESSARY.
>

But checksum is valid for inner packet. So I do not see any other
appropriate checksum flag here. Can you suggest another flag which is
better suited?
