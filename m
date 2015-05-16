From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink: Kill bogus lock_sock in netlink_insert
Date: Sat, 16 May 2015 09:50:11 -0700
Message-ID: <1431795011.27831.122.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150514042151.GA5482@gondor.apana.org.au>
	 <20150514055824.GB6058@gondor.apana.org.au>
	 <20150514060230.GD6058@gondor.apana.org.au>
	 <20150515.124955.1765730151919172866.davem@redhat.com>
	 <1431712914.27831.116.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38517 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbbEPQuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 12:50:14 -0400
Received: by igcau1 with SMTP id au1so20299043igc.1
        for <netdev@vger.kernel.org>; Sat, 16 May 2015 09:50:13 -0700 (PDT)
In-Reply-To: <1431712914.27831.116.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-15 at 11:01 -0700, Eric Dumazet wrote:
> On Fri, 2015-05-15 at 12:49 -0400, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Thu, 14 May 2015 14:02:30 +0800
> >=20
> > > On Thu, May 14, 2015 at 01:58:24PM +0800, Herbert Xu wrote:
> > >>=20
> > >> This patch also removes a bogus socket lock introduced by that
> > >> very same patch.
> > >=20
> > > This bogus socket lock is still there in the current tree.
> > >=20
> > > ---8<---
> > > The commit c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink:
> > > eliminate nl_sk_hash_lock") added a lock_sock to netlink_insert
> > > with no justifications whatsoever.
> > >=20
> > > This patch kills it.
> > >=20
> > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >=20
> > Eric, does this improve your benchmark?
>=20
> I don't think so, but I can test this in about one hour.

Maybe the difference between 3.15 and 4.1 is not coming from
rhashtable/netlink but other core stuff, like mutex code.

The workload is largely dominated by mutex acquisition anyway.

    88.42%  [kernel]          [k] osq_lock                     =20
     1.91%  [kernel]          [k] mutex_spin_on_owner.isra.4   =20
     0.46%  [kernel]          [k] mutex_optimistic_spin        =20
     0.33%  [kernel]          [k] _raw_spin_lock               =20
     0.32%  [kernel]          [k] inet_dump_ifaddr             =20
     0.31%  [kernel]          [k] inet6_dump_addr              =20
     0.23%  [kernel]          [k] mutex_unlock                 =20
     0.23%  [kernel]          [k] _raw_read_lock_bh            =20
     0.21%  [kernel]          [k] _raw_spin_lock_irqsave       =20
     0.20%  perf              [.] 0x0000000000046273           =20

-  88.49%      getaddrinfo  [kernel.kallsyms]    [k] osq_lock          =
                                                                       =
                        =E2=97=86
   - osq_lock                                                          =
                                                                       =
                        =E2=96=92
      - 100.00% mutex_optimistic_spin                                  =
                                                                       =
                        =E2=96=92
           __mutex_lock_slowpath                                       =
                                                                       =
                        =E2=96=92
         - mutex_lock                                                  =
                                                                       =
                        =E2=96=92
            - 45.48% netlink_dump                                      =
                                                                       =
                        =E2=96=92
               + 87.27% netlink_recvmsg                                =
                                                                       =
                        =E2=96=92
               + 12.73% __netlink_dump_start                           =
                                                                       =
                        =E2=96=92
            - 38.93% rtnl_lock                                         =
                                                                       =
                        =E2=96=92
               + 52.52% rtnetlink_rcv                                  =
                                                                       =
                        =E2=96=92
               + 47.48% rtnetlink_rcv_msg                              =
                                                                       =
                        =E2=96=92
            - 15.59% __netlink_dump_start                              =
                                                                       =
                        =E2=96=92
                 rtnetlink_rcv_msg                                     =
                                                                       =
                        =E2=96=92
                 netlink_rcv_skb                                       =
                                                                       =
                        =E2=96=92
                 rtnetlink_rcv                                         =
                                                                       =
                        =E2=96=92
                 netlink_unicast                                       =
                                                                       =
                        =E2=96=92
                 netlink_sendmsg                                       =
                                                                       =
                        =E2=96=92
                 sock_sendmsg                                          =
                                                                       =
                        =E2=96=92
                 SYSC_sendto                                           =
                                                                       =
                        =E2=96=92
                 sys_sendto                                            =
                                                                       =
                        =E2=96=92
                 system_call_fastpath                                  =
                                                                       =
                        =E2=96=92
               + __sendto_nocancel                                     =
                                                                       =
                        =E2=96=92
+   1.96%      getaddrinfo  [kernel.kallsyms]    [k] mutex_spin_on_owne=
r.isra.4    =20
