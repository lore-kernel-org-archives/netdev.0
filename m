From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3 net-next 1/2] net: skbuff: Remove errornous length
 validation in skb_vlan_pop()
Date: Tue, 20 Sep 2016 10:12:35 -0700
Message-ID: <CAOrHB_CJBSyuZ1EV0gMkckEvmDhxqDpXGgj55VXfAn+YjuWAOQ@mail.gmail.com>
References: <1474364917-31710-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:37631 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754246AbcITRMl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 13:12:41 -0400
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 4ABEBA80C7
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 19:12:39 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id u4XcFHMbZ3CI for <netdev@vger.kernel.org>;
        Tue, 20 Sep 2016 19:12:37 +0200 (CEST)
Received: from mail-it0-f45.google.com (mail-it0-f45.google.com [209.85.214.45])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id A1F8FA80BE
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 19:12:37 +0200 (CEST)
Received: by mail-it0-f45.google.com with SMTP id n143so25407739ita.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 10:12:37 -0700 (PDT)
In-Reply-To: <1474364917-31710-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 2:48 AM, Shmulik Ladkani
<shmulik.ladkani@ravellosystems.com> wrote:
> In 93515d53b1
>   "net: move vlan pop/push functions into common code"
> skb_vlan_pop was moved from its private location in openvswitch to
> skbuff common code.
>
> In case skb has non hw-accel vlan tag, the original 'pop_vlan()' assured
> that skb->len is sufficient (if skb->len < VLAN_ETH_HLEN then pop was
> considered a no-op).
>
> This validation was moved as is into the new common 'skb_vlan_pop'.
>
> Alas, in its original location (openvswitch), there was a guarantee that
> 'data' points to the mac_header, therefore the 'skb->len < VLAN_ETH_HLEN'
> condition made sense.
> However there's no such guarantee in the generic 'skb_vlan_pop'.
>
> For short packets received in rx path going through 'skb_vlan_pop',
> this causes 'skb_vlan_pop' to fail pop-ing a valid vlan hdr (in the non
> hw-accel case) or to fail moving next tag into hw-accel tag.
>
> Remove the 'skb->len < VLAN_ETH_HLEN' condition entirely:
> It is superfluous since inner '__skb_vlan_pop' already verifies there
> are VLAN_ETH_HLEN writable bytes at the mac_header.
>
> Note this presents a slight change to skb_vlan_pop() users:
> In case total length is smaller than VLAN_ETH_HLEN, skb_vlan_pop() now
> returns an error, as opposed to previous "no-op" behavior.
> Existing callers (e.g. tc act vlan, ovs) usually drop the packet if
> 'skb_vlan_pop' fails.
>
> Fixes: 93515d53b1 ("net: move vlan pop/push functions into common code")
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Cc: Pravin Shelar <pshelar@ovn.org>
> ---
>  v3: Elaborate log message to explain the change presented to
>      'skb_vlan_pop' users for packets smaller than VLAN_ETH_HLEN
>
>  v2: Remove 'skb->len < VLAN_ETH_HLEN' condition entirely (instead of
>      testing skb->mac_len as was in v1), suggested by Pravin Shelar
>
>  net/core/skbuff.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
>

Reviewed-by: Pravin B Shelar <pshelar@ovn.org>
