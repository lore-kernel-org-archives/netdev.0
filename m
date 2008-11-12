From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 20:41:14 +0300
Message-ID: <20081112174114.GA4743@ioremap.net>
References: <7e0dd21a0811110343v677c511ck69314fa19ace44b7@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B5@NASANEXMB10.na.qualcomm.com> <7e0dd21a0811110950g1182b86cv3e938df93f53d29d@mail.gmail.com> <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C3@NASANEXMB10.na.qualcomm.com> <20081111185036.GA17717@ioremap.net> <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com> <20081111192954.GA19409@ioremap.net> <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com> <20081112135828.GA30946@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:33567 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751530AbYKLRlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 12:41:15 -0500
Content-Disposition: inline
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali.

On Wed, Nov 12, 2008 at 09:07:43AM -0800, Lovich, Vitali (vlovich@qualcomm.com) wrote:
> I think you misunderstand how the API works.  Yes the user could call send from the thread he's filling in data from.  But the idea is that he would ideally do this from another thread so that it's possible to control latency between packet sends.  Additionally, even without trying to control latency, there would still have to be complicated logic in userspace to determine when enough packets have been placed in the buffer to overcome the cost of a system call.
> 
> This is why we need to know which frame in the ring buffer the skb is associated with.

What's the problem of invoking send machinery from different thread?
You can wait in appropriate syscall until multiple packets have been
sent and then return, or update some shared flag in the mapped area
which says that something is being sent. When dev_queue_xmit() for
selected set of packets completes, you can update that variable, and
based on its value userspace can overwrite the area used by already
sent packets.

I see the only reason to have a notification about skb completion is an
absolute need to send sync data, i.e. packet data can not be overwritten
until packet reaches the media. But getting that existing Linux
splice/sendfile and any other ->sendpage() users are racy in this regard
for centuries, this does not look as a strong demand for me.

-- 
	Evgeniy Polyakov
