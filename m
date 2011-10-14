From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Fri, 14 Oct 2011 18:00:52 +0200
Message-ID: <1318608052.2223.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318576791.2533.99.camel@edumazet-laptop>
	 <20111014.034224.1197576516015404466.davem@davemloft.net>
	 <4E985A3F.5080103@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62907 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456Ab1JNQAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 12:00:36 -0400
Received: by wyg36 with SMTP id 36so226924wyg.19
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 09:00:35 -0700 (PDT)
In-Reply-To: <4E985A3F.5080103@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 octobre 2011 =C3=A0 08:50 -0700, Rick Jones a =C3=A9crit=
 :

> Is the wireless problem strictly a wireless problem?  Many of the=20
> drivers where Eric has been fixing the truesize accounting have been=20
> wired devices no?

Yes, but the goal of such fixes it to make bugs happen too with said
wired devices ;)

About WIFI, I get these TCP Collapses on two different machines, one
using drivers/net/wireless/rt2x00 driver

Extract from drivers/net/wireless/rt2x00/rt2x00queue.h

/**
 * DOC: Entry frame size
 *=20
 * Ralink PCI devices demand the Frame size to be a multiple of 128 byt=
es,
 * for USB devices this restriction does not apply, but the value of
 * 2432 makes sense since it is big enough to contain the maximum fragm=
ent
 * size according to the ieee802.11 specs.=20
 * The aggregation size depends on support from the driver, but should
 * be something around 3840 bytes.
 */
#define DATA_FRAME_SIZE         2432
#define MGMT_FRAME_SIZE         256
#define AGGREGATION_SIZE        3840



You understand why we endup using skb->truesize > 4096 buffers=20

I liked doing the copybreak only if needed, I found the OFO case was
 most of the time responsible of the Collapses.

Now we also could do the copybreak for frames queued into regular
 receive_queue, if current wmem_alloc is above 25% of rcvbuf space...
