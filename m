From: Vincent Li <vincent.mc.li@gmail.com>
Subject: socket bind to local address ::ffff:127.0.0.1 question
Date: Wed, 12 Feb 2014 12:41:21 -0800
Message-ID: <CAK3+h2zzx5AocGeJxu9cW0kNkiRew6GNDMrbsNq-7H8co=T0_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:36315 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458AbaBLUlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 15:41:22 -0500
Received: by mail-oa0-f42.google.com with SMTP id i7so11684321oag.29
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 12:41:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

we have a traffic path like <BIGIP monitor userland process on Linux>
<------> router<------->pool/real server

there is a  weird issue that intermittently, a socket is bound to
loopback address '::ffff:127.0.0.1' which caused issue for us because
remote end host can't SYN+ACK the SYN source from 127.0.0.1, strace
the userland process shows:

6797  12:36:48.815296 connect(11, {sa_family=AF_INET6,
sin6_port=htons(8180), inet_pton(AF_INET6, "::ffff:172.16.3.165",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=875638834}, 28) = -1
EINPROGRESS (Operation now in progress)
6797  12:36:48.815464 gettimeofday({1391744208, 815499}, NULL) = 0
6797  12:36:48.815552 time(NULL)        = 1391744208
6797  12:36:48.815657 stat64("/etc/localtime", {st_mode=S_IFREG|0644,
st_size=331, ...}) = 0
...................
6797  12:36:48.816948 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(45621), inet_pton(AF_INET6, "::ffff:127.0.0.1",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433145657494601756]) = 0

the working strace is like:

6797  12:30:03.855031 connect(11, {sa_family=AF_INET6,
sin6_port=htons(8180), inet_pton(AF_INET6, "::ffff:172.16.3.165",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=875638834}, 28) = -1
EINPROGRESS (Operation now in progress)
6797  12:30:03.855198 gettimeofday({1391743803, 855244}, NULL) = 0
6797  12:30:03.855284 time(NULL)        = 1391743803
6797  12:30:03.855377 stat64("/etc/localtime", {st_mode=S_IFREG|0644,
st_size=331, ...}) = 0
........................................
6797  12:30:03.856757 getsockname(11, {sa_family=AF_INET6,
sin6_port=htons(59567), inet_pton(AF_INET6, "::ffff:172.16.17.161",
&sin6_addr), sin6_flowinfo=0, sin6_scope_id=0},
[18433145657494601756]) = 0

I looked kernel code through cscope

Cscope tag: LOOPBACK4_IPV6
   #   line  filename / context / line
   1     51  include/net/transp_v6.h <<GLOBAL>>
             #define LOOPBACK4_IPV6 cpu_to_be32(0x7f000006)
   2    640  net/dccp/ipv6.c <<dccp_v6_request_recv_sock>>
             newinet->daddr = newinet->saddr = newinet->rcv_saddr =
LOOPBACK4_IPV6;
   3   1023  net/dccp/ipv6.c <<dccp_v6_connect>>
             inet->rcv_saddr = LOOPBACK4_IPV6;
   4    495  net/ipv4/ip_sockglue.c <<do_ip_setsockopt>>
             inet->daddr != LOOPBACK4_IPV6)) {
   5    342  net/ipv6/af_inet6.c <<inet6_bind>>
             v4addr = LOOPBACK4_IPV6;
   6    193  net/ipv6/datagram.c <<ip6_datagram_connect>>
             inet->rcv_saddr = LOOPBACK4_IPV6;
   7    109  net/ipv6/ipv6_sockglue.c <<ipv6_update_options>>
             inet_sk(sk)->daddr != LOOPBACK4_IPV6) {
   8    287  net/ipv6/raw.c <<rawv6_bind>>
             v4addr = LOOPBACK4_IPV6;
   9    280  net/ipv6/tcp_ipv6.c <<tcp_v6_connect>>
             inet->rcv_saddr = LOOPBACK4_IPV6;
  10   1435  net/ipv6/tcp_ipv6.c <<tcp_v6_syn_recv_sock>>
             newinet->daddr = newinet->saddr = newinet->rcv_saddr =
LOOPBACK4_IPV6;

is  LOOPBACK4_IPV6 (0x7f000006) equivalent to ::ffff:127.0.0.1 ? I
tried to do ipv6 decimal or hex conversion, the result seems does not
match.

any clue?

Vincent
