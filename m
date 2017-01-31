From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 09/10] bnxt_en: Add basic XDP support.
Date: Mon, 30 Jan 2017 23:33:31 -0800
Message-ID: <CACKFLimcOKbewjqsJ9se6_VFD9MfAQ6aATiNnTHNeZOHyp-dmg@mail.gmail.com>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
 <1485827375-20421-10-git-send-email-michael.chan@broadcom.com> <20170130210345.5a00e190@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:34955 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750776AbdAaHe0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:34:26 -0500
Received: by mail-vk0-f47.google.com with SMTP id x75so231590108vke.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:33:32 -0800 (PST)
In-Reply-To: <20170130210345.5a00e190@cakuba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 9:04 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
>
>
>> +     if (netif_running(dev))
>> +             bnxt_close_nic(bp, true, false);
>> +
>> +     old = xchg(&bp->xdp_prog, prog);
>> +     if (old)
>> +             bpf_prog_put(old);
>> +
>> +     if (prog) {
>> +             bnxt_set_rx_skb_mode(bp, true);
>> +     } else {
>> +             bool sh = (bp->flags & BNXT_FLAG_SHARED_RINGS) ? true : false;
>> +             int rx, tx;
>> +
>> +             bnxt_set_rx_skb_mode(bp, false);
>> +             bnxt_get_max_rings(bp, &rx, &tx, sh);
>> +             if (rx > 1) {
>> +                     bp->flags &= ~BNXT_FLAG_NO_AGG_RINGS;
>> +                     bp->dev->hw_features |= NETIF_F_LRO;
>> +             }
>> +     }
>> +     bp->tx_nr_rings_xdp = tx_xdp;
>> +     bp->tx_nr_rings = bp->tx_nr_rings_per_tc * tc + tx_xdp;
>> +     bp->cp_nr_rings = max_t(int, bp->tx_nr_rings, bp->rx_nr_rings);
>> +     bp->num_stat_ctxs = bp->cp_nr_rings;
>> +     bnxt_set_tpa_flags(bp);
>> +     bnxt_set_ring_params(bp);
>> +
>> +     if (netif_running(dev))
>> +             return bnxt_open_nic(bp, true, false);
>
> Mm..  I thought doing open/close like this and risking you won't be
> able to come back up was frowned upon [1].  I must be misunderstanding
> things...

We take these steps:

1. Check to make sure we have enough rings, MSIX, other resources
first.  If we don't have enough resources, ndo_xdp() will return error
code.  Device is still up.
2. We then call firmware to reserve the rings.  If the firmware call
fails, ndo_xdp() will return error code.  Device is still up.
3. Now we close the device and open the device with additional rings.
Yeah, it is possible the open will fail, but it should be quite
unlikely.  In the event that it fails, the netdev will not be in an
inconsistent state.  It will be in the down state.
