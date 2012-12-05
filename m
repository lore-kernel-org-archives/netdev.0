From: Weiping Pan <wpan@redhat.com>
Subject: [RFC PATCH net-next 0/3 V4] net-tcp: TCP/IP stack bypass for loopback connections
Date: Wed,  5 Dec 2012 10:54:16 +0800
Message-ID: <cover.1354674151.git.wpan@redhat.com>
References: <CAEkNxbGTwGEBMCpSdib_paaxs0ekc52HWNo2Vai0nNSrZ1Zkng@mail.gmail.com>
Cc: brutus@google.com, Weiping Pan <wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17726 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661Ab2LECyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 21:54:24 -0500
In-Reply-To: <CAEkNxbGTwGEBMCpSdib_paaxs0ekc52HWNo2Vai0nNSrZ1Zkng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1 patch overview
[PATCH 1/3] is the original V3 patch from  Bruce(brutus@google.com),
I just rebase it on top of net-next
commit 03f52a0a5542(ip6mr: Add sizeof verification to MRT6_ASSERT and
MT6_PIM).
http://patchwork.ozlabs.org/patch/184523/

[PATCH 2/3] is to fix the bug in tcp_close() that triggered by [PATCH 1/3],
since for tcp friends data skb, it has no tcp header, and its transport_header
is NULL,
so it will panic if we deference tcp_hdr(skb) in tcp_close().

[PATCH 3/3] is to fix the problem raised by Eric(eric.dumazet@gmail.com)
http://www.spinics.net/lists/netdev/msg210750.html

The sock pointed by request_sock->friend may be freed since it does not have a
lock to protect it.
I just delete request_sock->friend since I think it is useless.

For sk_buff->friend, it has the same problem, and I use
"atomic_add(skb->truesize, &sk->sk_wmem_alloc)" to guarantee that the sock can
not be freed before the skb is freed.

Then for 3-way handshake with tcp friends enabled,
SYN->friend is NULL, SYN/ACK->friend is set in tcp_make_synack(),
and ACK->friend is set in tcp_send_ack().

For normal data and FIN skbs, their friend pointer is NULL.

2 performance analysis
In short, TCP_RR increases by 5 or 6 times, TCP_CRR keeps the same,
TCP_SENDFILE and TCP_MAERTS are not stable, sometimes they increase while
sometimes decrease, so we can regard them as no increase.
For TCP_STREAM, it depends on the message size, if it is bigger than 8192, it
increases else decreases.

Intel(R) Xeon(R) E5506, 2 sockets, 8 cores, 2.13GHz
Memory 4GB
--------------------------------------------------------------------------
TCP friends performance results start


BASE means normal tcp with friends DISABLED.
AF_UNIX means sockets for local interprocess communication, for reference.
FRIENDS means tcp with friends ENABLED.
I set -s 51882 -m 16384 -M 87380 for all the three kinds of sockets by default.
The first percentage number is FRIENDS/BASE.
The second percentage number is FRIENDS/AF_UNIX.
We set -i 10,2 -I 95,20 to stabilize the statistics.



      BASE    AF_UNIX    FRIENDS               TCP_STREAM
  21741.94   30653.90   17115.66   78%   55%



      BASE    AF_UNIX    FRIENDS               TCP_MAERTS
  17464.98          -   17134.63   98%    -%



      BASE    AF_UNIX    FRIENDS             TCP_SENDFILE
     25707          -      30828  119%    -%


TCP_SENDFILE can not work with -i 10,2 -I 95,20 (strange), so I use average.



        MS       BASE    AF_UNIX    FRIENDS            TCP_STREAM_MS
         1      15.64       5.90       5.12   32%   86%
         2      30.93       9.81      10.48   33%  106%
         4      58.22      19.70      21.29   36%  108%
         8     117.00      39.00      42.74   36%  109%
        16     231.08      84.59      83.90   36%   99%
        32     439.39     159.93     163.03   37%  101%
        64     879.13     323.31     322.78   36%   99%
       128    1617.55     632.50     646.34   39%  102%
       256    3091.72    1316.36    1206.93   39%   91%
       512    5077.18    2359.51    2342.00   46%   99%
      1024    7403.20    6302.20    3335.23   45%   52%
      2048   10194.40   13922.19    5751.23   56%   41%
      4096   13338.08   22566.45    9447.29   70%   41%
      8192   14467.93   28122.20   13758.43   95%   48%
     16384   22463.15   37522.42   26804.36  119%   71%
     32768   14743.58   30591.61   17040.15  115%   55%
     65536   24743.77   33855.93   40418.15  163%  119%
    131072   13925.14   31762.52   48292.60  346%  152%
    262144   16126.15   32912.89   25610.47  158%   77%
    524288   12080.51   35059.27   30608.31  253%   87%
   1048576   10539.06   28200.14   16953.69  160%   60%
