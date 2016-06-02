From: Pau Espin <pau.espin@tessares.net>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 SACK block
Date: Thu, 2 Jun 2016 19:05:12 +0200
Message-ID: <CALCp7mmd+XbFsYBnUG-U54J5LaKTDhYBeZQiSt+aVUYDN9y6ug@mail.gmail.com>
References: <1464694717-22548-1-git-send-email-pau.espin@tessares.net>
	<1464707563.5939.114.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALCp7mkPCFESn1a8mG3v17v5AQgn2m+xcq17PBWRVewABZkBig@mail.gmail.com>
	<CAK6E8=e+cn60PjMAz1B3qk9Z0tnRe4r67HM+CmQPRVg7u_iCoA@mail.gmail.com>
	<9A5E8677-D012-4CEA-87AA-C4B6674A700A@netflix.com>
	<CALCp7m=kVidPi6LkeZ525FxwuZHW1hotzDUyw=nV-zb_E=yacw@mail.gmail.com>
	<3C9243BB-8A7C-40CA-A3C8-16B40084C87C@netflix.com>
	<CALCp7mnpbUHK45GmHPOGn6-qroQpm1dCK4apceVbkjbrsF63mQ@mail.gmail.com>
	<B4ACE4BD-4ACC-42C5-8B94-728D15777CA5@netflix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, mdalal@cisco.com
To: Randall Stewart <rrs@netflix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:33738 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161147AbcFBRFO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 13:05:14 -0400
Received: by mail-qk0-f180.google.com with SMTP id n63so40688395qkf.0
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 10:05:14 -0700 (PDT)
In-Reply-To: <B4ACE4BD-4ACC-42C5-8B94-728D15777CA5@netflix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 2, 2016 at 3:14 PM, Randall Stewart <rrs@netflix.com> wrote=
:
>
> Pau:
>
> Hopefully me setting the =E2=80=9Cplain text=E2=80=9D in my Mac-Mail =
preferences will make this
> plain text :-)
>
>
> >>
> >>
> >> Well yes the probability is increased but definitely not assured :=
-)
> >> Your scenario is specific to a very high loss path. Which is why
> >> the challenge ack is lost...
> >>
> >
> > Correct. But still an improvement in this particular situation with
> > the only drawback of checking against 5 (4+1) SEQ numbers instead o=
f
> > 1.
> >
> >
> >>
> >>
> >> Possibly another alternative is to change the client where when se=
nding a
> >> RST
> >> with a TCB instead of using snd_nxt you could use snd_una. Of cour=
se that
> >> could
> >> also result in a challenge ACK if the receiver has not yet receive=
d a
> >> ACK that is in flight (that was the whole purpose of the challenge=
 ack). I
> >> think overall
> >> you will always have this problem i.e. the sender of the RST may n=
ot know
> >> precisely
> >> the state of the receiver.
> >>
> >>
> >> Indeed, I guess there will still be same problem in other scenario=
s.
> >> On top of that, it seems a bit weird to me to send a RST packet us=
ing
> >> a SEQ number which was already used to send a different packet (th=
at's
> >> what would happen in this case right?).
> >>
> >>
> >> Why the trick here is you want to RST the connection. You need to =
use
> >> a seq number that is valid.. the seq numbers once a RST is being s=
ent
> >> mean nothing the app will get the same thing.
> >>
> >> In fact snd_nxt in the scenario above is *also* a re-used sequence=
 number.
> >> You
> >> retransmitted from snd_una for one segment, snd_nxt got left 1 seg=
ment up,
> >> so
> >> when you sent the RST it would be snd_nxt which was previously a d=
ata
> >> segment being marked with RST.
> >>
> >> If you wanted to assure that no other segment had been sent with t=
hat
> >> sequence you would have to put snd_max as the value, but of course
> >> that *would* return a challenge ack for sure.
> >>
> >> The trick here is you are trying to =E2=80=9Cguess=E2=80=9D where =
the peer is. The only
> >> thing you know for sure is snd_una. Anything else in flight won=E2=
=80=99t  reset
> >> the peer. In fact in your scenario if you had sent snd_una instead=
 of
