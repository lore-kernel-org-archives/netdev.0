From: Chris Friesen <chris.friesen@windriver.com>
Subject: weird behaviour, getting EAGAIN on a connect() call on a unix stream
 socket
Date: Fri, 1 Aug 2014 21:51:21 -0600
Message-ID: <53DC6039.2010002@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49648 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbaHBDvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 23:51:23 -0400
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca.corp.ad.wrs.com [147.11.189.40])
	by mail.windriver.com (8.14.9/8.14.5) with ESMTP id s723pNEI009063
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 1 Aug 2014 20:51:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to figure out what would case a connect() call on a unix stream
socket to return EAGAIN.  (On a 3.4 kernel, if it matters.)

I've got two unix stream sockets on the system, created by two qemu instances
as virtio-serial channels.

I've got an app that tries to connect() to both of them in turn.  The connect()
to the first socket fails with EAGAIN, the second one succeeds, and all
subsequent retries on the first fail.  Here's an strace() of the sequence:

socket(PF_FILE, SOCK_STREAM, 0)         = 6
fcntl(6, F_GETFL)                       = 0x2 (flags O_RDWR)
fcntl(6, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
connect(6, {sa_family=AF_FILE, sun_path="/var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock"}, 61) = -1 EAGAIN (Resource temporarily unavailable)
clock_gettime(CLOCK_MONOTONIC, {158877, 262941763}) = 0
socket(PF_FILE, SOCK_STREAM, 0)         = 7
fcntl(7, F_GETFL)                       = 0x2 (flags O_RDWR)
fcntl(7, F_SETFL, O_RDWR|O_NONBLOCK)    = 0
connect(7, {sa_family=AF_FILE, sun_path="/var/lib/libvirt/qemu/cgcs.messaging.instance-00000008.sock"}, 61) = 0
getdents(5, /* 0 entries */, 32768)     = 0
close(5)                                = 0
clock_gettime(CLOCK_MONOTONIC, {158877, 265359109}) = 0
poll([{fd=3, events=POLLIN}, {fd=4, events=POLLIN}, {fd=7, events=POLLIN}], 3, 997) = 0 (Timeout)
clock_gettime(CLOCK_MONOTONIC, {158878, 265914614}) = 0
connect(6, {sa_family=AF_FILE, sun_path="/var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock"}, 61) = -1 EAGAIN (Resource temporarily unavailable)


With the app not running, netstat seems to show that something is trying to
connect to the socket in question:

root@compute-0:~# netstat -ap unix |grep messaging
unix  2      [ ACC ]     STREAM     LISTENING     1109818  17379/qemu-system-x /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
unix  2      [ ACC ]     STREAM     LISTENING     1110051  17425/qemu-system-x /var/lib/libvirt/qemu/cgcs.messaging.instance-00000008.sock
unix  2      [ ]         STREAM     CONNECTING    0        -                   /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
unix  2      [ ]         STREAM     CONNECTING    0        -                   /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
unix  2      [ ]         STREAM     CONNECTED     1109848  17379/qemu-system-x /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock


Here's /proc/net/unix for completeness:

root@compute-0:~/host-guest-comm# grep -a messaging /proc/net/unix
ffff880045c35540: 00000002 00000000 00010000 0001 01 1109818 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
ffff8800576b8a80: 00000002 00000000 00010000 0001 01 1110051 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000008.sock
ffff880045e2f040: 00000002 00000000 00000000 0001 02     0 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
ffff88004bc5ea80: 00000002 00000000 00000000 0001 02     0 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock
ffff880045e2f540: 00000002 00000000 00000000 0001 03 1109848 /var/lib/libvirt/qemu/cgcs.messaging.instance-00000007.sock



The crazy thing is that I can't figure out what could be causing the
CONNECTED/CONNECTING sockets.  There are no background processes of the
connecting app running, no zombie processes, no forked children, etc.

Just to make things more interesting, I successfully ran this application
several times (connecting to both sockets) before this behaviour started
happening.  I was running it under strace and just killed it with ctrl-C.

Anyone got any ideas?   Please CC me since I'm not subscribed to the list.

Thanks,
Chris