MS means Message Size in bytes, that is -m -M for netperf



        RR       BASE    AF_UNIX    FRIENDS                TCP_RR_RR
         1   13064.17   95593.46   72982.11  558%   76%
         2   12000.95   95477.38   65203.37  543%   68%
         4   12560.45   90758.17   69983.71  557%   77%
         8   17991.62   96794.53   77293.14  429%   79%
        16   13015.98   89384.69   83125.91  638%   92%
        32   13863.00   89870.17   88986.21  641%   99%
        64   10632.42   88906.59   83055.69  781%   93%
       128   13673.29   85629.27   92984.32  680%  108%
       256   12965.59   88117.74   86155.43  664%   97%
       512   17158.55   90866.08   85498.26  498%   94%
      1024   16951.15   82982.26   82286.84  485%   99%
      2048   11814.75   76684.40   83154.99  703%  108%
      4096   10393.91   63204.65   68558.71  659%  108%
      8192    7757.81   50318.63   50270.39  647%   99%
     16384    8147.26   37392.42   38619.89  474%  103%
     32768    8846.85   24847.64   28412.23  321%  114%
     65536    4974.59   16717.47   17327.65  348%  103%
    131072    4148.19    9053.56    9402.89  226%  103%
    262144    3029.66    5575.51    6119.65  201%  109%
    524288     923.40    3271.52    3649.37  395%  111%
   1048576     385.47    1173.18    1017.43  263%   86%
RR means Request Response Message Size in bytes, that is -r req,resp for netperf



        RR       BASE    AF_UNIX    FRIENDS               TCP_CRR_RR
         1    3424.40          -    3608.92  105%    -%
         2    3355.94          -    3523.77  105%    -%
         4    3437.05          -    3538.48  102%    -%
         8    3465.41          -    3630.49  104%    -%
        16    3495.40          -    3516.93  100%    -%
        32    3425.78          -    3524.90  102%    -%
        64    3432.01          -    3628.25  105%    -%
       128    3434.69          -    3573.88  104%    -%
       256    3413.94          -    3616.94  105%    -%
       512    3457.32          -    3675.38  106%    -%
      1024    3476.01          -    3634.25  104%    -%
      2048    3484.38          -    3539.96  101%    -%
      4096    3304.86          -    3564.57  107%    -%
      8192    3420.40          -    3599.02  105%    -%
     16384    3358.47          -    3571.60  106%    -%
     32768    3299.75          -    3469.19  105%    -%
     65536    2635.22          -    3292.74  124%    -%
    131072     119.97          -    3008.15 2507%    -%
    262144     933.66          -    2189.83  234%    -%
    524288     175.82          -     607.32  345%    -%
   1048576      41.70          -     296.22  710%    -%
RR means Request Response Message Size in bytes, that is -r req,resp for netperf -H 127.0.0.1



TCP friends performance results end
--------------------------------------------------------------------------

In short, I think the performance of tcp friends is not overwhelming than
loopback.

Friends VS AF__UNIX
Their call path are almost the same, but AF_UNIX uses its own send/recv codes
with proper locks,
so AF_UNIX's performance is much better than Friends.

Friends VS normal tcp
Friends directly adds skb into peer's sk_receive_queue if it gets the lock.
So the sender and receiver have serious lock contention.

Normal tcp sends skb into sk_write_queue, then sends it in net_tx_action() and
receives it in net_rx_action(), then adds it into peer's sk_receive_queue.
So the sender just needs to lock the write queue while the receiver just needs
to lock the receive queue, so they have little lock contention.

3 TODO
1 try to confirm that the root cause of regression in some cases is the lock
contention.

2 find a better way to fix the regression.

Any hints ?

thanks

Weiping Pan (3):
  Bruce's orignal tcp friend V3
  fix panic in tcp_close()
  delete request_sock->friend

 Documentation/networking/ip-sysctl.txt |    8 +
 include/linux/skbuff.h                 |    2 +
 include/net/inet_connection_sock.h     |    4 +
 include/net/sock.h                     |   32 ++-
 include/net/tcp.h                      |   13 +-
 net/core/skbuff.c                      |    1 +
 net/core/sock.c                        |    1 +
 net/core/stream.c                      |   36 ++
 net/ipv4/inet_connection_sock.c        |   38 ++
 net/ipv4/sysctl_net_ipv4.c             |    7 +
 net/ipv4/tcp.c                         |  610 +++++++++++++++++++++++++++-----
 net/ipv4/tcp_input.c                   |   12 +-
 net/ipv4/tcp_ipv4.c                    |    5 +
 net/ipv4/tcp_minisocks.c               |   11 +-
 net/ipv4/tcp_output.c                  |   19 +-
 15 files changed, 707 insertions(+), 92 deletions(-)

-- 
1.7.4.4
