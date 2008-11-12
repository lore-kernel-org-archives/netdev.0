From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 22:14:00 +0300
Message-ID: <20081112191400.GA6291@ioremap.net>
References: <20081111185036.GA17717@ioremap.net> <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com> <20081111192954.GA19409@ioremap.net> <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com> <20081112135828.GA30946@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com> <20081112174114.GA4743@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA61260@NASANEXMB10.na.qualcomm.com> <20081112181134.GA5396@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA61272@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:55440 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640AbYKLTOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 14:14:04 -0500
Content-Disposition: inline
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61272@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2008 at 11:05:03AM -0800, Lovich, Vitali (vlovich@qualcomm.com) wrote:
> I still don't see it.  This can only be a problem for vmsplice, since I believe
> sendpage & splice copy the data from the source pipe if necessary.
> vmsplice solves this through the SPLICE_F_GIFT flag (if not specified, 
> I'm assuming it copies the data into a temporary buffer).  So I don't 
> believe that these are actually racy functions if used properly.

Sendpage only copies data if underlying device does not support
scatter-gather and hardware checksum capabilities. Effectively what's
being done is a page (no matter if it is anonymous mapping or VFS page
cache) reference counter increase and skb submit, which in the best case
results in dev_queue_xmit() just like in your approach. Then syscall
returns and userspace will never ever know that page was transmitted.
It actually can be dropped just there without even seeing the wire if
hardware decided that, that is why hardware checksumming is needed:
hardware will calculate appropriate checksums over the data which is in
given pages at real send time and not when userspace called sendpage().

> However, your suggestion makes non-racy usage of the tx ring impossible
> unless you know ahead of time how many frames you will need (in which case, resetting
> the status flag is pointless).  But for proper ring buffer behaviour, it needs to
> clear the flag in the skb destructor, once we know the data will no longer be used by
> the driver.

Here is the main point: why do you ever care about data that was or was
not transmitted and want to update something at destruction time and not
when dev_qeueue_xmit() returns. As pointed above, destruction time does
not guarantee that skb was sent as long as return from dev_qeueue_xmit().

So you can update whatever flags you have to after return of the
dev_qeueue_xmit() and will get the same behaviour as sendfile:
immediate write into the same memory area results in sending new content
(on some NICs).

> > Please also update your mailer to wrap strings into 80-or-so lines, it
> > is hard to answer into the middle of the paragraph.
> Sorry - I hate using Outlook because it doesn't seem to honour my settings.
> I'll split up the lines manually instead of trusting Outlook.

Non-trivial solution for long mails :)

-- 
	Evgeniy Polyakov
