From: Josef Bacik <jbacik@fb.com>
Subject: TCP stops sending packets over loopback on 4.10-rc3?
Date: Tue, 24 Jan 2017 06:20:53 -0500
Message-ID: <1485256853.4014.0@smtp.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: Lawrence Brakmo <brakmo@fb.com>, Kernel Team <kernel-team@fb.com>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33342 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750739AbdAXLVD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 06:21:03 -0500
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0OBHwYI018615
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 03:21:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 285vd99cs7-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 03:21:02 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've been trying to test some NBD changes I had made recently and I 
started having packet timeouts.  I traced this down to tcp just 
stopping sending packets after a lot of writing.  All NBD does is call 
kernel_sendmsg() with a request struct and some pages when it does 
writes.  I did a bunch of tracing and I've narrowed it down to running 
out of sk_wmem_queued space.  In tcp_sendmsg() here

new_segment:
                        /* Allocate new segment. If the interface is SG,
                         * allocate skb fitting to single page.
                         */
                        if (!sk_stream_memory_free(sk))
                                goto wait_for_sndbuf;

we hit this pretty regularly, and eventually just get stuck in 
sk_stream_wait_memory until the timeout ends and we error out 
everything.  Now sk_stream_memory_free checks the sk_wmem_queued and 
calls into the sk_prot->stream_memory_free(), so I broke this out like 
the following


    if (sk->sk_wmem_queued >= sk->sk_sndbuf) {
        trace_printk("sk_wmem_queued %d, sk_sndbuf %d\n", 
sk->sk_wmem_queued, sk->sk_sndbuf);
        goto wait_for_sndbuf;
     }
     if (sk->sk_prot->stream_memory_free && 
!sk->sk_prot->stream_memory_free(sk)) {
        trace_printk("sk_stream_memory_free\n");
        goto wait_for_sndbuf;
     }

And I got this in my tracing

   kworker/u16:5-112   [001] ....  1375.637564: tcp_sendmsg: 
sk_wmem_queued 4204872, sk_sndbuf 4194304
   kworker/u16:5-112   [001] ....  1375.639657: tcp_sendmsg: 
sk_wmem_queued 4204872, sk_sndbuf 4194304
   kworker/u16:5-112   [003] ....  1375.641128: tcp_sendmsg: 
sk_wmem_queued 4204872, sk_sndbuf 4194304
   kworker/u16:5-112   [003] ....  1375.643441: tcp_sendmsg: 
sk_wmem_queued 4204872, sk_sndbuf 4194304
   kworker/u16:5-112   [001] ....  1375.807614: tcp_sendmsg: 
sk_wmem_queued 4204872, sk_sndbuf 4194304
   kworker/u16:5-112   [001] ....  1377.538744: tcp_sendmsg: 
sk_wmem_queued 4204872, sk_sndbuf 4194304
   kworker/u16:5-112   [001] ....  1377.543418: tcp_sendmsg: 
sk_wmem_queued 4204872, sk_sndbuf 4194304
    kworker/2:4H-1535  [002] ....  1377.544685: tcp_sendmsg: 
sk_wmem_queued 4204872, sk_sndbuf 4194304
   kworker/u16:5-112   [000] ....  1379.378352: tcp_sendmsg: 
sk_wmem_queued 4205796, sk_sndbuf 4194304
   kworker/u16:5-112   [003] ....  1380.985721: tcp_sendmsg: 
sk_wmem_queued 4212416, sk_sndbuf 4194304

This is as far as I've gotten and I'll keep digging into it, but I was 
wondering if this looks familiar to anybody?  Also one thing I've 
noticed is sk_stream_wait_memory() will wait on sk_sleep(sk), but 
basically nothing wakes this up.  For example it seems the main way we 
reduce sk_wmem_queued is through sk_wmem_free_skb(), which doesn't 
appear to wake anything up in any of its callers, so anybody who does 
end up sleeping will basically never wake up.  That seems like it 
should be more broken than it is, so I'm curious to know how things are 
actually woken up in this case.  Thanks,

Josef
