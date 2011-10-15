From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Sat, 15 Oct 2011 08:39:35 +0200
Message-ID: <1318660775.2525.29.camel@edumazet-laptop>
References: <1318576791.2533.99.camel@edumazet-laptop>
	 <20111014.034224.1197576516015404466.davem@davemloft.net>
	 <4E985A3F.5080103@hp.com> <4E98B3B4.20406@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59677 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab1JOGjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2011 02:39:43 -0400
Received: by wyg36 with SMTP id 36so719032wyg.19
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 23:39:42 -0700 (PDT)
In-Reply-To: <4E98B3B4.20406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 14 octobre 2011 =C3=A0 15:12 -0700, Rick Jones a =C3=A9crit=
 :

Thanks Rick


> So, a test as above from a system running 2.6.38-11-generic to a syst=
em=20
> running 3.0.0-12-generic.  On the sender we have:
>=20
> raj@tardy:~/netperf2_trunk$ netstat -s > before; src/netperf -H=20
> raj-8510w.americas.hpqcorp.net -t tcp_rr -- -b 256 -D -o=20
> throughput,local_transport_retrans,remote_transport_retrans,lss_size_=
end,rsr_size_end=20
> ; netstat -s > after
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_I=
NET=20
> to internal-host.americas.hpqcorp.net (16.89.245.115) port 0 AF_INET =
:=20
> nodelay : first burst 256
> Throughput,Local Transport Retransmissions,Remote Transport=20
> Retransmissions,Local Send Socket Size Final,Remote Recv Socket Size =
=46inal
> 76752.43,274,0,16384,98304
>=20
> 274 retransmissions at the sender.  The "beforeafter" of that on the =
sender:
>=20
> raj@tardy:~/netperf2_trunk$ cat delta.send

> Tcp:
>      2 active connections openings
>      0 passive connection openings
>      0 failed connection attempts
>      0 connection resets received
>      0 connections established
>      766727 segments received
>      734408 segments send out

>      274 segments retransmited

	Exactly the count of dropped frames because of receiver sk_rmem_alloc =
+
backlog.len hitting receiver sk_rcvbuf

static inline bool sk_rcvqueues_full(const struct sock *sk, const struc=
t sk_buff *skb)
{
        unsigned int qsize =3D sk->sk_backlog.len + atomic_read(&sk->sk=
_rmem_alloc);

        return qsize + skb->truesize > sk->sk_rcvbuf;
}

static inline __must_check int sk_add_backlog(struct sock *sk, struct s=
k_buff *skb)
{
        if (sk_rcvqueues_full(sk, skb))
                return -ENOBUFS;

        __sk_add_backlog(sk, skb);
        sk->sk_backlog.len +=3D skb->truesize;
        return 0;
}

In very old kernels, we had no limit on backlog, so we could queue lot
of extra skbs in it and eventually consume all kernel memory (OOM)

refs : commit c377411f249 (net: sk_add_backlog() take rmem_alloc into
account)
	commit 6b03a53a5ab7 (tcp: use limited socket backlog)

	commit 8eae939f14003 (net: add limit for socket backlog )

Now we enforce a limit, better to chose a correct limit / tcpwindow
combination so that normal trafic doesnt trigger drops at receiver

