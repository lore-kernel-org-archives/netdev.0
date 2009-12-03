From: kapil dakhane <kdakhane@gmail.com>
Subject: Re: soft lockup in inet_csk_get_port
Date: Wed, 2 Dec 2009 20:13:24 -0800
Message-ID: <99d458640912022013l473690dax3f497248072cce0d@mail.gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com>
	 <4B14B35F.5000403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:61947 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755506AbZLCENS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 23:13:18 -0500
Received: by iwn1 with SMTP id 1so649111iwn.33
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2009 20:13:24 -0800 (PST)
In-Reply-To: <4B14B35F.5000403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Hmm, I did an one hour audit and could not yet find the bug.
>
> Is it a reproductible error, and any chance I can have a snapshot of
> "netstat -atn" before the lockup ? (maybe privately, since it might be
> too big for netdev)
>
It happens every time. I am working on it will send it to you very soon.

> What is the 'fast' program, is it freely available somewhere ?
>
Its some thing we cooked up in house to test linux network stack
scalability. Its a single threaded transparent proxy, it uses libevent
(which uses epoll), and forwards data from incoming transparently
captured connection, to its original destination. It does this without
doing any copy of data once its read from socket. Clients simply send
data to content server's ip-address, without being aware of the proxy
in the middle, and content-servers see clients ip-address as the
source ip. mpstat output shows that it has very little overhead in
terms of user-space cpu.

Let me know what part of the program you are interested in, and I can
give you the code snippets. IMO, here's what you should know:
sysctl options:
net.ipv4.ip_local_port_range = 1024 65535
# increase TCP max buffer size setable using setsockopt()
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
# increase Linux autotuning TCP buffer limits
# min, default, and max number of bytes to use
# set max to at least 4MB, or higher if you use very high BDP paths
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_keepalive_intvl = 5
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_time = 180
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_max_syn_backlog = 8192
error: "net.ipv4.netfilter.ip_conntrack_max" is an unknown key
error: "net.ipv4.ip_conntrack_max" is an unknown key
net.ipv4.tcp_max_tw_buckets = 360000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 0
net.core.netdev_max_backlog = 5000

/etc/security/limits.conf :
* - nofile 262144



Listen sockets options:
    176   if ((sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP))
