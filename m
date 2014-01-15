From: Stuart Kendrick <stuart.kendrick.sea@gmail.com>
Subject: unable to send TCP SYNs from ports below 1024
Date: Tue, 14 Jan 2014 17:37:03 -0800
Message-ID: <CAACXELm1Yfv+=oC-N+nnR7apHc+gtZSVpqSbX2Rtkiq6-Y1QtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:62988 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbaAOBhG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 20:37:06 -0500
Received: by mail-la0-f52.google.com with SMTP id c6so909269lan.25
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 17:37:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on a box which refuses to send TCP SYNs from source ports below 1024
[This breaks NFS-mounting, as the NFS client wants to use source ports
below 1024]

Linux ubuntu 3.8.0-35-generic #50~precise1-Ubuntu SMP Wed Dec 4
17:25:51 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux

In a fit of pique, I wiped and rebuilt from scratch a couple weeks ago
... didn't help


VALIDATION
I verify the problem by using netcat plus two instances of tcpdump,
one running on the box itself, the other running on a second box
plugged into a SPAN port on the local Ethernet switch

This invocation produces TCP SYNs in both traces
ubuntu# nc -4 -p 1024 10.1.1.1 2049

Whereas this invocation produces TCP SYNs only in the on-board pcap --
the pcap taken from the switch's SPAN port contains nothing (well, it
contains the ARP exchange for 10.1.1.1, but not TCP frames).
ubuntu# nc -4 -p 1023 10.1.1.1 2049

The NIC carries all sorts of other traffic just fine ... http, https,
sftp, ftp, ssh ... but all those employ TCP source ports above 1024.


RULED OUT
(1) No iptables rules
ubuntu# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
ubuntu#


(2) ufw disabled
ubuntu# ufw status
Status: inactive
ubuntu#


(3) I've tried two different NICs, one employing the e1000e driver,
the other the e1000 driver:
ubuntu# modinfo e1000e | more
filename:
/lib/modules/3.8.0-35-generic/kernel/drivers/net/ethernet/intel/e1000e/e1000e.ko
version:        2.1.4-k
license:        GPL
description:    Intel(R) PRO/1000 Network Driver
[...]

ubuntu# modinfo e1000 | more
filename:
/lib/modules/3.8.0-35-generic/kernel/drivers/net/ethernet/intel/e1000/e1000.ko
version:        7.3.21-k8-NAPI
license:        GPL
description:    Intel(R) PRO/1000 Network Driver
[...]


(4) I've tried upgrading the e1000e driver to 2.5.4; no change in behavior


(5) Ports & Addresses
I've tried various TCP source & destination ports, and from those
results am claiming that the problem is limited to situations in which
the source port is below 1024.  I've also tried using UDP ... but I
don't see frames in either pcap when I use the '-u' option
ubuntu# nc -4 -p 1023 10.1.1.1 2049

ubuntu# nc -4 -p 1024 10.1.1.1 2049


Suggestions?

(A) I have modified the source of the e1000e-2.5.4 driver to add
'printk' statements at key points ...
(B) and I've enabled kernel tracing:
mount -t debugfs nodev /sys/kernel/debug
echo function > /sys/kernel/debug/tracing/current_tracer
echo 1 > /sys/kernel/debug/tracing/events/net/enable
echo 1 > /sys/kernel/debug/tracing/tracing_on
(C) But the output is daunting ... and I haven't figured out how to
distinguish, for example, the TCP SYN events from the ARP
transmissions.  More work needed.

(D) I have SystemTap installed ... but the particular example scripts
(networking-oriented) which might offer insight are throwing semantic
errors ... I'm not sure I'm smart enough to debug these
http://sourceware-org.1504.n7.nabble.com/updated-example-scripts-td256998.html

Before I crawl farther down either of these paths, I figured I'd ask
for input/ideas.

?

tia,

--sk

Stuart Kendrick
