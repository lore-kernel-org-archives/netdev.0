From: Pau Espin <pau.espin@tessares.net>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 SACK block
Date: Wed, 1 Jun 2016 17:19:40 +0200
Message-ID: <CALCp7m=kVidPi6LkeZ525FxwuZHW1hotzDUyw=nV-zb_E=yacw@mail.gmail.com>
References: <1464694717-22548-1-git-send-email-pau.espin@tessares.net>
	<1464707563.5939.114.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALCp7mkPCFESn1a8mG3v17v5AQgn2m+xcq17PBWRVewABZkBig@mail.gmail.com>
	<CAK6E8=e+cn60PjMAz1B3qk9Z0tnRe4r67HM+CmQPRVg7u_iCoA@mail.gmail.com>
	<9A5E8677-D012-4CEA-87AA-C4B6674A700A@netflix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, mdalal@cisco.com
To: Randall Stewart <rrs@netflix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34535 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758611AbcFAPTm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 11:19:42 -0400
Received: by mail-qg0-f43.google.com with SMTP id p34so39513144qgp.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 08:19:41 -0700 (PDT)
In-Reply-To: <9A5E8677-D012-4CEA-87AA-C4B6674A700A@netflix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, first of all, here you can find the packetdrill test I created to
show up the scenario in which SACK is used and the RST is answered
with a challenge_ack. You will find below too some answers to some
previous comments.

0  socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
+0 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
+0 bind(3, {sa_family =3D AF_INET, sin_port =3D htons(13000), sin_addr =
=3D
inet_addr("192.168.0.1")}, ...) =3D 0
+0 listen(3, 1) =3D 0

+0 < S 0:0(0) win 500 <mss 1460,sackOK,nop,nop,nop,wscale 7> sock(3)
+0 > S. 0:0(0) ack 1 win 29200 <mss 1460,nop,nop,sackOK,nop,wscale 7> s=
ock(3)
+0 < . 1:1(0) ack 1 win 500 sock(3)
+0 accept(3, ..., ...) =3D 4

// First roundtrip of data client->server (upload)
+0 < P. 1:1001(1000) win 500 sock(4)
+0 > . 1:1(0) ack 1001 <...> sock(4)

//In here we would have 2nd packet but it's dropped by net...
// +0 < P. 1001:2001(1000) win 500 sock(4)

// 3nd packet arrives without prev packet being seen. SACK will be used=
=2E
+0 < P. 2001:3001(1000) win 500 sock(4)
+0 > . 1:1(0) ack 1001 <nop,nop,sack 2001:3001>

// RST arrives from client, for instance caused by setsockopt(fd,
SOL_SOCKET, SO_LINGER, ...)
//Challenge ACK is sent back
+0 < R. 3001:3001(0) win 500 sock(4)
+0 > . 1:1(0) ack 1001 <nop,nop,sack 2001:3001>

// To clearly differentiate closing connections around the same time
due to packetdrill finishing
+0 `sleep 20`


On Wed, Jun 1, 2016 at 12:32 PM, Randall Stewart <rrs@netflix.com> wrot=
e:
> Yuchung:
>
> Thanks for adding me in here.. Not sure if Mitesh is still at Cisco o=
r not..
> most of the
> rest of us are *not*. I think Anantha was at NEC last I heard but I h=
ave not
> talked to him in a while :-)
>
> Now there is one thing that Pau is missing here is that while in theo=
ry
> each ACK can only have 4 Sack blocks, that does not mean the
> SACK sender does not have *many* more SACK blocks on his score
> board. The scoreboard is kept until a time-out occurs and you only
> are sending the latest four. So I think the risk is a bit more than
> only 5 sequence numbers depending of course how one is to
> implement this :)
>
> You can implement it with a limit of 4 blocks, but one could
> also implement it based on the total number of sack blocks
> the receiver has..
>
> So in the scenario tcpdumped below, the client is sending
> RST(1240942836) to the server. Presumably the client=E2=80=99s snd_nx=
t
> was set to this after say retransmitting the missing piece. The clien=
t
> therefore (if its anything like BSD) will use the snd_nxt to send in =
the
> reset.. which
> of course would generate a challenge ack which as you say is dropped.
>
> One could take the approach below, and allow N blocks but in this
> scenario you are just luckily that the snd_nxt of the client happens =
to
> be an edge of one of your SACK blocks.
>
Indeed, as Yuchung noticed too, I was wrong from conceptual point of
view thinking the SACKs in the packet were all the SACK blocks which
could be stored. But still, the code patch changing the behavior
(which improved the situation in my scenario) was checking only
against selective_acks (struct tcp_sack_block selective_acks[4];), so
there's no need to check for all the possible SACK blocks in the score
board to improve the situation imho.

