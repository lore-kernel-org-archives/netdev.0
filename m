From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 16:58:28 +0300
Message-ID: <20081112135828.GA30946@ioremap.net>
References: <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com> <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com> <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com> <20081111185036.GA17717@ioremap.net> <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com> <20081111192954.GA19409@ioremap.net> <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lovich, Vitali" <vlovich@qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:54935 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750940AbYKLN6b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 08:58:31 -0500
Content-Disposition: inline
In-Reply-To: <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Wed, Nov 12, 2008 at 02:43:07PM +0100, Johann Baudy (johaahn@gmail.com) wrote:
> Thanks a lot for this list :)
> So for example, is using of skb->mark to store a buffer index a good solution ?
> Or do you prefer another solution?

Qdisk uses various classification models, and for example dsmark uses
skb->mark in particular. Most of others use priority field. tc_verd is
used to store classification verdict.

> > At the first place I do not understand, why do you want to change the
> > skb, since you can mmap whatever area you need and provide those pages
> > into skb, which at free time will drop the reference counter. Skb lives
> > in socket queue, so until it is empty you can sleep not allowing mapped
> > buffer to shrink.
> We need to get the tpacket_hdr associated to data in skb in order to
> inform user that buffer is now available (This is done through status
> field, which is not sent over the network). What do you mean with
> "provide those pages", through frags? If yes, is it ok when frags are
> linearized?

Hmm, for example splice() is supposed to do the same what you have, but
because of udp_send*() limitations it can't. Splice does not care if
data was overwritten during transfer, i.e. when ->sendpage() returns all
code assumes that data has been successfully transmitted, so userspace
can overwrite mapped area or file content, and this new data will
actually be transmitted. I believe you can use the same model and do not
care about userspace notifications after execution returned to the
userspace from the 'sending call'.

-- 
	Evgeniy Polyakov
