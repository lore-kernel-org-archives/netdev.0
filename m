From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching - tg3 support
Date: Wed, 04 Jul 2007 09:22:39 -0400
Message-ID: <1183555359.5157.38.camel@localhost>
References: <OF95AE6EF1.D13A78A8-ON6525730E.0016D384-6525730E.0017C2E4@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Gagan Arneja <gaagaan@gmail.com>,
	Jeff Garzik <jeff@garzik.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev <netdev@vger.kernel.org>, Rick Jones <rick.jones2@hp.com>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:6227 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758188AbXGDNWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 09:22:45 -0400
Received: by wr-out-0506.google.com with SMTP id i30so93591wra
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2007 06:22:43 -0700 (PDT)
In-Reply-To: <OF95AE6EF1.D13A78A8-ON6525730E.0016D384-6525730E.0017C2E4@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-07 at 09:49 +0530, Krishna Kumar2 wrote:

> Do you see any contention for tx_lock which can justify having a prep
> handler? As I understood, no other CPU can be in the xmit code at the
> same time since RUNNING bit is held. Hence getting this lock early or
> late should not matter for the xmit side (and you are also holding
> dev->queue_lock while running prep so no new skbs can also be added to
> the dev during this time). And I couldn't find any driver that uses the
> same tx_lock on rx, 

On any non-LLTX driver:
netif_tx_lock() is grabbed on both tx and receive paths. 

I have to admit, the e1000 is too clever for its own good:
there is no documentation/description (and Herbert never explained) but
it seems to be able to play with only certain parts of the ring on tx
side and others on rx side so that a lock becomes unnecessary. So even
for non-LLTX, some lock needs to be held on rx just to be clean (and
theres a lot of grunty-ness against LLTX drivers out there).

> so where is the saving by doing prep ?

You would agree i think that if there is contention between two CPUs for
the same lock, gut feeling is there is benefit to do things outside the
lock when possible. This becomes more important with batching when
amortizing the cost of a lock.
Theres a little more than that and I could write up a longer description
if needed.

Also note: not all drivers may be able to move things outside of the
lock - infact the tun driver i converted is hard to do anything with
since it doesnt have any hardware features that makes it easy to move
things outside. For this reason this api is optional (and tun infact
doesnt use it); and as i have said a few times now, i will be more than
happy to get rid of it if experiments show it is unnecessary. For now my
take is someone needs to disprove it is valuable (most prefered with
experiments).

cheers,
jamal

