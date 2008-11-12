From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Thu, 13 Nov 2008 00:46:01 +0300
Message-ID: <20081112214601.GA19547@ioremap.net>
References: <20081111192954.GA19409@ioremap.net> <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com> <20081112135828.GA30946@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com> <20081112174114.GA4743@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA61260@NASANEXMB10.na.qualcomm.com> <20081112181134.GA5396@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA61272@NASANEXMB10.na.qualcomm.com> <20081112191400.GA6291@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA6128D@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:60000 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751420AbYKLVqC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 16:46:02 -0500
Content-Disposition: inline
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA6128D@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 12, 2008 at 01:23:33PM -0800, Lovich, Vitali (vlovich@qualcomm.com) wrote:
> I don't care whether or not the data was sent - I care whether or not the driver
> might still use the data in the frame the skb is referring to.  In the destructor, clearly the
> driver can't since it gave up its reference.  After dev_queue_xmit, we don't know because
> the driver (or the skb queue layer) may have decided to delay packet transmission.
> 
> Potentially the user might even have written half the payload of a packet when the device decides to
> send out the skb for that frame and thus send out half the payload from one 
> packet and half the payload from another.

And what's the point in waiting for data to be unused?
You want to implement a system, which will behave more consistent than
existing zero-copy approach, but yet not 100% correctly...

> > So you can update whatever flags you have to after return of the
> > dev_qeueue_xmit() and will get the same behaviour as sendfile:
> > immediate write into the same memory area results in sending new
> > content
> > (on some NICs).
> But using your approach, how can a user ever know whether or not he actually sent
> a packet?

There is no way to know that. At all. skb can be dropped by zillions of
reasons and after it was submitted to the qdisk layer, there is no way
to know how its life will continue. Well, in some cases it is possible
to know (when qdisk just frees skb), but it is far from 100% of the
cases.

> Am I missing something fundamental in my understanding?  I don't see any way, outside
> of using the skb destructor, to notify the user when he can safely write to a frame
> without interfering with any pending skbs.

Having a callback at destruction time does mean that noone uses skb, but
are you sure this is needed? With existing zero-copy (splice/sendfile)
this is not true, but you want to extend this approach...

If you _do_ want to make it that way, you can remove destructor at all
and implement own packet-socket-only allocation policy and thus have own
private destructor without extending skb.

-- 
	Evgeniy Polyakov
