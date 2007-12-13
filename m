From: "Kevin Wilson" <Kevin.Wilson@comtrol.com>
Subject: What was the reason for 2.6.22 SMP kernels to change how sendmsg is called?
Date: Thu, 13 Dec 2007 14:54:31 -0600
Message-ID: <B1F576FE19C55C43B8D2E31F061B50C04E60B1@exchange.comtrol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.comtrol.com ([204.73.219.163]:46674 "EHLO
	Exchange.comtrol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763654AbXLMVIU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 16:08:20 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In SMP kernels 2.6.21 and prior you could use a SOCK's sendmsg() call via the PROTO structure directly. e.g., sock->sk_prot->sendmsg().

Now in 2.6.22 and later kernels you must use the higher level SOCKET to make a call to PROTO_OPS then to sendmsg(). e.g., socket->ops->sendmsg().

Would someone please clue me in as to what source changes caused previously working driver code to go belly up? (ref original post below) I tried finding it in git but I don't think this was intentional but rather a side effect of some other change made between .21 & .22.

The 2nd method fixes the kernel oops I reported. Thanks to all those that assisted me (0) with my first post to this list (see below) ... uh, oh yeah, did I mention that number would tally up to ZERO people. ;-}

Thanks,

Kevin

***********************************************************************
-----Original Message-----
From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org]On Behalf Of Kevin Wilson
Sent: Tuesday, December 11, 2007 16:51
To: netdev@vger.kernel.org
Subject: sk_prot->sendmsg(...) giving me a kernel oops on kernels past
2.6.20


I've searched everywhere (including this list) for a report but couldn't
find anything that can tell me what implementation step(s) I am missing.
Essentially all the kernels past 2.6.20 gives me a kernel oops on the
sendmsg code.

I know the sk_buff changes worked things over quite a bit but I have (or
thought I did) those changes accounted for in our driver. Are there any
specific implementation changes we need to add that we didn't need prior
before we now use sendmsg()? Below is the general gist of the code I am
executing, any pointers to what I am missing would be very welcome.

Thanks a bunch.

Kevin

***************************************
done in userland and passed via ioctl:
***************************************

sk = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

tcp_params.boxid = boxIndex;
tcp_params.sk = sk;
tcp_params.rbuf = malloc(4096);
tcp_params.rbuf_size = 4096;
tcp_params.wbuf = malloc(1460);
tcp_params.wbuf_size = 1460;

rc = ioctl(fd, SI_SET_TCP, &tcp_params);

***************************************
done in kernel space:
***************************************

struct tcp_sock *tp;
struct sock *mysock;

tp = sockfd_lookup(tcp_params.sk, &i);

mysock = tp->sk;

mysock->sk_prot->sendmsg(...);	<-- OOPS HERE

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
