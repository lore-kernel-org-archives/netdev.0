From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] openvswitch: maintain correct checksum state in
 conntrack actions
Date: Sat, 14 Jan 2017 10:42:26 -0800
Message-ID: <CAOrHB_AyzpHEeFGayagJPfZxVuMS-ZN0uTcCiZAjPCHspzhp0Q@mail.gmail.com>
References: <1484267598-4493-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:47379 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbdANSmd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 13:42:33 -0500
Received: from mfilter13-d.gandi.net (mfilter13-d.gandi.net [217.70.178.141])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 2EC91FB881
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 19:42:30 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter13-d.gandi.net (mfilter13-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id X8altr_QTqQD for <netdev@vger.kernel.org>;
        Sat, 14 Jan 2017 19:42:28 +0100 (CET)
Received: from mail-it0-f54.google.com (mail-it0-f54.google.com [209.85.214.54])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 80673FB882
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 19:42:28 +0100 (CET)
Received: by mail-it0-f54.google.com with SMTP id x2so59927402itf.1
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 10:42:28 -0800 (PST)
In-Reply-To: <1484267598-4493-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 4:33 PM, Lance Richardson <lrichard@redhat.com> wrote:
> When executing conntrack actions on skbuffs with checksum mode
> CHECKSUM_COMPLETE, the checksum must be updated to account for
> header pushes and pulls. Otherwise we get "hw csum failure"
> logs similar to this (ICMP packet received on geneve tunnel
> via ixgbe NIC):
>
> [  405.740065] genev_sys_6081: hw csum failure
> [  405.740106] CPU: 3 PID: 0 Comm: swapper/3 Tainted: G          I     4.10.0-rc3+ #1
> [  405.740108] Call Trace:
> [  405.740110]  <IRQ>
> [  405.740113]  dump_stack+0x63/0x87
> [  405.740116]  netdev_rx_csum_fault+0x3a/0x40
> [  405.740118]  __skb_checksum_complete+0xcf/0xe0
> [  405.740120]  nf_ip_checksum+0xc8/0xf0
> [  405.740124]  icmp_error+0x1de/0x351 [nf_conntrack_ipv4]
> [  405.740132]  nf_conntrack_in+0xe1/0x550 [nf_conntrack]
> [  405.740137]  ? find_bucket.isra.2+0x62/0x70 [openvswitch]
> [  405.740143]  __ovs_ct_lookup+0x95/0x980 [openvswitch]
> [  405.740145]  ? netif_rx_internal+0x44/0x110
> [  405.740149]  ovs_ct_execute+0x147/0x4b0 [openvswitch]
> [  405.740153]  do_execute_actions+0x22e/0xa70 [openvswitch]
> [  405.740157]  ovs_execute_actions+0x40/0x120 [openvswitch]
> [  405.740161]  ovs_dp_process_packet+0x84/0x120 [openvswitch]
> [  405.740166]  ovs_vport_receive+0x73/0xd0 [openvswitch]
> [  405.740168]  ? udp_rcv+0x1a/0x20
> [  405.740170]  ? ip_local_deliver_finish+0x93/0x1e0
> [  405.740172]  ? ip_local_deliver+0x6f/0xe0
> [  405.740174]  ? ip_rcv_finish+0x3a0/0x3a0
> [  405.740176]  ? ip_rcv_finish+0xdb/0x3a0
> [  405.740177]  ? ip_rcv+0x2a7/0x400
> [  405.740180]  ? __netif_receive_skb_core+0x970/0xa00
> [  405.740185]  netdev_frame_hook+0xd3/0x160 [openvswitch]
> [  405.740187]  __netif_receive_skb_core+0x1dc/0xa00
> [  405.740194]  ? ixgbe_clean_rx_irq+0x46d/0xa20 [ixgbe]
> [  405.740197]  __netif_receive_skb+0x18/0x60
> [  405.740199]  netif_receive_skb_internal+0x40/0xb0
> [  405.740201]  napi_gro_receive+0xcd/0x120
> [  405.740204]  gro_cell_poll+0x57/0x80 [geneve]
> [  405.740206]  net_rx_action+0x260/0x3c0
> [  405.740209]  __do_softirq+0xc9/0x28c
> [  405.740211]  irq_exit+0xd9/0xf0
> [  405.740213]  do_IRQ+0x51/0xd0
> [  405.740215]  common_interrupt+0x93/0x93
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Looks good.
Acked-by: Pravin B Shelar <pshelar@ovn.org>

Thanks.
