From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v5 1/3] net: ipv6: Unduplicate
 {raw,udp}v6_sendmsg code
Date: Fri, 25 Apr 2014 11:24:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6FF01A@AcuExch.aculab.com>
References: <1398424172-17530-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: 'Lorenzo Colitti' <lorenzo@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56299 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751028AbaDYL0A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 07:26:00 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32716-03 for <netdev@vger.kernel.org>;
 Fri, 25 Apr 2014 12:25:50 +0100 (BST)
In-Reply-To: <1398424172-17530-1-git-send-email-lorenzo@google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti
> rawv6_sendmsg and udpv6_sendmsg have ~100 lines of almost
> identical code. Move this into a new ipv6_datagram_send_common
> helper function.
> 
> Tested: black-box tested using user-mode Linux.
> 
> - Basic UDP sends using sendto work.
> - Mark routing and oif routing using SO_BINDTODEVICE work.
...
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index d640925..f1a247a 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -785,6 +785,13 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
>  int ip6_datagram_connect(struct sock *sk, struct sockaddr *addr, int addr_len);
>  int ip6_datagram_connect_v6_only(struct sock *sk, struct sockaddr *addr,
>  				 int addr_len);
> +int ip6_datagram_send_common(struct sock *sk, struct msghdr *msg,
> +			     struct sockaddr_in6 *sin6, int addr_len,
> +			     struct flowi6 *fl6, struct dst_entry **dstp,
> +			     struct ipv6_txoptions **optp,
> +			     struct ipv6_txoptions *opt_space,
> +			     int *hlimit, int *tclass, int *dontfrag,
> +			     int *connected);

That is a lot of parameters! and udp send is probably an important path.

You also repeatedly dereference some of them (eg hlimit).
I think that all of hlimit, tclass, dontfrag and connected could be shadowed
by locals and only written out on success (maybe into a structure?).
It might also be possible to reduce the number of arguments by using a sequence of calls.
(getting the args 'passed by register' helps performance.)

	David