>      0 bad segments received.
>      0 resets sent
> Udp:
>      7 packets received
>      0 packets to unknown port received.
>      0 packet receive errors
>      7 packets sent
> UdpLite:
> TcpExt:
>      0 packets pruned from receive queue because of socket buffer ove=
rrun
>      0 ICMP packets dropped because they were out-of-window
>      0 TCP sockets finished time wait in fast timer
>      2 delayed acks sent
>      0 delayed acks further delayed because of locked socket
>      Quick ack mode was activated 0 times
>      170856 packets directly queued to recvmsg prequeue.
>      1204 bytes directly in process context from backlog
>      170678 bytes directly received in process context from prequeue
>      592090 packet headers predicted
>      170626 packets header predicted and directly queued to user
>      1375 acknowledgments not containing data payload received
>      174911 predicted acknowledgments
>      150 times recovered from packet loss by selective acknowledgemen=
ts
>      0 congestion windows recovered without slow start by DSACK
>      0 congestion windows recovered without slow start after partial =
ack
>      299 TCP data loss events
>      TCPLostRetransmit: 9
>      0 timeouts after reno fast retransmit
>      0 timeouts after SACK recovery
>      253 fast retransmits
>      14 forward retransmits
>      6 retransmits in slow start
>      0 other TCP timeouts
>      1 SACK retransmits failed
>      0 times receiver scheduled too late for direct processing
>      0 packets collapsed in receive queue due to low socket buffer
>      0 DSACKs sent for old packets
>      0 DSACKs received
>      0 connections reset due to unexpected data
>      0 connections reset due to early user close
>      0 connections aborted due to timeout
>      0 times unabled to send RST due to no memory
>      TCPDSACKIgnoredOld: 0
>      TCPDSACKIgnoredNoUndo: 0
>      TCPSackShifted: 0
>      TCPSackMerged: 1031
>      TCPSackShiftFallback: 240
>      TCPBacklogDrop: 0
>      IPReversePathFilter: 0
> IpExt:
>      InMcastPkts: 0
>      OutMcastPkts: 0
>      InBcastPkts: 1
>      InOctets: -1012182764
>      OutOctets: -1436530450
>      InMcastOctets: 0
>      OutMcastOctets: 0
>      InBcastOctets: 147
>=20
> and then the deltas on the receiver:
>=20
> raj@raj-8510w:~/netperf2_trunk$ cat delta.recv
> Ip:
>      734669 total packets received
>      0 with invalid addresses
>      0 forwarded
>      0 incoming packets discarded
>      734669 incoming packets delivered
>      766696 requests sent out
>      0 dropped because of missing route
> Icmp:
>      0 ICMP messages received
>      0 input ICMP message failed.
>      ICMP input histogram:
>          destination unreachable: 0
>      0 ICMP messages sent
>      0 ICMP messages failed
>      ICMP output histogram:
> IcmpMsg:
>          InType3: 0
> Tcp:
>      0 active connections openings
>      2 passive connection openings
>      0 failed connection attempts
>      0 connection resets received
>      0 connections established
>      734651 segments received
>      766695 segments send out
>      0 segments retransmited
>      0 bad segments received.
>      0 resets sent
> Udp:
>      1 packets received
>      0 packets to unknown port received.
>      0 packet receive errors
>      1 packets sent
> UdpLite:
> TcpExt:
>      28 packets pruned from receive queue because of socket buffer ov=
errun
>      0 delayed acks sent
>      0 delayed acks further delayed because of locked socket
>      19 packets directly queued to recvmsg prequeue.
>      0 bytes directly in process context from backlog
>      667 bytes directly received in process context from prequeue
>      727842 packet headers predicted
>      9 packets header predicted and directly queued to user
>      161 acknowledgments not containing data payload received
>      229704 predicted acknowledgments


>      6774 packets collapsed in receive queue due to low socket buffer
>      TCPBacklogDrop: 276

	Yes, these two counters explain all.

	1) "6774 packets collapsed in receive queue due to low socket buffer"

We spend a _lot_ of cpu time in "collapsing" process : Taking several
skb and build a compound one (using one PAGE and trying to fill all the
available bytes in it with contigous parts).

Doing this work is of course last desperate attempt before the much
painfull :

	2) TCPBacklogDrop: 276

	We plain drop incoming messages because too much kernel memory is used
by the socket.

> IpExt:
>      InMcastPkts: 0
>      OutMcastPkts: 0
>      InBcastPkts: 17
>      OutBcastPkts: 0
>      InOctets: 38973144
>      OutOctets: 40673137
>      InMcastOctets: 0
>      OutMcastOctets: 0
>      InBcastOctets: 1816
>      OutBcastOctets: 0
>=20
> this is an otherwise clean network, no errors reported by ifconfig or=
=20
> ethtool -S, and the packet rate was well within the limits of 1 GbE a=
nd=20
> the ProCurve 2724 switch between the two systems.
>=20
>  From just a very quick look it looks like tcp_v[46]_rcv is called,=20
> finds that the socket is owned by the user, attempts to add to the=20
> backlog, but the path called by sk_add_backlog does not seem to make =
any=20
> attempts to compress things, so when the quantity of data is << the=20
> truesize it starts tossing babies out with the bathwater.
>=20

Rick, could you redo the test, using following bit on receiver :

echo 1 >/proc/sys/net/ipv4/tcp_adv_win_scale

If you still have collapses/retransmits, you then could try :

echo -2 >/proc/sys/net/ipv4/tcp_adv_win_scale

Thanks !
