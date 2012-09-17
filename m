From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Regarding group_forward_mask in bridge in 3.4 kernel
Date: Mon, 17 Sep 2012 20:13:48 +0530
Message-ID: <CADAe=++yAm3t-ZqMKy9h-Rda5=pOYQD2-cKUd3S1VKmBZQfT9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:40772 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756348Ab2IQOoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 10:44:19 -0400
Received: by obbuo13 with SMTP id uo13so9020251obb.19
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 07:44:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to enable group_fwd_mask in bridge by giving the below
command so that it can forward provider bpdu's whose destination
address is 01-80-C2-00-00-08.

echo 8 > /sys/class/net/vpc1_br/bridge/group_fwd_mask

But still the provider BPDU's are dropped by the bridge. After some
debugging I have found that logic in br_input.c has some issue

                switch (dest[5]) {
                case 0x00:      /* Bridge Group Address */
                        /* If STP is turned off,
                           then must forward to keep loop detection */
                        if (p->br->stp_enabled == BR_NO_STP)
                                goto forward;
                        break;

                case 0x01:      /* IEEE MAC (Pause) */
                        goto drop;

                default:
                        /* Allow selective forwarding for most other
protocols */
                        if (p->br->group_fwd_mask & (1u << dest[5]))
                                goto forward;
                }

In my case dest[5] is 8 and p->br->group_fwd_mask is 8. The default
case is triggered but the expression in if condition
is always ZERO as a result BPDU is not forwarded.

Am I giving wrong value for group_fwd_mask ?? I tried other values but
seems only 8 and 0 is accepted.

Regards,
Ajith
