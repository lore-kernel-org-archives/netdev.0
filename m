From: fengguang.wu@intel.com
Subject: -27% netperf TCP_STREAM regression by "tcp_memcontrol: Kill struct
 tcp_memcontrol"
Date: Tue, 22 Oct 2013 22:41:29 +0100
Message-ID: <20131022214129.GB2715@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

We noticed big netperf throughput regressions

    a4fe34bf902b8f709c63      2e685cad57906e19add7  
------------------------  ------------------------  
                  707.40       -40.7%       419.60  lkp-nex04/micro/netperf/120s-200%-TCP_STREAM
                 2775.60       -23.7%      2116.40  lkp-sb03/micro/netperf/120s-200%-TCP_STREAM
                 3483.00       -27.2%      2536.00  TOTAL netperf.Throughput_Mbps

and bisected it to

commit 2e685cad57906e19add7189b5ff49dfb6aaa21d3
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Sat Oct 19 16:26:19 2013 -0700

    tcp_memcontrol: Kill struct tcp_memcontrol
    
    Replace the pointers in struct cg_proto with actual data fields and kill
    struct tcp_memcontrol as it is not fully redundant.
    
    This removes a confusing, unnecessary layer of abstraction.
    
    Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 a1896af98145c8ae2765a787845c43c9700c7dc0 02c93b50f66f1d1b34983bf3cc7e9a0dcc7105dc M	include
:040000 040000 ebe5d0619b54ddf730224f6581f595491eb36989 cd560b4a6e56cecac931814ba16420e167eb68f6 M	mm
:040000 040000 5df01f70484e07fbf98a7d5b8e0a53270777ac3d 1f8d1b340d8810a79691777f4e3ee529027b3c9b M	net
bisect run success

