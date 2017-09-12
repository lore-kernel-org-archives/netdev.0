From: liujian <liujian56@huawei.com>
Subject: Re: [PATCH] tcp: TCP_USER_TIMEOUT can not work in tcp_probe_timer()
Date: Tue, 12 Sep 2017 14:08:48 +0800
Message-ID: <e7e09201-40c2-933a-1e8e-a31eddcc75ab@huawei.com>
References: <1505111262-12620-1-git-send-email-liujian56@huawei.com>
 <1505141357.15310.115.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505142785.15310.117.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505143348.15310.118.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
        <yoshfuji@linux-ipv6.org>, <edumazet@google.com>,
        <ycheng@google.com>, <hkchu@google.com>, <netdev@vger.kernel.org>,
        <weiyongjun1@huawei.com>,
        wangkefeng 00227729 <wangkefeng.wang@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:6451 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750911AbdILGJQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 02:09:16 -0400
In-Reply-To: <1505143348.15310.118.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In the scenario, tcp server side IP changed, and at that memont,
userspace application still send data continuously;
tcp_send_head(sk)'s timestamp always be refreshed.

Here is the packetdrill script:

   0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
   +0 bind(3, ..., ...) = 0
   +0 listen(3, 1) = 0

   +0 < S 0:0(0) win 0 <mss 1460,sackOK,nop,nop,nop,wscale 7>
   +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 7>

  +.1 < . 1:1(0) ack 1 win 65530
   +0 accept(3, ..., ...) = 4

   +0 setsockopt(4, SOL_TCP, TCP_USER_TIMEOUT, [3000], 4) = 0
   +0 write(4, ..., 24) = 24
   +0 > P. 1:25(24) ack 1 win 229
   +.1 < . 1:1(0) ack 25 win 65530

//change the ipaddress
   +1 `ifconfig tun0 192.168.0.10/16`

   +1 write(4, ..., 24) = 24
   +1 write(4, ..., 24) = 24
   +1 write(4, ..., 24) = 24
   +1 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24
   +3 write(4, ..., 24) = 24

   +0 `ifconfig tun0 192.168.0.1/16`
   +0 < . 1:1(0) ack 1 win 1000
   +0 write(4, ..., 24) = -1


[root@localhost ~]# time ./gtests/net/packetdrill/packetdrill test.pkt
test.pkt:50: runtime error in write call: Expected result -1 but got 24 with errno 2 (No such file or directory)

real	1m11.364s
user	0m0.028s
sys	0m0.106s

[root@localhost ~]# netstat -toen
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode      Timer
tcp        0    504 192.168.0.1:8080        192.0.2.1:33993         ESTABLISHED 0          45453      probe (22.38/0/7)

since the script didn't wait for enough time, here only got 7 probes.

在 2017/9/11 23:22, Eric Dumazet 写道:
> On Mon, 2017-09-11 at 08:13 -0700, Eric Dumazet wrote:
> 
>> You can see we got only 3 probes, not 4.
> 
> Here is complete packetdrill test showing that code behaves as expected.
> 
>     0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
>    +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
>    +0 bind(3, ..., ...) = 0
>    +0 listen(3, 1) = 0
> 
>    +0 < S 0:0(0) win 0 <mss 1460,sackOK,nop,nop,nop,wscale 7>
>    +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 8>
> 
> // Client advertises a zero receive window, so we can't send.
>   +.1 < . 1:1(0) ack 1 win 0
>    +0 accept(3, ..., ...) = 4
> 
>    +0 setsockopt(4, SOL_TCP, TCP_USER_TIMEOUT, [3000], 4) = 0
>    +0 write(4, ..., 2920) = 2920
> 
> // Window probes are scheduled just like RTOs.
>   +.3~+.31 > . 0:0(0) ack 1
>   +.6~+.62 > . 0:0(0) ack 1
>  +1.2~+1.24 > . 0:0(0) ack 1
> 
> // Peer opens its window too late !
>    +3 < . 1:1(0) ack 1 win 1000
>    +0 > R 1:1(0)
> 
> 
> 
> .
> 
