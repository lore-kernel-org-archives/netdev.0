From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC net-next iproute2 0/2] Add support for operating raw sockest via diag interface
Date: Wed, 26 Oct 2016 22:30:06 +0300
Message-ID: <1477510208-20292-1-git-send-email-gorcunov@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andrey Vagin <avagin@openvz.org>,
        Cyrill Gorcunov <gorcunov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33474 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752805AbcJZTaZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 15:30:25 -0400
Received: by mail-lf0-f65.google.com with SMTP id n3so732227lfn.0
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 12:30:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The diag interface for raw sockets is now in linux-net-next
http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=432490f9d455fb842d70219f22d9d2c812371676
so here is early patches for misc/ss

While "showing" action works as expected, I see some weird effects on
"kill" socket actions. In particular I've a test program which binds
sockets to veth interface

	# ip link add dev vm1 type veth peer name vm2

        setsockopt(sk, SOL_SOCKET, SO_BINDTODEVICE, "vm1", 3);
        setsockopt(sk6, SOL_SOCKET, SO_BINDTODEVICE, "vm1", 3);
        setsockopt(skc, SOL_SOCKET, SO_BINDTODEVICE, "vm1", 3);
        setsockopt(sk6, SOL_SOCKET, SO_BINDTODEVICE, "vm1", 3);
        setsockopt(skicmp, SOL_SOCKET, SO_BINDTODEVICE, "vm1", 3);

so the output shows

[root@pcs7 iproute2]# ./misc/ss -A raw
State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
UNCONN     0      0                                             *%vm1:icmp                                                            *:*                    
UNCONN     0      0                                                 *:ipproto-255                                                     *:*                    
UNCONN     0      0                                             *%vm1:ipproto-255                                                     *:*                    
UNCONN     0      0                                    127.0.0.10%vm1:ipproto-255                                                     *:*                    
UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
UNCONN     0      0                                                :::ipv6-icmp                                                      :::*                    
ESTAB      0      0                                               ::1:ipproto-255                                                   ::1:ipproto-9091         
UNCONN     0      0                                           ::1%vm1:ipproto-255                                                    :::*                    
[root@pcs7 iproute2]# 

But when I start killing sockets

[root@pcs7 iproute2]# ./misc/ss -aKw 'dev == vm1'
State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
UNCONN     0      0                                             *%vm1:ipproto-255                                                     *:*                    
UNCONN     0      0                                    127.0.0.10%vm1:ipproto-255                                                     *:*                    
UNCONN     0      0                                           ::1%vm1:ipproto-255                                                    :::*                    
[root@pcs7 iproute2]# 
[root@pcs7 iproute2]# ./misc/ss -aKw 'dev == vm1'
State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
UNCONN     0      0                                    127.0.0.10%vm1:ipproto-255                                                     *:*                    
[root@pcs7 iproute2]# ./misc/ss -aKw 'dev == vm1'
State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
UNCONN     0      0                                             *%vm1:icmp                                                            *:*                    
[root@pcs7 iproute2]# ./misc/ss -aKw 'dev == vm1'
State      Recv-Q Send-Q                                Local Address:Port                                                 Peer Address:Port                
[root@pcs7 iproute2]# 

It doesn't do all this in one pass, so I suspect I miss something in second patch?
Please take a look, once time permit.

Cyrill Gorcunov (2):
  libnetlink: Add test for error code returned from netlink reply
  ss: Add inet raw sockets information gathering via netlink diag
    interface

 include/linux/inet_diag.h | 15 +++++++++++++++
 lib/libnetlink.c          | 21 +++++++++++++++++++++
 misc/ss.c                 | 20 ++++++++++++++++++--
 3 files changed, 54 insertions(+), 2 deletions(-)

-- 
2.7.4
