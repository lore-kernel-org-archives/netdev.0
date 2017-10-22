From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Sun, 22 Oct 2017 09:49:04 -0700
Message-ID: <1508690944.30291.48.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171022033808.12641-1-den@klaipeden.com>
         <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508645419.9317.7.camel@klaipeden.com>
         <1508649690.30291.44.camel@edumazet-glaptop3.roam.corp.google.com>
         <1508677159.3011.1.camel@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ncardwell@google.com
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:45300 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751376AbdJVQtH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 12:49:07 -0400
Received: by mail-pg0-f45.google.com with SMTP id b192so10039567pga.2
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 09:49:07 -0700 (PDT)
In-Reply-To: <1508677159.3011.1.camel@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-10-22 at 21:59 +0900, Koichiro Den wrote:
> On Sat, 2017-10-21 at 22:21 -0700, Eric Dumazet wrote:
> > On Sun, 2017-10-22 at 13:10 +0900, Koichiro Den wrote:
> > > On Sat, 2017-10-21 at 20:52 -0700, Eric Dumazet wrote:
> > > > On Sun, 2017-10-22 at 12:38 +0900, Koichiro Den wrote:
> > > > > When retransmission on TSQ handler was introduced in the commit
> > > > > f9616c35a0d7 ("tcp: implement TSQ for retransmits"), the retransmitted
> > > > > skbs' timestamps were updated on the actual transmission. In the later
> > > > > commit 385e20706fac ("tcp: use tp->tcp_mstamp in output path"), it stops
> > > > > being done so. In the commit, the comment says "We try to refresh
> > > > > tp->tcp_mstamp only when necessary", and at present tcp_tsq_handler and
> > > > > tcp_v4_mtu_reduced applies to this. About the latter, it's okay since
> > > > > it's rare enough.
> > > > > 
> > > > > About the former, even though possible retransmissions on the tasklet
> > > > > comes just after the destructor run in NET_RX softirq handling, the time
> > > > > between them could be nonnegligibly large to the extent that
> > > > > tcp_rack_advance or rto rearming be affected if other (remaining) RX,
> > > > > BLOCK and (preceding) TASKLET sofirq handlings are unexpectedly heavy.
> > > > > 
> > > > > So in the same way as tcp_write_timer_handler does, doing
> > > > > tcp_mstamp_refresh
> > > > > ensures the accuracy of algorithms relying on it.
> > > > > 
> > > > > Signed-off-by: Koichiro Den <den@klaipeden.com>
> > > > > ---
> > > > >  net/ipv4/tcp_output.c | 4 +++-
> > > > >  1 file changed, 3 insertions(+), 1 deletion(-)
> > > > 
> > > > Very nice catch, thanks a lot Koichiro.
> > > > 
> > > > This IMO would target net tree, since it is a bug fix.
> > > > 
> > > > Fixes: 385e20706fac ("tcp: use tp->tcp_mstamp in output path")
> > > 
> > > Ok I will submit it to net tree. Thanks!
> > > > 
> > > > Thanks !
> > > > 
> > > > We should have caught that in our regression packetdrill tests...
> > > 
> > > In its "remote" mode testing not relying on tun xmit, I agree it could be
> > > caught. If it's better to write, test and attach the script, please let me
> > > know.
> > 
> > Packetdrill in the normal (local) mode will do it.
> > 
> > Push fq packet scheduler on tun0, and packets will be held long enough
> > in FQ that TSQ will be effective.
> Ah yes, I missed it, thank you.
> > 
> > Adding TCP TS support on folloginw packetdrill test should demonstrate
> > the issue and if your patch cures it.
> Thanks for the demo script. I thought making the issue described in my commit
> message obvious with a packetdrill script on its own was a bit difficult without
> heavy load on test bed (or intentionally injecting time-consuming code).
> 
> IIUC, whether or not TCP TS val reflects a bit later timestamp than its last
> reception, which triggered TSQ handler, sounds much better. Though it is still
> like "With some probability, one millisecond delay is reflected on TS val, so
> the packetdrill test passes. Otherwise we can say that the test fails."
> Am I correct? To be honest I am still wondering what is the best way to make the
> issue obvious.

Here is the test I cooked.

Note that it actually passes just fine, do I am wondering if your patch
is needed after all..


# cat fq-pacing-tsq-rtx-ts.pkt
// Test if TSQ applies to retransmits.

