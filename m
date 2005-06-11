From: Willy Tarreau <willy@w.ods.org>
Subject: [PATCH] fix small DoS on connect() (was Re: BUG: Unusual TCP Connect() results.)
Date: Sat, 11 Jun 2005 09:43:50 +0200
Message-ID: <20050611074350.GD28759@alpha.home.local>
References: <42A9C607.4030209@unixtrix.com> <42A9BA87.4010600@stud.feec.vutbr.cz> <20050610222645.GA1317@pcw.home.local> <20050610.154248.130848042.davem@davemloft.net> <20050611062413.GA1324@pcw.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xschmi00@stud.feec.vutbr.cz, alastair@unixtrix.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050611062413.GA1324@pcw.home.local>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi David,

well, I could easily build a proof of concept demonstrating the security
problem implied by the simultaneous connect support. For this, I have two
machines on the LAN. One (wks, 10.0.3.9, 2.4.29) wants to connect to
www.kernel.org:80 (204.152.191.5). It works as expected :

  wks:willy$ printf "HEAD / HTTP/1.0\r\n\r\n" | nc -p 10000 204.152.191.5 80; echo "ret=$?"
  HTTP/1.1 200 OK
  Date: Sat, 11 Jun 2005 07:08:27 GMT
  Server: Apache/2.0.52 (Fedora)
  Accept-Ranges: bytes
  Connection: close
  Content-Type: text/html

  ret=0

The other one (pcw) tries to prevent wks from connecting to www.kernel.org,
by sending to it about 10 SYNs per second spoofing kernel.org's port 80 :
  pcw# hping2 -i u100000 -k -a 204.152.191.5 -s 80 -I eth0 10.0.3.9 -p 10000 -S -M 12345678

During this, the client cannot connect to www.kernel.org from this port
anymore :
  wks$ printf "HEAD / HTTP/1.0\r\n\r\n" | nc -p 10000 204.152.191.5 80; echo "ret=$?"
  ret=1

Capture on the victim (wks=victim, pcw=attacker, www=www.kernel.org):

  wks 09:06:44.020809 10.0.3.9.10000 > 204.152.191.5.80: S 4010109823:4010109823(0) win 5840 <mss 1460,nop,wscale 0> (DF)
  pcw 09:06:44.065589 204.152.191.5.80 > 10.0.3.9.10000: S 12345678:12345678(0) win 512
  wks 09:06:44.065621 10.0.3.9.10000 > 204.152.191.5.80: S 4010109823:4010109823(0) ack 12345679 win 5840 <mss 1460,nop,wscale 0> (DF)
  pcw 09:06:44.166544 204.152.191.5.80 > 10.0.3.9.10000: S 12345678:12345678(0) win 512
  www 09:06:44.217896 204.152.191.5.80 > 10.0.3.9.10000: S 2774672577:2774672577(0) ack 4010109824 win 5840 <mss 1420,nop,wscale 2> (DF)
  wks 09:06:44.217939 10.0.3.9.10000 > 204.152.191.5.80: . ack 12345679 win 5840 (DF)
  wks 09:06:47.020040 10.0.3.9.10000 > 204.152.191.5.80: S 4010109823:4010109823(0) ack 12345679 win 5840 <mss 1460,nop,wscale 0> (DF)
  ...

=> cannot establish, because of either my local firewall or www.kernel.org's
blocks wrong ACKs. Without a firewall, wks would have got an RST.

