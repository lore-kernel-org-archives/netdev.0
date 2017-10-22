From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Sat, 21 Oct 2017 22:21:30 -0700
Message-ID: <1508649690.30291.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171022033808.12641-1-den@klaipeden.com>
         <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508645419.9317.7.camel@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:56428 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751047AbdJVFVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 01:21:32 -0400
Received: by mail-pg0-f66.google.com with SMTP id m18so9418723pgd.13
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2017 22:21:32 -0700 (PDT)
In-Reply-To: <1508645419.9317.7.camel@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-10-22 at 13:10 +0900, Koichiro Den wrote:
> On Sat, 2017-10-21 at 20:52 -0700, Eric Dumazet wrote:
> > On Sun, 2017-10-22 at 12:38 +0900, Koichiro Den wrote:
> > > When retransmission on TSQ handler was introduced in the commit
> > > f9616c35a0d7 ("tcp: implement TSQ for retransmits"), the retransmitted
> > > skbs' timestamps were updated on the actual transmission. In the later
> > > commit 385e20706fac ("tcp: use tp->tcp_mstamp in output path"), it stops
> > > being done so. In the commit, the comment says "We try to refresh
> > > tp->tcp_mstamp only when necessary", and at present tcp_tsq_handler and
> > > tcp_v4_mtu_reduced applies to this. About the latter, it's okay since
> > > it's rare enough.
> > > 
> > > About the former, even though possible retransmissions on the tasklet
> > > comes just after the destructor run in NET_RX softirq handling, the time
> > > between them could be nonnegligibly large to the extent that
> > > tcp_rack_advance or rto rearming be affected if other (remaining) RX,
> > > BLOCK and (preceding) TASKLET sofirq handlings are unexpectedly heavy.
> > > 
> > > So in the same way as tcp_write_timer_handler does, doing tcp_mstamp_refresh
> > > ensures the accuracy of algorithms relying on it.
> > > 
> > > Signed-off-by: Koichiro Den <den@klaipeden.com>
> > > ---
> > >  net/ipv4/tcp_output.c | 4 +++-
> > >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > Very nice catch, thanks a lot Koichiro.
> > 
> > This IMO would target net tree, since it is a bug fix.
> > 
> > Fixes: 385e20706fac ("tcp: use tp->tcp_mstamp in output path")
> Ok I will submit it to net tree. Thanks!
> > 
> > Thanks !
> > 
> > We should have caught that in our regression packetdrill tests...
> In its "remote" mode testing not relying on tun xmit, I agree it could be
> caught. If it's better to write, test and attach the script, please let me know.

Packetdrill in the normal (local) mode will do it.

Push fq packet scheduler on tun0, and packets will be held long enough
in FQ that TSQ will be effective.

Adding TCP TS support on folloginw packetdrill test should demonstrate
the issue and if your patch cures it.

// Test if TSQ applies to retransmits.

`tc qdisc replace dev tun0 root fq quantum 1514 initial_quantum 1514 flow_limit 5
sysctl -e -q net.ipv4.tcp_min_tso_segs=1`

    0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
   +0 bind(3, ..., ...) = 0
   +0 listen(3, 1) = 0

   +0 < S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
   +0 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 8>
 +.01 < . 1:1(0) ack 1 win 1500
   +0 accept(3, ..., ...) = 4

   +0 %{ assert tcpi_snd_cwnd == 10, tcpi_snd_cwnd }%
// send one frame per ms
   +0 setsockopt(4, SOL_SOCKET, SO_MAX_PACING_RATE, [1514000], 4) = 0
   +0 setsockopt(4, SOL_SOCKET, SO_SNDBUF, [1000000], 4) = 0

   +0 write(4, ..., 120000) = 120000

   +0 > .  1:1461(1460) ack 1
+.001 > .  1461:2921(1460) ack 1
+.001 > .  2921:4381(1460) ack 1
+.001 > .  4381:5841(1460) ack 1
+.001 > .  5841:7301(1460) ack 1
+.001 > .  7301:8761(1460) ack 1
+.001 > .  8761:10221(1460) ack 1
+.001 > .  10221:11681(1460) ack 1
+.001 > .  11681:13141(1460) ack 1
+.001 > .  13141:14601(1460) ack 1
 +.01 < . 1:1(0) ack 14601 win 1500

