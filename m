From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 22:29:54 +0300
Message-ID: <20081111192954.GA19409@ioremap.net>
References: <20081106194032.GB31673@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com> <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com> <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com> <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com> <20081111185036.GA17717@ioremap.net> <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Lovich, Vitali" <vlovich@qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:40105 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750725AbYKKT34 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 14:29:56 -0500
Content-Disposition: inline
In-Reply-To: <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2008 at 08:19:09PM +0100, Johann Baudy (johaahn@gmail.com) wrote:
> > I think you should be almost 200% sure that skb is not allowed to grow up :)
> Well! I'm lost :)
> 
> How can we forward a pointer from skb allocation to skb destructor
> without adding a kind of destructor argument in sk_buff struct?

There are several possibilities:
* update destructor with your own data and put old one behind the data
	in skb
* update destructor, but put your own data into some storage which can
	be accessed from your callback, storage entry may contain
	whatever data you want and of course old destructor
* put your data into socket pointer (there still may be issues with
	destructor)
* if you fully own the skb, reuse whatever members there you like
	(except those which may be used by lower layer)
* find why do you need to have callback at destruction time and
	eliminate this problem.
	Btw, netchannels do this way, since they are very similar to
	packet socket, but compared to your approach they have a copy.

At the first place I do not understand, why do you want to change the
skb, since you can mmap whatever area you need and provide those pages
into skb, which at free time will drop the reference counter. Skb lives
in socket queue, so until it is empty you can sleep not allowing mapped
buffer to shrink.

-- 
	Evgeniy Polyakov
