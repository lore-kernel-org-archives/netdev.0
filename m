From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: net-next/unix: BUG: using smp_processor_id() in preemptible
Date: Sun, 23 Nov 2008 04:32:30 +0100
Message-ID: <4928CECE.602@cosmosbay.com>
References: <Pine.LNX.4.64.0811221634370.10534@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060202060206070107090102"
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:33061 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755384AbYKWDcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 22:32:39 -0500
In-Reply-To: <Pine.LNX.4.64.0811221634370.10534@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060202060206070107090102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Ilpo J=E4rvinen a =E9crit :
> I got plenty of these from sock_prot_inuse_add:
>=20
> BUG: using smp_processor_id() in preemptible [00000000] code: rcS/1146
>=20
> caller is sock_prot_inuse_add+0x24/0x42
> Pid: 1146, comm: rcS Not tainted 2.6.28-rc6-01121-g89a2f15 #76
> Call Trace:
>  [<ffffffff80365767>] debug_smp_processor_id+0xd3/0xe8
>  [<ffffffff80485a0f>] sock_prot_inuse_add+0x24/0x42
>  [<ffffffff80514cdd>] unix_create1+0x161/0x176
>  [<ffffffff80514d52>] unix_create+0x60/0x6b
>  [<ffffffff80483f66>] __sock_create+0x144/0x1bd
>  [<ffffffff80483edb>] ? __sock_create+0xb9/0x1bd
>  [<ffffffff8048402d>] sock_create+0x2d/0x2f
>  [<ffffffff80484274>] sys_socket+0x29/0x5b
>  [<ffffffff8020c10a>] system_call_fastpath+0x16/0x1b
>=20
>=20

Thanks Ilpo for this report

I guess the following is necessary.

Once Christopher and Rusty work on percpu variables is finished,
the preempt_enable()/disable() wont be necessary anymore, so
its a temporary workaround anyway.

[PATCH] net: make sock_prot_inuse_add() preempt safe

Ilpo J=E4rvinen reported that commit a8076d8db98de6da61394b2e942320e46126=
43ac
(net: af_unix should update its inuse counter) was triggering
a warning in smp_processor_id(), being called in a preemptible code.

Fix is to make sock_prot_inuse_add() safe in this regard. This fix
can be reverted when new percpu infrastructure is ready, allowing
a cpu to safely do a increment/decrement on a percpu var.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------060202060206070107090102
Content-Type: text/plain;
 name="prot_inuse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="prot_inuse.patch"

diff --git a/net/core/sock.c b/net/core/sock.c
index a4e840e..d4f5ad7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1942,8 +1942,8 @@ static DECLARE_BITMAP(proto_inuse_idx, PROTO_INUSE_NR);
 #ifdef CONFIG_NET_NS
 void sock_prot_inuse_add(struct net *net, struct proto *prot, int val)
 {
-	int cpu = smp_processor_id();
-	per_cpu_ptr(net->core.inuse, cpu)->val[prot->inuse_idx] += val;
+	per_cpu_ptr(net->core.inuse, get_cpu())->val[prot->inuse_idx] += val;
+	put_cpu();
 }
 EXPORT_SYMBOL_GPL(sock_prot_inuse_add);
 
@@ -1989,7 +1989,9 @@ static DEFINE_PER_CPU(struct prot_inuse, prot_inuse);
 
 void sock_prot_inuse_add(struct net *net, struct proto *prot, int val)
 {
+	preempt_disable();
 	__get_cpu_var(prot_inuse).val[prot->inuse_idx] += val;
+	preempt_enable();
 }
 EXPORT_SYMBOL_GPL(sock_prot_inuse_add);
 

--------------060202060206070107090102--