+.001 > .  14601:16061(1460) ack 1
+.001 > .  16061:17521(1460) ack 1
+.001 > .  17521:18981(1460) ack 1
+.001 > .  18981:20441(1460) ack 1
+.001 > .  20441:21901(1460) ack 1
+.001 > .  21901:23361(1460) ack 1
+.001 > .  23361:24821(1460) ack 1
+.001 > .  24821:26281(1460) ack 1
+.001 > .  26281:27741(1460) ack 1
+.001 > .  27741:29201(1460) ack 1
+.001 > .  29201:30661(1460) ack 1
+.001 > .  30661:32121(1460) ack 1
+.001 > .  32121:33581(1460) ack 1
+.001 > .  33581:35041(1460) ack 1
+.001 > .  35041:36501(1460) ack 1
+.001 > .  36501:37961(1460) ack 1
+.001 > .  37961:39421(1460) ack 1
+.001 > .  39421:40881(1460) ack 1
+.001 > .  40881:42341(1460) ack 1
+.001 > .  42341:43801(1460) ack 1
 +.01 < .  1:1(0) ack 43801 win 1500

+.001 > .  43801:45261(1460) ack 1
+.001 > .  45261:46721(1460) ack 1
+.001 > .  46721:48181(1460) ack 1
+.001 > .  48181:49641(1460) ack 1
+.001 > .  49641:51101(1460) ack 1
+.001 > .  51101:52561(1460) ack 1
+.001 > .  52561:54021(1460) ack 1
+.001 > .  54021:55481(1460) ack 1
+.001 > .  55481:56941(1460) ack 1
+.001 > .  56941:58401(1460) ack 1
+.001 > .  58401:59861(1460) ack 1
+.001 > .  59861:61321(1460) ack 1
+.001 > .  61321:62781(1460) ack 1
+.001 > .  62781:64241(1460) ack 1
+.001 > .  64241:65701(1460) ack 1
+.001 > .  65701:67161(1460) ack 1
+.001 > .  67161:68621(1460) ack 1
+.001 > .  68621:70081(1460) ack 1
+.001 > .  70081:71541(1460) ack 1
+.001 > .  71541:73001(1460) ack 1
+.001 > .  73001:74461(1460) ack 1
+.001 > .  74461:75921(1460) ack 1
+.001 > .  75921:77381(1460) ack 1
+.001 > .  77381:78841(1460) ack 1
+.001 > .  78841:80301(1460) ack 1
+.001 > .  80301:81761(1460) ack 1
+.001 > .  81761:83221(1460) ack 1
+.001 > .  83221:84681(1460) ack 1
+.001 > .  84681:86141(1460) ack 1
+.001 > .  86141:87601(1460) ack 1
+.001 > .  87601:89061(1460) ack 1
+.001 > .  89061:90521(1460) ack 1
+.001 > .  90521:91981(1460) ack 1
+.001 > .  91981:93441(1460) ack 1
+.001 > .  93441:94901(1460) ack 1
+.001 > .  94901:96361(1460) ack 1
+.001 > .  96361:97821(1460) ack 1
+.001 > .  97821:99281(1460) ack 1
+.001 > .  99281:100741(1460) ack 1
+.001 > .  100741:102201(1460) ack 1

// Ok lets trigger a bunch of rtx !
+.001 < .  1:1(0) ack 43801 win 1500 <nop,nop, sack 78841:102201>
+.001 > .  43801:45261(1460) ack 1
+.001 > .  45261:46721(1460) ack 1
+.001 > .  46721:48181(1460) ack 1
+.001 > .  48181:49641(1460) ack 1
+.001 > .  49641:51101(1460) ack 1
+.001 > .  51101:52561(1460) ack 1
+.001 > .  52561:54021(1460) ack 1
+.001 > .  54021:55481(1460) ack 1
+.001 > .  55481:56941(1460) ack 1
+.001 > .  56941:58401(1460) ack 1
+.001 > .  58401:59861(1460) ack 1
+.001 > .  59861:61321(1460) ack 1
+.001 > .  61321:62781(1460) ack 1
+.001 > .  62781:64241(1460) ack 1
+.001 > .  64241:65701(1460) ack 1
+.001 > .  65701:67161(1460) ack 1
