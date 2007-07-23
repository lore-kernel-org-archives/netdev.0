From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 00/10] Implement batching skb API
Date: Mon, 23 Jul 2007 10:19:53 +0530
Message-ID: <OFFA8C2879.1D54F523-ON65257321.0010F240-65257321.001A8A31@in.ibm.com>
References: <1185108670.5192.122.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, kaber@trash.net, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	sri@us.ibm.com, davem@davemloft.net, herbert@gondor.apana.org.au
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1185108670.5192.122.camel@localhost>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Jamal,

J Hadi Salim <j.hadi123@gmail.com> wrote on 07/22/2007 06:21:09 PM:

> My concern is there is no consistency in results. I see improvements on
> something which you say dont. You see improvement in something that
> Evgeniy doesnt etc.

Hmmm ? Evgeniy has not even tested my code to find some regression :) And
you may possibly not find much improvement in E1000 when you run iperf
(which
is what I do) compared to pktgen. I can re-run and confirm this since my
last
E1000 run was quite some time back.

My point is that batching not being viable for E1000 (or tg3) need not be
the
sole criterea for inclusion. If IPoIB or other drivers can take advantage
of
it and get better results, then batching can be considered. Maybe E1000 too
can get improvements if some one with more expertise tries to add this API
(not judging your driver writing capabilities - just stating that driver
writers will know more knobs to exploit a complex device like E1000).

> > Since E1000 doesn't seem to use the TX lock on RX (atleast I couldn't
find
> > it),
> > I feel having prep will not help as no other cpu can execute the
queue/xmit
> > code anyway (E1000 is also a LLTX driver).
>
> My experiments show it is useful (in a very visible way using pktgen)
> for e1000 to have the prep() interface.

I meant : have you compared results of batching with prep on vs prep off,
and
what is the difference in BW ?

> >  Other driver that hold tx lock could get improvement however.
>
> So you do see the value then with non LLTX drivers, right? ;->

No. I see value only in non-LLTX drivers which also gets the same TX lock
in the RX path. If different locks are got by TX/RX, then since you are
holding queue_lock before calling 'prep', this excludes other TX from
running at the same time. In that case, pre-poning the get of the tx_lock
to do the 'prep' will not cause any degradation (since no other tx can run
anyway, while rx can run as it gets a different lock).

> The value is also there in LLTX drivers even if in just formating a skb
> ready for transmit. If this is not clear i could do a much longer
> writeup on my thought evolution towards adding prep().

In LLTX drivers, the driver does the 'prep' without holding the tx_lock in
any case, so there should be no improvement. Could you send the write-up
since
I really don't see the value in prep unless the driver is non-LLTX *and*
TX/RX holds the same TX lock. I think that is the sole criterea, right ?

> > If it helps, I guess you could send me a patch to
> > add that and I can also test it to see what the effect is. I didn't add
it
> > since IPoIB wouldn't be able to exploit it (unless someone is kind
enough
> > to show me how to).
>
> Such core code should not just be focussed on IPOIB.

There is *nothing* IPoIB specific or focus in my code. I said adding prep
doesn't
work for IPoIB and so it is pointless to add bloat to the code until some
code can
actually take advantage of this feature (I am sure you will agree). Which
is why I
also mentioned to please send me a patch if you find it useful for any
driver
rather than rejecting this idea.

> > I think the code I have is ready and stable,
>
> I am not sure how to intepret that - are you saying all-is-good and we
> should just push your code in?

I am only too well aware that Dave will not accept any code (having
experienced with Mobile IPv6 a long time back when he said to move most
of it to userspace and he was absolutely correct :). What I meant to say
is that there isn't much point in saying that your code is not ready or
you are using old code base, or has multiple restart functions, or is not
tested enough, etc, and then say let's re-do/rethink the whole
implementation when my code is already working and giving good results.
Unless you have some design issues with it, or code is written badly, is
not maintainable, not linux style compliant, is buggy, will not handle
some case/workload, type of issues.

OTOH, if you find some cases that are better handled with :
      1. prep handler
      2. xmit_win (which I don't have now),
then please send me patches and I will also test out and incorporate.

> It sounds disingenuous but i may have misread you.

("lacking in frankness, candor, or sincerity; falsely or hypocritically
ingenuous; insincere") ???? Sorry, no response to personal comments and
have a flame-war :)

Thanks,

- KK
