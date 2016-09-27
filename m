From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] net: skbuff: Fix incorrect skb->mac_len adjustment in skb_vlan_push()
Date: Tue, 27 Sep 2016 13:04:35 -0700
Message-ID: <CAOrHB_C6H8AqqfLDvj296LnnLC7dLX5724cxGXujLTbgSBf50A@mail.gmail.com>
References: <1474997505-5059-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:51224 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933331AbcI0UEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 16:04:39 -0400
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 521C7A80C8
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 22:04:38 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id o8Z0lnLeiK_o for <netdev@vger.kernel.org>;
        Tue, 27 Sep 2016 22:04:36 +0200 (CEST)
Received: from mail-it0-f52.google.com (mail-it0-f52.google.com [209.85.214.52])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id AFF52A80CE
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 22:04:36 +0200 (CEST)
Received: by mail-it0-f52.google.com with SMTP id j69so25096367itb.0
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 13:04:36 -0700 (PDT)
In-Reply-To: <1474997505-5059-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 27, 2016 at 10:31 AM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> In case 'skb_vlan_push' is called on an skb with a hw-accel vlan tag
> already present, the existing hw-accel tag is inserted into payload, and
> the new given tag is placed as new hw-accel tag.
>
> After the insertion:
>  - 'mac_header' is adjusted to point to the new start of the vlan_ethhdr
>  - 'data' is adjusted to point to the vlan_hdr portion
>    (since packet's payload is the inner 802.1q)
>
> However, 'mac_len' is incorrectly incremented with additional VLAN_HLEN
> bytes, resulting in a total value of 18 bytes.
>
> Meaning, when issuing 'skb_push(skb, skb->mac_len)' the data points
> to random content, 4 bytes PRIOR the ethhdr location.
>
> This is problematic, as many constructs in the stack are issuing
> 'skb_push(skb, skb->mac_len)' prior xmit to a device (e.g tcf_mirred,
> tcf_bpf, nf_dup_netdev_egress), resulting in bogus frames being
> xmitted (having random 4 bytes at start of frame).
>
> For example:
>
>  # ip l add dev d0 type dummy
>  # tc filter add dev eth0 parent ffff: pref 1 basic \
>      action vlan push protocol 802.1ad id 5 pipe \
>      action mirred egress redirect dev d0
>
> Any 802.1q (hw-accel) tagged frames arriving on eth0 are xmitted as
> bogus frames on d0; whereas the expected behavior is having QinQ frames.
>
> Fix, removing the unnecessary VLAN_HLEN adjustment of mac_len.
>
> Fixes: 93515d53b1 ("net: move vlan pop/push functions into common code")
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Cc: Pravin Shelar <pshelar@ovn.org>
> Cc: Jiri Pirko <jiri@mellanox.com>
> ---
>
>  - David, if patch ok, suggest this goes to -stable
>
>  - Pravin, original push_vlan() code in openvswitch/actions.c prior Jiri
>    has moved it into skbuff.c had the following comment:
>         /* Update mac_len for subsequent MPLS actions */
>         skb->mac_len += VLAN_HLEN;
>    Can you please acknowlegde OvS code is also ok with suggested change?
>

OVS MPLS does depends on mac-len to track MPLS header (ref
skb_mpls_header()). Therefore vlan header changes needs to update
mac-len. But after commit 48d2ab609b6bb ("net: mpls: Fixups for GSO")
it does not need to use mac-len to track MPLS header.
To keep simple fix for stable, we can move the skb mac-len adjustment
to OVS module. Later on patch can remove this MPLS dependency on
mac-len for net-next branch.