# bad: [aec2994e1799312822a30fefc27205e7360fe5af] Merge 'pwm/for-next' into devel-hourly-2013102222
# good: [31d141e3a666269a3b6fcccddb0351caf7454240] Linux 3.12-rc6
git bisect start 'aec2994e1799312822a30fefc27205e7360fe5af' '31d141e3a666269a3b6fcccddb0351caf7454240' '--'
# good: [ef26157747d42254453f6b3ac2bd8bd3c53339c3] batman-adv: tvlv - basic infrastructure
git bisect good ef26157747d42254453f6b3ac2bd8bd3c53339c3
# bad: [cc6a88faebab06b0323818cd102a6aae443cf34a] Merge 'netdev-next/master' into devel-hourly-2013102222
git bisect bad cc6a88faebab06b0323818cd102a6aae443cf34a
# good: [5cda73b68ebf7e08586d61e6777e64e12df23f07] Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next
git bisect good 5cda73b68ebf7e08586d61e6777e64e12df23f07
# good: [a8fab0744585c1ab61009bfc1a1958f28e1c864f] x86/jump_label: expect default_nop if static_key gets enabled on boot-up
git bisect good a8fab0744585c1ab61009bfc1a1958f28e1c864f
# good: [21d35d212469c3138f8916f7e47b779313d79751] net: sky2: remove unnecessary pci_set_drvdata()
git bisect good 21d35d212469c3138f8916f7e47b779313d79751
# bad: [61c1db7fae21ed33c614356a43bf6580c5e53118] ipv6: sit: add GSO/TSO support
git bisect bad 61c1db7fae21ed33c614356a43bf6580c5e53118
# good: [a4fe34bf902b8f709c635ab37f1f39de0b86cff2] tcp_memcontrol: Remove the per netns control.
git bisect good a4fe34bf902b8f709c635ab37f1f39de0b86cff2
# bad: [1b66917d6b76db0abe1a1bbf86b2517ba8b91d98] cgxb4: remove duplicate include in cxgb4.h
git bisect bad 1b66917d6b76db0abe1a1bbf86b2517ba8b91d98
# bad: [0a6fa23dcb10eeb21adfd9955f7030f952a8122d] ipv4: Use math to point per net sysctls into the appropriate struct net.
git bisect bad 0a6fa23dcb10eeb21adfd9955f7030f952a8122d
# bad: [2e685cad57906e19add7189b5ff49dfb6aaa21d3] tcp_memcontrol: Kill struct tcp_memcontrol
git bisect bad 2e685cad57906e19add7189b5ff49dfb6aaa21d3
# first bad commit: [2e685cad57906e19add7189b5ff49dfb6aaa21d3] tcp_memcontrol: Kill struct tcp_memcontrol


                              netperf.Throughput_Mbps

   750 ++-------------------------------------------------------------------+
       *...*...                             .*...                         ..*
   700 ++      *...*..*...*...*...*...*...*.     *...*...*...*...*..*...*.  |
       |                                                                    |
   650 ++                                                                   |
       |                                                                    |
   600 ++                                                                   |
       |                                                                    |
   550 ++                                                                   |
       |                                                                    |
   500 ++                                                                   |
       |                                                                    |
   450 ++                                                                   |
       O   O       O  O   O       O       O  O   O   O   O   O              |
   400 ++------O--------------O-------O-------------------------------------+


                                  vmstat.system.in

   17200 ++-----------------------------------------------------------------+
   17100 ++               ..*..*.      *...*..                              |
         |          *...*.       ..  ..       *                        .*...|
   17000 ++       ..                .          +                     *.     *
   16900 ++..*.. .                 *            +                  ..       |
   16800 *+     *                                +       *        .         |
   16700 ++                                       *..   + +      *          |
         |                                           . +   +   ..           |
   16600 ++                                           *     + .             |
   16500 ++                                                  *              |
   16400 ++                                                                 |
   16300 ++                                                                 |
         O          O   O      O       O              O                     |
   16200 ++  O  O           O      O       O  O   O      O   O              |
   16100 ++-----------------------------------------------------------------+


                                   vmstat.system.cs

   550000 ++----------------------------------------------------------------+
   500000 *+..*..*..        *...*..    *...  ..*..*..    .*..*...*..    *...*
          |         .     ..       . ..    *.        . ..           . ..    |
   450000 ++         *...*          *                 *              *      |
   400000 ++                                                                |
   350000 ++                                                                |
   300000 ++                                                                |
          |                                                                 |
   250000 ++                                                                |
   200000 ++                                                                |
   150000 ++                                                                |
   100000 ++                                                                |
          |                                                                 |
    50000 O+  O  O   O   O  O   O   O  O   O   O  O   O   O  O              |
        0 ++----------------------------------------------------------------+


                          lock_stat.slock-AF_INET.contentions

   150000 ++----------------------------------------------------------------+
          |                 *...         ..*...                             |
   140000 ++               +    *      *.      *                            |
   130000 ++              +      :    :         :                           |
          |            ..*        :   :         :                       *...*
   120000 ++ .*..  ..*.           :  :         O :                    ..    |
   110000 ++.    *.                : :           :                  .*      |
          *                         *             :       *       ..        |
   100000 ++                                      *.     + :     *          |
    90000 ++                                        ..  +   :  ..           |
          |                                            +    : .             |
    80000 ++                           O              *      *              |
    70000 O+         O   O      O                     O                     |
          |   O             O       O             O          O              |
    60000 ++-----O-------------------------O--------------O-----------------+


                 lock_stat.slock-AF_INET.contentions.lock_sock_nested

   130000 ++----------------------------------------------------------------+
          |                                                                 |
   120000 ++                *...         ..*...*                            |
   110000 ++               +    *      *.       :                           |
          |               +      +    :        O:                       *...*
   100000 ++ .*..   .*...*        +   :          :                    ..    |
          |..     ..               + :           :                  .*      |
    90000 *+     *                  *             :       *       ..        |
          |                                       *.     + :     *          |
    80000 ++                                        ..  +   :  ..           |
    70000 ++                                           +    : .             |
          |              O      O      O              *      *              |
    60000 O+         O                            O   O                     |
          |   O  O          O       O      O              O  O              |
    50000 ++----------------------------------------------------------------+


                    lock_stat.slock-AF_INET.contentions.tcp_v4_rcv

   150000 ++----------------------------------------------------------------+
          |                 *...                                            |
   140000 ++               +    *      *...*...*                            |
   130000 ++              +      :    :         :                           |
          |            ..*        :   :         :                       *...*
   120000 ++ .*..  ..*.           :  :         O :                    ..    |
   110000 ++.    *.                : :           :                  .*      |
          *                         *             :               ..        |
   100000 ++                                      *.      *      *          |
    90000 ++                                        ..  .. +   ..           |
          |                                            .    + .             |
    80000 ++                           O              *      *              |
    70000 ++         O   O      O                     O                     |
          O   O             O       O             O          O              |
    60000 ++-----O-------------------------O--------------O-----------------+


                        lock_stat.slock-AF_INET/1.contentions

   50000 ++-----------------------------------------------------------------+
         |                  *..                                           ..*
   45000 ++                +           *...*..                          *.  |
   40000 ++               +    *.     +       *..                     ..    |
         |  .*..         +       ..  +           .                 ..*      |
   35000 ++.    *...  ..*           +             *      *.      *.         |
         *          *.             *               :    :  ..  ..           |
   30000 ++                                         :   :     .             |
         |                                          :  :     *              |
   25000 ++                                          : :                    |
   20000 ++                                           *                     |
         |                                    O                             |
   15000 ++                            O              O                     |
         O   O  O   O   O   O  O   O       O      O      O   O              |
   10000 ++-----------------------------------------------------------------+


                  lock_stat.slock-AF_INET/1.contentions.tcp_v4_rcv

   50000 ++-----------------------------------------------------------------+
         |                  *..                                           ..*
   45000 ++                +           *...*..                          *.  |
   40000 ++               +    *.     +       *..                     ..    |
         |  .*..         +       ..  +           .                 ..*      |
   35000 ++.    *...  ..*           +             *      *.      *.         |
         *          *.             *               :    :  ..  ..           |
   30000 ++                                         :   :     .             |
         |                                          :  :     *              |
   25000 ++                                          : :                    |
   20000 ++                                           *                     |
         |                                    O                             |
   15000 ++                            O              O                     |
         O   O  O   O   O   O  O   O       O      O      O   O              |
   10000 ++-----------------------------------------------------------------+


                 lock_stat.slock-AF_INET/1.contentions.release_sock

   35000 ++-----------------------------------------------------------------*
         |                  *..                                         *.  |
   30000 ++                +           *...*..*.                      ..    |
         |                +    *..   ..         ..                 ..*      |
         |  .*..         +        . .                    *.      *.         |
   25000 ++.    *...*...*          *              *     :  ..  ..           |
         *                                         +    :     .             |
   20000 ++                                         +  :     *              |
         |                                           + :                    |
   15000 ++                                           *                     |
         |                                                                  |
         |                                    O                             |
   10000 O+         O   O      O       O          O   O                     |
         |   O  O           O      O       O             O   O              |
    5000 ++-----------------------------------------------------------------+


                           lock_stat.&rq->lock.contentions

   45000 ++-----------------------------------------------------------------+
         |                 .*..        *...                                 |
   40000 ++              ..    *..   ..    *..                              |
   35000 ++ .*..      ..*         . .         *.                       .*...*
         |..    *...*.             *            ..                  .*.     |
   30000 *+                                                       ..        |
   25000 ++                                       *..    *...  ..*          |
         |                                           . ..    *.             |
   20000 ++                                           *                     |
   15000 ++                                                                 |
         |                                                                  |
   10000 ++                                                                 |
    5000 O+  O  O   O   O   O  O   O   O   O  O   O   O      O              |
         |                                               O                  |
       0 ++-----------------------------------------------------------------+


                   lock_stat.&rq->lock.contentions.try_to_wake_up

   35000 ++-----------------------------------------------------------------+
         |                                                                  |
   30000 ++                .*..            *..                              |
         |   *           ..    *..        :                                 |
   25000 ++.. :         *         .       :   *.                        *   |
         |.   :        :           *.    :      ..                      ::  |
   20000 *+    :       :             .. :                       .*     :  : |
         |     :      :                 :         *...        ..  +    :  : |
   15000 ++     :    :                 *              *      *     +  :    :|
         |      *... :                                 +   ..       + :     *
   10000 ++         *                                   + .          *      |
         |                                               *                  |
    5000 ++                                   O                             |
         O   O  O   O   O   O  O       O   O          O  O   O              |
       0 ++------------------------O--------------O-------------------------+


                     lock_stat.&rq->lock.contentions.__schedule

   35000 ++-----------------------------------------------------------------+
         |                                                                  |
   30000 ++                 *..                                             |
         |                ..              .*..                              |
   25000 ++ .*           .     *...     ..                              *.  |
         |..  +        .*          *...*      *                        :  ..|
   20000 *+    +     ..                        +                       :    |
         |      *...*                           +              ..*... :     *
   15000 ++                                      +         ..*.      *      |
         |                                        *...*..*.                 |
   10000 ++                                                                 |
         |                                                                  |
    5000 ++                    O                                            |
         O   O  O   O   O   O      O   O   O  O   O   O  O   O              |
       0 ++-----------------------------------------------------------------+


             lock_stat.&(&base->lock)->rlock.contentions.lock_timer_base

   18000 ++----------------------------*------------------------------------+
         |                ..*..       +    *..                         .*...*
   16000 ++           ..*.     *..   +        *...                  .*.     |
   14000 ++ .*..*...*.            . +             *      *.       ..        |
         |..                       *               +    :  ..   .*          |
   12000 *+                                         +   :     ..            |
   10000 ++                                          + :     *              |
         |                                            *                     |
    8000 ++                                                                 |
    6000 ++                                                                 |
         |                                                                  |
    4000 ++                                                                 |
    2000 ++                    O                                            |
         O   O  O   O   O   O      O   O   O  O   O   O  O   O              |
       0 ++-----------------------------------------------------------------+


                     lock_stat.&(&n->list_lock)->rlock.contentions

   140000 ++----------------------------------------------------------------+
          |                                       O                         |
   120000 O+  O  O   O   O  O   O                     O                     |
          |                         O  O   O   O          O  O              |
   100000 ++                                                                |
          |                                                                 |
    80000 ++                                                                |
          |                                                                 |
    60000 ++                                                                |
          |                                                                 |
    40000 ++                                                                |
          |                                                                 |
    20000 ++                                                                |
          |                                                                 |
        0 *+--*--*---*---*--*---*---*--*---*---*--*---*---*--*---*---*--*---*


            lock_stat.&(&n->list_lock)->rlock.contentions.get_partial_node

   250000 ++----------------------------------------------------------------+
          |                                                                 |
          O                                       O                         |
   200000 ++  O  O   O   O  O   O   O  O   O   O      O      O              |
          |                                               O                 |
          |                                                                 |
   150000 ++                                                                |
          |                                                                 |
   100000 ++                                                                |
          |                                                                 |
          |                                                                 |
    50000 ++                                                                |
          |                                                                 |
          |                                                                 |
        0 *+--*--*---*---*--*---*---*--*---*---*--*---*---*--*---*---*--*---*


           lock_stat.&(&n->list_lock)->rlock.contentions.unfreeze_partials

   45000 ++-----------------------------------------------------------------+
         O                                        O                         |
   40000 ++         O   O   O                         O                     |
   35000 ++  O  O              O   O       O  O          O   O              |
         |                             O                                    |
   30000 ++                                                                 |
   25000 ++                                                                 |
         |                                                                  |
   20000 ++                                                                 |
   15000 ++                                                                 |
         |                                                                  |
   10000 ++                                                                 |
    5000 ++                                                                 |
         |                                                                  |
       0 *+--*--*---*---*---*--*---*---*---*--*---*---*--*---*---*---*--*---*


                                  iostat.cpu.user

   1.8 ++-------------------------------------------------------------------+
       *...*...*.         *...*.      *...*..                               |
   1.6 ++        ..     ..      ..  ..       *...*..    .*...*...*      *...*
       |               .           .                . ..          +   ..    |
       |           *..*           *                  *             + .      |
   1.4 ++                                                           *       |
       |                                                                    |
   1.2 ++                                                                   |
       |                                                                    |
     1 ++                                                                   |
       |                                                                    |
       |                                                                    |
   0.8 ++                         O       O      O   O                      |
       O   O   O   O  O   O   O       O      O           O   O              |
   0.6 ++-------------------------------------------------------------------+


                                  iostat.cpu.system

   96.6 ++------------------------------------------------------------------+
        |   O          O              O   O       O  O   O                  |
   96.4 O+      O  O       O   O  O                          O              |
        |                                                                   |
        |                                                                   |
   96.2 ++                                                                  |
        |                                                                   |
     96 ++                                                                  |
        |                                                                   |
   95.8 ++                                    O                             |
        |            ..*.         *.                 *..            *..     |
        |          *.    ..      +  ..             ..   .         ..   .  ..*
   95.6 ++       ..             +           ..*...*      *...  ..*      *.  |
        |     ..*          *...*      *...*.                 *.             |
   95.4 *+--*---------------------------------------------------------------+
