From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: tcp_v4_err/request sock refcnt leak?
Date: Mon, 23 Mar 2015 18:27:36 +0800
Message-ID: <550FEA98.3040009@gmail.com>
References: <20150323090317.GB8934@haze>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36090 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbCWKdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 06:33:06 -0400
Received: by padcy3 with SMTP id cy3so187597376pad.3
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 03:33:06 -0700 (PDT)
In-Reply-To: <20150323090317.GB8934@haze>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B403=E6=9C=8823=E6=97=A5 17:03, Erik Hugne =E5=86=99=
=E9=81=93:
> I'm hitting this warning on latest net-next when i try to SSH into a =
machine
> with eth0 added to a bridge (but i think the problem is older than th=
at)
>
> Steps to reproduce:
> node2 ~ # brctl addif br0 eth0
> [  223.758785] device eth0 entered promiscuous mode
> node2 ~ # ip link set br0 up
> [  244.503614] br0: port 1(eth0) entered forwarding state
> [  244.505108] br0: port 1(eth0) entered forwarding state
> node2 ~ # [  251.160159] ------------[ cut here ]------------
> [  251.160831] WARNING: CPU: 0 PID: 3 at include/net/request_sock.h:1=
02 tcp_v4_err+0x6b1/0x720()
> [  251.162077] Modules linked in:
> [  251.162496] CPU: 0 PID: 3 Comm: ksoftirqd/0 Not tainted 4.0.0-rc3+=
 #18
> [  251.163334] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> [  251.164078]  ffffffff81a8365c ffff880038a6ba18 ffffffff8162ace4 00=
00000000009898
> [  251.165084]  0000000000000000 ffff880038a6ba58 ffffffff8104da85 ff=
ff88003fa437c0
> [  251.166195]  ffff88003fa437c0 ffff88003fa74e00 ffff88003fa43bb8 ff=
ff88003fad99a0
> [  251.167203] Call Trace:
> [  251.167533]  [<ffffffff8162ace4>] dump_stack+0x45/0x57
> [  251.168206]  [<ffffffff8104da85>] warn_slowpath_common+0x85/0xc0
> [  251.169239]  [<ffffffff8104db65>] warn_slowpath_null+0x15/0x20
> [  251.170271]  [<ffffffff81559d51>] tcp_v4_err+0x6b1/0x720
> [  251.171408]  [<ffffffff81630d03>] ? _raw_read_lock_irq+0x3/0x10
> [  251.172589]  [<ffffffff81534e20>] ? inet_del_offload+0x40/0x40
> [  251.173366]  [<ffffffff81569295>] icmp_socket_deliver+0x65/0xb0
> [  251.174134]  [<ffffffff815693a2>] icmp_unreach+0xc2/0x280
> [  251.174820]  [<ffffffff8156a82d>] icmp_rcv+0x2bd/0x3a0
> [  251.175473]  [<ffffffff81534ea2>] ip_local_deliver_finish+0x82/0x1=
e0
> [  251.176282]  [<ffffffff815354d8>] ip_local_deliver+0x88/0x90
> [  251.177004]  [<ffffffff815350f0>] ip_rcv_finish+0xf0/0x310
> [  251.177693]  [<ffffffff815357bc>] ip_rcv+0x2dc/0x390
> [  251.178336]  [<ffffffff814f5da3>] __netif_receive_skb_core+0x713/0=
xa20
> [  251.179170]  [<ffffffff814f7fca>] __netif_receive_skb+0x1a/0x80
> [  251.179922]  [<ffffffff814f97d4>] process_backlog+0x94/0x120
> [  251.180639]  [<ffffffff814f9612>] net_rx_action+0x1e2/0x310
> [  251.181356]  [<ffffffff81051267>] __do_softirq+0xa7/0x290
> [  251.182046]  [<ffffffff81051469>] run_ksoftirqd+0x19/0x30
> [  251.182726]  [<ffffffff8106cc23>] smpboot_thread_fn+0x153/0x1d0
> [  251.183485]  [<ffffffff8106cad0>] ? SyS_setgroups+0x130/0x130
> [  251.184228]  [<ffffffff8106935e>] kthread+0xee/0x110
> [  251.184871]  [<ffffffff81069270>] ? kthread_create_on_node+0x1b0/0=
x1b0
> [  251.185690]  [<ffffffff81631108>] ret_from_fork+0x58/0x90
> [  251.186385]  [<ffffffff81069270>] ? kthread_create_on_node+0x1b0/0=
x1b0
> [  251.187216] ---[ end trace c947fc7b24e42ea1 ]---
> [  259.542268] br0: port 1(eth0) entered forwarding state


I'm not familiar with this part, IMHO, this might be a double call for =
reqsk_put?


diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 25a9615..fd805c0 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -316,7 +316,6 @@ static void dccp_v4_err(struct sk_buff *skb, u32 in=
fo)
  		 * errors returned from accept().
  		 */
  		inet_csk_reqsk_queue_drop(sk, req);
-		reqsk_put(req);
  		goto out;

  	case DCCP_REQUESTING:
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 69d8f13..5137ab3 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -174,7 +174,6 @@ static void dccp_v6_err(struct sk_buff *skb, struct=
 inet6_skb_parm *opt,
  		}

  		inet_csk_reqsk_queue_drop(sk, req);
-		reqsk_put(req);
  		goto out;

  	case DCCP_REQUESTING:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5554b8f..b1eaf3d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -487,7 +487,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
  		 */
  		inet_csk_reqsk_queue_drop(sk, req);
  		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
-		reqsk_put(req);
  		goto out;

  	case TCP_SYN_SENT:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6e3f90d..1d551fa 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -427,7 +427,6 @@ static void tcp_v6_err(struct sk_buff *skb, struct =
inet6_skb_parm *opt,

  		inet_csk_reqsk_queue_drop(sk, req);
  		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
-		reqsk_put(req);
  		goto out;

  	case TCP_SYN_SENT:










>
> node2 ~ # ethtool -i eth0
> driver: virtio_net
> version: 1.0.0
> firmware-version:
> bus-info: 0000:00:03.0
> supports-statistics: no
> supports-test: no
> supports-eeprom-access: no
> supports-register-dump: no
> supports-priv-flags: no
>
>
> Networking seems to recover after i remove eth0 from the bridge.
>
> //E
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--=20
=E5=A4=A9=E4=B8=8B=E8=8B=B1=E9=9B=84=E5=87=BA=E6=88=91=E8=BE=88=EF=BC=8C=
=E4=B8=80=E5=85=A5=E6=B1=9F=E6=B9=96=E5=B2=81=E6=9C=88=E5=82=AC=E3=80=82
=E9=B8=BF=E5=9B=BE=E9=9C=B8=E4=B8=9A=E8=B0=88=E7=AC=91=E9=97=B4=EF=BC=8C=
=E4=B8=8D=E8=83=9C=E4=BA=BA=E7=94=9F=E4=B8=80=E5=9C=BA=E9=86=89=E3=80=82
