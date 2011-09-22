From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ehea: Remove sleep at .ndo_get_stats
Date: Thu, 22 Sep 2011 17:14:57 +0200
Message-ID: <1316704497.29549.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1316700657-14980-1-git-send-email-brenohl@br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: brenohl@br.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:36719 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855Ab1IVPOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 11:14:47 -0400
Received: by ewy4 with SMTP id 4so35308ewy.19
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2011 08:14:46 -0700 (PDT)
In-Reply-To: <1316700657-14980-1-git-send-email-brenohl@br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 septembre 2011 =C3=A0 11:10 -0300, brenohl@br.ibm.com a =C3=
=A9crit :
> Currently ehea ndo_get_stats can sleep in two places, in a hcall
> and in a GFP_KERNEL alloc, which is not correct.
> This patch creates a workqueue that grabs the information from time
> to time from the hardware, and place it into the device structure,
> so that, .ndo_get_stats quickly returns the device structure statisti=
cs
> block.
>=20
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> ---


Hmm... trigerring a work queue everytime NAPI is run ? That seems very
expensive to me, if for example no one wants device stats at all.

I read ehea correctly, this blocking suff is only used to compute
stats->multicast and stats->rx_errors.=20

They probably could be updated once per second, nobody will complain.
(So use a workqueue, and trigger the job once per second, not once per
incoming packet)

Also, you dont provide a safe ndo_get_stats() implementation.

Think that several process might read your device stats in //

So the memset(stats, 0, sizeof(*stats)) is wrong :
You can clear stats that are currently read by another thread.

This makes SNMP readers read intermediate null values, and they dont
like this.

=46ix is real easy : remove the memset(stats, 0, sizeof(*stats)) :

You only write on some fields, other fields are already 0