With the attached patch, I can no longer block the communication :

  09:31:23.004379 IP (tos 0x0, ttl  64, id 36202, offset 0, flags [DF], length: 60) 10.0.3.1.10000 > 204.152.191.5.80: S [tcp sum ok] 1176290222:1176290222(0) win 13920 <mss 6960,sackOK,timestamp 4294921924 0,nop,wscale 2>
  09:31:23.051743 IP (tos 0x0, ttl  64, id 9074, offset 0, flags [none], length: 40) 204.152.191.5.80 > 10.0.3.1.10000: S [tcp sum ok] 12345678:12345678(0) win 512
  09:31:23.102683 IP (tos 0x0, ttl  64, id 42364, offset 0, flags [none], length: 40) 204.152.191.5.80 > 10.0.3.1.10000: S [tcp sum ok] 12345678:12345678(0) win 512
  09:31:23.203546 IP (tos 0x0, ttl  58, id 0, offset 0, flags [DF], length: 60) 204.152.191.5.80 > 10.0.3.1.10000: S [tcp sum ok] 3923636405:3923636405(0) ack 1176290223 win 5792 <mss 1420,sackOK,timestamp 2199155996 4294921924,nop,wscale 2>
  09:31:23.203625 IP (tos 0x0, ttl  64, id 36204, offset 0, flags [DF], length: 52) 10.0.3.1.10000 > 204.152.191.5.80: . [tcp sum ok] 1176290223:1176290223(0) ack 3923636406 win 3480 <nop,nop,timestamp 4294922124 2199155996>

=> the client ignores fake SYNs and the connection establishes normally.

The proposed patch adds a "tcp_simult_connect "sysctl which is disabled by
default to fix the problem for non-aware people. Those who know they need
the simultaneous connect can enable it manually, but I doubt we can find
many of them.

Does it seem appropriate for mainline ? In this case, I would also backport
it to 2.4 and send it to you for inclusion.

Thanks,
Willy


diff -urN linux-2.6.11.11/include/linux/sysctl.h linux-2.6.11.11-tcp/include/linux/sysctl.h
--- linux-2.6.11.11/include/linux/sysctl.h	Mon Mar 28 07:06:45 2005
+++ linux-2.6.11.11-tcp/include/linux/sysctl.h	Sat Jun 11 09:00:22 2005
@@ -345,6 +345,7 @@
 	NET_TCP_MODERATE_RCVBUF=106,
 	NET_TCP_TSO_WIN_DIVISOR=107,
 	NET_TCP_BIC_BETA=108,
+	NET_TCP_SIMULT_CONNECT=109,
 };
 
 enum {
diff -urN linux-2.6.11.11/include/net/tcp.h linux-2.6.11.11-tcp/include/net/tcp.h
--- linux-2.6.11.11/include/net/tcp.h	Mon Mar 28 07:06:45 2005
+++ linux-2.6.11.11-tcp/include/net/tcp.h	Sat Jun 11 08:56:16 2005
@@ -608,6 +608,7 @@
 extern int sysctl_tcp_bic_beta;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
+extern int sysctl_tcp_simult_connect;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
diff -urN linux-2.6.11.11/net/ipv4/sysctl_net_ipv4.c linux-2.6.11.11-tcp/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.11.11/net/ipv4/sysctl_net_ipv4.c	Mon Mar 28 07:06:48 2005
+++ linux-2.6.11.11-tcp/net/ipv4/sysctl_net_ipv4.c	Sat Jun 11 08:55:27 2005
@@ -690,6 +690,14 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_SIMULT_CONNECT,
+		.procname	= "tcp_simult_connect",
+		.data		= &sysctl_tcp_simult_connect,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff -urN linux-2.6.11.11/net/ipv4/tcp_input.c linux-2.6.11.11-tcp/net/ipv4/tcp_input.c
--- linux-2.6.11.11/net/ipv4/tcp_input.c	Fri Jun 10 22:49:43 2005
+++ linux-2.6.11.11-tcp/net/ipv4/tcp_input.c	Sat Jun 11 08:58:54 2005
@@ -84,6 +84,7 @@
 
 int sysctl_tcp_stdurg;
 int sysctl_tcp_rfc1337;
+int sysctl_tcp_simult_connect;
 int sysctl_tcp_max_orphans = NR_FILE;
 int sysctl_tcp_frto;
 int sysctl_tcp_nometrics_save;
@@ -4620,7 +4621,7 @@
 	if (tp->rx_opt.ts_recent_stamp && tp->rx_opt.saw_tstamp && tcp_paws_check(&tp->rx_opt, 0))
 		goto discard_and_undo;
 
-	if (th->syn) {
+	if (th->syn && sysctl_tcp_simult_connect) {
 		/* We see SYN without ACK. It is attempt of
 		 * simultaneous connect with crossed SYNs.
 		 * Particularly, it can be connect to self.
