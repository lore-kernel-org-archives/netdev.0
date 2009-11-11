From: "Marcus D. Leech" <mleech@ripnet.com>
Subject: Re: Possible bug: SO_TIMESTAMPING 2.6.30+
Date: Tue, 10 Nov 2009 19:13:54 -0500
Message-ID: <4AFA01C2.6020504@ripnet.com>
References: <4AF8B67E.3030604@ripnet.com>	<20091110091252.1667d27d@pundit> <20091110230352.65d369af@pundit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christopher Zimmermann <madroach@zakweb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ripnet.com ([66.78.99.10]:3691 "EHLO mx1.ripnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751206AbZKKANw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 19:13:52 -0500
In-Reply-To: <20091110230352.65d369af@pundit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christopher Zimmermann wrote:
>
>
> -------------------------------- net/ipv4/udp.c
> -------------------------------- index c47c989..4bd178a 100644
> @@ -596,6 +596,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock
> *sk, struct msghdr *msg, return -EOPNOTSUPP;
>  
>  	ipc.opt = NULL;
> +	ipc.shtx.flags = 0;
>  
>  	if (up->pending) {
>  		/*
> @@ -643,6 +644,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock
> *sk, struct msghdr *msg, ipc.addr = inet->saddr;
>  
>  	ipc.oif = sk->sk_bound_dev_if;
> +	err = sock_tx_timestamp(msg, sk, &ipc.shtx);
> +	if (err)
> +		return err;
>  	if (msg->msg_controllen) {
>  		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
>  		if (err)
>
>   
That is already in 2.6.30

I took a look this afternoon at ipv6/udp.c and ipv6/ip6_output.c   and
was able to glue-in a small (a few lines) piece of code
  that apparently makes TX timestamping work for V6 DATAGRAM sockets--I
had to do it in ipv6/ip6_output.c, otherwise,
  I'd have to modify calls to the v6 _append function to pass in an
extra parameter to indicate hardware Tx timestamping.
  It was easier to simply pick up shtx->hardware in the _append
function, and then check to see if sk->sk_type == SOCK_DGRAM,
  and then set the appropriate fields in the skb.  In ipv4/udp.c, this
is done in udp_sendmsg(), before calling the _append function.

Doing this in AF_PACKET looked like it was going to be *very* easy, but
in my tests so far, it doesn't do anything useful.  More
  investigation in the lab this evening, and then I'll put together some
cdiffs against 2.6.32-rc5.  Once that's done, perhaps I can get
  some guidance about how to post those patches?

The same kind of stuff doesn't appear to work for AF_PACKET, so once I
have AF_PACKET working, I'll perhaps post a
  patch set.  I'm very new to this community, so I don't know how to go
about posting patches "officially" etc.  But it seems that
  getting this working for at least:

     V4  SOCK_DGRAM
     V6  SOCK_DGRAM
     AF_PACKET SOCK_DGRAM/SOCK_RAW

Should be quite straightforward--using the existing code in ipv4/udp.c 
as a guide.   Hopefully, if I can get this going for all 3, I'll get
  to keep my job :-)   [just kidding!].


Cheers
Marcus
currently a IEEE 1588-2008 code monkey at a semiconductor company

-- 
Marcus Leech
Principal Investigator, Shirleys Bay Radio Astronomy Consortium
http://www.sbrac.org

