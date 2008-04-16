From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: A Linux TCP SACK Question
Date: Wed, 16 Apr 2008 07:40:35 -0700
Message-ID: <1e41a3230804160740g1b4f135bh2f0548e8c15bcddb@mail.gmail.com>
References: <Pine.LNX.4.64.0804151035060.17123@wrl-59.cs.helsinki.fi>
	 <fc3c25e72104.4804a729@fnal.gov>
	 <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
	 <20080416.012732.152357000.davem@davemloft.net>
	 <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>, wenji@fnal.gov,
	Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.189]:52618 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102AbYDPOki convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 10:40:38 -0400
Received: by rn-out-0910.google.com with SMTP id e11so1086582rng.17
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 07:40:36 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 16, 2008 at 2:21 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
>
> On Wed, 16 Apr 2008, David Miller wrote:
>
>  > From: "John Heffner" <johnwheffner@gmail.com>
>  > Date: Tue, 15 Apr 2008 15:40:05 -0700
>  >
>  > > Subject: [PATCH] Increase the max_burst threshold from 3 to tp->=
reordering.
>  > >
>  > > This change is necessary to allow cwnd to grow during persistent
>  > > reordering.  Cwnd moderation is applied when in the disorder sta=
te
>  > > and an ack that fills the hole comes in.  If the hole was greate=
r
>  > > than 3 packets, but less than tp->reordering, cwnd will shrink w=
hen
>  > > it should not have.
>  > >
>  > > Signed-off-by: John Heffner <jheffner@napa.(none)>
>  >
>  > I think this patch is correct, or at least more correct than what
>  > this code is doing right now.
>  >
>  > Any objections to my adding this to net-2.6.26?
>
>  I don't have objections.
>
>  But I want to note that tp->reordering does not consider the situati=
on on
>  that specific ACK because its value might originate a number of segm=
ents
>  and even RTTs back. I think it could be possible to find a more
>  appropriate value for max_burst locally to an ACK. ...Though it migh=
t be a
>  bit over-engineered solution. For SACK we calculate similar metric a=
nyway
>  in tcp_clean_rtx_queue to find if tp->reordering needs to be updated=
 at
>  cumulative ACK and for NewReno min(tp->sacked_out, tp->reordering) +=
 3
>  could perhaps be used (I'm not sure if these would be foolproof in
>  recovery though).

Reordering is generally a random process resulting from a packet
traversing parallel queues.  (In the case of netem, the random process
is explicitly defined by simulation.)  As reordering is created by
packets sitting in queues, these queues *should* be able to absorb a
burst of at least the reordering size.  That's at least my
justification for using the reordering threshold as max_burst, along
with the fact that it should prevent cwnd from getting clamped.

Anyway, max_burst isn't a standard.  TCP makes no guarantees that it
won't burst a full window.  If anything, I actually think that in most
cases we'd be better off without it.  It's harmful to high-bdp flows
because it pulls down cwnd, which has a long-term effect in response
to a short-term event.

  -John
