From: SZALAY Attila <sasa@balabit.hu>
Subject: Problem with __check_and_rekey
Date: Tue, 12 Aug 2003 15:20:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812132050.GA27178@mochrul.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi All!

We have found a deadlock in kernel version 2.4.21.

With sysreq we get this call trace:

Trace; c01a9946 <secure_tcp_sequence_number+52/b0>
Trace; c0256cbc <tcp_v4_conn_request+418/4a8>
[...]
Trace; c023e890 <ip_rcv_finish+0/219>
Trace; c022c88b <netif_receive_skb+11b/148>
Trace; c022c939 <process_backlog+81/124>
Trace; c022ca6f <net_rx_action+93/144>
Trace; c011ee3d <do_softirq+7d/dc>
Trace; c010a2eb <do_IRQ+db/ec>
Trace; c01a88e7 <SHATransform+d3/114>
Trace; c01a8b04 <extract_entropy+1dc/328>
Trace; c01a8c6b <get_random_bytes+1b/40>
Trace; c01a98c8 <__check_and_rekey+5c/88>
Trace; c01a9946 <secure_tcp_sequence_number+52/b0>
Trace; c02559cd <tcp_v4_connect+2f9/3fc>
Trace; c026304d <inet_stream_connect+10d/268>
Trace; c0225de7 <sys_connect+5b/78>
Trace; c0262482 <inet_setsockopt+2a/34>

First call of __check_and_rekey locks ip_lock.

But when we harvest entropy, there is an interrupt triggered by an incomi=
ng
packet. Because of the incoming SYN packet we try to generate another
sequence number. Hovewer ip_lock is already locked...

We created this patch to avoid the problem:

--- tcp_ipv4.c~ Tue Jun 24 22:44:52 2003
+++ tcp_ipv4.c  Tue Aug 12 14:21:33 2003
@@ -872,8 +872,10 @@
                        tp->write_seq =3D ip_randomisn();
                else
 #endif
+               local_bh_disable();
                tp->write_seq =3D secure_tcp_sequence_number(sk->saddr, s=
k->daddr,
                                                           sk->sport, usi=
n->sin_port);
+               local_bh_enable();
        }
=20
 #ifdef CONFIG_GRKERNSEC_RANDID

--=20
Szalay Attila                     BalaBit IT Biztons=E1gtechnikai Kft.
tel:(36-1)-371-05-40              1116 Bp. Csurgoi ut 20/b
fax:(36-1)-208-08-75              http://www.balabit.hu/
