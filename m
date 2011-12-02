From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Fri, 02 Dec 2011 16:11:27 +0100
Message-ID: <1322838687.2762.18.camel@edumazet-laptop>
References: <igorm@etf.rs> <1322831399-23505-1-git-send-email-igorm@etf.rs>
	 <1322836191.2762.3.camel@edumazet-laptop>
	 <CAFdo_mVwRgB3OEBA7=nMcemr1x1WLkXC05UAnDW_n5gyYy9W=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Tom Herbert <therbert@google.com>
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:61555 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651Ab1LBPLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 10:11:31 -0500
Received: by vbbfc26 with SMTP id fc26so2351666vbb.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 07:11:31 -0800 (PST)
In-Reply-To: <CAFdo_mVwRgB3OEBA7=nMcemr1x1WLkXC05UAnDW_n5gyYy9W=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 15:54 +0100, Igor Maravi=C4=87=
 a =C3=A9crit :
> > Hmm... What about rtl8169_tx_clear_range() or rtl8169_tx_clear() ?
> >
>=20
> You mean we should put netdev_reset_queue() in those functions?
>=20
> I think that we shouldn't put any thing in these functions.
>=20
> When ever they are called, they are precede/followed by function
> rtl8169_hw_reset() which calls rtl_hw_reset() which calls
> rtl8169_init_ring_indexes() in which I've put netdev_reset_queue()
>=20
> Only time when rtl8169_tx_clear_range() isn't preceded/followed by
> rtl8169_hw_reset() is in function rtl8169_xmit_frags(). In that
> function it's
> called only in case there's an error. In case there was an error in t=
hat
> function, netdev_sent_queue() will never be called, so we are going t=
o have
> accurate length of queue.

Quite frankly, any queued skb is eventually freed, so
netdev_reset_queue() could be avoided.

r8169 driver has some problems (see current threads on netdev about it)=
,
and its not very clear that BQL locking requirements are going to be
respected. This can lead to inaccurate BQL counts and a txqueue freeze.

(In particular, a chip reset can be triggered by an IRQ, while another
cpu is currently sending an skb through ndo_start_xmit())

So I advise not using netdev_reset_queue() in this driver, only
netdev_completed_queue(), and make sure that their calls are serialized
under a given lock (see include/linux/dynamic_queue_limits.h comments)