> >> snd_nxt it would have worked. If you changed the sender to use
> >> snd_una then it would be interesting to see if that also gave you
> >> similar results...
> >>
> >>
> >>
> >>
> >> Your fix happens to work since the receiver happens to have the SA=
CK blocks
> >> in question.. this is fine and if you don=E2=80=99t mind *weakenin=
g the security* of
> >> the
> >> RST you could do that. I think for stack I am working on for FreeB=
SD I will
> >> change
> >> the stack I am working on to recognize the RST going out and use s=
nd_una.
> >>
> >>
> >> You mean here you are always going to use snd_una or that you are
> >> going to try to figure out some heuristics to use either snd_next =
or
> >> snd_una depending on the scenario?
> >>
> >>
> >> For this scenario I will always use snd_una I am not sure you can =
reliably
> >> develop any heuristics to tell you to use snd_una/snd_nxt or some =
other
> >> block that as been sent :-)
> >>
> >> snd_una is actually the most actuate as to what you know at the ti=
me not
> >> snd_nxt. I am sure using snd_nxt is a hold over from before the RF=
C got
> >> implemented.
> >>
> >
> > As, as far as I understand now, it could be useful to improve the
> > situation in the sender too by checking if we recently received SAC=
K
> > blocks from the receiver and in that case sending the RST using
> > snd_una instead of snd_nxt because in that case we will almost sure=
ly
> > receive a challenge_ack if we use snd_nxt as SEQ for the RST.
> >
>
> Checking the scoreboard and using snd_una instead of snd_nxt
> might help things.
>
> > On the other hand, using  always snd_una as SEQ for the RST would
> > cause other (even more usual) cases to be discarded or answered wit=
h a
> > challenge ACK which are accepted right now. I'm thinking for instan=
ce
> > any case in which you send packets (so in flight packets
> > sender->receiver) just before the RST is sent (with the snd_una).
> > Packets are received by the receiver and RCV_NXT is updated and the=
n
> > you receive the RST which is < than RCV_NXT just updated. Am I miss=
ing
> > something? Please correct me if I'm wrong.
> >
>
> I think if packets are in flight either way you are taking a gamble o=
n what
> you are sending, snd_nxt/snd_una and snd_max.
>
> If you are idle and send a RST then those should all be the same and
> you will win :)
>
> snd_nxt will be questionable if you are in the middle of retransmitti=
ng (your case)
> since you really don=E2=80=99t know where it is.
>
> I do like your idea of using the scoreboard to tell if you need to us=
e
> snd_una or snd_nxt. In theory if the scoreboard is empty using
> snd_nxt should be the equivalent to using snd_max.. but if they
> are not equal then you are doing a retransmit and it becomes a crap
> shoot what you should use here.
>
> All of this IMO is only relevant if you are having high packet loss. =
If that
> is not the case having to go through a challenge ack to remove a TCB
> does not hurt anything.
>
> > Even in my case (SACK on), I guess it could even happen that due to
> > fast retransmit the first unacked packet (snd_una) is sent and then
> > the sender also sends the RST, and the receiver received the data
> > packet, updates RCV_NXT and the RST packet is discarded.
>
> And the challenge ack is sent back.
>
No, it's not, that why I think so far using snd_una is probably not a
better idea than using snd_nxt. Becasue you still have the same
problems (sometimes the RST is not accepted), plus sometimes, on top
of that, the receiver doesn't send  a challenge_ack or a dupack.

If I understood snd_una correctly, it can happen if sender sends a
packet, and before receiving the ACK for it (which was already
processed by the receiver), it sends a RST.

I use this packetdrill test to emulate the scenario:

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

