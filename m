From: Josef Bacik <jbacik@fb.com>
Subject: Re: TCP stops sending packets over loopback on 4.10-rc3?
Date: Thu, 26 Jan 2017 16:59:08 -0500
Message-ID: <1485467948.25897.2.camel@fb.com>
References: <1485256853.4014.0@smtp.office365.com>
         <1485266868.16328.292.camel@edumazet-glaptop3.roam.corp.google.com>
         <1485353664.5902.2@smtp.office365.com>
         <1485354408.5902.3@smtp.office365.com>
         <1485355199.5145.14.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Lawrence Brakmo <brakmo@fb.com>,
        Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:51374 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753562AbdAZWAa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 17:00:30 -0500
In-Reply-To: <1485355199.5145.14.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-01-25 at 06:39 -0800, Eric Dumazet wrote:
> On Wed, 2017-01-25 at 09:26 -0500, Josef Bacik wrote:
> 
> > 
> > Nope ftrace isn't broken, I'm just dumb, the space is being
> > reclaimed 
> > by sk_wmem_free_skb().  So I guess I need to figure out why I stop 
> > getting ACK's from the other side of the loopback.  Thanks,
> ss -temoi dst 127.0.0.1
> 
> Might give you some hints, like packets being dropped.
> 
> ACK can be delayed if the reader is slow to consume bytes.
> 

Yup looks like I'm getting packet loss for some reason, but the
application is sitting there in recvmsg, so it's not hung and
definitely available for receiving new packets.

ESTAB      0      4124232                                              
                                                          ::1:34044    
                                                                       
                                            ::1:nbd                   t
imer:(on,1min38sec,9) ino:20067 sk:8 <->
         skmem:(r0,rb6291456,t0,tb4194304,f1720,w4204872,o0,bl0) ts
sack cubic wscale:7,7 rto:102912 backoff:9 rtt:0.084/0.038 ato:40
mss:65464 cwnd:1 ssthresh:18 bytes_acked:71964077253
bytes_received:68804409996 segs_out:3882829 segs_in:4092731 send
6234.7Mbps lastsnd:4336 lastrcv:111289 lastack:111299 unacked:28
retrans:1/4277 lost:28 reordering:60 rcv_rtt:1.875 rcv_space:1315136

ESTAB      0      0                                                    
                                                         ::1:nbd       
                                                                       
                                           ::1:34044                 ti
mer:(keepalive,109min,0) ino:19396 sk:2 <->
         skmem:(r0,rb6291456,t0,tb2626560,f0,w0,o0,bl0) ts sack cubic
wscale:7,7 rto:201 rtt:0.279/0.16 ato:40 mss:65464 cwnd:16 ssthresh:9
bytes_acked:68804409996 bytes_received:71964077252 segs_out:4092730
segs_in:3882792 send 30033.7Mbps lastsnd:111286 lastrcv:111307
lastack:111286 retrans:0/3113 reordering:26 rcv_rtt:1 rcv_space:4782816

I traced tcp_enter_loss() and once things stop moving that starts
firing.  That's all I have so far, been busy with other things but I'm
devoting my full attention to this now.  Thanks,

Josef
