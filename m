From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH net-next] af_unix: dont send SCM_CREDENTIALS by default
Date: Mon, 12 Sep 2011 12:15:46 -0700
Message-ID: <1315854946.2576.3122.camel@schen9-DESK>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
	 <1315337580.2576.3066.camel@schen9-DESK>
	 <1315338186.3400.20.camel@edumazet-laptop>
	 <1315339157.2576.3079.camel@schen9-DESK>
	 <1315340388.3400.28.camel@edumazet-laptop>
	 <CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
	 <1315372100.3400.76.camel@edumazet-laptop>  <4E66FF38.9000107@intel.com>
	 <1315381503.3400.85.camel@edumazet-laptop>
	 <1315396903.2364.23.camel@schen9-mobl>
	 <1315430766.2532.1.camel@edumazet-laptop>
	 <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315473888.2301.21.camel@schen9-mobl>
	 <1315544777.5410.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10321 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753689Ab1ILTMb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Sep 2011 15:12:31 -0400
In-Reply-To: <1315544777.5410.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-09 at 07:06 +0200, Eric Dumazet wrote:
> Le jeudi 08 septembre 2011 =C3=A0 02:24 -0700, Tim Chen a =C3=A9crit =
:
>=20
> > Looking forward to the patch.  This should improve the scalability =
of
> > af_unix.
>=20
> Here it is, based on top on previous one [af_unix: Fix use-after-free
> crashes]
>=20
> Thanks
>=20
> [PATCH net-next] af_unix: dont send SCM_CREDENTIALS by default
>=20
> Since commit 7361c36c5224 (af_unix: Allow credentials to work across
> user and pid namespaces) af_unix performance dropped a lot.
>=20
> This is because we now take a reference on pid and cred in each write=
(),
> and release them in read(), usually done from another process,
> eventually from another cpu. This triggers false sharing.
>=20
> # Events: 154K cycles
> #
> # Overhead  Command       Shared Object                              =
 Symbol
> # ........  .......  ..................  ............................=
=2E......
> #
>     10.40%  hackbench  [kernel.kallsyms]   [k] put_pid
>      8.60%  hackbench  [kernel.kallsyms]   [k] unix_stream_recvmsg
>      7.87%  hackbench  [kernel.kallsyms]   [k] unix_stream_sendmsg
>      6.11%  hackbench  [kernel.kallsyms]   [k] do_raw_spin_lock
>      4.95%  hackbench  [kernel.kallsyms]   [k] unix_scm_to_skb
>      4.87%  hackbench  [kernel.kallsyms]   [k] pid_nr_ns
>      4.34%  hackbench  [kernel.kallsyms]   [k] cred_to_ucred
>      2.39%  hackbench  [kernel.kallsyms]   [k] unix_destruct_scm
>      2.24%  hackbench  [kernel.kallsyms]   [k] sub_preempt_count
>      1.75%  hackbench  [kernel.kallsyms]   [k] fget_light
>      1.51%  hackbench  [kernel.kallsyms]   [k] __mutex_lock_interrupt=
ible_slowpath
>      1.42%  hackbench  [kernel.kallsyms]   [k] sock_alloc_send_pskb
>=20
>=20
> This patch includes SCM_CREDENTIALS information in a af_unix message/=
skb
> only if requested by the sender, [man 7 unix for details how to inclu=
de
> ancillary data using sendmsg() system call]
>=20
> Note: This might break buggy applications that expected SCM_CREDENTIA=
L
> from an unaware write() system call.
>=20
> Performance boost in hackbench : more than 50% gain on a 16 thread
> machine (2 quad-core cpus, 2 threads per core)
>=20
> hackbench 20 thread 2000
>=20
> 4.224 sec instead of 9.102 sec
>=20
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This speeds up the case where we're not passing SCM_CREDENTIALS nicely.

Acked-by: Tim Chen <tim.c.chen@linux.intel.com>
