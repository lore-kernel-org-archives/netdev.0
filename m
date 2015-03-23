From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp_v4_err/request sock refcnt leak?
Date: Mon, 23 Mar 2015 07:11:57 -0700
Message-ID: <1427119917.25985.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150323090317.GB8934@haze> <550FEA98.3040009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:36308 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbCWOL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 10:11:59 -0400
Received: by pdbcz9 with SMTP id cz9so188725674pdb.3
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 07:11:59 -0700 (PDT)
In-Reply-To: <550FEA98.3040009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-23 at 18:27 +0800, Fan Du wrote:
> =E4=BA=8E 2015=E5=B9=B403=E6=9C=8823=E6=97=A5 17:03, Erik Hugne =E5=86=
=99=E9=81=93:
> > I'm hitting this warning on latest net-next when i try to SSH into =
a machine
> > with eth0 added to a bridge (but i think the problem is older than =
that)
> >
> > Steps to reproduce:
> > node2 ~ # brctl addif br0 eth0
> > [  223.758785] device eth0 entered promiscuous mode
> > node2 ~ # ip link set br0 up
> > [  244.503614] br0: port 1(eth0) entered forwarding state
> > [  244.505108] br0: port 1(eth0) entered forwarding state
> > node2 ~ # [  251.160159] ------------[ cut here ]------------
> > [  251.160831] WARNING: CPU: 0 PID: 3 at include/net/request_sock.h=
:102 tcp_v4_err+0x6b1/0x720()
> > [  251.162077] Modules linked in:
> > [  251.162496] CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted 4.0.0-rc=
3+ #18
> > [  251.163334] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> > [  251.164078]  ffffffff81a8365c ffff880038a6ba18 ffffffff8162ace4 =
0000000000009898
> > [  251.165084]  0000000000000000 ffff880038a6ba58 ffffffff8104da85 =
ffff88003fa437c0
> > [  251.166195]  ffff88003fa437c0 ffff88003fa74e00 ffff88003fa43bb8 =
ffff88003fad99a0
> > [  251.167203] Call Trace:
> > [  251.167533]  [<ffffffff8162ace4>] dump_stack+0x45/0x57
> > [  251.168206]  [<ffffffff8104da85>] warn_slowpath_common+0x85/0xc0
> > [  251.169239]  [<ffffffff8104db65>] warn_slowpath_null+0x15/0x20
> > [  251.170271]  [<ffffffff81559d51>] tcp_v4_err+0x6b1/0x720
> > [  251.171408]  [<ffffffff81630d03>] ? _raw_read_lock_irq+0x3/0x10
> > [  251.172589]  [<ffffffff81534e20>] ? inet_del_offload+0x40/0x40
> > [  251.173366]  [<ffffffff81569295>] icmp_socket_deliver+0x65/0xb0
> > [  251.174134]  [<ffffffff815693a2>] icmp_unreach+0xc2/0x280
> > [  251.174820]  [<ffffffff8156a82d>] icmp_rcv+0x2bd/0x3a0
> > [  251.175473]  [<ffffffff81534ea2>] ip_local_deliver_finish+0x82/0=
x1e0
> > [  251.176282]  [<ffffffff815354d8>] ip_local_deliver+0x88/0x90
> > [  251.177004]  [<ffffffff815350f0>] ip_rcv_finish+0xf0/0x310
> > [  251.177693]  [<ffffffff815357bc>] ip_rcv+0x2dc/0x390
> > [  251.178336]  [<ffffffff814f5da3>] __netif_receive_skb_core+0x713=
/0xa20
> > [  251.179170]  [<ffffffff814f7fca>] __netif_receive_skb+0x1a/0x80
> > [  251.179922]  [<ffffffff814f97d4>] process_backlog+0x94/0x120
> > [  251.180639]  [<ffffffff814f9612>] net_rx_action+0x1e2/0x310
> > [  251.181356]  [<ffffffff81051267>] __do_softirq+0xa7/0x290
> > [  251.182046]  [<ffffffff81051469>] run_ksoftirqd+0x19/0x30
> > [  251.182726]  [<ffffffff8106cc23>] smpboot_thread_fn+0x153/0x1d0
> > [  251.183485]  [<ffffffff8106cad0>] ? SyS_setgroups+0x130/0x130
> > [  251.184228]  [<ffffffff8106935e>] kthread+0xee/0x110
> > [  251.184871]  [<ffffffff81069270>] ? kthread_create_on_node+0x1b0=
/0x1b0
> > [  251.185690]  [<ffffffff81631108>] ret_from_fork+0x58/0x90
> > [  251.186385]  [<ffffffff81069270>] ? kthread_create_on_node+0x1b0=
/0x1b0
> > [  251.187216] ---[ end trace c947fc7b24e42ea1 ]---
> > [  259.542268] br0: port 1(eth0) entered forwarding state
>=20
>=20
> I'm not familiar with this part, IMHO, this might be a double call fo=
r reqsk_put?

It is yes.

I got confused because reqsk_timer_handler() _has_ to call
reqsk_put(req) after calling inet_csk_reqsk_queue_drop(), because
the timer holds a reference on req.

Would you like to send the official patch, mentioning :

=46ixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener time=
r")

Thanks !