//In here we assume the case in which 1 packet is sent and then the
RST (using snd_una) is generated before seeing the ACK which is in
flight from receiver->sender:
+0 < P. 1001:2001(1000) win 500 sock(4)
+0 > . 1:1(0) ack 2001 <...>
+0 < R. 1001:1001(0) win 500 sock(4)
// No extra ACK after the RST is generated

// To clearly differentiate closing connections around the same time
due to packetdrill finishing
+0 `sleep 10`

That's basically because it fails in a prior check to the SEQ=3D=3DRCV_=
NXT
in the receiver.
The check is actually:
if (!tcp_sequence(tp, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq)) =
{

then, inside the if, as the packet is a RST, it is discarded without
sending any packet back.
The fail inside tcp_sequence is because this condition is true:
"before(end_seq, tp->rcv_wup)"

That's the case in which 1 packets before the RST has been already
acked but it didn't arrive yet to the client when it decided to reset
the connection. I guess it can be quite a common scenario.

Maybe the logic in BSD-alike hosts is different, I don't know.

> >
> > So, as a summary I think we should still keep the patch in the
> > receiver to improve the situation in any case, and also do further
> > work to improve the situation in the sender.
> >
> > All that being said, it's OK for me to add a sysctl to configure it=
=2E
> > More opinions on whether it's needed or not for the patch are welco=
me.
>
> I can=E2=80=99t say whats best for linux.. since I am really not invo=
lved in that
> community :-) But I do like the ideas of sysctl=E2=80=99s to control =
behavior. That
> way the sysadmin can cater the system to his/or/her environment :-D
>
> R
>
> >
> >> I don=E2=80=99t like the idea of weakening the security, I know as=
 you propose below
> >> its
> >> just 5 in 2^^32 instead of 1 in 2^^32 but depending on how you imp=
lement it
> >> you could stretch that to be the number of sack blocks the receive=
r holds.
> >>
> >>
> >> As stated above, I think it would probably be enough to check for
> >> those 4-5 seq numbers and not for all of them, which would on top =
not
> >> hit on security that much (but still maybe too much for somebody).
> >>
> >>
> >> I would think if you implement it that way I would have an option =
of sysctl
> >> to turn
> >> it off. But I still think snd_una is a better alternative ;-)
> >>
> >> R
> >>
> >>
> >>
> >> R
> >>
> >>
> >> On Jun 1, 2016, at 1:41 AM, Yuchung Cheng <ycheng@google.com> wrot=
e:
> >>
> >> On Tue, May 31, 2016 at 9:50 AM, Pau Espin <pau.espin@tessares.net=
> wrote:
> >>
> >>
> >> Hi, sorry re-sending because I didn't have plain text mode enabled=
 and
> >> message didn't arrive to the mailing list. Also dropping some mail
> >> addresses from RFC authors which probed to be unavailable anymore.
> >>
> >> The problem is not caused by the host-wide rate limit.
> >> I analyzed the scenario with tcpdump and I see the challenge ACKs =
are
> >> being sent, but due to network conditions sometimes they can be lo=
st.
> >> On top of that, the RST being sent from the client to the server a=
fter
> >> receiving the challenge ACK can also sometimes be lost. I even fou=
nd
> >> the client/router had a problem with iptables setup and was actual=
ly
> >> not sending back RST for incoming TCP packets without an existing
> >> connection established (should be the one already closed before wi=
th
> >> the first RST sent by the client and which originated the challeng=
e
> >> ACK).
> >>
> >> In my test scenario I'm using MultiPathTCP and I'm recreating (des=
troy
> >> with RST, then create with SYN)  the subflow on one of the interfa=
ces
> >> every aprox 5 seconds while uploading a big file. Due to network
> >> conditions and/or router stopping the RSTs, after less than 5 min,=
 I
