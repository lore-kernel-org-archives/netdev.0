From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Tue, 24 Jan 2017 09:26:15 -0800
Message-ID: <CAK6E8=eR5N-AV9sDJGwB-VKTojqSBRnPF6e7cK4jeavTzP97Hw@mail.gmail.com>
References: <20170123185922.48046-1-tracywwnj@gmail.com> <20170123185922.48046-4-tracywwnj@gmail.com>
 <20170124073043.GA21590@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Wang <tracywwnj@gmail.com>, netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:36862 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdAXR05 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 12:26:57 -0500
Received: by mail-it0-f41.google.com with SMTP id c7so90518392itd.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 09:26:56 -0800 (PST)
In-Reply-To: <20170124073043.GA21590@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 11:30 PM, Willy Tarreau <w@1wt.eu> wrote:
>
> On Mon, Jan 23, 2017 at 10:59:22AM -0800, Wei Wang wrote:
> > This patch adds a new socket option, TCP_FASTOPEN_CONNECT, as an
> > alternative way to perform Fast Open on the active side (client).
>
> Wei, I think that nothing prevents from reusin the original TCP_FASTOPEN
> sockopt instead of adding a new one. The original one does this :
>
>         case TCP_FASTOPEN:
>                 if (val >= 0 && ((1 << sk->sk_state) & (TCPF_CLOSE |
>                     TCPF_LISTEN))) {
>                         tcp_fastopen_init_key_once(true);
>
>                         fastopen_queue_tune(sk, val);
>                 } else {
>                         err = -EINVAL;
>                 }
>                 break;
>
> and your new option does this :
>
>         case TCP_FASTOPEN_CONNECT:
>                 if (val > 1 || val < 0) {
>                         err = -EINVAL;
>                 } else if (sysctl_tcp_fastopen & TFO_CLIENT_ENABLE) {
>                         if (sk->sk_state == TCP_CLOSE)
>                                 tp->fastopen_connect = val;
>                         else
>                                 err = -EINVAL;
>                 } else {
>                         err = -EOPNOTSUPP;
>                 }
>                 break;
>
> Now if we compare :
>   - the value ranges are the same (0,1)
>   - tcp_fastopen_init_key_once() only performs an initialization once
>   - fastopen_queue_tune() only sets sk->max_qlen based on the backlog,
>     this has no effect on an outgoing connection ;
>   - tp->fastopen_connect can be applied to a listening socket without
>     side effect.
>
> Thus I think we can merge them this way :
>
>         case TCP_FASTOPEN:
>                 if (val >= 0) {
>                         if ((sysctl_tcp_fastopen & TFO_CLIENT_ENABLE) &&
>                             (sk->sk_state == TCP_CLOSE)
>                                 tp->fastopen_connect = val;
>
>                         if ((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_LISTEN))) {
>                                 tcp_fastopen_init_key_once(true);
>                                 fastopen_queue_tune(sk, val);
>                         }
>                 } else {
>                         err = -EINVAL;
>                 }
>                 break;
>
> And for the userland, the API is even simpler because we can use the
> same TCP_FASTOPEN sockopt regardless of the socket direction. Also,
> I don't know if TCP_FASTOPEN is supported on simultaneous connect,
> but at least if it works it would be easier to understand this way.
It supports partially (i.e. send SYN data but not accept simul.
SYN-data crossing).
Here is the snippet of packetdrill test we use internally:

`sysctl net.ipv4.tcp_timestamps=0`

// Cache warmup: send a Fast Open cookie request
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK) = 0
0.000 sendto(3, ..., 0, MSG_FASTOPEN, ..., ...) = -1 EINPROGRESS
(Operation is now in progress)
0.000 > S 0:0(0) <mss 1460,nop,nop,sackOK,nop,wscale 8,FO,nop,nop>
0.010 < S. 123:123(0) ack 1 win 14600 <mss
1460,nop,nop,sackOK,nop,wscale 6,FO abcd1234,nop,nop>
0.010 > . 1:1(0) ack 1
0.020 close(3) = 0
0.020 > F. 1:1(0) ack 1
0.030 < F. 1:1(0) ack 2 win 92
0.030 > .  2:2(0) ack 2


//
// Test: simulatenous fast open
//
+.010 socket(..., SOCK_STREAM, IPPROTO_TCP) = 4
+.000 fcntl(4, F_SETFL, O_RDWR|O_NONBLOCK) = 0
+.000 sendto(4, ..., 1000, MSG_FASTOPEN, ..., ...) = 1000
+.000 > S 0:1000(1000) <mss 1460,nop,nop,sackOK,nop,wscale 8,FO
abcd1234,nop,nop>
// Simul. SYN-data crossing: we don't support that yet so ack only remote ISN
+.005 < S 1234:1734(500) win 14600 <mss 1040,nop,nop,sackOK,nop,wscale
6,FO 87654321,nop,nop>
+.000 > S. 0:0(0) ack 1235 <mss 1460,nop,nop,sackOK,nop,wscale 8>

// SYN data is never retried.
+.045 < S. 1234:1234(0) ack 1001 win 14600 <mss
940,nop,nop,sackOK,nop,wscale 6,FO 12345678,nop,nop>
+.000 > . 1001:1001(0) ack 1
// The other end retries
+.100 < P. 1:501(500) ack 1000 win 257
+.000 > . 1001:1001(0) ack 501
+.000 read(4, ..., 4096) = 500
+.000 close(4) = 0
+.000 > F. 1001:1001(0) ack 501
+.050 < F. 501:501(0) ack 1002 win 257
+.000 > . 1002:1002(0) ack 502


>
> Do you think there's a compelling reason for adding a new option or
> are you interested in a small patch to perform the change above ?
I like the proposal especially other stack also uses TCP_FASTOPEN
https://msdn.microsoft.com/en-us/library/windows/desktop/ms738596(v=vs.85).aspx


>
> Regards,
> Willy
