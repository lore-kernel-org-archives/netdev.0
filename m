From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net V2] openvswitch: fix skb_panic due to the incorrect
 actions attrlen
Date: Tue, 15 Aug 2017 16:35:03 -0700
Message-ID: <CAOrHB_CTHWMJEp_QG3EKn07sWk1QKPe8CEBx_4860u_GRKr12g@mail.gmail.com>
References: <20170815112913.14678-1-zlpnobody@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Pravin Shelar <pshelar@nicira.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Liping Zhang <zlpnobody@gmail.com>,
        Neil McKee <neil.mckee@inmon.com>
To: Liping Zhang <zlpnobody@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:47834 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751598AbdHOXfF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 19:35:05 -0400
Received: from mail-wr0-f178.google.com (mail-wr0-f178.google.com [209.85.128.178])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 57DFCC5A46
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 01:35:04 +0200 (CEST)
Received: by mail-wr0-f178.google.com with SMTP id k71so7577340wrc.2
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 16:35:04 -0700 (PDT)
In-Reply-To: <20170815112913.14678-1-zlpnobody@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 4:29 AM, Liping Zhang <zlpnobody@163.com> wrote:
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
> ---
>  V2: move actions_attrlen into ovs_skb_cb, which will make codes more
>      clean, suggested by Pravin Shelar.
>
>  net/openvswitch/actions.c  | 2 ++
>  net/openvswitch/datapath.c | 2 +-
>  net/openvswitch/datapath.h | 3 +++
>  3 files changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index e4610676299b..f849ef52853f 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -921,6 +921,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>                         /* Include actions. */
>                         upcall.actions = actions;
>                         upcall.actions_len = actions_len;
> +                       upcall.actions_attrlen = OVS_CB(skb)->acts_origlen;
OVS_CB acts_origlen should be accessible in upcall_msg_size (), is
there reason to add this member to struct dp_upcall_info?
