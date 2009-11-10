From: Christopher Zimmermann <madroach@zakweb.de>
Subject: Re: Possible bug: SO_TIMESTAMPING 2.6.30+
Date: Tue, 10 Nov 2009 23:03:52 +0100
Message-ID: <20091110230352.65d369af@pundit>
References: <4AF8B67E.3030604@ripnet.com>
	<20091110091252.1667d27d@pundit>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Marcus D. Leech" <mleech@ripnet.com>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:51902 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754394AbZKJWDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 17:03:52 -0500
In-Reply-To: <20091110091252.1667d27d@pundit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 09:12:52 +0100
Christopher Zimmermann <madroach@zakweb.de> wrote:

> On Mon, 09 Nov 2009 19:40:30 -0500
> "Marcus D. Leech" <mleech@ripnet.com> wrote:
> 
> 
> > I know that Patrick Ohly has essentially moved on from doing the 
> > SO_TIMESTAMPING stuff, so
> >    who's maintaining it now?
> 
> I worked on it a month ago or so and have a patchset from Patick Ohly
> and some changes by me which fix software timestamping and make the
> ioctl interface to the hardware more flexible (keeping backwards
> compatibility). Patches are attached.
> Still I never tried IPv6 and don't think the patches do anything about
> it.
> It would be nice to know weather software tx timestamps work
> with/without the patches.
> 
> 
> Christopher

Have a look at commit 51f31cabe3ce5345b51e4a4f82138b38c4d5dc91.
It adds support for SO_TIMESTAMPING in the transport layer, but only
for the ipv4 variants.
Good news is, it does look like it was simple to do the same to
ipv6/udp.c. Have fun.


    ip: support for TX timestamps on UDP and RAW sockets
    
    Instructions for time stamping outgoing packets are take from the
    socket layer and later copied into the new skb.
    
    Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


But only in ipv4/udp.c:

-------------------------------- net/ipv4/udp.c
-------------------------------- index c47c989..4bd178a 100644
@@ -596,6 +596,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock
*sk, struct msghdr *msg, return -EOPNOTSUPP;
 
 	ipc.opt = NULL;
+	ipc.shtx.flags = 0;
 
 	if (up->pending) {
 		/*
@@ -643,6 +644,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock
*sk, struct msghdr *msg, ipc.addr = inet->saddr;
 
 	ipc.oif = sk->sk_bound_dev_if;
+	err = sock_tx_timestamp(msg, sk, &ipc.shtx);
+	if (err)
+		return err;
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
 		if (err)
