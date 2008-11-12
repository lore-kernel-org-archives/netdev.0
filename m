From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 09:59:20 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61260@NASANEXMB10.na.qualcomm.com>
References: <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com>
 <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com>
 <20081111185036.GA17717@ioremap.net>
 <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com>
 <20081111192954.GA19409@ioremap.net>
 <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com>
 <20081112135828.GA30946@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com>
 <20081112174114.GA4743@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:29562 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbYKLR7W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 12:59:22 -0500
In-Reply-To: <20081112174114.GA4743@ioremap.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Evgeniy Polyakov [mailto:zbr@ioremap.net]
> Sent: November-12-08 9:41 AM
> To: Lovich, Vitali
> Cc: Johann Baudy; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> Hi Vitali.
> 
> On Wed, Nov 12, 2008 at 09:07:43AM -0800, Lovich, Vitali
> (vlovich@qualcomm.com) wrote:
> > I think you misunderstand how the API works.  Yes the user could call
> send from the thread he's filling in data from.  But the idea is that
> he would ideally do this from another thread so that it's possible to
> control latency between packet sends.  Additionally, even without
> trying to control latency, there would still have to be complicated
> logic in userspace to determine when enough packets have been placed in
> the buffer to overcome the cost of a system call.
> >
> > This is why we need to know which frame in the ring buffer the skb is
> associated with.
> 
> What's the problem of invoking send machinery from different thread?
> You can wait in appropriate syscall until multiple packets have been
> sent and then return, or update some shared flag in the mapped area
> which says that something is being sent. When dev_queue_xmit() for
> selected set of packets completes, you can update that variable, and
> based on its value userspace can overwrite the area used by already
> sent packets.
> 
> I see the only reason to have a notification about skb completion is an
> absolute need to send sync data, i.e. packet data can not be
> overwritten
> until packet reaches the media. But getting that existing Linux
> splice/sendfile and any other ->sendpage() users are racy in this
> regard
> for centuries, this does not look as a strong demand for me.
> 
They aren't racy - not in the sense that your suggestion would make it.  With current splice & sendfile, when it returns from the syscall, the user knows that it has been transmitted and thus can continue using the file descriptors & memory (in the case of vmsplice).  However, with your suggestion, the user could actually never know when it's safe to write into memory (even in a single-threaded situation).  Thus it is racy in a single-threaded situation (even on a UP it's potentially racy) which is a pretty amazing feat.  Consider:

User fills up the 100 frames available in the ring buffer.  Calls send.  Send, after calling dev_queue_xmit on each frame marks it as free for use.  Send returns.  User continues filling up buffer.

In this situation, the user now has no clue whether or not the frames were actually sent out.  This is going to cause huge problems because the user won't understand why their data is being sent out corrupted (with also no way to prevent it).  I think this is becomes more and more of a problem if the card can't keep up with the packet rate, and thus it'll still be processing its tx queue as the user-space will be overwriting the ring buffer.

This state-machine approach is the exact parallel to how the RX code works (on receive it tries to place the skb data in a free frame and relies on the user to free that frame).
