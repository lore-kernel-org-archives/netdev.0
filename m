From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: After a while of system running no incoming UDP any more?
Date: Fri, 28 Jul 2017 01:41:05 -0700
Message-ID: <1501231265.12695.25.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
         <1500905950.2458.6.camel@redhat.com>
         <20170728062644.bp7agcf6bh7g6yfw@torres.zugschlus.de>
         <1501229105.12695.23.camel@edumazet-glaptop3.roam.corp.google.com>
         <1501229702.2597.3.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marc Haber <mh+netdev@zugschlus.de>, netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36404 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdG1IlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 04:41:13 -0400
Received: by mail-wm0-f45.google.com with SMTP id t201so119415976wmt.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 01:41:09 -0700 (PDT)
In-Reply-To: <1501229702.2597.3.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-07-28 at 10:15 +0200, Paolo Abeni wrote:
> Hi,
> 
> On Fri, 2017-07-28 at 01:05 -0700, Eric Dumazet wrote:

> I think that the leaked sockets are still unhashed on close() (via
> udp_lib_close() -> sk_common_release() ->sk_proto->unhash()), so they
> should not be listed there ?!? (Rush answer, subject to lack of coffee
> issues)

If the daemon is still running, sockets are not closed and we can watch
refcount being increased.

We can see this even on an UDP_RR workload (no UDP flood at all)

lpk51:~# while :
> do
> ./super_netperf 10 -H 2002:af6:b34:: -t UDP_RR -l 1 -- -N
> done


lpk52:~# cat /proc/net/udp6|grep -v " 2 "
  sl  local_address                         remote_address
st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode ref
pointer drops
  293: F60A02200000340B0000000000000000:F0A9
F60A02200000330B0000000000000000:AB11 01 00000000:00000000 00:00000000
00000000     0        0 583763 387 ffff880ddb862c00 0
 3251: F60A02200000340B0000000000000000:FC37
F60A02200000330B0000000000000000:EA7F 01 00000000:00000000 00:00000000
00000000     0        0 586126 356 ffff880dd25a7940 0
 4043: F60A02200000340B0000000000000000:FF4F
F60A02200000330B0000000000000000:9A35 01 00000500:00000000 00:00000000
00000000     0        0 583760 409 ffff880ddb863180 0
 7832: F60A02200000340B0000000000000000:8E1C
F60A02200000330B0000000000000000:DEC1 01 00000000:00000000 00:00000000
00000000     0        0 583766 387 ffff880ddb863700 0
 8568: F60A02200000340B0000000000000000:90FC
F60A02200000330B0000000000000000:8A60 01 00000000:00000000 00:00000000
00000000     0        0 580369 379 ffff880d9e7b2700 0
13085: F60A02200000340B0000000000000000:A2A1
F60A02200000330B0000000000000000:CDB3 01 00000000:00000000 00:00000000
00000000     0        0 586915 397 ffff880e31994140 0
14975: F60A02200000340B0000000000000000:AA03
F60A02200000330B0000000000000000:9C71 01 00000000:00000000 00:00000000
00000000     0        0 586123 355 ffff880d9d1baec0 0
15155: F60A02200000340B0000000000000000:AAB7
F60A02200000330B0000000000000000:D324 01 00000000:00000000 00:00000000
00000000     0        0 583769 367 ffff880dd88141c0 0
25421: F60A02200000340B0000000000000000:D2D1
F60A02200000330B0000000000000000:CA33 01 00000000:00000000 00:00000000
00000000     0        0 586120 424 ffff880dfda4b0c0 0
28774: F60A02200000340B0000000000000000:DFEA
F60A02200000330B0000000000000000:DD05 01 00000500:00000000 00:00000000
00000000     0        0 583757 411 ffff880ddb862680 0
