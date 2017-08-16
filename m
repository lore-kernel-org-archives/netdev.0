From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net V3] openvswitch: fix skb_panic due to the incorrect
 actions attrlen
Date: Wed, 16 Aug 2017 12:21:17 -0700
Message-ID: <CAOrHB_CTLaHZnM=GfgaKK_YfqqkN3xbuUhZTTS-u=uE7rcPVUg@mail.gmail.com>
References: <20170816053007.13991-1-zlpnobody@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Liping Zhang <zlpnobody@gmail.com>,
        Neil McKee <neil.mckee@inmon.com>
To: Liping Zhang <zlpnobody@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:45681 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751893AbdHPTVU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 15:21:20 -0400
Received: from mail-wr0-f173.google.com (mail-wr0-f173.google.com [209.85.128.173])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id D99B1A80C8
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 21:21:18 +0200 (CEST)
Received: by mail-wr0-f173.google.com with SMTP id x43so24838949wrb.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 12:21:18 -0700 (PDT)
In-Reply-To: <20170816053007.13991-1-zlpnobody@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 10:30 PM, Liping Zhang <zlpnobody@163.com> wrote:
> From: Liping Zhang <zlpnobody@gmail.com>
>
> For sw_flow_actions, the actions_len only represents the kernel part's
> size, and when we dump the actions to the userspace, we will do the
> convertions, so it's true size may become bigger than the actions_len.
>
> But unfortunately, for OVS_PACKET_ATTR_ACTIONS, we use the actions_len
> to alloc the skbuff, so the user_skb's size may become insufficient and
> oops will happen like this:
>   skbuff: skb_over_panic: text:ffffffff8148fabf len:1749 put:157 head:
>   ffff881300f39000 data:ffff881300f39000 tail:0x6d5 end:0x6c0 dev:<NULL>
>   ------------[ cut here ]------------
>   kernel BUG at net/core/skbuff.c:129!
>   [...]
>   Call Trace:
>    <IRQ>
>    [<ffffffff8148be82>] skb_put+0x43/0x44
>    [<ffffffff8148fabf>] skb_zerocopy+0x6c/0x1f4
>    [<ffffffffa0290d36>] queue_userspace_packet+0x3a3/0x448 [openvswitch]
>    [<ffffffffa0292023>] ovs_dp_upcall+0x30/0x5c [openvswitch]
>    [<ffffffffa028d435>] output_userspace+0x132/0x158 [openvswitch]
>    [<ffffffffa01e6890>] ? ip6_rcv_finish+0x74/0x77 [ipv6]
>    [<ffffffffa028e277>] do_execute_actions+0xcc1/0xdc8 [openvswitch]
>    [<ffffffffa028e3f2>] ovs_execute_actions+0x74/0x106 [openvswitch]
>    [<ffffffffa0292130>] ovs_dp_process_packet+0xe1/0xfd [openvswitch]
>    [<ffffffffa0292b77>] ? key_extract+0x63c/0x8d5 [openvswitch]
>    [<ffffffffa029848b>] ovs_vport_receive+0xa1/0xc3 [openvswitch]
>   [...]
>
> Also we can find that the actions_len is much little than the orig_len:
>   crash> struct sw_flow_actions 0xffff8812f539d000
>   struct sw_flow_actions {
>     rcu = {
>       next = 0xffff8812f5398800,
>       func = 0xffffe3b00035db32
>     },
>     orig_len = 1384,
>     actions_len = 592,
>     actions = 0xffff8812f539d01c
>   }
>
> So as a quick fix, use the orig_len instead of the actions_len to alloc
> the user_skb.
>
> Last, this oops happened on our system running a relative old kernel, but
> the same risk still exists on the mainline, since we use the wrong
> actions_len from the beginning.
>
> Fixes: ccea74457bbd ("openvswitch: include datapath actions with sampled-packet upcall to userspace")
> Cc: Neil McKee <neil.mckee@inmon.com>
> Signed-off-by: Liping Zhang <zlpnobody@gmail.com>

Looks good.
Acked-by: Pravin B Shelar <pshelar@ovn.org>