`tc qdisc replace dev tun0 root fq quantum 1514 initial_quantum 1514 flow_limit 5
sysctl -e -q net.ipv4.tcp_min_tso_segs=1`

    0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
   +0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
   +0 bind(3, ..., ...) = 0
   +0 listen(3, 1) = 0

   +0 < S 0:0(0) win 65535 <mss 1460,sackOK,TS val 190 ecr 0>
   +0 > S. 0:0(0) ack 1 <mss 1460,sackOK,TS val 5000 ecr 190>
 +.01 < . 1:1(0) ack 1 win 65535 <nop,nop,TS val 200 ecr 5000>
   +0 accept(3, ..., ...) = 4

   +0 %{ assert tcpi_snd_cwnd == 10, tcpi_snd_cwnd }%
// send one frame per ms
   +0 setsockopt(4, SOL_SOCKET, SO_MAX_PACING_RATE, [1514000], 4) = 0
   +0 setsockopt(4, SOL_SOCKET, SO_SNDBUF, [1000000], 4) = 0

   +0 write(4, ..., 120000) = 120000

+.000 > . 1:1449(1448) ack 1 <nop, nop, TS val 400 ecr 200>
+.001 > . 1449:2897(1448) ack 1 <nop, nop, TS val 401 ecr 200>
+.001 > . 2897:4345(1448) ack 1 <nop, nop, TS val 402 ecr 200>
+.001 > . 4345:5793(1448) ack 1 <nop, nop, TS val 403 ecr 200>
+.001 > . 5793:7241(1448) ack 1 <nop, nop, TS val 404 ecr 200>
+.001 > . 7241:8689(1448) ack 1 <nop, nop, TS val 405 ecr 200>
+.001 > . 8689:10137(1448) ack 1 <nop, nop, TS val 406 ecr 200>
+.001 > . 10137:11585(1448) ack 1 <nop, nop, TS val 407 ecr 200>
+.001 > . 11585:13033(1448) ack 1 <nop, nop, TS val 408 ecr 200>
+.001 > . 13033:14481(1448) ack 1 <nop, nop, TS val 409 ecr 200>
 +.01 < . 1:1(0) ack 14481 win 65535 <nop, nop, TS val 220 ecr 409>

+.000 > . 14481:15929(1448) ack 1 <nop, nop, TS val 420 ecr 220>
+.001 > . 15929:17377(1448) ack 1 <nop, nop, TS val 421 ecr 220>
+.001 > . 17377:18825(1448) ack 1 <nop, nop, TS val 422 ecr 220>
+.001 > . 18825:20273(1448) ack 1 <nop, nop, TS val 423 ecr 220>
+.001 > . 20273:21721(1448) ack 1 <nop, nop, TS val 424 ecr 220>
+.001 > . 21721:23169(1448) ack 1 <nop, nop, TS val 425 ecr 220>
+.001 > . 23169:24617(1448) ack 1 <nop, nop, TS val 426 ecr 220>
+.001 > . 24617:26065(1448) ack 1 <nop, nop, TS val 427 ecr 220>
+.001 > . 26065:27513(1448) ack 1 <nop, nop, TS val 428 ecr 220>
+.001 > . 27513:28961(1448) ack 1 <nop, nop, TS val 429 ecr 220>
+.001 > . 28961:30409(1448) ack 1 <nop, nop, TS val 430 ecr 220>
+.001 > . 30409:31857(1448) ack 1 <nop, nop, TS val 431 ecr 220>
+.001 > . 31857:33305(1448) ack 1 <nop, nop, TS val 432 ecr 220>
+.001 > . 33305:34753(1448) ack 1 <nop, nop, TS val 433 ecr 220>
+.001 > . 34753:36201(1448) ack 1 <nop, nop, TS val 434 ecr 220>
+.001 > . 36201:37649(1448) ack 1 <nop, nop, TS val 435 ecr 220>
+.001 > P. 37649:39097(1448) ack 1 <nop, nop, TS val 436 ecr 220>
+.001 > . 39097:40545(1448) ack 1 <nop, nop, TS val 437 ecr 220>
+.001 > . 40545:41993(1448) ack 1 <nop, nop, TS val 438 ecr 220>
+.001 > . 41993:43441(1448) ack 1 <nop, nop, TS val 439 ecr 220>
 +.01 < .  1:1(0) ack 43441 win 65535 <nop, nop, TS val 240 ecr 439>

