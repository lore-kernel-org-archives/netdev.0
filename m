From: liujian <liujian56@huawei.com>
Subject: Re: [PATCH] tcp: TCP_USER_TIMEOUT can not work in tcp_probe_timer()
Date: Wed, 13 Sep 2017 14:56:06 +0800
Message-ID: <b72fefba-e701-2ec8-0e7b-3bba6ed25205@huawei.com>
References: <1505111262-12620-1-git-send-email-liujian56@huawei.com>
 <1505141357.15310.115.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505142785.15310.117.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505143348.15310.118.camel@edumazet-glaptop3.roam.corp.google.com>
 <e7e09201-40c2-933a-1e8e-a31eddcc75ab@huawei.com>
 <1505228700.15310.138.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505230686.15310.141.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from szxga05-in.huawei.com ([45.249.212.191]:6042 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbdIMG4y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 02:56:54 -0400
In-Reply-To: <1505230686.15310.141.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



在 2017/9/12 23:38, Eric Dumazet 写道:
> On Tue, 2017-09-12 at 08:05 -0700, Eric Dumazet wrote:
>> On Tue, 2017-09-12 at 14:08 +0800, liujian wrote:
>>> Hi,
>>>
>>> In the scenario, tcp server side IP changed, and at that memont,
>>> userspace application still send data continuously;
>>> tcp_send_head(sk)'s timestamp always be refreshed.
>>>
>>> Here is the packetdrill script:
>>>
>>>    0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
>>>    +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
>>>    +0 bind(3, ..., ...) = 0
>>>    +0 listen(3, 1) = 0
>>>
>>>    +0 < S 0:0(0) win 0 <mss 1460,sackOK,nop,nop,nop,wscale 7>
>>>    +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 7>
>>>
>>>   +.1 < . 1:1(0) ack 1 win 65530
>>>    +0 accept(3, ..., ...) = 4
>>>
>>>    +0 setsockopt(4, SOL_TCP, TCP_USER_TIMEOUT, [3000], 4) = 0
>>>    +0 write(4, ..., 24) = 24
>>>    +0 > P. 1:25(24) ack 1 win 229
>>>    +.1 < . 1:1(0) ack 25 win 65530
>>>
>>> //change the ipaddress
>>>    +1 `ifconfig tun0 192.168.0.10/16`
>>>
>>>    +1 write(4, ..., 24) = 24
>>>    +1 write(4, ..., 24) = 24
>>>    +1 write(4, ..., 24) = 24
>>>    +1 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>    +3 write(4, ..., 24) = 24
>>>
>>>    +0 `ifconfig tun0 192.168.0.1/16`
>>>    +0 < . 1:1(0) ack 1 win 1000
>>>    +0 write(4, ..., 24) = -1
>>>
>>>
>>
>> This has nothing to do with the code patch you have changed.
>>
>> How have you tested your patch exactly ?
>>
I tested the patch, it can work.

[root@localhost ~]# time ./gtests/net/packetdrill/packetdrill test.pkt
test.pkt:24: runtime error in write call: Expected result 24 but got -1 with errno 110 (Connection timed out)

real	0m5.356s
user	0m0.026s
sys	0m0.104s

[root@localhost ~]# ss -toenmi src :8080
State       Recv-Q Send-Q               Local Address:Port                              Peer Address:Port
ESTAB       0      48                     192.168.0.1:8080                                 192.0.2.1:39559               timer:(persist,186ms,2) ino:37178 sk:6 <->
	 skmem:(r0,rb369280,t0,tb87040,f1792,w2304,o0,bl0) sack cubic wscale:7,7 rto:301 backoff:2 rtt:100.253/37.643 mss:1460 cwnd:10 bytes_acked:24 segs_out:5 segs_in:3 send 1.2Mbps lastsnd:976 lastrcv:4082 lastack:3982 pacing_rate 2.3Mbps rcv_space:29200


if change the TCP_USER_TIMEOUT to 30s, test result as below:

[root@localhost ~]#   time ./gtests/net/packetdrill/packetdrill test.pkt
test.pkt:37: runtime error in write call: Expected result 24 but got -1 with errno 110 (Connection timed out)

real	0m44.362s
user	0m0.018s
sys	0m0.110s

ESTAB       0      360                         192.168.0.1:8080                                      192.0.2.1:47577     timer:(persist,516ms,6) ino:18806 sk:5 <->
	 skmem:(r0,rb369280,t0,tb87040,f1792,w2304,o0,bl0) sack cubic wscale:7,7 rto:301 backoff:6 rtt:100.228/37.623 mss:10 bytes_acked:24 segs_out:22 segs_in:3 send 1.2Mbps lastsnd:2343 lastrcv:40450 lastack:40350 pacing_rate 2.3Mbps rcv_sp

> 
> lpaa23:~# ss -toenmi src :8080
> State      Recv-Q Send-Q Local Address:Port               Peer
> Address:Port              
> ESTAB      0      144    192.168.134.161:8080
> 192.0.2.1:51165               timer:(persist,8.262ms,5) ino:1
> 82083 sk:3 <->
> 	 skmem:(r0,rb359040,t0,tb46080,f1792,w2304,o0,bl0,d0) sack cubic
> wscale:7,8 rto:301 backoff:5 rtt:100.127/37.576 
> mss:1460 rcvmss:536 advmss:1460 cwnd:10 bytes_acked:24 segs_out:12
> segs_in:3 data_segs_out:12 send 1.2Mbps lastsnd:1370 l
> astrcv:13348 lastack:13248 pacing_rate 2.3Mbps delivery_rate 116.7Kbps
> app_limited busy:11346ms rcv_space:29200 notsent:1
> 44 minrtt:100.043userspace application still send data continuously
> 
> This is the typical RTO timer, not zero window probe.
> 
with the script, it is not zero window; but the code enter tcp_probe_timer.
->tcp_sendmsg
-->tcp_push
---->__tcp_push_pending_frames
------>tcp_write_xmit
-------->tcp_transmit_skb (at this function, tcp_send_head(sk)'s timestamp was be refreshed)
---------->ip_queue_xmit (can not find route, return -EHOSTUNREACH)
-------->tcp_transmit_skb (send fail, do not advance send head)
------->tcp_check_probe_timer (reset ICSK_TIME_PROBE0 timer)

Here userspace application still send data continuously,
it triggered ICSK_TIME_PROBE0 timer and tcp_send_head(sk)'s timestamp refresh.