...
    106   if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one))
    114   if (setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, &one, sizeof(one))
    122   if (setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &one, sizeof(one))
    131     if (setsockopt(sock, SOL_SOCKET, SO_SNDBUF, &val, sizeof(val))
    141     if (setsockopt(sock, SOL_SOCKET, SO_RCVBUF, &val, sizeof(val))

  int flags = fcntl(fd, F_GETFL, 0);
  if (flags >= 0 && fcntl(fd, F_SETFL, flags | O_NONBLOCK)

    162     if (setsockopt(sock, SOL_IP, IP_TRANSPARENT, &one, sizeof(one))
...
    190   if (bind(sock, (struct sockaddr *)&sain, sizeof(sain))
//listen port == 4002
    202   if (listen(sock, config.listen_backlog) == -1) { //backlog == 1024
Client socket options:
  int flags = fcntl(fd, F_GETFL, 0);
  if (flags >= 0 && fcntl(fd, F_SETFL, flags | O_NONBLOCK)

Outbound connections:
  if (unlikely((conn->ssock = socket(AF_INET, SOCK_STREAM,  IPPROTO_TCP))
  if (unlikely(setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, &one, sizeof(one))
  if (unlikely(setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &one, sizeof(one))
  if (unlikely(setsockopt(sock, SOL_SOCKET, SO_SNDBUF, &val, sizeof(val))
  if (unlikely(setsockopt(sock, SOL_SOCKET, SO_RCVBUF, &val, sizeof(val))
  int flags = fcntl(fd, F_GETFL, 0);
//O_NONBLOCK
  if (flags >= 0 && fcntl(fd, F_SETFL, flags | O_NONBLOCK) == 0)
   if (setsockopt(sock, SOL_IP, IP_TRANSPARENT, &one, sizeof(one))
//masquerade client
  local_sain.sin_family = AF_INET;
  local_sain.sin_addr.s_addr = tctx->client_sain->sin_addr.s_addr;
  local_sain.sin_port = tctx->client_sain->sin_port;
  int attempts = 0;
  again:
  attempts++;
  UPDATE_MAX_STAT(server.peak_masqattempts, attempts);
  if (unlikely(bind(*(tctx->ssock), (struct sockaddr *)&local_sain,
                    sizeof(local_sain)) == -1)) {
    if (errno == EADDRINUSE && attempts < config.max_masq_attempts) {
      local_sain.sin_port = htons(generate_random_port());
      goto again;
    }
  if (unlikely(connect(conn->ssock, (struct sockaddr *)&conn->server_sain,
                       sizeof(conn->server_sain))

// Get the local address
  socklen_t sl = sizeof(conn->sproxy_sain);
  if (unlikely(getsockname(conn->ssock, (struct sockaddr *)&conn->sproxy_sain,
                           &sl) == -1)) {
    LOG_ERROR(NULL, "Unable to get the local address for server connection "
              "(%d): %s.\n", errno, strerror(errno));
    return -1;
  }


Network setup:
Clients and servers are segregated into several vlans:
ifcfg-eth1.147  ifcfg-eth2.143  ifcfg-eth2.43  ifcfg-eth4.145
ifcfg-eth4.45  ifcfg-eth5.153  ifcfg-eth6.139  ifcfg-eth6.39
ifcfg-eth7.141  ifcfg-eth7.41
ifcfg-eth1.148  ifcfg-eth2.144  ifcfg-eth2.44  ifcfg-eth4.146
ifcfg-eth4.46  ifcfg-eth5.154  ifcfg-eth6.140  ifcfg-eth6.40
ifcfg-eth7.142  ifcfg-eth7.42
ifcfg-eth1.47   ifcfg-eth2.149  ifcfg-eth2.49  ifcfg-eth4.151
ifcfg-eth4.51  ifcfg-eth5.53   ifcfg-eth6.155  ifcfg-eth6.55
ifcfg-eth7.157  ifcfg-eth7.57
ifcfg-eth1.48   ifcfg-eth2.150  ifcfg-eth2.50  ifcfg-eth4.152
ifcfg-eth4.52  ifcfg-eth5.54   ifcfg-eth6.156  ifcfg-eth6.56
ifcfg-eth7.158  ifcfg-eth7.58

Traffic comes in through ifcfg-ethx.xx and goes out via ifcfg-ethx.1xx
on the same NIC. Reverse traffic goes from 1xx to xx.

iptables and ip rules are set like so:
Printing MANGLE rules...
Chain PREROUTING (policy ACCEPT 20M packets, 8970M bytes)
 pkts bytes target     prot opt in     out     source
destination
 681M  586G DIVERT     tcp  --  *      *       0.0.0.0/0
0.0.0.0/0           socket
1290K   76M TPROXY     tcp  --  eth6.39 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.39.1:4002 mark
0x1/0x1
1902K  112M TPROXY     tcp  --  eth6.40 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.40.1:4002 mark
0x1/0x1
1348K   79M TPROXY     tcp  --  eth7.41 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.41.1:4002 mark
0x1/0x1
 867K   51M TPROXY     tcp  --  eth7.42 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.42.1:4002 mark
0x1/0x1
 850K   49M TPROXY     tcp  --  eth2.43 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.43.1:4002 mark
0x1/0x1
 847K   49M TPROXY     tcp  --  eth2.44 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.44.1:4002 mark
0x1/0x1
1334K   78M TPROXY     tcp  --  eth4.45 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.45.1:4002 mark
0x1/0x1
 858K   50M TPROXY     tcp  --  eth4.46 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.46.1:4002 mark
0x1/0x1
 818K   46M TPROXY     tcp  --  eth1.47 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.47.1:4002 mark
0x1/0x1
 807K   45M TPROXY     tcp  --  eth1.48 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.48.1:4002 mark
0x1/0x1
 804K   45M TPROXY     tcp  --  eth2.49 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.49.1:4002 mark
0x1/0x1
 906K   51M TPROXY     tcp  --  eth2.50 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.50.1:4002 mark
0x1/0x1
1569K   89M TPROXY     tcp  --  eth4.51 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.51.1:4002 mark
0x1/0x1
1851K  105M TPROXY     tcp  --  eth4.52 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.52.1:4002 mark
0x1/0x1
1798K  101M TPROXY     tcp  --  eth5.53 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.53.1:4002 mark
0x1/0x1
1829K  103M TPROXY     tcp  --  eth5.54 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.54.1:4002 mark
0x1/0x1
1752K   99M TPROXY     tcp  --  eth6.55 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.55.1:4002 mark
0x1/0x1
1777K  101M TPROXY     tcp  --  eth6.56 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.56.1:4002 mark
0x1/0x1
1800K  102M TPROXY     tcp  --  eth7.57 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.57.1:4002 mark
0x1/0x1
1794K  101M TPROXY     tcp  --  eth7.58 *       0.0.0.0/0
0.0.0.0/0           tcp dpt:80 TPROXY redirect 192.168.58.1:4002 mark
0x1/0x1

Chain INPUT (policy ACCEPT 708M packets, 588G bytes)
 pkts bytes target     prot opt in     out     source
destination

Chain FORWARD (policy ACCEPT 20M packets, 8970M bytes)
 pkts bytes target     prot opt in     out     source
destination

Chain OUTPUT (policy ACCEPT 713M packets, 593G bytes)
 pkts bytes target     prot opt in     out     source
destination

Chain POSTROUTING (policy ACCEPT 733M packets, 602G bytes)
 pkts bytes target     prot opt in     out     source
destination

Chain DIVERT (1 references)
 pkts bytes target     prot opt in     out     source
destination
 681M  586G MARK       all  --  *      *       0.0.0.0/0
0.0.0.0/0           MARK xset 0x1/0xffffffff
 681M  586G ACCEPT     all  --  *      *       0.0.0.0/0
0.0.0.0/0

Printing IP rules...
0:      from all lookup 255
32765:  from all fwmark 0x1 lookup 100
32766:  from all lookup main
32767:  from all lookup default


Each fast proxy handles traffic from two client-facing vlans.

Hope this helps.

Regards,
Kapil