+.000 > . 43441:44889(1448) ack 1 <nop, nop, TS val 450 ecr 240>
+.001 > . 44889:46337(1448) ack 1 <nop, nop, TS val 451 ecr 240>
+.001 > . 46337:47785(1448) ack 1 <nop, nop, TS val 452 ecr 240>
+.001 > . 47785:49233(1448) ack 1 <nop, nop, TS val 453 ecr 240>
+.001 > . 49233:50681(1448) ack 1 <nop, nop, TS val 454 ecr 240>
+.001 > . 50681:52129(1448) ack 1 <nop, nop, TS val 455 ecr 240>
+.001 > . 52129:53577(1448) ack 1 <nop, nop, TS val 456 ecr 240>
+.001 > . 53577:55025(1448) ack 1 <nop, nop, TS val 457 ecr 240>
+.001 > . 55025:56473(1448) ack 1 <nop, nop, TS val 458 ecr 240>
+.001 > . 56473:57921(1448) ack 1 <nop, nop, TS val 459 ecr 240>
+.001 > . 57921:59369(1448) ack 1 <nop, nop, TS val 460 ecr 240>
+.001 > . 59369:60817(1448) ack 1 <nop, nop, TS val 461 ecr 240>
+.001 > . 60817:62265(1448) ack 1 <nop, nop, TS val 462 ecr 240>
+.001 > . 62265:63713(1448) ack 1 <nop, nop, TS val 463 ecr 240>
+.001 > . 63713:65161(1448) ack 1 <nop, nop, TS val 464 ecr 240>
+.001 > . 65161:66609(1448) ack 1 <nop, nop, TS val 465 ecr 240>
+.001 > . 66609:68057(1448) ack 1 <nop, nop, TS val 466 ecr 240>
+.001 > . 68057:69505(1448) ack 1 <nop, nop, TS val 467 ecr 240>
+.001 > P. 69505:70953(1448) ack 1 <nop, nop, TS val 468 ecr 240>
+.001 > . 70953:72401(1448) ack 1 <nop, nop, TS val 469 ecr 240>
+.001 > . 72401:73849(1448) ack 1 <nop, nop, TS val 470 ecr 240>
+.001 > . 73849:75297(1448) ack 1 <nop, nop, TS val 471 ecr 240>
+.001 > . 75297:76745(1448) ack 1 <nop, nop, TS val 472 ecr 240>
+.001 > . 76745:78193(1448) ack 1 <nop, nop, TS val 473 ecr 240>
+.001 > . 78193:79641(1448) ack 1 <nop, nop, TS val 474 ecr 240>
+.001 > . 79641:81089(1448) ack 1 <nop, nop, TS val 475 ecr 240>
+.001 > . 81089:82537(1448) ack 1 <nop, nop, TS val 476 ecr 240>
+.001 > . 82537:83985(1448) ack 1 <nop, nop, TS val 477 ecr 240>
+.001 > . 83985:85433(1448) ack 1 <nop, nop, TS val 478 ecr 240>
+.001 > . 85433:86881(1448) ack 1 <nop, nop, TS val 479 ecr 240>
+.001 > . 86881:88329(1448) ack 1 <nop, nop, TS val 480 ecr 240>
+.001 > . 88329:89777(1448) ack 1 <nop, nop, TS val 481 ecr 240>
+.001 > . 89777:91225(1448) ack 1 <nop, nop, TS val 482 ecr 240>
+.001 > . 91225:92673(1448) ack 1 <nop, nop, TS val 483 ecr 240>
+.001 > . 92673:94121(1448) ack 1 <nop, nop, TS val 484 ecr 240>
+.001 > . 94121:95569(1448) ack 1 <nop, nop, TS val 485 ecr 240>
+.001 > . 95569:97017(1448) ack 1 <nop, nop, TS val 486 ecr 240>
+.001 > . 97017:98465(1448) ack 1 <nop, nop, TS val 487 ecr 240>
+.001 > . 98465:99913(1448) ack 1 <nop, nop, TS val 488 ecr 240>
+.001 > . 99913:101361(1448) ack 1 <nop, nop, TS val 489 ecr 240>

