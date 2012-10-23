From: Cong Xu <davidxu06@gmail.com>
Subject: Synchronization between process context and softirq context on SMP machine
Date: Tue, 23 Oct 2012 20:56:30 +0000 (UTC)
Message-ID: <loom.20121023T223837-223@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:50545 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933722Ab2JWVJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 17:09:59 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TQljg-0000Jv-Be
	for netdev@vger.kernel.org; Tue, 23 Oct 2012 23:10:04 +0200
Received: from csdhcp-120-208.cs.purdue.edu ([128.10.120.208])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 23:10:04 +0200
Received: from davidxu06 by csdhcp-120-208.cs.purdue.edu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 23:10:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I met some problems when I did some research in improving the TCP/UDP 
performance of Virtual Machine(VM), if anybody can offer me some help or 
suggestion to handle my problem, I will be very appreciated.


On virtual machine platform, virtual CPU (vCPU) of each VM can not be always 
online when several vCPUs share one physical CPU (pCPU) (Here we can simply 
assume the vCPU scheduling is round-robin.). Therefore, the high delay of TCP 
receiving of VM hurts the TCP throughput significantly. In order to handle this 
problem I assign a virtual co-processor (co-vCPU) which is almost always online 
to each VM and pin NIC IRQ of the VM to this co-vCPU. ( If you are not familiar 
with VM, you can simply assume that in a common OS the user level application 
(e.g. iperf) runs on a cpu which will be offline every 30ms, and the bottom half
 or softirq context runs on another cpu which is always online. )

In my experiment, this method works well for UDP but does not work for TCP. I 
doubt that it is due to the synchronization between process context and softirq 
context. Because when I read some source code of TCP layer in linux, I found 
that both softirq context (e.g. tcp_v4_rcv() in net/ipv4/tcp_ipv4.c) and process 
context (e.g. tcp_recvmsg() in net/ipv4/tcp.c) call lock_sock()/unlock_sock() 
when they access the buffers in kernel(receive_queue, backlog_queue or p
requeue). Therefore, sometimes softirq context can not access the receiving 
buffers locked by another vCPU which runs the user level receiving process 
(iperf server) and this vCPU holding the spinlock has been descheduled by VM 
monitor(VMM) or hypervisor.


I am not sure I described my problem clearly. Anyway, welcome any suggestion on 
it.
