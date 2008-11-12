From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 12 Nov 2008 13:23:33 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA6128D@NASANEXMB10.na.qualcomm.com>
References: <20081111185036.GA17717@ioremap.net>
 <7e0dd21a0811111119h3675a137t422bd508ccf2c963@mail.gmail.com>
 <20081111192954.GA19409@ioremap.net>
 <7e0dd21a0811120543k6907de3aw6b0c3de49b2ea5d2@mail.gmail.com>
 <20081112135828.GA30946@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com>
 <20081112174114.GA4743@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61260@NASANEXMB10.na.qualcomm.com>
 <20081112181134.GA5396@ioremap.net>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61272@NASANEXMB10.na.qualcomm.com>
 <20081112191400.GA6291@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Johann Baudy <johaahn@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:57820 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbYKLVXi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 16:23:38 -0500
In-Reply-To: <20081112191400.GA6291@ioremap.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Evgeniy Polyakov [mailto:zbr@ioremap.net]
> Sent: November-12-08 11:14 AM
> To: Lovich, Vitali
> Cc: Johann Baudy; netdev@vger.kernel.org
> Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> Here is the main point: why do you ever care about data that was or was
> not transmitted and want to update something at destruction time and
> not
> when dev_qeueue_xmit() returns. As pointed above, destruction time does
> not guarantee that skb was sent as long as return from
> dev_qeueue_xmit().
I don't care whether or not the data was sent - I care whether or not the driver
might still use the data in the frame the skb is referring to.  In the destructor, clearly the
driver can't since it gave up its reference.  After dev_queue_xmit, we don't know because
the driver (or the skb queue layer) may have decided to delay packet transmission.

Potentially the user might even have written half the payload of a packet when the device decides to
send out the skb for that frame and thus send out half the payload from one 
packet and half the payload from another.

> 
> So you can update whatever flags you have to after return of the
> dev_qeueue_xmit() and will get the same behaviour as sendfile:
> immediate write into the same memory area results in sending new
> content
> (on some NICs).
But using your approach, how can a user ever know whether or not he actually sent
a packet?

Am I missing something fundamental in my understanding?  I don't see any way, outside
of using the skb destructor, to notify the user when he can safely write to a frame
without interfering with any pending skbs.
