From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.7.8/amd64 full interrupt hangs due to iwlwifi under big nfs
 copies out
Date: Wed, 20 Feb 2013 09:39:46 -0800
Message-ID: <1361381986.19353.205.camel@edumazet-glaptop>
References: <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org> <20120715215935.GF24420@merlins.org>
	 <1342419529.3265.12217.camel@edumazet-glaptop>
	 <20120716151826.GA10586@merlins.org>
	 <1342455717.2830.14.camel@edumazet-glaptop>
	 <20130219040557.GB4778@merlins.org>
	 <1361251033.19353.120.camel@edumazet-glaptop>
	 (sfid-20130219_061917_530878_1ED7A14C) <1361268221.8553.1.camel@jlt4.sipsolutions.net>
	 <1361290909.19353.140.camel@edumazet-glaptop>
	 (sfid-20130219_172155_748777_C3ED0F5E) <1361351538.8629.3.camel@jlt4.sipsolutions.net>
	 (sfid-20130220_101252_930264_DBD3955C) <1361351703.8629.5.camel@jlt4.sipsolutions.net>
	 <1361373064.19353.180.camel@edumazet-glaptop>
	 (sfid-20130220_161110_395796_DBAC0744) <1361377243.8629.34.camel@jlt4.sipsolutions.net>
	 <1361379331.19353.189.camel@edumazet-glaptop>
	 (sfid-20130220_175537_373410_F2F98F44) <1361379597.8629.39.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc MERLIN <marc@merlins.org>, David Miller <davem@davemloft.net>,
	Larry.Finger@lwfinger.net, bhutchings@solarflare.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:50172 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206Ab3BTRjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 12:39:48 -0500
In-Reply-To: <1361379597.8629.39.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-20 at 17:59 +0100, Johannes Berg wrote:

> Yeah, I don't follow netdev much any more...
> 

Short answer : tcp stack has autotuning sk_rcvbuf, tracking _memory_ use
of a socket.

If network layer provides 8k fat skbs (holding 1500 bytes), the
advertised TCP receive window will be much smaller than if network layer
provides 2k skbs.

Its quite visible in a tcpdump in the beginning of a tcp session.

You'll see how linux grows the receive window, before and after my
patch. You'll see how the sender can send its data faster.

Providing nice skbs is a way to speedup Internet browsing, as most http
traffic happen exactly while tcp receiver didnt yet advertised a big
window. (Especially visible with large RTT)

> > 
> >         /* If frame is small enough to fit in skb->head, pull it completely.
> >          * If not, only pull ieee80211_hdr so that splice() or TCP coalesce
> >          * are more efficient.
> >          */
> 
> Oh, right, though I guess the comment is now wrong since practically
> every packet will be copied either here or in mac80211 (A-MSDUs are
> split up there)

Comment is not 'wrong', it describes what happens here.

If there is enough room in skb->head to avoid attaching a page fragment
to the skb, lets copy the frame so that the page fragment can be reused
by the NIC driver immediately.
