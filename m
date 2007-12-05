From: Matt Mathis <mathis@psc.edu>
Subject: Re: [PATCH net-2.6 0/3]: Three TCP fixes
Date: Tue, 4 Dec 2007 21:13:34 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712041636020.15251@tesla.psc.edu>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
 <47559FA1.2090104@psc.edu> <Pine.LNX.4.64.0712042252450.12072@kivilampi-30.cs.helsinki.fi>
 <4755C3E9.4090609@psc.edu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1233065670-499382716-1196809029=:15251"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?X-UNKNOWN?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:56236 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbXLECOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 21:14:04 -0500
In-Reply-To: <4755C3E9.4090609@psc.edu>
Content-ID: <Pine.LNX.4.64.0712042036250.15251@tesla.psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1233065670-499382716-1196809029=:15251
Content-Type: TEXT/PLAIN; CHARSET=X-UNKNOWN; FORMAT=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0712042036251.15251@tesla.psc.edu>

I can shed light one one detail:  ratehalving w/bounding parameters uses=20
snd_cwnd/4 to be appropriately conservative during slowstart.  Ideally cwnd=
=20
would be saved for every transmitted segment, and during recovery, ssthresh=
=20
and min_cwnd would be set to saved_cwnd/2.  However since cwnd is not saved=
=20
and during slowstart it might be doubled each RTT (depending on what other=
=20
algorithms are in effect), at the time the loss is detected cwnd/2 might=20
already be at the maximum window size for the path (pipe+queue size).  This=
=20
was observed to do some bad things on real networks, so we included another=
=20
factor of two reduction, which is really only correct for slowstart.=20
However, this does not usually hurt the normal loss in congestion avoidence=
=20
case, unless something else unexpected goes wrong.

We considered some logic to attempt to estimate cwnd at the time a lost=20
segment was sent, using the current cwnd and ssthresh (i.e. when the loss i=
s=20
detected), but it was cumbersome, not well behaved, impossible to model, an=
d=20
didn't make enough difference.

Actually the reason we abandoned RH is that is it sets cwnd from flight siz=
e=20
in a really bad way.  When you have large windows and burst losses, includi=
ng=20
possibly a few segments with lost retransmissions, you are likely to depres=
s=20
the flight size because either you run out of receiver window or the sendin=
g=20
app can't refill the socket quickly enough when snd_una advances.  The
consequence is that cwnd is pulled down not by losses, but other non-path=
=20
"congestion", which takes potentially thousands of RTTs for AIMD to recover=
=2E

Unfortunately idea of setting cwnd from flightsize has been standardized in=
=20
RFC 2851....

This is one of the problems that I would really like to revisit, if I had t=
he
time.

Thanks,
--MM--
-------------------------------------------
Matt Mathis      http://www.psc.edu/~mathis
Work:412.268.3319    Home/Cell:412.654.7529
-------------------------------------------

On Tue, 4 Dec 2007, John Heffner wrote:

> Ilpo J=E4rvinen wrote:
>> On Tue, 4 Dec 2007, John Heffner wrote:
>>=20
>>> Ilpo J=E4rvinen wrote:
>>>> ...I'm still to figure out why tcp_cwnd_down uses snd_ssthresh/2
>>>> as lower bound even though the ssthresh was already halved, so=20
>>>> snd_ssthresh
>>>> should suffice.
>>> I remember this coming up at least once before, so it's probably worth =
a
>>> comment in the code.  Rate-halving attempts to actually reduce cwnd to=
=20
>>> half
>>> the delivered window.  Here, cwnd/4 (ssthresh/2) is a lower bound on ho=
w=20
>>> far
>>> rate-halving can reduce cwnd.  See the "Bounding Parameters" section of
>>> <http://www.psc.edu/networking/papers/FACKnotes/current/>.
>>=20
>> Thanks for the info! Sadly enough it makes NewReno recovery quite=20
>> inefficient when there are enough losses and high BDP link (in my case=
=20
>> 384k/200ms, BDP sized buffer). There might be yet another bug in it as w=
ell=20
>> (it is still a bit unclear how tcp variables behaved during my scenario =
and=20
>> I'll investigate further) but reduction in the transfer rate is going to=
=20
>> last longer than a short moment (which is used as motivation in those FA=
CK=20
>> notes). In fact, if I just use RFC2581 like setting w/o rate-halving (an=
d=20
>> experience the initial "pause" in sending), the ACK clock to send out ne=
w=20
>> data works very nicely beating rate halving fair and square. For SACK/FA=
CK=20
>> it works much nicer because recovery is finished much earlier and slow=
=20
>> start recovers cwnd quickly.
>
> I believe this is exactly the reason why Matt (CC'd) and Jamshid abandone=
d=20
> this line of work in the late 90's.  In my opinion, it's probably not suc=
h a=20
> bad idea to use cwnd/2 as the bound.  In some situations, the current=20
> rate-halving code will work better, but as you point out, in others the c=
wnd=20
> is lowered too much.
>
>
>> ...Mind if I ask another similar one, any idea why prior_ssthresh is=20
>> smaller (3/4 of it) than cwnd used to be (see tcp_current_ssthresh)?
>
> Not sure on that one.  I'm not aware of any publications this is based on=
=2E=20
> Maybe Alexey knows?
>
>  -John
>
---1233065670-499382716-1196809029=:15251--
