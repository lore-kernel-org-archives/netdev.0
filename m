From: Feng King <kinwin2008@gmail.com>
Subject: Re: Synchronization between process context and softirq context on
 SMP machine
Date: Wed, 24 Oct 2012 10:47:50 +0800
Message-ID: <CAHp4QVs9G7m-62k6yH+K4TxpW27XURLvUrW8bJUMRLKW-T6LYw@mail.gmail.com>
References: <loom.20121023T223837-223@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Cong Xu <davidxu06@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:40742 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934264Ab2JXCrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 22:47:51 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so42799wib.1
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 19:47:50 -0700 (PDT)
In-Reply-To: <loom.20121023T223837-223@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/10/24 Cong Xu <davidxu06@gmail.com>
>
> I met some problems when I did some research in improving the TCP/UDP
> performance of Virtual Machine(VM), if anybody can offer me some help or
> suggestion to handle my problem, I will be very appreciated.
>
>
> On virtual machine platform, virtual CPU (vCPU) of each VM can not be always
> online when several vCPUs share one physical CPU (pCPU) (Here we can simply
> assume the vCPU scheduling is round-robin.). Therefore, the high delay of TCP
> receiving of VM hurts the TCP throughput significantly. In order to handle this
> problem I assign a virtual co-processor (co-vCPU) which is almost always online
> to each VM and pin NIC IRQ of the VM to this co-vCPU. ( If you are not familiar
> with VM, you can simply assume that in a common OS the user level application
> (e.g. iperf) runs on a cpu which will be offline every 30ms, and the bottom half
>  or softirq context runs on another cpu which is always online. )
>
> In my experiment, this method works well for UDP but does not work for TCP. I
> doubt that it is due to the synchronization between process context and softirq
> context. Because when I read some source code of TCP layer in linux, I found
> that both softirq context (e.g. tcp_v4_rcv() in net/ipv4/tcp_ipv4.c) and process
> context (e.g. tcp_recvmsg() in net/ipv4/tcp.c) call lock_sock()/unlock_sock()
> when they access the buffers in kernel(receive_queue, backlog_queue or p
> requeue). Therefore, sometimes softirq context can not access the receiving
> buffers locked by another vCPU which runs the user level receiving process
> (iperf server) and this vCPU holding the spinlock has been descheduled by VM
> monitor(VMM) or hypervisor.

 if socket is held by process(sock_owned_by_user), softirq will just
add skb to socket's backlog
and then return. when process called release_sock, skbs in backlog
will be handled in process context,
to finish their tcp handling.
  so if softirq enqueues skb more quickly than process consume speed,
the skbs held in sock recvqueue, prequeue
and backlog will grow, if sum of skb truesize beyond per socket
receive buffer limit, skb will be dropped. through
'ss -oemi' you can see per socket receive buffer consumed,
>
>
>
> I am not sure I described my problem clearly. Anyway, welcome any suggestion on
> it.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html




--

Best Regards
king