I did a quick check  on some of the related code and as far as I
understood, when  a new out of order packet is received, it is checked
(tcp_sack_new_ofo_skb) if it can be added to either rcv_next or any of
the 4 selective_acks blocks of the connection. If that's not possible,
a new one is built and added to the front of the list, shifting
previous ones.

The consequence of that, as far as I understand it, is that most
recently received out of order SEQ numbers are usually stored in the
selective_acks structure, which would act then as a cache for recently
seen SEQ numbers (and next expected seq numbers to receive). As
Randall pointed out, up to now RST are probably sent using snd_nxt, so
my guess is that probability of having a match with the selective_acks
blocks is quite high, as it probed in my test scenario which got a big
improvement.

> Possibly another alternative is to change the client where when sendi=
ng a
> RST
> with a TCB instead of using snd_nxt you could use snd_una. Of course =
that
> could
> also result in a challenge ACK if the receiver has not yet received a
> ACK that is in flight (that was the whole purpose of the challenge ac=
k). I
> think overall
> you will always have this problem i.e. the sender of the RST may not =
know
> precisely
> the state of the receiver.

Indeed, I guess there will still be same problem in other scenarios.
On top of that, it seems a bit weird to me to send a RST packet using
a SEQ number which was already used to send a different packet (that's
what would happen in this case right?).

>
> Your fix happens to work since the receiver happens to have the SACK =
blocks
> in question.. this is fine and if you don=E2=80=99t mind *weakening t=
he security* of
> the
> RST you could do that. I think for stack I am working on for FreeBSD =
I will
> change
> the stack I am working on to recognize the RST going out and use snd_=
una.
>

You mean here you are always going to use snd_una or that you are
going to try to figure out some heuristics to use either snd_next or
snd_una depending on the scenario?

> I don=E2=80=99t like the idea of weakening the security, I know as yo=
u propose below
> its
> just 5 in 2^^32 instead of 1 in 2^^32 but depending on how you implem=
ent it
> you could stretch that to be the number of sack blocks the receiver h=
olds.
>

As stated above, I think it would probably be enough to check for
those 4-5 seq numbers and not for all of them, which would on top not
hit on security that much (but still maybe too much for somebody).

