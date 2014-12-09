From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: linux-next 20141208 -  net/sched/sch_fq_codel.c:97 suspicious RCU
Date: Tue, 09 Dec 2014 12:51:40 -0500
Message-ID: <6468.1418147500@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1418147500_3854P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1418147500_3854P
Content-Type: text/plain; charset=us-ascii

Spotted this in dmesg while investigating why my wireless broke
sometime between next-20141201 and next-20141208.  Probably not
related, as wireless has been broken on several boot attempts of -1208,
but this has popped only once....

Looks like the fault of

commit 46e5da40aec256155cfedee96dd21a75da941f2c
Author: John Fastabend <john.fastabend@gmail.com>
Date:   Fri Sep 12 20:04:52 2014 -0700

    net: qdisc: use rcu prefix and silence sparse warnings

but I freely admit that exhausts my RCU debugging skills. :)

[  104.743212] ===============================
[  104.743214] [ INFO: suspicious RCU usage. ]
[  104.743218] 3.18.0-next-20141208 #27 Tainted: G           OE
[  104.743219] -------------------------------
[  104.743224] net/sched/sch_fq_codel.c:97 suspicious rcu_dereference_check() usage!
[  104.743227]
other info that might help us debug this:

[  104.743231]
rcu_scheduler_active = 1, debug_locks = 1
[  104.743236] 4 locks held by unbound/1873:
[  104.743239]  #0:  (rcu_read_lock_bh){......}, at: [<ffffffff8a537066>] rcu_lock_acquire+0x0/0x22
[  104.743257]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff8a4ebd44>] rcu_lock_acquire+0x0/0x22
[  104.743274]  #2:  (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.....}, at: [<ffffffff8a4f3ea4>] __dev_queue_xmit+0x32a/0x66a
[  104.743292]  #3:  (&qdisc_tx_lock){+.-...}, at: [<ffffffff8a4f3ead>] __dev_queue_xmit+0x333/0x66a
[  104.743302]
stack backtrace:
[  104.743307] CPU: 2 PID: 1873 Comm: unbound Tainted: G           OE  3.18.0-next-20141208 #27
[  104.743309] Hardware name: Dell Inc. Latitude E6530/07Y85M, BIOS A15 06/20/2014
[  104.743312]  0000000000000001 ffff8800b9f3f978 ffffffff8a6ba925 ffff880223bac210
[  104.743317]  0000000000000001 ffff8800b9f3f9a8 ffffffff8a07f124 ffff8800b9ce4e00
[  104.743323]  ffff880223fea600 0000000000000000 ffff8800c6e2c000 ffff8800b9f3f9f8
[  104.743329] Call Trace:
[  104.743336]  [<ffffffff8a6ba925>] dump_stack+0x50/0xa8
[  104.743343]  [<ffffffff8a07f124>] lockdep_rcu_suspicious+0xea/0xf3
[  104.743348]  [<ffffffff8a514903>] fq_codel_enqueue+0x79/0x21c
[  104.743353]  [<ffffffff8a6c5228>] ? _raw_spin_lock+0x37/0x3f
[  104.743357]  [<ffffffff8a4f3fb5>] __dev_queue_xmit+0x43b/0x66a
[  104.743362]  [<ffffffff8a4f41ef>] dev_queue_xmit+0xb/0xd
[  104.743367]  [<ffffffff8a537beb>] ip_finish_output2+0x42b/0x46c
[  104.743371]  [<ffffffff8a53838f>] ip_finish_output+0x13c/0x144
[  104.743376]  [<ffffffff8a5393f1>] ip_output+0x4c/0x70
[  104.743381]  [<ffffffff8a538d92>] ip_local_out_sk+0x54/0x5f
[  104.743385]  [<ffffffff8a539c2f>] ip_send_skb+0x12/0x37
[  104.743390]  [<ffffffff8a55d145>] udp_send_skb+0x176/0x1db
[  104.743394]  [<ffffffff8a55d839>] udp_sendmsg+0x63e/0x87c
[  104.743398]  [<ffffffff8a537379>] ? skb_set_owner_w+0x56/0x56
[  104.743404]  [<ffffffff8a09011d>] ? __rcu_read_unlock+0xf5/0xfd
[  104.743408]  [<ffffffff8a568135>] ? rcu_read_unlock+0x3e/0x5d
[  104.743413]  [<ffffffff8a568af9>] inet_sendmsg+0x3d/0x66
[  104.743419]  [<ffffffff8a4d6a4b>] __sock_sendmsg_nosec+0x25/0x27
[  104.743422]  [<ffffffff8a4d80da>] sock_sendmsg+0x5a/0x7b
[  104.743429]  [<ffffffff8a12581b>] ? might_fault+0xae/0xb0
[  104.743433]  [<ffffffff8a4d6c22>] ? audit_sockaddr+0x2b/0x44
[  104.743437]  [<ffffffff8a4da1ff>] SYSC_sendto+0x119/0x15c
[  104.743443]  [<ffffffff8a00e2b5>] ? do_audit_syscall_entry+0xb8/0xc7
[  104.743447]  [<ffffffff8a4da85d>] SyS_sendto+0x9/0xb
[  104.743453]  [<ffffffff8a6c5fd2>] system_call_fastpath+0x12/0x17


--==_Exmh_1418147500_3854P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVIc2rAdmEQWDXROgAQJTjhAAoWASTftlDRqz0z9qzju12nrRDwgmtOQg
OmqLq/isuXXnHd9RWcB2zalmfhwWgkPzYKZJfc6NEHz5p59jNS2AhC89KlS55Wj2
16rArpiIOquYn3qoQNBlZvjRqTr1SvjWZex6h/IumZNDxqa7EnyC3k7oEetDpFAO
sK2lar2HdTlFbFgN9gA7EWjmdNjLEfqO2OrXTFLqgt4pvnCwPrYljkAjWS+1tQLw
jxEubNZyXq94OJkbbwejtMtJ2pwyNaIISvxG0vZAZ8rRJmS7OXoak7hHfwAQpRCY
/pxcWjOrwoRi6+bmsoAuCLd9+xkp5QjNnO16Mjk7WhRxRIY7SwomKZMAdyrItXqp
AKkTETmvEZofJ6/jdvK+cJ3388hD1lAikKh8QvvU6+rlZLU6L0G5NLZ9bDKEqFRa
o5k0EskwRpKoUZC1uc4Imh5aZYVeUIUp01ASz6//VcqeAmwvHdc0RxeQhj6ZYkBZ
8p0YZf27e526n73DMPTeCbfTO6j5EfVZBj0X6YDzIfVILTR6NkDFAApx1Nc7p/D1
wdEpN2GJaiJ3intYsBQ4YhPfE44B+UHn4IUjgP5rxNr28o40MCyx52tAgNtLsUgs
9xpFXOWNHXAakkKT1LcE3My0s0fbkFX2G7nUnbXfgB+lXd1STe+OFJyBlRpMcrzd
U8p/s0EbsaY=
=43L/
-----END PGP SIGNATURE-----

--==_Exmh_1418147500_3854P--
