From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 12:40:11 +0200
Message-ID: <4AD84D8B.5020103@gmail.com>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <20091016050310.GA5574@1wt.eu> <Pine.LNX.4.58.0910161137490.3886@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50318 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877AbZJPKl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 06:41:29 -0400
In-Reply-To: <Pine.LNX.4.58.0910161137490.3886@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov a =E9crit :
> 	Hello,
>=20
> On Fri, 16 Oct 2009, Willy Tarreau wrote:
>=20
>>> 	This will need little change in inet_csk_reqsk_queue_prune()
>>> but it saves SYN-ACK traffic during deferring period in the
>>> common case when client sends ACK. If such compromise is
>>> acceptable I can prepare and test some patch.
>> I would personally like this a lot ! This will satisfy people who
>> expect it to establish at the end of the "TCP_DEFER_ACCEPT delay"
>> as can be interpreted from the man page, will reduce the number of
>> useless SYN-ACKs that annoy other people while still making no
>> visible change for anyone who would rely on the current behaviour.
>=20
> 	OK, I don't have much time now, this is what I'm
> going to test later today and later can provide proper comments:
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

I tested both patches and they perform very well, thank you !

=46or the minimum 1 sec value, tcpdump looks like :
12:32:03.850456 IP 127.0.0.1.20000 > 127.0.0.1.2222: S 1879889239:18798=
89239(0) win 32792 <mss 16396,nop,nop,timestamp 952803 0,nop,wscale 6>
12:32:03.850463 IP 127.0.0.1.2222 > 127.0.0.1.20000: S 1890330616:18903=
30616(0) ack 1879889240 win 32768 <mss 16396,nop,nop,timestamp 952803 9=
52803,nop,wscale 6>
12:32:03.850469 IP 127.0.0.1.20000 > 127.0.0.1.2222: . ack 1 win 513 <n=
op,nop,timestamp 952803 952803>

12:32:06.849989 IP 127.0.0.1.2222 > 127.0.0.1.20000: S 1890330616:18903=
30616(0) ack 1879889240 win 32768 <mss 16396,nop,nop,timestamp 955803 9=
52803,nop,wscale 6>
12:32:06.849996 IP 127.0.0.1.20000 > 127.0.0.1.2222: . ack 1 win 513 <n=
op,nop,timestamp 955803 955803>

So listening application gets the accept() 3 seconds after initial SYN


# ss -emoian | grep SYN-RECV
SYN-RECV   0      0                 127.0.0.1:2222             127.0.0.=
1:20000  timer:(on,24sec,4) ino:0 sk:f6f0ec80

I wonder if tcp_diag should be extented a bit to reflect fact that the =
ACK was received from client
(ie forward the inet_rsk(req)->acked information to idiag_rqueue)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index cb73fde..c172bd4 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -589,7 +589,7 @@ static int inet_diag_fill_req(struct sk_buff *skb, =
struct sock *sk,
 	r->id.idiag_src[0] =3D ireq->loc_addr;
 	r->id.idiag_dst[0] =3D ireq->rmt_addr;
 	r->idiag_expires =3D jiffies_to_msecs(tmo);
- 	r->idiag_rqueue =3D 0;
+	r->idiag_rqueue =3D ireq->acked;
 	r->idiag_wqueue =3D 0;
 	r->idiag_uid =3D sock_i_uid(sk);
 	r->idiag_inode =3D 0;



->=20
# ss -emoian | grep SYN-RECV
SYN-RECV   1      0                 127.0.0.1:2222             127.0.0.=
1:20000  timer:(on,24sec,4) ino:0 sk:f6f0ec80

