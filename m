From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after
	some time
Date: Tue, 9 Sep 2008 02:38:53 +0200
Message-ID: <20080909003852.GA20315@pest>
References: <20080902150008.GD7289@schleppi.birkenwald.de> <OF604A6380.9CF7D18A-ON882574BF.000171B8-882574BF.00031DB5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs02.svr02.mucip.net ([83.170.6.69]:36375 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990AbYIIAjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 20:39:00 -0400
Content-Disposition: inline
In-Reply-To: <OF604A6380.9CF7D18A-ON882574BF.000171B8-882574BF.00031DB5@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 05:34:00PM -0700, David Stevens wrote:

Hi David,

>         I looked at this some more and didn't see anything obvious.
> The send side doesn't need group membership to send, or anything
> special, really. The only thing that comes to mind is that maybe you
> have a bogus route installed (since you don't have a bogus interface
> flag :-)).
>         Can you do an "ip -6 route list" when it's happening?

Sure, here we go

miredo:~# ip -6 route list
2001::/32 via fe80::1 dev teredo  metric 1024  mtu 1280 advmss 1220 hoplimit 4294967295
2001:1b10:100::1:1 via fe80::2c0:9fff:fe4b:8ccf dev eth0  proto zebra  metric 2  mtu 1500 advmss 1440 hoplimit 4294967295
2001:1b10:100::1:2 via fe80::2c0:9fff:fe4b:8a4d dev eth0  proto zebra  metric 2  mtu 1500 advmss 1440 hoplimit 4294967295
2001:1b10:100::21:1 via fe80::2c0:9fff:fe4b:8a4d dev eth0  proto zebra  metric 2  mtu 1500 advmss 1440 hoplimit 4294967295
2001:1b10:100::53:1 via fe80::2c0:9fff:fe4b:8ccf dev eth0  proto zebra  metric 2  mtu 1500 advmss 1440 hoplimit 4294967295
2001:1b10:100::119:1 via fe80::2c0:9fff:fe4b:8a4d dev eth0  proto zebra  metric 2  mtu 1500 advmss 1440 hoplimit 4294967295
2001:1b10:100::1:9000:1 via fe80::2c0:9fff:fe4b:8a4d dev eth0  proto zebra  metric 2  mtu 1500 advmss 1440 hoplimit 4294967295
2001:1b10:100:3::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440 hoplimit 4294967295
fe80::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440 hoplimit 4294967295
fe80::/64 dev teredo  proto kernel  metric 256  mtu 1280 advmss 1220 hoplimit 4294967295
ff00::/8 dev eth0  metric 256  mtu 1500 advmss 1440 hoplimit 4294967295
ff00::/8 dev teredo  metric 256  mtu 1280 advmss 1220 hoplimit 4294967295
default via 2001:1b10:100:3::1 dev eth0  metric 1  mtu 1500 advmss 1440 hoplimit 4294967295

>         Also might be worthwhile to see the entire arg list, so
> maybe using the "-s" option to strace to increase it, and we
> probably only need sendmsg(), so maybe:
> 
> strace -s 1024 -e trace=sendmsg -e verbose=sendmsg ping6 -I eth0 ....
> 
> I wanted to see more detail than strace could fit in the default length. 
> :-)

Working (all-hosts):
sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0\25S\0\3\0\305\305H\212/\r\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37 !\"#$%&'()*+,-./01234567"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, MSG_CONFIRM) = 64

Non-working (RIPng group):
sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0MS\0\0012\305\305HCA\r\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37 !\"#$%&'()*+,-./01234567"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, 0) = -1 EINVAL (Invalid argument)
sendmsg(3, {msg_name(28)={sa_family=AF_INET6, sin6_port=htons(58), inet_pton(AF_INET6, "ff02::9", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, msg_iov(1)=[{"\200\0\0\0MS\0\0012\305\305H\36F\r\0\10\t\n\v\f\r\16\17\20\21\22\23\24\25\26\27\30\31\32\33\34\35\36\37 !\"#$%&'()*+,-./01234567"..., 64}], msg_controllen=32, {cmsg_len=32, cmsg_level=SOL_IPV6, cmsg_type=, ...}, msg_flags=0}, 0) = -1 EINVAL (Invalid argument)

(yes, ping6 is actually trying twice when it's broken, no idea why)

Bernhard

