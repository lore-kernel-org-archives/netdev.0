From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on
 retransmit window
Date: Tue, 17 Jun 2014 20:56:42 -0400
Message-ID: <CADVnQy=qdaB7GEK8Ggenr92ckjwM3jOdsS18KEQver=9haWmCA@mail.gmail.com>
References: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com>
	<20140616211954.6E12BA3A89@unicorn.suse.cz>
	<CAK6E8=dxszKmHssR7ib7Fxfm6hQRdbwBG1ygRvOXoSAXddBSPA@mail.gmail.com>
	<CADVnQy=sd2V2A5Rzd+OtcH1a+un3-fATSn_acKdMKUcdbpGadg@mail.gmail.com>
	<CAK6E8=fb0x5Z0dnA6PDbxJKYn3z1y42Pr555t7apLbT97R8O-Q@mail.gmail.com>
	<CADVnQykk0pmryWdRjq21OXYK3Pvi5xWCkaB7Jf2acF5qtnzANg@mail.gmail.com>
	<20140617122038.GA7275@unicorn.suse.cz>
	<CAK6E8=e=EoxMfGMFnO90MVfBWGmoua8=4ptG978-jfD2S-J8Fw@mail.gmail.com>
	<20140617224241.GA17969@unicorn.suse.cz>
	<2421.1403051930@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Kubecek <mkubecek@suse.cz>,
	Yuchung Cheng <ycheng@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:52466 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754273AbaFRA4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 20:56:44 -0400
Received: by mail-wg0-f47.google.com with SMTP id k14so98010wgh.18
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2014 17:56:43 -0700 (PDT)
In-Reply-To: <2421.1403051930@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2014 at 8:38 PM, Jay Vosburgh
<jay.vosburgh@canonical.com> wrote:
> Michal Kubecek <mkubecek@suse.cz> wrote:
>
>>On Tue, Jun 17, 2014 at 02:35:23PM -0700, Yuchung Cheng wrote:
>>> On Tue, Jun 17, 2014 at 5:20 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
>>> > On Mon, Jun 16, 2014 at 08:44:04PM -0400, Neal Cardwell wrote:
>>> >> On Mon, Jun 16, 2014 at 8:25 PM, Yuchung Cheng <ycheng@google.com> wrote:
>>> >> > However Linux is inconsistent on the loss of a retransmission. It
>>> >> > reduces ssthresh (and cwnd) if this happens on a timeout, but not in
>>> >> > fast recovery (tcp_mark_lost_retrans). We should fix that and that
>>> >> > should help dealing with traffic policers.
>>> >>
>>> >> Yes, great point!
>>> >
>>> > Does it mean the patch itself would be acceptable if the reasoning in
>>> > its commit message was changed? Or would you prefer a different way to
>>> > unify the two situations?
>>>
>>> It's the latter but it seems to belong to a different patch (and it'll
>>> not solve the problem you are seeing).
>>
>>OK, thank you. I guess we will have to persuade them to move to cubic
>>which handles their problems much better.
>>
>>> The idea behind the RFC is that TCP should reduce cwnd and ssthresh
>>> across round trips of send, but not within an RTT. Suppose cwnd was
>>> 10 on first timeout, so cwnd becomes 1 and ssthresh is 5. Then after 3
>>> round trips, we time out again. By the design of Reno this should
>>> reset cwnd from 8 to 1, and ssthresh from 5 to 2.5.
>>
>>Shouldn't that be from 5 to 4? We reduce ssthresh to half of current
>>cwnd, not current ssthresh.
>>
>>BtW, this is exactly the problem our customer is facing: they have
>>relatively fast line (15 Mb/s) but with big buffers so that the
>>roundtrip times can rise from unloaded 35 ms up to something like 1.5 s
>>under full load.
>>
>>What happens is this: cwnd initally rises to ~2100 then first drops
>>are encountered, cwnd is set to 1 and ssthresh to ~1050. The slow start
>>lets cwnd reach ssthresh but after that, a slow linear growth follows.
>>In this state, all in-flight packets are dropped (simulation of what
>>happens on router switchover) so that cwnd is reset to 1 again and
>>ssthresh to something like 530-550 (cwnd was a bit higher than ssthresh).
>>If a packet loss comes shortly after that, cwnd is still very low and
>>ssthresh is reduced to half of that cwnd (i.e. much lower than to half
>>of ssthresh). If unlucky, one can even end up with ssthresh reduced to 2
>>which takes really long to recover from.
>
>         I'm also looking into a problem that exhibits very similar TCP
> characteristics, even down to cwnd and ssthresh values similar to what
> you cite.  In this case, the situation has to do with high RTT (around
> 80 ms) connections competing with low RTT (1 ms) connections.  This case
> is already using cubic.
>
>         Essentially, a high RTT connection to the server transfers data
> in at a reasonable and steady rate until something causes some packets
> to be lost (in this case, another transfer from a low RTT host to the
> same server).  Some packets are lost, and cwnd drops from ~2200 to ~300
> (in stages, first to ~1500, then ~600, then to ~300, ).  The ssthresh
> starts at around 1100, then drops to ~260, which is the lowest cwnd
> value.
>
>         The recovery from the low cwnd situation is very slow; cwnd
> climbs a bit and then remains essentially flat for around 5 seconds.  It
> then begins to climb until a few packets are lost again, and the cycle
> repeats.  If no futher losses occur (if the competing traffic has
> ceased, for example), recovery from a low cwnd (300 - 750 ish) to the
> full value (~2200) requires on the order of 20 seconds.  The connection
> exits recovery state fairly quickly, and most of the 20 seconds is spent
> in open state.

Interesting. I'm a little surprised it takes CUBIC so long to re-grow
cwnd to the full value. Would you be able to provide your kernel
version number and post a tcpdump binary packet trace somewhere
public?

One thing you could try would be to disable CUBIC's "fast convergence" feature:

  echo 0 > /sys/module/tcp_cubic/parameters/fast_convergence

We have noticed that this feature can hurt performance when there is a
high rate of random packet drops (packet drops that are not correlated
with the sending rate of the flow in question).

neal
