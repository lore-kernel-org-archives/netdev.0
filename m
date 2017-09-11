From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: TCP_USER_TIMEOUT can not work in tcp_probe_timer()
Date: Mon, 11 Sep 2017 08:13:05 -0700
Message-ID: <1505142785.15310.117.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1505111262-12620-1-git-send-email-liujian56@huawei.com>
         <1505141357.15310.115.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        edumazet@google.com, ycheng@google.com, hkchu@google.com,
        netdev@vger.kernel.org, weiyongjun1@huawei.com
To: liujian56@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35931 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750782AbdIKPNI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 11:13:08 -0400
Received: by mail-pg0-f66.google.com with SMTP id d8so4766804pgt.3
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 08:13:08 -0700 (PDT)
In-Reply-To: <1505141357.15310.115.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-11 at 07:49 -0700, Eric Dumazet wrote:
> On Mon, 2017-09-11 at 14:27 +0800, liujian56@huawei.com wrote:
> > From: liujian <liujian56@huawei.com>
> > 
> > After the tcp socket go to ESTABLISHED stat, change IP address (server
> > side),
> > then the tcp socket will go tcp_probe_timer process.
> > 
> > [root@localhost net]# netstat -toe
> > Active Internet connections (w/o servers)
> > Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode      Timer
> > tcp        0   1104 9.81.254:personal-agent 9.84.201.213:23597      ESTABLISHED root       12819      probe (4.36/0/7)
> > [root@localhost net]# cat /proc/net/tcp
> >   sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode                                                     
> >    3: B1FE5109:15B3 D5C95409:5C2D 01 00000495:00000000 04:0000005E 00000000     0        7 12819 2 ffff95cdcf45a000 20 4 1 10 -1 
> > 
> > In my test case, tcp_write_queue_head(sk) and tcp_send_head(sk) is  same
> > SKB.
> > And ((s32)(tcp_time_stamp(tp) - start_ts) >
> > jiffies_to_msecs(icsk->icsk_user_timeout))
> >  always is false.
> 
> Interesting.
> 
> >  Here use keepalive_time_elapsed(tp) to do the compare as
> > tcp_keepalive_timer do.
> 
> 
> But zero window probe and TCP_USER_TIMEOUT can be used without
> keepalives...
> 
> 
> A packetdrill test would help, I will write one.

So existing code seems to work :

# cat window-probe-without-data-user-timeout.pkt

    0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
   +0 bind(3, ..., ...) = 0
   +0 listen(3, 1) = 0

   +0 < S 0:0(0) win 0 <mss 1460,sackOK,nop,nop,nop,wscale 7>
   +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 8>

// Client advertises a zero receive window, so we can't send.
  +.1 < . 1:1(0) ack 1 win 0
   +0 accept(3, ..., ...) = 4

   +0 setsockopt(4, SOL_TCP, TCP_USER_TIMEOUT, [3000], 4) = 0
   +0 write(4, ..., 2920) = 2920

// Window probes are scheduled just like RTOs.
  +.3~+.31 > . 0:0(0) ack 1
  +.6~+.62 > . 0:0(0) ack 1
 +1.2~+1.24 > . 0:0(0) ack 1
 +2.4~+2.48 > . 0:0(0) ack 1

# ./packetdrill window-probe-without-data-user_timeout.pkt
08:10:39.306137 IP 192.0.2.1.58149 > 192.168.79.31.8080: Flags [S], seq 0, win 0, options [mss 1460,sackOK,nop,nop,nop,wscale 7], length 0
08:10:39.306166 IP 192.168.79.31.8080 > 192.0.2.1.58149: Flags [S.], seq 3982794529, ack 1, win 29200, options [mss 1460,nop,nop,sackOK,nop,wscale 8], length 0
08:10:39.406296 IP 192.0.2.1.58149 > 192.168.79.31.8080: Flags [.], ack 1, win 0, length 0
08:10:39.716004 IP 192.168.79.31.8080 > 192.0.2.1.58149: Flags [.], ack 1, win 115, length 0
08:10:40.327133 IP 192.168.79.31.8080 > 192.0.2.1.58149: Flags [.], ack 1, win 115, length 0
08:10:41.540243 IP 192.168.79.31.8080 > 192.0.2.1.58149: Flags [.], ack 1, win 115, length 0

You can see we got only 3 probes, not 4.
