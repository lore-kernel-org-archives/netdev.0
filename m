From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Mon, 26 Apr 2010 09:09:25 -0700
Message-ID: <20100426160925.GD2529@linux.vnet.ibm.com>
References: <t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
 <20100421213543.GO2563@linux.vnet.ibm.com>
 <20100422145640.GB3228@redhat.com>
 <20100422160144.GC2524@linux.vnet.ibm.com>
 <h2xa44ae5cd1004230550uf734c89eo2b1d1945d446068c@mail.gmail.com>
 <20100423194255.GE2589@linux.vnet.ibm.com>
 <m2xa44ae5cd1004231559hcf90671asf146a43b4748c2c3@mail.gmail.com>
 <20100425023455.GM2440@linux.vnet.ibm.com>
 <w2sa44ae5cd1004250849q73704370vc6af935c70db9b73@mail.gmail.com>
 <p2ga44ae5cd1004251320j55d23ba7ua0fa14497f623d76@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivek Goyal <vgoyal@redhat.com>, Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:36766 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752545Ab0DZQJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 12:09:29 -0400
Content-Disposition: inline
In-Reply-To: <p2ga44ae5cd1004251320j55d23ba7ua0fa14497f623d76@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 04:20:13PM -0400, Miles Lane wrote:
> > I am down to seeing three suspicious rcu_dereference_check traces when
> > I apply this patch and all the previous patches to 2.6.34-rc5-git6.
> >
> > 1. The "__sched_setscheduler+0x19d/0x300" trace.
> > 2. The two "is_swiotlb_buffer+0x2e/0x3b" traces (waiting to see
> > Johannes' patch show up in a Linux snapshot)
> >
> > Did I miss a patch for the setscheduler issue?
> 
> Hmm.  I am still seeing these two messages as well.
> 
> [   83.363146] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   83.363148] ---------------------------------------------------
> [   83.363151] include/net/inet_timewait_sock.h:227 invoked
> rcu_dereference_check() without protection!
> [   83.363154]
> [   83.363155] other info that might help us debug this:
> [   83.363156]
> [   83.363158]
> [   83.363159] rcu_scheduler_active = 1, debug_locks = 1
> [   83.363162] 2 locks held by gwibber-service/5076:
> [   83.363164]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff8110534a>]
> seq_read+0x37/0x381
> [   83.363176]  #1:  (&(&hashinfo->ehash_locks[i])->rlock){+.-...},
> at: [<ffffffff813ddcd5>] established_get_next+0xc4/0x132
> [   83.363186]
> [   83.363187] stack backtrace:
> [   83.363191] Pid: 5076, comm: gwibber-service Not tainted 2.6.34-rc5-git6 #27
> [   83.363194] Call Trace:
> [   83.363202]  [<ffffffff81068086>] lockdep_rcu_dereference+0x9d/0xa5
> [   83.363207]  [<ffffffff813dc998>] twsk_net+0x4f/0x57
> [   83.363212]  [<ffffffff813ddc65>] established_get_next+0x54/0x132
> [   83.363216]  [<ffffffff813dde47>] tcp_seq_next+0x5d/0x6a
> [   83.363221]  [<ffffffff81105599>] seq_read+0x286/0x381
> [   83.363226]  [<ffffffff81105313>] ? seq_read+0x0/0x381
> [   83.363231]  [<ffffffff8113503c>] proc_reg_read+0x8d/0xac
> [   83.363236]  [<ffffffff810ebf14>] vfs_read+0xa6/0x103
> [   83.363241]  [<ffffffff810ec027>] sys_read+0x45/0x69
> [   83.363246]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b
> 
> [   84.660302] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   84.660304] ---------------------------------------------------
> [   84.660308] include/net/inet_timewait_sock.h:227 invoked
> rcu_dereference_check() without protection!
> [   84.660311]
> [   84.660312] other info that might help us debug this:
> [   84.660313]
> [   84.660315]
> [   84.660316] rcu_scheduler_active = 1, debug_locks = 1
> [   84.660319] no locks held by gwibber-service/5081.
> [   84.660321]
> [   84.660322] stack backtrace:
> [   84.660325] Pid: 5081, comm: gwibber-service Not tainted 2.6.34-rc5-git6 #27
> [   84.660328] Call Trace:
> [   84.660339]  [<ffffffff81068086>] lockdep_rcu_dereference+0x9d/0xa5
> [   84.660345]  [<ffffffff813cad6f>] twsk_net+0x4f/0x57
> [   84.660350]  [<ffffffff813cb18f>] __inet_twsk_hashdance+0x50/0x158
> [   84.660355]  [<ffffffff813e0bb9>] tcp_time_wait+0x1c1/0x24b
> [   84.660360]  [<ffffffff813d3d97>] tcp_fin+0x83/0x162
> [   84.660364]  [<ffffffff813d4727>] tcp_data_queue+0x1ff/0xa1e
> [   84.660370]  [<ffffffff810496aa>] ? mod_timer+0x1e/0x20
> [   84.660375]  [<ffffffff813d8363>] tcp_rcv_state_process+0x89d/0x8f2
> [   84.660381]  [<ffffffff813943bb>] ? release_sock+0x30/0x10b
> [   84.660386]  [<ffffffff813de772>] tcp_v4_do_rcv+0x2de/0x33f
> [   84.660391]  [<ffffffff8139440d>] release_sock+0x82/0x10b
> [   84.660395]  [<ffffffff813ce875>] tcp_close+0x1b5/0x37e
> [   84.660401]  [<ffffffff813ecdb7>] inet_release+0x50/0x57
> [   84.660405]  [<ffffffff81391ae4>] sock_release+0x1a/0x66
> [   84.660410]  [<ffffffff81391b52>] sock_close+0x22/0x26
> [   84.660415]  [<ffffffff810ece07>] __fput+0x120/0x1cd
> [   84.660420]  [<ffffffff810ecec9>] fput+0x15/0x17
> [   84.660424]  [<ffffffff810e9d41>] filp_close+0x63/0x6d
> [   84.660428]  [<ffffffff810e9e22>] sys_close+0xd7/0x111
> [   84.660434]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x1b

Eric Dumazet traced these down to a commit from Eric Biederman.

If I don't hear from Eric Biederman in a few days, I will attempt a
patch, but it would be more likely to be correct coming from someone
with a better understanding of the code.  ;-)

							Thanx, Paul
