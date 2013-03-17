From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Sun, 17 Mar 2013 13:25:52 -0700
Message-ID: <1363551952.29475.93.camel@edumazet-glaptop>
References: <CANP3RGdWMHv-7TZ4fvASrmz7NXkO7B2g2RCZwV8ecExUsQTQ2w@mail.gmail.com>
	 <1363384577-21287-1-git-send-email-zenczykowski@gmail.com>
	 <504C9EFCA2D0054393414C9CB605C37F20BE6A2B@SJEXCHMB06.corp.ad.broadcom.com>
	 <20130317.142425.1713640249735424829.davem@davemloft.net>
	 <1363549074.4752.3.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dmitry@broadcom.com,
	zenczykowski@gmail.com, maze@google.com, netdev@vger.kernel.org,
	yuvalmin@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:52046 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756519Ab3CQUZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 16:25:55 -0400
Received: by mail-pb0-f43.google.com with SMTP id md12so5895297pbc.16
        for <netdev@vger.kernel.org>; Sun, 17 Mar 2013 13:25:54 -0700 (PDT)
In-Reply-To: <1363549074.4752.3.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-17 at 21:37 +0200, Eilon Greenstein wrote:
> On Sun, 2013-03-17 at 14:24 -0400, David Miller wrote:
> > From: "Dmitry Kravkov" <dmitry@broadcom.com>
> > Date: Sun, 17 Mar 2013 13:10:37 +0000
> > 
> > > Probably this commit resolved the issue:
> > > 
> > > commit bef05406ac0ea6f468e1e25e9934f3011ea9259b
> > > Author: Dmitry Kravkov <dmitry@broadcom.com>
> > > Date:   Tue Sep 11 04:34:08 2012 +0000
> > > 
> > >     bnx2x: Avoid sending multiple statistics queries
> > > 
> > > Can you try it pls?
> > 
> > These are completely seperate bugs.
> > 
> > The macro in question does not handle rollover of the lower 32-bits of
> > the statistic properly at all, and therefore Maciej's patch should be
> > applied and queud up for -stable.
> > 
> > Please give it your ACK unless you can find a bug in his change.
> 
> Both the high value and the low value are read from the chip - so this
> patch will increment the higher 32 bits twice (well, more than once).
> Not taking the HW/FW high counter at all is also not acceptable since
> the reading frequency is not high enough without those.
> 
> So the original patch is nacked, but we are trying to figure out what is
> causing the statistics to misbehave and it might be related to sending
> statistics query twice.

This looks like the typical problem of updating a 64bit value in non
atomic way.

Its guaranteed to happen on 32bit hosts.
We had to introduce include/linux/u64_stats_sync.h to help to solve this
without adding extra cost on 64bit arches.

In bnx2x case, we perform 32bit operations even on 64bit host, so we
probably need to add a seqcount_t, so that a stat consumer can detect it
read a stale value.
