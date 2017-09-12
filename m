From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: TCP_USER_TIMEOUT can not work in tcp_probe_timer()
Date: Tue, 12 Sep 2017 08:38:06 -0700
Message-ID: <1505230686.15310.141.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1505111262-12620-1-git-send-email-liujian56@huawei.com>
         <1505141357.15310.115.camel@edumazet-glaptop3.roam.corp.google.com>
         <1505142785.15310.117.camel@edumazet-glaptop3.roam.corp.google.com>
         <1505143348.15310.118.camel@edumazet-glaptop3.roam.corp.google.com>
         <e7e09201-40c2-933a-1e8e-a31eddcc75ab@huawei.com>
         <1505228700.15310.138.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        edumazet@google.com, ycheng@google.com, hkchu@google.com,
        netdev@vger.kernel.org, weiyongjun1@huawei.com,
        wangkefeng 00227729 <wangkefeng.wang@huawei.com>
To: liujian <liujian56@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:37525 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751404AbdILPiI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 11:38:08 -0400
Received: by mail-pg0-f66.google.com with SMTP id v5so6326756pgn.4
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 08:38:08 -0700 (PDT)
In-Reply-To: <1505228700.15310.138.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-12 at 08:05 -0700, Eric Dumazet wrote:
> On Tue, 2017-09-12 at 14:08 +0800, liujian wrote:
> > Hi,
> > 
> > In the scenario, tcp server side IP changed, and at that memont,
> > userspace application still send data continuously;
> > tcp_send_head(sk)'s timestamp always be refreshed.
> > 
> > Here is the packetdrill script:
> > 
> >    0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> >    +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> >    +0 bind(3, ..., ...) = 0
> >    +0 listen(3, 1) = 0
> > 
> >    +0 < S 0:0(0) win 0 <mss 1460,sackOK,nop,nop,nop,wscale 7>
> >    +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 7>
> > 
> >   +.1 < . 1:1(0) ack 1 win 65530
> >    +0 accept(3, ..., ...) = 4
> > 
> >    +0 setsockopt(4, SOL_TCP, TCP_USER_TIMEOUT, [3000], 4) = 0
> >    +0 write(4, ..., 24) = 24
> >    +0 > P. 1:25(24) ack 1 win 229
> >    +.1 < . 1:1(0) ack 25 win 65530
> > 
> > //change the ipaddress
> >    +1 `ifconfig tun0 192.168.0.10/16`
> > 
> >    +1 write(4, ..., 24) = 24
> >    +1 write(4, ..., 24) = 24
> >    +1 write(4, ..., 24) = 24
> >    +1 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> >    +3 write(4, ..., 24) = 24
> > 
> >    +0 `ifconfig tun0 192.168.0.1/16`
> >    +0 < . 1:1(0) ack 1 win 1000
> >    +0 write(4, ..., 24) = -1
> > 
> > 
> 
> This has nothing to do with the code patch you have changed.
> 
> How have you tested your patch exactly ?
> 


lpaa23:~# ss -toenmi src :8080
State      Recv-Q Send-Q Local Address:Port               Peer
Address:Port              
ESTAB      0      144    192.168.134.161:8080
192.0.2.1:51165               timer:(persist,8.262ms,5) ino:1
82083 sk:3 <->
	 skmem:(r0,rb359040,t0,tb46080,f1792,w2304,o0,bl0,d0) sack cubic
wscale:7,8 rto:301 backoff:5 rtt:100.127/37.576 
mss:1460 rcvmss:536 advmss:1460 cwnd:10 bytes_acked:24 segs_out:12
segs_in:3 data_segs_out:12 send 1.2Mbps lastsnd:1370 l
astrcv:13348 lastack:13248 pacing_rate 2.3Mbps delivery_rate 116.7Kbps
app_limited busy:11346ms rcv_space:29200 notsent:1
44 minrtt:100.043

This is the typical RTO timer, not zero window probe.