// Ok lets trigger a bunch of rtx !
+.001 < .  1:1(0) ack 43441 win 65535 <nop,nop, TS val 280 ecr 489, nop, nop, sack 78841:101361>
+.000 > . 43441:44889(1448) ack 1 <nop, nop, TS val 500 ecr 280>
+.001 > . 44889:46337(1448) ack 1 <nop, nop, TS val 501 ecr 280>
+.001 > . 46337:47785(1448) ack 1 <nop, nop, TS val 502 ecr 280>
+.001 > . 47785:49233(1448) ack 1 <nop, nop, TS val 503 ecr 280>
+.001 > . 49233:50681(1448) ack 1 <nop, nop, TS val 504 ecr 280>
+.001 > . 50681:52129(1448) ack 1 <nop, nop, TS val 505 ecr 280>
+.001 > . 52129:53577(1448) ack 1 <nop, nop, TS val 506 ecr 280>
+.001 > . 53577:55025(1448) ack 1 <nop, nop, TS val 507 ecr 280>
+.001 > . 55025:56473(1448) ack 1 <nop, nop, TS val 508 ecr 280>
+.001 > . 56473:57921(1448) ack 1 <nop, nop, TS val 509 ecr 280>
+.001 > . 57921:59369(1448) ack 1 <nop, nop, TS val 510 ecr 280>
+.001 > . 59369:60817(1448) ack 1 <nop, nop, TS val 511 ecr 280>
+.001 > . 60817:62265(1448) ack 1 <nop, nop, TS val 512 ecr 280>
+.001 > . 62265:63713(1448) ack 1 <nop, nop, TS val 513 ecr 280>
+.001 > . 63713:65161(1448) ack 1 <nop, nop, TS val 514 ecr 280>



A "tcpdump -p -n -s 0 -i any port 8080" while packetdrill runs, shows for the RTX phase :

09:43:46.008860 IP 192.0.2.1.33257 > 192.168.105.33.8080: Flags [.], ack 43441, win 65535, options [nop,nop,TS val 280 ecr 895244774,nop,nop,sack 1 {78841:101361}], length 0
09:43:46.008882 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 43441:44889, ack 1, win 28960, options [nop,nop,TS val 895244777 ecr 280], length 1448: HTTP
09:43:46.009832 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 44889:46337, ack 1, win 28960, options [nop,nop,TS val 895244777 ecr 280], length 1448: HTTP
09:43:46.010831 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 46337:47785, ack 1, win 28960, options [nop,nop,TS val 895244777 ecr 280], length 1448: HTTP
09:43:46.011832 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 47785:49233, ack 1, win 28960, options [nop,nop,TS val 895244777 ecr 280], length 1448: HTTP
09:43:46.012831 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 49233:50681, ack 1, win 28960, options [nop,nop,TS val 895244777 ecr 280], length 1448: HTTP
09:43:46.013832 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 50681:52129, ack 1, win 28960, options [nop,nop,TS val 895244777 ecr 280], length 1448: HTTP
09:43:46.014832 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 52129:53577, ack 1, win 28960, options [nop,nop,TS val 895244778 ecr 280], length 1448: HTTP
09:43:46.015831 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 53577:55025, ack 1, win 28960, options [nop,nop,TS val 895244779 ecr 280], length 1448: HTTP
09:43:46.016831 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 55025:56473, ack 1, win 28960, options [nop,nop,TS val 895244780 ecr 280], length 1448: HTTP
09:43:46.017831 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 56473:57921, ack 1, win 28960, options [nop,nop,TS val 895244781 ecr 280], length 1448: HTTP
09:43:46.018831 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 57921:59369, ack 1, win 28960, options [nop,nop,TS val 895244782 ecr 280], length 1448: HTTP
09:43:46.019832 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 59369:60817, ack 1, win 28960, options [nop,nop,TS val 895244783 ecr 280], length 1448: HTTP
09:43:46.020831 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 60817:62265, ack 1, win 28960, options [nop,nop,TS val 895244784 ecr 280], length 1448: HTTP
09:43:46.021831 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 62265:63713, ack 1, win 28960, options [nop,nop,TS val 895244785 ecr 280], length 1448: HTTP
09:43:46.022831 IP 192.168.105.33.8080 > 192.0.2.1.33257: Flags [.], seq 63713:65161, ack 1, win 28960, options [nop,nop,TS val 895244786 ecr 280], length 1448: HTTP

We do see the TS val being properly incremented (after the initial burst to hit TSQ limit)
