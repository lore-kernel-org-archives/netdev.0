From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 11 Nov 2008 19:59:17 +0100
Message-ID: <7e0dd21a0811111059i4d1bc0e6va6032bbfb3f0002c@mail.gmail.com>
References: <1225450706.5301.94.camel@localhost>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61126@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811110410v5fa8abadib70cebecb282bc1@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611B8@NASANEXMB10.na.qualcomm.com>
	 <7e0dd21a0811111008x2e674384kaa560d766a8f643e@mail.gmail.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C4@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:54622 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbYKKS7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 13:59:20 -0500
Received: by fk-out-0910.google.com with SMTP id 18so28789fkq.5
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2008 10:59:17 -0800 (PST)
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA611C4@NASANEXMB10.na.qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vitali,

> I'm saying that that frame's status should just be set to TP_STATUS_KERNEL, not user.  The kernel wants nothing to do with this frame any more and the user needs to know that.  I was going to add statistics tracking to keep track of how many packets were sent vs rejected.  This was more of an issue with my approach where I had a dedicated kernel thread doing all of this.

In all cases of error, Kernel is blocking on the same frame until
update, indeed packet_increment_head() is only called on success.
I've done this in order to not skip a packet in case of
skb_alloc_send_skb error().

I believe, we have 3 options on all failure, if we set packet to:
- TP_STATUS_KERNEL: User can consider that buffer is free and it will
fill it again.
If we choose TP_STATUS_KERNEL by default, that's means content is lost
even for sock_alloc_send_skb() error. Such behavior is not acceptable,
User is not able to show the difference between packet success and
packet failure on a specific frame (same status).
- TP_STATUS_USER: Kernel will try to send it again and again,
especially if send() is called in a loop (even it is impossible).
This is current way of working, It looks like a manner to block on issue.
- TP_STATUS_LOOSING(or other): as TP_STATUS_USER with more info for user.
Whereas TP_STATUS_USER, this one provides user with the buffer where
error has occurred.

Thanks,
Johann
-- 
Johann Baudy
johaahn@gmail.com
