From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in tcp_try_to_open
Date: Mon, 21 Nov 2011 14:57:44 -0800
Message-ID: <CAK6E8=cNBCJbQs9dKcOwU1yZMC6czgMEuZt4Ubt=t-kBzHfFmw@mail.gmail.com>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
 <1321469885-10885-5-git-send-email-ncardwell@google.com> <alpine.DEB.2.00.1111170706330.23028@melkinpaasi.cs.helsinki.fi>
 <CADVnQymPTWsD0Hx060qYUMrFPxgQPdJWwPA9oDce6qMVL4tVpA@mail.gmail.com> <alpine.DEB.2.00.1111201024080.22397@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <therbert@google.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:63511 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab1KUXGM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 18:06:12 -0500
Received: by qadc14 with SMTP id c14so729861qad.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 15:06:11 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111201024080.22397@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 20, 2011 at 12:38 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Sat, 19 Nov 2011, Neal Cardwell wrote:
>> If your concern is receivers lying, then there are other easy ways
>> that a misbehaving receiver can get a sender to send too fast
>> (e.g. cumulatively ACKing the highest sequence number seen,
>> irrespective of holes). IMHO it would be a shame to penalize the vas=
t
>> majority of well-behaved users to plug one potential attack vector
>> when there are other easy holes that an attacker would use.
>
> I disagree... there is huge difference as the receiver then has to ga=
mble
> with the reliability of the flow. DSACK attack is nasty in that that =
it
> allows maintaining reliability while cheating bw.
>

I feel the original change Neal is proposing is getting lost. This
patch proposes when

a. ack is dubious
b. but it's not time to recover yet
c. and other checks in tcp_try_keep_open affirms the network is in
good condition, i.e, stat =3D=3D Open
3. do not moderate cwnd (not 3, not 10 or any magic number).

Your concern is valid, but if that's true for majority then I argue
all undo logic on dsack or TS are causing major threats since they all
require some trusts of the remote end. Why even bother processing
DSACK if we can't trust them?

AFAIK cwnd moderation is to lower bursty drops not to discourage
(dsack) cheating. I believe the reason is the same in
tcp_try_to_open(). We are in common cases, e.g., loss-recovery, this
logic hurts performance.
