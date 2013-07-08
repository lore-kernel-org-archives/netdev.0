From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: net/ipv4/route.c: Routing anomaly introduced by 89aef89 (ipv4:
 Delete routing cache.)
Date: Mon, 8 Jul 2013 11:34:57 +0300
Message-ID: <20130708113457.4a0d6023@pluto>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org,
	eyal.birger@gmail.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:50837 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752098Ab3GHIfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 04:35:11 -0400
Received: by mail-wi0-f174.google.com with SMTP id k10so8757369wiv.13
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 01:35:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In 89aef89 (ipv4: Delete routing cache) the following was removed from
ip_route_input_common (nowadays named ip_route_input_noref):

-       tos &= IPTOS_RT_MASK;

As a side effect, the 'tos' argument passed to 'ip_route_input_slow' is
the "raw" u8, as present in iph->tos (opposed to the formerly "masked"
value).

This may affect the route calculation, as this value is later placed in
fl4.flowi4_tos for matching purposes (using equality to the tos stored
in the FIB Rule and/or Route).

(BTW, the question whether applying the historical IPTOS_RT_MASK
prior route lookup is interesting on its own...)

However, 89aef89 created an anomaly - since in the output path, routing
*still* uses the IPTOS_RT_MASK (see __ip_route_output_key for example).

It seems the omission of 'tos &= IPTOS_RT_MASK' from
'ip_route_input_noref' was accidental.

We should align input/output behavior by reverting the omission, or
alternatively we may reconsider the entire IPTOS_RT_MASK thing.

Regards,
Shmulik
