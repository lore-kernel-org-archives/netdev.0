From: Sam Russell <sam.h.russell@gmail.com>
Subject: MPLS outbound packets being dropped
Date: Sun, 6 Dec 2015 23:20:58 +1300
Message-ID: <CAJm+voUzeyccnn57U_LEDQNO1qyn9xEYMDOjvqWeW+awifuDCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:32843 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbbLFKU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 05:20:59 -0500
Received: by ykdv3 with SMTP id v3so166965586ykd.0
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2015 02:20:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tl;dr mpls_output expects skb->protocol to be set to correct
ethertype, but it isn't

https://github.com/torvalds/linux/blob/ede2059dbaf9c6557a49d466c8c7778343b208ff/net/mpls/mpls_iptunnel.c#L64

Problem:

I set up two interfaces pointed at each other, and added a static arp
entry to minimise complexity

ifconfig enp0s8 10.0.0.1/24 up
ifconfig enp0s9 up
arp -s 10.0.0.5 00:12:34:56:78:90

I then added an MPLS route

./dev/iproute2/ip/ip route add 192.168.2.0/24 encap mpls 100 via inet
10.0.0.5 dev enp0s8

I then tried to ping an IP in this route but got errors back

ping 192.168.2.1
* PING 192.168.2.1 (192.168.2.1) 56(84) bytes of data.
* ping: sendmsg: Invalid argument

I then recorded calls to skb_kfree

./tools/perf/perf record -e skb:kfree_skb -g -a

This gave me the following packet trace:

   100.00%   100.00%  ping     [kernel.kallsyms]  [k] kfree_skb
               |
               ---kfree_skb
                  mpls_output
                  lwtunnel_output
                  ip_local_out_sk
                  ip_send_skb
                  ip_push_pending_frames
                  raw_sendmsg
                  inet_sendmsg
                  sock_sendmsg
                  ___sys_sendmsg
                  __sys_sendmsg
                  sys_sendmsg
                  entry_SYSCALL_64_fastpath
                  sendmsg
                  0

I then went through mpls_output.c and put printk() at every call to
"goto drop" and found that this was being hit after failing to match
skb->protocol

https://github.com/torvalds/linux/blob/ede2059dbaf9c6557a49d466c8c7778343b208ff/net/mpls/mpls_iptunnel.c#L64

My understanding is that skb->protocol is normally set after
dst_output. For example, a ping packet hitting a normal IPv4 route
should follow something like:

raw_sendmsg
ip_push_pending_frames
ip_send_skb
ip_local_out_sk
dst_output
ip_output

ip_output() is the first place where skb->protocol gets set

https://github.com/torvalds/linux/blob/dbd3393c56a8794fe596e7dd20d0efa613b9cf61/net/ipv4/ip_output.c#L356

The path that a packet follows when hitting an MPLS route is as follows:

raw_sendmsg
ip_push_pending_frames
ip_send_skb
ip_local_out_sk
dst_output
lwtunnel_output
mpls_output

lwtunnel_output merely routes to the correct output function (mpls_output)
mpls_output expects skb->protocol to be set, but nothing has set it
yet, so it drops the packet!

Any suggestions on how mpls_output should detect the protocol?

Setup:

Ubuntu 15.10

iproute2 built from head

Kernel 4.3, both ubuntu mainline and home-built:
make menuconfig, add lwtunnel, mpls-router, mpls-gso and mpls-iptunnel

Running virtualbox on OSX
