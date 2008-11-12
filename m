From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 14:33:53 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA612A5@NASANEXMB10.na.qualcomm.com>
References: <20081111192954.GA19409@ioremap.net>
 <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com>
 <20081112135828.GA30946@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com>
 <20081112174114.GA4743@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61260@NASANEXMB10.na.qualcomm.com>
 <20081112181134.GA5396@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61272@NASANEXMB10.na.qualcomm.com>
 <20081112191400.GA6291@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA6128D@NASANEXMB10.na.qualcomm.com>
 <20081112214601.GA19547@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:20977 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbYKLWd5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 17:33:57 -0500
In-Reply-To: <20081112214601.GA19547@ioremap.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Evgeniy Polyakov [mailto:zbr@ioremap.net]
> Sent: November-12-08 1:46 PM
> To: Lovich, Vitali
> Cc: Johann Baudy; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> On Wed, Nov 12, 2008 at 01:23:33PM -0800, Lovich, Vitali
> (vlovich@qualcomm.com) wrote:
> > I don't care whether or not the data was sent - I care whether or not
> the driver
> > might still use the data in the frame the skb is referring to.  In
> the destructor, clearly the
> > driver can't since it gave up its reference.  After dev_queue_xmit,
> we don't know because
> > the driver (or the skb queue layer) may have decided to delay packet
> transmission.
> >
> > Potentially the user might even have written half the payload of a
> packet when the device decides to
> > send out the skb for that frame and thus send out half the payload
> from one
> > packet and half the payload from another.
> 
> And what's the point in waiting for data to be unused?
So that the application in user space can actually send uncorrupted packets.
Think for instance if I have a 1GB pcap dump and I want to replay it - without
Waiting for data to be unused, I could potentially send out corrupt packets or
skip some.
> You want to implement a system, which will behave more consistent than
> existing zero-copy approach, but yet not 100% correctly...
I'm trying to implement a system which is zero-copy with traditional socket send()
semantics (or at least as close as is possible).  I don't see why it wouldn't work
100% correctly.

> > > So you can update whatever flags you have to after return of the
> > > dev_qeueue_xmit() and will get the same behaviour as sendfile:
> > > immediate write into the same memory area results in sending new
> > > content
> > > (on some NICs).
> > But using your approach, how can a user ever know whether or not he
> actually sent
> > a packet?
> 
> There is no way to know that. At all. skb can be dropped by zillions of
> reasons and after it was submitted to the qdisk layer, there is no way
> to know how its life will continue. Well, in some cases it is possible
> to know (when qdisk just frees skb), but it is far from 100% of the
> cases.
Right - so I don't really care if the skb gets silently dropped by lower
layers.  My only concern is that there is some kind of protection that the
user can use to ensure that he doesn't overwrite data that is in the middle of
being transmitted.  I think that's the communication disconnect we're having.
You think I'm concerned about dropped packets - but that's just a side issue.
I recognize that some lower layer may abandon the skb for whatever reason.  The
main issue is data integrity - the pages in the scatter/gather list aren't touched
in user space until the device lets go of the skb.  With your approach, a race is actually
extremely likely (guaranteed if we roll in the ring buffer at all).  Consider:

Thread A
Calls send in loop to flush buffer

Thread B
Fills buffer
As soon as next frame is free (using the status flag), fill it in & update status flag.

Clearly, Thread B would actually see the status flag
cleared before the device actually tried to send the skb (unless the skb managed to
get sent out before dev_queue_xmit returned).

> 
> > Am I missing something fundamental in my understanding?  I don't see
> any way, outside
> > of using the skb destructor, to notify the user when he can safely
> write to a frame
> > without interfering with any pending skbs.
> 
> Having a callback at destruction time does mean that noone uses skb,
> but
> are you sure this is needed? With existing zero-copy (splice/sendfile)
> this is not true, but you want to extend this approach...
> 
> If you _do_ want to make it that way, you can remove destructor at all
> and implement own packet-socket-only allocation policy and thus have
> own
> private destructor without extending skb.
Can you please elaborate on this further.  What do you mean by custom allocation policy
and private destructor?  Isn't that exactly what we're doing now?  We're just trying to
figure out in our destructor which frame the skb was built from.