>
> R
>
>
> On Jun 1, 2016, at 1:41 AM, Yuchung Cheng <ycheng@google.com> wrote:
>
> On Tue, May 31, 2016 at 9:50 AM, Pau Espin <pau.espin@tessares.net> w=
rote:
>
>
> Hi, sorry re-sending because I didn't have plain text mode enabled an=
d
> message didn't arrive to the mailing list. Also dropping some mail
> addresses from RFC authors which probed to be unavailable anymore.
>
> The problem is not caused by the host-wide rate limit.
> I analyzed the scenario with tcpdump and I see the challenge ACKs are
> being sent, but due to network conditions sometimes they can be lost.
> On top of that, the RST being sent from the client to the server afte=
r
> receiving the challenge ACK can also sometimes be lost. I even found
> the client/router had a problem with iptables setup and was actually
> not sending back RST for incoming TCP packets without an existing
> connection established (should be the one already closed before with
> the first RST sent by the client and which originated the challenge
> ACK).
>
> In my test scenario I'm using MultiPathTCP and I'm recreating (destro=
y
> with RST, then create with SYN)  the subflow on one of the interfaces
> every aprox 5 seconds while uploading a big file. Due to network
> conditions and/or router stopping the RSTs, after less than 5 min, I
> have more than 32 subflow connections created for that MPTCP
> connection, which is the hardcoded maximum, and from that point I'm
> unable to create/use new subflows until some of them are closed, whic=
h
> can take quite a lot of time. After this patch is applied, the number
> of subflows is kind of stable at 4-5 subflows during the whole upload=
=2E
> It's still not 2 (one permanent in iface1 and the recreated one in
> iface2) because sometimes due to network problems the packet before
> the RST is lost and thus the RST which arrives is not equal to next
> expected seq number from the right edge of the SACK block. But still,
> it makes the situation quite better, specially from user point of
> view.
>
> Here's an example of the issue without my patch (challenge ACK is sen=
t
> although the RST is in current place). It shows server acknowledging
> data with SACK in first line. Then, on 2nd line, client decides to
> terminate the connexion and uses his next SEQ number available. On 3r=
d
> line, server answers with the challenge ACK. Then no answer comes fro=
m
> that challenge ack and the TCP conn is left opened.
>
> 14202    73.086360    10.0.4.2    443    10.67.15.100    53755    TCP
>  94    [TCP Dup ACK 14192#4] 443=E2=86=9253755 [ACK] Seq=3D3551806992
> Ack=3D1240653972 Win=3D1573120 Len=3D0 TSval=3D4022818 TSecr=3D110678=
9
> SLE=3D1240836636 SRE=3D1240942836 SLE=3D1240770084 SRE=3D1240835220
> 14203    73.086363    10.67.15.100    53755    10.0.4.2    443    TCP
>  74    53755=E2=86=92443 [RST, ACK] Seq=3D1240942836 Ack=3D3551806992=
 Win=3D90240
> Len=3D0 TSval=3D1106847 TSecr=3D4022536
> 14204    73.086368    10.0.4.2    443    10.67.15.100    53755    TCP
>  94    [TCP Dup ACK 14192#5] 443=E2=86=9253755 [ACK] Seq=3D3551806992
> Ack=3D1240653972 Win=3D1573120 Len=3D0 TSval=3D4022818 TSecr=3D110678=
9
> SLE=3D1240836636 SRE=3D1240942836 SLE=3D1240770084 SRE=3D1240835220
>
> So, the main point in here is trying to improve the situation to clos=
e
> the connections and free resources in some specific cases without
> actually going pre RFC5961 state. That would mean when a RST is
> received, up to 4-5 SEQs are checked to match instead of 1.
>
> I didn't contact the authors of the RFC. I CC them in this e-mail. I
> hope that's the right thing to do in this case and that they don't
> mind it in case they want to follow the topic.
>
> I will have a look at packetdrill to try to reproduce it somehow ther=
e.
>
> On Tue, May 31, 2016 at 5:12 PM, Eric Dumazet <eric.dumazet@gmail.com=
>
> wrote:
>
> On Tue, 2016-05-31 at 13:38 +0200, Pau Espin Pedrol wrote:
>
> RFC 5961 advises to only accept RST packets containing a seq number
> matching the next expected seq number instead of the whole receive
> window in order to avoid spoofing attacks.
>
> However, this situation is not optimal in the case SACK is in use at =
the
> time the RST is sent. I recently run into a scenario in which packet
> losses were high while uploading data to a server, and userspace was
> willing to frequently terminate connections by sending a RST. In
> this case, the ACK sent on the receiver side is frozen waiting for a =
lost
> packet retransmission and a SACK block is used to let the client
> continue uploading data. At some point later on, the client sends the
> RST, which matches the next expected seq number of the SACK block on =
the
> receiver side which is going forward receiving data.
>
> In this scenario, as RFC 5961 defines, the SEQ doesn't match the froz=
en
> main ACK at receiver side and thus gets dropped and a challenge ACK i=
s
> sent, which gets usually lost due to network conditions. The main
> consequence is that the connection stays alive for a while even if it
> made sense to accept the RST. This can get really bad if lots of
> connections like this one are created in few seconds, allocating all =
the
> resources of the server easily.
>
> From security point of view: the maximum number of SACK blocks for a =
TCP
> connection is limited to 4 due to options field maximum length, and t=
hat
>
> This is not true. The maximum number of SACK blocks for a TCP "packet=
"
> is limited to 4. But a TCP connection can keep an arbitrary amount of
> SACK blocks.
>
> means we match at maximum against 5 seq numbers, which should make it
> still difficult for attackers to inject a valid RST message.
>
> This patch was tested in a 3.18 kernel and probed to improve the
> situation in the scenario described above.
>
> Signed-off-by: Pau Espin Pedrol <pau.espin@tessares.net>
> ---
> net/ipv4/tcp_input.c | 18 +++++++++++++++++-
> 1 file changed, 17 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index d6c8f4cd0..4727dc8 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -5159,6 +5159,7 @@ static bool tcp_validate_incoming(struct sock *=
sk,
> struct sk_buff *skb,
>                                const struct tcphdr *th, int syn_inerr=
)
> {
>      struct tcp_sock *tp =3D tcp_sk(sk);
> +     bool rst_seq_match =3D false;
>
>      /* RFC1323: H1. Apply PAWS check first. */
>      if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp=
 &&
> @@ -5195,13 +5196,28 @@ static bool tcp_validate_incoming(struct sock=
 *sk,
> struct sk_buff *skb,
>
>      /* Step 2: check RST bit */
>      if (th->rst) {
> -             /* RFC 5961 3.2 :
> +             /* RFC 5961 3.2 (extended to match against SACK too if
> available):
>               * If sequence number exactly matches RCV.NXT, then
>               *     RESET the connection
>               * else
>               *     Send a challenge ACK
>               */
>              if (TCP_SKB_CB(skb)->seq =3D=3D tp->rcv_nxt)
> +                     rst_seq_match =3D true;
> +             else if (tcp_is_sack(tp)) {
> +                     int this_sack;
> +                     struct tcp_sack_block *sp =3D tp->rx_opt.dsack =
?
> +                                     tp->duplicate_sack :
> tp->selective_acks;
> +
> +                     for (this_sack =3D 0; this_sack < tp->rx_opt.nu=
m_sacks;
> ++this_sack) {
> +                             if (TCP_SKB_CB(skb)->seq =3D=3D
> sp[this_sack].end_seq) {
> +                                     rst_seq_match =3D true;
> +                                     break;
> +                             }
> +                     }
> +             }
> +
> +             if (rst_seq_match)
>                      tcp_reset(sk);
>              else
>                      tcp_send_challenge_ack(sk, skb);
> --
> 2.5.0
>
>
> It looks like you want to seriously relax RFC 5961 ...
>
> Could you have a problem because of the host-wide RFC 5961 rate limit=
 ?
>
> Have you contacted RFC authors ?
>
> If the peer sends the RST, presumably it should answer to the challen=
ge
> ACK right away, since it does not care of the SACK blocks anymore.
>
> A packetdrill test demonstrating the issue would be nice.
>
> Thanks.
>
>
>
>
>
>
> --
> Pau Espin Pedrol | R&D Engineer - External
> pau.espin@tessares.net | +32 487 43 36 50
> Tessares SA | Hybrid Access Solutions
> www.tessares.net
> 6 Rue Louis de Geer, 1348 Louvain-la-Neuve, Belgium
>
> --
>
> ------------------------------
> DISCLAIMER.
> This email and any files transmitted with it are confidential and int=
ended
> solely for the use of the individual or entity to whom they are addre=
ssed.
> If you have received this email in error please notify the system man=
ager.
> This message contains confidential information and is intended only f=
or the
> individual named. If you are not the named addressee you should not
> disseminate, distribute or copy this e-mail. Please notify the sender
> immediately by e-mail if you have received this e-mail by mistake and
> delete this e-mail from your system. If you are not the intended reci=
pient
> you are notified that disclosing, copying, distributing or taking any
> action in reliance on the contents of this information is strictly
> prohibited.
>
>
> --------
> Randall Stewart
> rrs@netflix.com
> 803-317-4952
>
>
>
>
>



--=20
Pau Espin Pedrol | R&D Engineer - External
pau.espin@tessares.net | +32 487 43 36 50
Tessares SA | Hybrid Access Solutions
www.tessares.net
6 Rue Louis de Geer, 1348 Louvain-la-Neuve, Belgium

--=20

------------------------------
DISCLAIMER.
This email and any files transmitted with it are confidential and inten=
ded=20
solely for the use of the individual or entity to whom they are address=
ed.=20
If you have received this email in error please notify the system manag=
er.=20
This message contains confidential information and is intended only for=
 the=20
individual named. If you are not the named addressee you should not=20
disseminate, distribute or copy this e-mail. Please notify the sender=20
immediately by e-mail if you have received this e-mail by mistake and=20
delete this e-mail from your system. If you are not the intended recipi=
ent=20
you are notified that disclosing, copying, distributing or taking any=20
action in reliance on the contents of this information is strictly=20
prohibited.