> >> have more than 32 subflow connections created for that MPTCP
> >> connection, which is the hardcoded maximum, and from that point I'=
m
> >> unable to create/use new subflows until some of them are closed, w=
hich
> >> can take quite a lot of time. After this patch is applied, the num=
ber
> >> of subflows is kind of stable at 4-5 subflows during the whole upl=
oad.
> >> It's still not 2 (one permanent in iface1 and the recreated one in
> >> iface2) because sometimes due to network problems the packet befor=
e
> >> the RST is lost and thus the RST which arrives is not equal to nex=
t
> >> expected seq number from the right edge of the SACK block. But sti=
ll,
> >> it makes the situation quite better, specially from user point of
> >> view.
> >>
> >> Here's an example of the issue without my patch (challenge ACK is =
sent
> >> although the RST is in current place). It shows server acknowledgi=
ng
> >> data with SACK in first line. Then, on 2nd line, client decides to
> >> terminate the connexion and uses his next SEQ number available. On=
 3rd
> >> line, server answers with the challenge ACK. Then no answer comes =
from
> >> that challenge ack and the TCP conn is left opened.
> >>
> >> 14202    73.086360    10.0.4.2    443    10.67.15.100    53755    =
TCP
> >> 94    [TCP Dup ACK 14192#4] 443=E2=86=9253755 [ACK] Seq=3D35518069=
92
> >> Ack=3D1240653972 Win=3D1573120 Len=3D0 TSval=3D4022818 TSecr=3D110=
6789
> >> SLE=3D1240836636 SRE=3D1240942836 SLE=3D1240770084 SRE=3D124083522=
0
> >> 14203    73.086363    10.67.15.100    53755    10.0.4.2    443    =
TCP
> >> 74    53755=E2=86=92443 [RST, ACK] Seq=3D1240942836 Ack=3D35518069=
92 Win=3D90240
> >> Len=3D0 TSval=3D1106847 TSecr=3D4022536
> >> 14204    73.086368    10.0.4.2    443    10.67.15.100    53755    =
TCP
> >> 94    [TCP Dup ACK 14192#5] 443=E2=86=9253755 [ACK] Seq=3D35518069=
92
> >> Ack=3D1240653972 Win=3D1573120 Len=3D0 TSval=3D4022818 TSecr=3D110=
6789
> >> SLE=3D1240836636 SRE=3D1240942836 SLE=3D1240770084 SRE=3D124083522=
0
> >>
> >> So, the main point in here is trying to improve the situation to c=
lose
> >> the connections and free resources in some specific cases without
> >> actually going pre RFC5961 state. That would mean when a RST is
> >> received, up to 4-5 SEQs are checked to match instead of 1.
> >>
> >> I didn't contact the authors of the RFC. I CC them in this e-mail.=
 I
> >> hope that's the right thing to do in this case and that they don't
> >> mind it in case they want to follow the topic.
> >>
> >> I will have a look at packetdrill to try to reproduce it somehow t=
here.
> >>
> >> On Tue, May 31, 2016 at 5:12 PM, Eric Dumazet <eric.dumazet@gmail.=
com>
> >> wrote:
> >>
> >> On Tue, 2016-05-31 at 13:38 +0200, Pau Espin Pedrol wrote:
> >>
> >> RFC 5961 advises to only accept RST packets containing a seq numbe=
r
> >> matching the next expected seq number instead of the whole receive
> >> window in order to avoid spoofing attacks.
> >>
> >> However, this situation is not optimal in the case SACK is in use =
at the
> >> time the RST is sent. I recently run into a scenario in which pack=
et
> >> losses were high while uploading data to a server, and userspace w=
as
> >> willing to frequently terminate connections by sending a RST. In
> >> this case, the ACK sent on the receiver side is frozen waiting for=
 a lost
> >> packet retransmission and a SACK block is used to let the client
> >> continue uploading data. At some point later on, the client sends =
the
> >> RST, which matches the next expected seq number of the SACK block =
on the
> >> receiver side which is going forward receiving data.
> >>
> >> In this scenario, as RFC 5961 defines, the SEQ doesn't match the f=
rozen
> >> main ACK at receiver side and thus gets dropped and a challenge AC=
K is
> >> sent, which gets usually lost due to network conditions. The main
> >> consequence is that the connection stays alive for a while even if=
 it
> >> made sense to accept the RST. This can get really bad if lots of
> >> connections like this one are created in few seconds, allocating a=
ll the
> >> resources of the server easily.
> >>
> >> From security point of view: the maximum number of SACK blocks for=
 a TCP
> >> connection is limited to 4 due to options field maximum length, an=
d that
> >>
> >> This is not true. The maximum number of SACK blocks for a TCP "pac=
ket"
> >> is limited to 4. But a TCP connection can keep an arbitrary amount=
 of
> >> SACK blocks.
> >>
> >> means we match at maximum against 5 seq numbers, which should make=
 it
> >> still difficult for attackers to inject a valid RST message.
> >>
> >> This patch was tested in a 3.18 kernel and probed to improve the
> >> situation in the scenario described above.
> >>
> >> Signed-off-by: Pau Espin Pedrol <pau.espin@tessares.net>
> >> ---
> >> net/ipv4/tcp_input.c | 18 +++++++++++++++++-
> >> 1 file changed, 17 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> >> index d6c8f4cd0..4727dc8 100644
> >> --- a/net/ipv4/tcp_input.c
> >> +++ b/net/ipv4/tcp_input.c
> >> @@ -5159,6 +5159,7 @@ static bool tcp_validate_incoming(struct soc=
k *sk,
> >> struct sk_buff *skb,
> >>                              const struct tcphdr *th, int syn_iner=
r)
> >> {
> >>    struct tcp_sock *tp =3D tcp_sk(sk);
> >> +     bool rst_seq_match =3D false;
> >>
> >>    /* RFC1323: H1. Apply PAWS check first. */
> >>    if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstam=
p &&
> >> @@ -5195,13 +5196,28 @@ static bool tcp_validate_incoming(struct s=
ock *sk,
> >> struct sk_buff *skb,
> >>
> >>    /* Step 2: check RST bit */
> >>    if (th->rst) {
> >> -             /* RFC 5961 3.2 :
> >> +             /* RFC 5961 3.2 (extended to match against SACK too =
if
> >> available):
> >>             * If sequence number exactly matches RCV.NXT, then
> >>             *     RESET the connection
> >>             * else
> >>             *     Send a challenge ACK
> >>             */
> >>            if (TCP_SKB_CB(skb)->seq =3D=3D tp->rcv_nxt)
> >> +                     rst_seq_match =3D true;
> >> +             else if (tcp_is_sack(tp)) {
> >> +                     int this_sack;
> >> +                     struct tcp_sack_block *sp =3D tp->rx_opt.dsa=
ck ?
> >> +                                     tp->duplicate_sack :
> >> tp->selective_acks;
> >> +
> >> +                     for (this_sack =3D 0; this_sack < tp->rx_opt=
=2Enum_sacks;
> >> ++this_sack) {
> >> +                             if (TCP_SKB_CB(skb)->seq =3D=3D
> >> sp[this_sack].end_seq) {
> >> +                                     rst_seq_match =3D true;
> >> +                                     break;
> >> +                             }
> >> +                     }
> >> +             }
> >> +
> >> +             if (rst_seq_match)
> >>                    tcp_reset(sk);
> >>            else
> >>                    tcp_send_challenge_ack(sk, skb);
> >> --
> >> 2.5.0
> >>
> >>
> >> It looks like you want to seriously relax RFC 5961 ...
> >>
> >> Could you have a problem because of the host-wide RFC 5961 rate li=
mit ?
> >>
> >> Have you contacted RFC authors ?
> >>
> >> If the peer sends the RST, presumably it should answer to the chal=
lenge
> >> ACK right away, since it does not care of the SACK blocks anymore.
> >>
> >> A packetdrill test demonstrating the issue would be nice.
> >>
> >> Thanks.
> >>
> >>
> >>
> >>
> >>
> >>
> >> --
> >> Pau Espin Pedrol | R&D Engineer - External
> >> pau.espin@tessares.net | +32 487 43 36 50
> >> Tessares SA | Hybrid Access Solutions
> >> www.tessares.net
> >> 6 Rue Louis de Geer, 1348 Louvain-la-Neuve, Belgium
> >>
> >> --
> >>
> >> ------------------------------
> >> DISCLAIMER.
> >> This email and any files transmitted with it are confidential and =
intended
> >> solely for the use of the individual or entity to whom they are ad=
dressed.
> >> If you have received this email in error please notify the system =
manager.
> >> This message contains confidential information and is intended onl=
y for the
> >> individual named. If you are not the named addressee you should no=
t
> >> disseminate, distribute or copy this e-mail. Please notify the sen=
der
> >> immediately by e-mail if you have received this e-mail by mistake =
and
> >> delete this e-mail from your system. If you are not the intended r=
ecipient
> >> you are notified that disclosing, copying, distributing or taking =
any
> >> action in reliance on the contents of this information is strictly
> >> prohibited.
> >>
> >>
> >> --------
> >> Randall Stewart
> >> rrs@netflix.com
> >> 803-317-4952
> >>
> >>
> >>
> >>
> >>
> >>
> >>
> >>
> >> --
> >> Pau Espin Pedrol | R&D Engineer - External
> >> pau.espin@tessares.net | +32 487 43 36 50
> >> Tessares SA | Hybrid Access Solutions
> >> www.tessares.net
> >> 6 Rue Louis de Geer, 1348 Louvain-la-Neuve, Belgium
> >>
> >> --
> >>
> >> ------------------------------
> >> DISCLAIMER.
> >> This email and any files transmitted with it are confidential and =
intended
> >> solely for the use of the individual or entity to whom they are ad=
dressed.
> >> If you have received this email in error please notify the system =
manager.
> >> This message contains confidential information and is intended onl=
y for the
> >> individual named. If you are not the named addressee you should no=
t
> >> disseminate, distribute or copy this e-mail. Please notify the sen=
der
> >> immediately by e-mail if you have received this e-mail by mistake =
and
> >> delete this e-mail from your system. If you are not the intended r=
ecipient
> >> you are notified that disclosing, copying, distributing or taking =
any
> >> action in reliance on the contents of this information is strictly
> >> prohibited.
> >>
> >>
> >> --------
> >> Randall Stewart
> >> rrs@netflix.com
> >> 803-317-4952
> >>
> >>
> >>
> >>
> >>
> >
> >
> >
> > --
> > Pau Espin Pedrol | R&D Engineer - External
> > pau.espin@tessares.net | +32 487 43 36 50
> > Tessares SA | Hybrid Access Solutions
> > www.tessares.net
> > 6 Rue Louis de Geer, 1348 Louvain-la-Neuve, Belgium
> >
> > --
> >
> > ------------------------------
> > DISCLAIMER.
> > This email and any files transmitted with it are confidential and i=
ntended
> > solely for the use of the individual or entity to whom they are add=
ressed.
> > If you have received this email in error please notify the system m=
anager.
> > This message contains confidential information and is intended only=
 for the
> > individual named. If you are not the named addressee you should not
> > disseminate, distribute or copy this e-mail. Please notify the send=
er
> > immediately by e-mail if you have received this e-mail by mistake a=
nd
> > delete this e-mail from your system. If you are not the intended re=
cipient
> > you are notified that disclosing, copying, distributing or taking a=
ny
> > action in reliance on the contents of this information is strictly
> > prohibited.
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
