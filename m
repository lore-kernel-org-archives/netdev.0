From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH v2 net-next] af_unix: dont send SCM_CREDENTIALS by
 default
Date: Mon, 19 Sep 2011 14:39:58 -0700
Message-ID: <1316468398.4680.6.camel@schen9-DESK>
References: <1315488497.2456.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315473888.2301.21.camel@schen9-mobl>
	 <1315544777.5410.19.camel@edumazet-laptop>
	 <20110918.210758.2207266633127640132.davem@davemloft.net>
	 <1316406528.2521.15.camel@edumazet-laptop>
	 <1316444524.2539.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1316447547.2539.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, zheng.z.yan@intel.com,
	yanzheng@21cn.com, netdev@vger.kernel.org, sfr@canb.auug.org.au,
	jirislaby@gmail.com, sedat.dilek@gmail.com, alex.shi@intel.com,
	Valdis.Kletnieks@vt.edu
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27341 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753770Ab1ISVkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Sep 2011 17:40:03 -0400
In-Reply-To: <1316447547.2539.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-09-19 at 17:52 +0200, Eric Dumazet wrote:
> Since commit 7361c36c5224 (af_unix: Allow credentials to work across
> user and pid namespaces) af_unix performance dropped a lot.
> 
> This is because we now take a reference on pid and cred in each write(),
> and release them in read(), usually done from another process,
> eventually from another cpu. This triggers false sharing.
> 
> # Events: 154K cycles
> #
> # Overhead  Command       Shared Object        Symbol
> # ........  .......  ..................  .........................
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
>      1.51%  hackbench  [kernel.kallsyms]   [k]
> __mutex_lock_interruptible_slowpath
>      1.42%  hackbench  [kernel.kallsyms]   [k] sock_alloc_send_pskb
> 
> 
> This patch includes SCM_CREDENTIALS information in a af_unix message/skb
> only if requested by the sender, [man 7 unix for details how to include
> ancillary data using sendmsg() system call]
> 
> Note: This might break buggy applications that expected SCM_CREDENTIAL
> from an unaware write() system call, and receiver not using SO_PASSCRED
> socket option.
> 
> If SOCK_PASSCRED is set on source or destination socket, we still
> include credentials for mere write() syscalls.
> 
> Performance boost in hackbench : more than 50% gain on a 16 thread
> machine (2 quad-core cpus, 2 threads per core)
> 
> hackbench 20 thread 2000
> 
> 4.228 sec instead of 9.102 sec
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---

Do we have to worry about the case where peer socket changes its flag
to SOCK_PASSCRED while packets are in flight?  If there isn't such
pathological use case, the patch looks fine to me.

Acked-by: Tim Chen <tim.c.chen@linux.intel.com>
