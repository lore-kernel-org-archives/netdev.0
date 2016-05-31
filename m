From: Pau Espin <pau.espin@tessares.net>
Subject: Re: [PATCH net-next] tcp: accept RST if SEQ matches right edge of
 SACK block
Date: Tue, 31 May 2016 18:50:46 +0200
Message-ID: <CALCp7mkPCFESn1a8mG3v17v5AQgn2m+xcq17PBWRVewABZkBig@mail.gmail.com>
References: <1464694717-22548-1-git-send-email-pau.espin@tessares.net>
	<1464707563.5939.114.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mdalal@cisco.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33315 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbcEaQur convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 12:50:47 -0400
Received: by mail-qk0-f179.google.com with SMTP id n63so148564787qkf.0
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 09:50:46 -0700 (PDT)
In-Reply-To: <1464707563.5939.114.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, sorry re-sending because I didn't have plain text mode enabled and
message didn't arrive to the mailing list. Also dropping some mail
addresses from RFC authors which probed to be unavailable anymore.

The problem is not caused by the host-wide rate limit.
I analyzed the scenario with tcpdump and I see the challenge ACKs are
being sent, but due to network conditions sometimes they can be lost.
On top of that, the RST being sent from the client to the server after
receiving the challenge ACK can also sometimes be lost. I even found
the client/router had a problem with iptables setup and was actually
not sending back RST for incoming TCP packets without an existing
connection established (should be the one already closed before with
the first RST sent by the client and which originated the challenge
ACK).

In my test scenario I'm using MultiPathTCP and I'm recreating (destroy
with RST, then create with SYN)  the subflow on one of the interfaces
every aprox 5 seconds while uploading a big file. Due to network
conditions and/or router stopping the RSTs, after less than 5 min, I
have more than 32 subflow connections created for that MPTCP
connection, which is the hardcoded maximum, and from that point I'm
unable to create/use new subflows until some of them are closed, which
can take quite a lot of time. After this patch is applied, the number
of subflows is kind of stable at 4-5 subflows during the whole upload.
It's still not 2 (one permanent in iface1 and the recreated one in
iface2) because sometimes due to network problems the packet before
the RST is lost and thus the RST which arrives is not equal to next
expected seq number from the right edge of the SACK block. But still,
it makes the situation quite better, specially from user point of
view.

Here's an example of the issue without my patch (challenge ACK is sent
although the RST is in current place). It shows server acknowledging
data with SACK in first line. Then, on 2nd line, client decides to
terminate the connexion and uses his next SEQ number available. On 3rd
line, server answers with the challenge ACK. Then no answer comes from
that challenge ack and the TCP conn is left opened.

