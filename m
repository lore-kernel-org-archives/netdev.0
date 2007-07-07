From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: call to schedule_timeout() with wrong state in af_inet.c
Date: Sat, 7 Jul 2007 14:44:02 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707071429050.3832@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:54411 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbXGGSqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 14:46:07 -0400
Received: from [192.168.1.102] (CPE0018396a01ee-CM001404e0fd78.cpe.net.cable.rogers.com [74.102.207.204])
	(authenticated bits=0)
	by rubicon.netdirect.ca (8.13.1/8.13.1) with ESMTP id l67IjoHJ015504
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 7 Jul 2007 14:46:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  based on a trivial check i added to kernel/timer.c, it seems that
schedule_timeout() is being called with a current state of
TASK_RUNNING, which shouldn't happen.  this appears to be the
offending snippet of code:

net/ipv4/af_inet.c (inet_wait_for_connect)
==========================================
...
while ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
                release_sock(sk);
                timeo = schedule_timeout(timeo);
                lock_sock(sk);
...

  at least, that's what *seems* to be the problem, based on dumping
the hex address and checking it against /proc/kallsyms.

  the diagnostic shows up whenever i run fetchmail, for instance:

Jul  7 14:42:07 localhost kernel: Bad schedule_timeout state: 0 from fetchmail, c0388732

  that last value is the value of __builtin_return_address(0), and i
cross-checked that against /proc/kallsyms:
...
c038845d T inet_bind
c0388615 T inet_stream_connect
c0388814 T inet_accept
c03888b5 T inet_sock_destruct
...

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
