From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 16/16] netconsole: update documentation for extended netconsole
Date: Thu, 16 Apr 2015 19:03:53 -0400
Message-ID: <1429225433-11946-17-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33169 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746AbbDPXEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:04:43 -0400
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 Documentation/networking/netconsole.txt | 95 ++++++++++++++++++++++++++++++++-
 1 file changed, 94 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
index a5d574a..e7a57c2 100644
--- a/Documentation/networking/netconsole.txt
+++ b/Documentation/networking/netconsole.txt
@@ -2,6 +2,7 @@
 started by Ingo Molnar <mingo@redhat.com>, 2001.09.17
 2.6 port and netpoll api by Matt Mackall <mpm@selenic.com>, Sep 9 2003
 IPv6 support by Cong Wang <xiyou.wangcong@gmail.com>, Jan 1 2013
+Reliable extended console support by Tejun Heo <tj@kernel.org>, Apr 16 2015
 
 Please send bug reports to Matt Mackall <mpm@selenic.com>
 Satyam Sharma <satyam.sharma@gmail.com>, and Cong Wang <xiyou.wangcong@gmail.com>
@@ -24,9 +25,10 @@ Sender and receiver configuration:
 It takes a string configuration parameter "netconsole" in the
 following format:
 
- netconsole=[src-port]@[src-ip]/[<dev>],[tgt-port]@<tgt-ip>/[tgt-macaddr]
+ netconsole=[+][src-port]@[src-ip]/[<dev>],[tgt-port]@<tgt-ip>/[tgt-macaddr]
 
    where
+        +             if present, enable reliable extended console support
         src-port      source for UDP packets (defaults to 6665)
         src-ip        source IP to use (interface address)
         dev           network interface (eth0)
@@ -107,6 +109,7 @@ To remove a target:
 The interface exposes these parameters of a netconsole target to userspace:
 
 	enabled		Is this target currently enabled?	(read-write)
+	extended	Extended mode enabled			(read-write)
 	dev_name	Local network interface name		(read-write)
 	local_port	Source UDP port to use			(read-write)
 	remote_port	Remote agent's UDP port			(read-write)
@@ -132,6 +135,96 @@ You can also update the local interface dynamically. This is especially
 useful if you want to use interfaces that have newly come up (and may not
 have existed when netconsole was loaded / initialized).
 
+Reliable extended console:
+==========================
+
+If '+' is prefixed to the configuration line or "extended" config file
+is set to 1, reliable extended console support is enabled. An example
+boot param follows.
+
+ linux netconsole=+4444@10.0.0.1/eth1,9353@10.0.0.2/12:34:56:78:9a:bc
+
+Reliable extended console support is consisted of three parts.
+
+1. Extended format messages
+---------------------------
+
+Log messages are transmitted with extended metadata header in the
+following format which is the same as /dev/kmsg.
+
+ <level>,<sequnum>,<timestamp>,<contflag>;<message text>
+
+Non printable characters in <message text> are escaped using "\xff"
+notation. If the message contains optional dictionary, verbatim
+newline is used as the delimeter. printk fragments from KERN_CONT
+messages are transmitted in the following form.
+
+ <level>,-,<timestamp>,-,fragid=<fragid>;<message fragment>
+
+Where <fragid> uniquely identifies the message being assembled. Later
+when the assembly is complete, the completed message with sequence
+number is transmitted. The receiver is responsible for handling the
+overlaps between fragements and the final assembled message.
+
+If a message doesn't fit in 1000 bytes, the message is split into
+multiple fragments by netconsole. These fragments are transmitted with
+"ncfrag" header field added.
+
+ ncfrag=<byte-offset>@<0-based-chunk-index>/<total-chunks>
+
+For example,
+
+ 6,416,1758426,-,ncfrag=0@0/2;the first chunk,
+ 6,416,1758426,-,ncfrag=16@1/2;the second chunk
+
+2. Retransmission requests
+--------------------------
+
+If extended console support is enabled, netconsole listens for packets
+arriving on the source port. The receiver can send the packets of the
+following form to request messages with specific sequence numbers.
+
+ nca <missing-seq> <missing-seq>...
+
+There can be any number of <missing-seq> as long as they fit inside
+1000 bytes. If the messages with the matching sequence numbers exist,
+netconsole will retransmit them immediately.
+
+3. ACK and emergency transmission
+---------------------------------
+
+If the receiver sends back a packet with the following format,
+netconsole enables ACK support.
+
+ nca<ack-seq> <missing-seq> <missing-seq>...
+
+If the ack sequence lags the current sequence by more than 10s,
+emergency transmission is started and all the unacked messages are
+retransmitted periodically with increasing interval. In the first
+round, each unacked message is transmitted every 100ms. In the next,
+every 200ms. The interval doubles until it reaches 1s and stays there.
+
+Each emergency transmitted message has "emg=1" header field added to
+it. For example,
+
+ 6,416,1758426,-,emg=1;netpoll: netconsole: local port 6666
+
+This exists to ensure that messages reach the destination even when
+things went pear-shaped. As long as netpoll and timer are working, the
+logging target has pretty good chance of receiving all messages.
+
+Receiver
+--------
+
+libncrx is a library which implements reliable remote logger using the
+above features. The library is available under tools/lib/netconsole.
+The library is a pure state machine with packet and timer plumbing
+left to the library user to ease integration into larger framework.
+See tools/lib/netconsole/ncrx.h for details.
+
+tools/ncrx/ncrx is a simple receiver program using libncrx which can
+be used as an example.
+
 Miscellaneous notes:
 ====================
 
-- 
2.1.0