14202    73.086360    10.0.4.2    443    10.67.15.100    53755    TCP
  94    [TCP Dup ACK 14192#4] 443=E2=86=9253755 [ACK] Seq=3D3551806992
Ack=3D1240653972 Win=3D1573120 Len=3D0 TSval=3D4022818 TSecr=3D1106789
SLE=3D1240836636 SRE=3D1240942836 SLE=3D1240770084 SRE=3D1240835220
14203    73.086363    10.67.15.100    53755    10.0.4.2    443    TCP
  74    53755=E2=86=92443 [RST, ACK] Seq=3D1240942836 Ack=3D3551806992 =
Win=3D90240
Len=3D0 TSval=3D1106847 TSecr=3D4022536
14204    73.086368    10.0.4.2    443    10.67.15.100    53755    TCP
  94    [TCP Dup ACK 14192#5] 443=E2=86=9253755 [ACK] Seq=3D3551806992
Ack=3D1240653972 Win=3D1573120 Len=3D0 TSval=3D4022818 TSecr=3D1106789
SLE=3D1240836636 SRE=3D1240942836 SLE=3D1240770084 SRE=3D1240835220

So, the main point in here is trying to improve the situation to close
the connections and free resources in some specific cases without
actually going pre RFC5961 state. That would mean when a RST is
received, up to 4-5 SEQs are checked to match instead of 1.

I didn't contact the authors of the RFC. I CC them in this e-mail. I
hope that's the right thing to do in this case and that they don't
mind it in case they want to follow the topic.

I will have a look at packetdrill to try to reproduce it somehow there.

On Tue, May 31, 2016 at 5:12 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Tue, 2016-05-31 at 13:38 +0200, Pau Espin Pedrol wrote:
>> RFC 5961 advises to only accept RST packets containing a seq number
>> matching the next expected seq number instead of the whole receive
>> window in order to avoid spoofing attacks.
>>
>> However, this situation is not optimal in the case SACK is in use at=
 the
>> time the RST is sent. I recently run into a scenario in which packet
>> losses were high while uploading data to a server, and userspace was
>> willing to frequently terminate connections by sending a RST. In
>> this case, the ACK sent on the receiver side is frozen waiting for a=
 lost
>> packet retransmission and a SACK block is used to let the client
>> continue uploading data. At some point later on, the client sends th=
e
>> RST, which matches the next expected seq number of the SACK block on=
 the
>> receiver side which is going forward receiving data.
>>
>> In this scenario, as RFC 5961 defines, the SEQ doesn't match the fro=
zen
>> main ACK at receiver side and thus gets dropped and a challenge ACK =
is
>> sent, which gets usually lost due to network conditions. The main
>> consequence is that the connection stays alive for a while even if i=
t
>> made sense to accept the RST. This can get really bad if lots of
>> connections like this one are created in few seconds, allocating all=
 the
>> resources of the server easily.
>>
>> From security point of view: the maximum number of SACK blocks for a=
 TCP
>> connection is limited to 4 due to options field maximum length, and =
that
>> means we match at maximum against 5 seq numbers, which should make i=
t
>> still difficult for attackers to inject a valid RST message.
>>
>> This patch was tested in a 3.18 kernel and probed to improve the
>> situation in the scenario described above.
>>
>> Signed-off-by: Pau Espin Pedrol <pau.espin@tessares.net>
>> ---
>>  net/ipv4/tcp_input.c | 18 +++++++++++++++++-
>>  1 file changed, 17 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index d6c8f4cd0..4727dc8 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -5159,6 +5159,7 @@ static bool tcp_validate_incoming(struct sock =
*sk, struct sk_buff *skb,
>>                                 const struct tcphdr *th, int syn_ine=
rr)
>>  {
>>       struct tcp_sock *tp =3D tcp_sk(sk);
>> +     bool rst_seq_match =3D false;
>>
>>       /* RFC1323: H1. Apply PAWS check first. */
>>       if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tsta=
mp &&
>> @@ -5195,13 +5196,28 @@ static bool tcp_validate_incoming(struct soc=
k *sk, struct sk_buff *skb,
>>
>>       /* Step 2: check RST bit */
>>       if (th->rst) {
>> -             /* RFC 5961 3.2 :
>> +             /* RFC 5961 3.2 (extended to match against SACK too if=
 available):
>>                * If sequence number exactly matches RCV.NXT, then
>>                *     RESET the connection
>>                * else
>>                *     Send a challenge ACK
>>                */
>>               if (TCP_SKB_CB(skb)->seq =3D=3D tp->rcv_nxt)
>> +                     rst_seq_match =3D true;
>> +             else if (tcp_is_sack(tp)) {
>> +                     int this_sack;
>> +                     struct tcp_sack_block *sp =3D tp->rx_opt.dsack=
 ?
>> +                                     tp->duplicate_sack : tp->selec=
tive_acks;
>> +
>> +                     for (this_sack =3D 0; this_sack < tp->rx_opt.n=
um_sacks; ++this_sack) {
>> +                             if (TCP_SKB_CB(skb)->seq =3D=3D sp[thi=
s_sack].end_seq) {
>> +                                     rst_seq_match =3D true;
>> +                                     break;
>> +                             }
>> +                     }
>> +             }
>> +
>> +             if (rst_seq_match)
>>                       tcp_reset(sk);
>>               else
>>                       tcp_send_challenge_ack(sk, skb);
>> --
>> 2.5.0
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
