From: =?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>
Subject: Re: [PATCH net-next v2] tcp: avoid reducing cwnd when ACK+DSACK is
 received
Date: Thu, 8 Jan 2015 16:39:04 +0100
Message-ID: <54AEA498.5030202@uclouvain.be>
References: <1420719609-18638-1-git-send-email-sebastien.barre@uclouvain.be> <1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Gregory Detal <gregory.detal@uclouvain.be>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:38169 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbbAHPjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:39:31 -0500
In-Reply-To: <1420730396.5947.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Le 08/01/2015 16:19, Eric Dumazet a =C3=A9crit :
> On Thu, 2015-01-08 at 13:20 +0100, S=C3=A9bastien Barr=C3=A9 wrote:
>> When the peer has delayed ack enabled, it may reply to a probe with =
an
>> ACK+D-SACK, with ack value set to tlp_high_seq. In the current code,
>> such ACK+DSACK will be missed and only at next, higher ack will the =
TLP
>> episode be considered done. Since the DSACK is not present anymore,
>> this will cost a cwnd reduction.
>>
> ...
>>   net/ipv4/tcp_input.c | 30 +++++++++++++-----------------
>>   1 file changed, 13 insertions(+), 17 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 075ab4d..cf63a29 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -3363,29 +3363,25 @@ static void tcp_replace_ts_recent(struct tcp=
_sock *tp, u32 seq)
>>   static void tcp_process_tlp_ack(struct sock *sk, u32 ack, int flag=
)
>>   {
>>   	struct tcp_sock *tp =3D tcp_sk(sk);
>> -	bool is_tlp_dupack =3D (ack =3D=3D tp->tlp_high_seq) &&
>> -			     !(flag & (FLAG_SND_UNA_ADVANCED |
>> -				       FLAG_NOT_DUP | FLAG_DATA_SACKED));
>>  =20
> No idea why you removed this bool, it really helped to understand the
> code. This makes your patch looks more complex than needed.
I did not remove it in v1=20
(http://www.spinics.net/lists/netdev/msg308653.html)
The removal was a request from Neal=20
(http://www.spinics.net/lists/netdev/msg308758.html)

I think he found it special to have part of the logic apart, in a bool,=
=20
and part of it in the if condition.
One possible option is to restore is_tlp_dupack and include the DSACK=20
check in it, although this will
not do much more than moving complexity in the bool definition. But=20
indeed, that might make
the patch more readable.

What do you and Neal think ?

regards,

S=C3=A9bastien.
>
>>   	/* Mark the end of TLP episode on receiving TLP dupack or when
>>   	 * ack is after tlp_high_seq.
>> +	 * With delayed acks, we may also get a regular ACK+DSACK, in whic=
h
>> +	 * case we don't want to reduce the cwnd either.
>>   	 */
>> -	if (is_tlp_dupack) {
>> +	if (((ack =3D=3D tp->tlp_high_seq) &&
>> +	     !(flag & (FLAG_SND_UNA_ADVANCED |
>> +		       FLAG_NOT_DUP | FLAG_DATA_SACKED))) ||
>> +	    (!before(ack, tp->tlp_high_seq) && (flag & FLAG_DSACKING_ACK))=
) {
>>   		tp->tlp_high_seq =3D 0;
>> -		return;
>> -	}
>
