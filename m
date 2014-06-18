From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on retransmit window
Date: Tue, 17 Jun 2014 19:00:30 -0700
Message-ID: <2986.1403056830@localhost.localdomain>
References: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com> <20140616211954.6E12BA3A89@unicorn.suse.cz> <CAK6E8=dxszKmHssR7ib7Fxfm6hQRdbwBG1ygRvOXoSAXddBSPA@mail.gmail.com> <CADVnQy=sd2V2A5Rzd+OtcH1a+un3-fATSn_acKdMKUcdbpGadg@mail.gmail.com> <CAK6E8=fb0x5Z0dnA6PDbxJKYn3z1y42Pr555t7apLbT97R8O-Q@mail.gmail.com> <CADVnQykk0pmryWdRjq21OXYK3Pvi5xWCkaB7Jf2acF5qtnzANg@mail.gmail.com> <20140617122038.GA7275@unicorn.suse.cz> <CAK6E8=e=EoxMfGMFnO90MVfBWGmoua8=4ptG978-jfD2S-J8Fw@mail.gmail.com> <20140617224241.GA17969@unicorn.suse.cz> <2421.1403051930@localhost.localdomain> <CADVnQy=qdaB7GEK8Ggenr92ckjwM3jOdsS18KEQver=9haWmCA@mail.gmail.com>
Cc: Michal Kubecek <mkubecek@suse.cz>,
	Yuchung Cheng <ycheng@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56197 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756370AbaFRCAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 22:00:44 -0400
In-reply-to: <CADVnQy=qdaB7GEK8Ggenr92ckjwM3jOdsS18KEQver=9haWmCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neal Cardwell <ncardwell@google.com> wrote:

>On Tue, Jun 17, 2014 at 8:38 PM, Jay Vosburgh
><jay.vosburgh@canonical.com> wrote:
>> Michal Kubecek <mkubecek@suse.cz> wrote:
>>
>>>On Tue, Jun 17, 2014 at 02:35:23PM -0700, Yuchung Cheng wrote:
>>>> On Tue, Jun 17, 2014 at 5:20 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
>>>> > On Mon, Jun 16, 2014 at 08:44:04PM -0400, Neal Cardwell wrote:
>>>> >> On Mon, Jun 16, 2014 at 8:25 PM, Yuchung Cheng <ycheng@google.com> wrote:
>>>> >> > However Linux is inconsistent on the loss of a retransmission. It
>>>> >> > reduces ssthresh (and cwnd) if this happens on a timeout, but not in
>>>> >> > fast recovery (tcp_mark_lost_retrans). We should fix that and that
>>>> >> > should help dealing with traffic policers.
>>>> >>
>>>> >> Yes, great point!
>>>> >
>>>> > Does it mean the patch itself would be acceptable if the reasoning in
>>>> > its commit message was changed? Or would you prefer a different way to
>>>> > unify the two situations?
>>>>
>>>> It's the latter but it seems to belong to a different patch (and it'll
>>>> not solve the problem you are seeing).
>>>
>>>OK, thank you. I guess we will have to persuade them to move to cubic
>>>which handles their problems much better.
>>>
>>>> The idea behind the RFC is that TCP should reduce cwnd and ssthresh
>>>> across round trips of send, but not within an RTT. Suppose cwnd was
>>>> 10 on first timeout, so cwnd becomes 1 and ssthresh is 5. Then after 3
>>>> round trips, we time out again. By the design of Reno this should
>>>> reset cwnd from 8 to 1, and ssthresh from 5 to 2.5.
>>>
>>>Shouldn't that be from 5 to 4? We reduce ssthresh to half of current
>>>cwnd, not current ssthresh.
>>>
>>>BtW, this is exactly the problem our customer is facing: they have
>>>relatively fast line (15 Mb/s) but with big buffers so that the
>>>roundtrip times can rise from unloaded 35 ms up to something like 1.5 s
>>>under full load.
>>>
>>>What happens is this: cwnd initally rises to ~2100 then first drops
>>>are encountered, cwnd is set to 1 and ssthresh to ~1050. The slow start
>>>lets cwnd reach ssthresh but after that, a slow linear growth follows.
>>>In this state, all in-flight packets are dropped (simulation of what
>>>happens on router switchover) so that cwnd is reset to 1 again and
>>>ssthresh to something like 530-550 (cwnd was a bit higher than ssthresh).
>>>If a packet loss comes shortly after that, cwnd is still very low and
>>>ssthresh is reduced to half of that cwnd (i.e. much lower than to half
>>>of ssthresh). If unlucky, one can even end up with ssthresh reduced to 2
>>>which takes really long to recover from.
>>
>>         I'm also looking into a problem that exhibits very similar TCP
>> characteristics, even down to cwnd and ssthresh values similar to what
>> you cite.  In this case, the situation has to do with high RTT (around
>> 80 ms) connections competing with low RTT (1 ms) connections.  This case
>> is already using cubic.
>>
>>         Essentially, a high RTT connection to the server transfers data
>> in at a reasonable and steady rate until something causes some packets
>> to be lost (in this case, another transfer from a low RTT host to the
>> same server).  Some packets are lost, and cwnd drops from ~2200 to ~300
>> (in stages, first to ~1500, then ~600, then to ~300, ).  The ssthresh
>> starts at around 1100, then drops to ~260, which is the lowest cwnd
>> value.
>>
>>         The recovery from the low cwnd situation is very slow; cwnd
>> climbs a bit and then remains essentially flat for around 5 seconds.  It
>> then begins to climb until a few packets are lost again, and the cycle
>> repeats.  If no futher losses occur (if the competing traffic has
>> ceased, for example), recovery from a low cwnd (300 - 750 ish) to the
>> full value (~2200) requires on the order of 20 seconds.  The connection
>> exits recovery state fairly quickly, and most of the 20 seconds is spent
>> in open state.
>
>Interesting. I'm a little surprised it takes CUBIC so long to re-grow
>cwnd to the full value. Would you be able to provide your kernel
>version number and post a tcpdump binary packet trace somewhere
>public?

	The kernel I'm using at the moment is an Ubuntu 3.2.0-54 distro
kernel, but I've reproduced the problem on Ubuntu distro 3.13 and a
mainline 3.15-rc (although in the 3.13/3.15 cases using netem to inject
delay).  I've been gathering data mostly with systemtap, but I should be
able to get some packet captures as well, although not until tomorrow.

	The test I'm using right now is pretty simple. I have three
machines: two, A and B, are separated by about 80 ms RTT; the third
machine, C, is about 1 ms from B, so:

	A --- 80ms --- B --- 1ms ---- C

	On A, I run an "iperf -i 1" to B, and let it max its cwnd, and
then on C, run an "iperf -t 1" to B ("-t 1" means only run for one
second then exit).  The iperf results on A look like this:

[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 1.0 sec   896 KBytes  7.34 Mbits/sec
[  3]  1.0- 2.0 sec  1.50 MBytes  12.6 Mbits/sec
[  3]  2.0- 3.0 sec  4.62 MBytes  38.8 Mbits/sec
[  3]  3.0- 4.0 sec  13.5 MBytes   113 Mbits/sec
[  3]  4.0- 5.0 sec  27.8 MBytes   233 Mbits/sec
[  3]  5.0- 6.0 sec  39.0 MBytes   327 Mbits/sec
[  3]  6.0- 7.0 sec  36.9 MBytes   309 Mbits/sec
[  3]  7.0- 8.0 sec  34.8 MBytes   292 Mbits/sec
[  3]  8.0- 9.0 sec  39.0 MBytes   327 Mbits/sec
[  3]  9.0-10.0 sec  36.9 MBytes   309 Mbits/sec
[  3] 10.0-11.0 sec  36.9 MBytes   309 Mbits/sec
[  3] 11.0-12.0 sec  11.1 MBytes  93.3 Mbits/sec
[  3] 12.0-13.0 sec  4.50 MBytes  37.7 Mbits/sec
[  3] 13.0-14.0 sec  2.88 MBytes  24.1 Mbits/sec
[  3] 14.0-15.0 sec  5.50 MBytes  46.1 Mbits/sec
[  3] 15.0-16.0 sec  6.38 MBytes  53.5 Mbits/sec
[  3] 16.0-17.0 sec  6.50 MBytes  54.5 Mbits/sec
[  3] 17.0-18.0 sec  6.38 MBytes  53.5 Mbits/sec
[  3] 18.0-19.0 sec  4.25 MBytes  35.7 Mbits/sec
[  3] 19.0-20.0 sec  6.38 MBytes  53.5 Mbits/sec
[  3] 20.0-21.0 sec  6.38 MBytes  53.5 Mbits/sec
[  3] 21.0-22.0 sec  6.38 MBytes  53.5 Mbits/sec
[  3] 22.0-23.0 sec  6.38 MBytes  53.5 Mbits/sec
[  3] 23.0-24.0 sec  6.50 MBytes  54.5 Mbits/sec
[  3] 24.0-25.0 sec  8.62 MBytes  72.4 Mbits/sec
[  3] 25.0-26.0 sec  6.38 MBytes  53.5 Mbits/sec
[  3] 26.0-27.0 sec  8.50 MBytes  71.3 Mbits/sec
[  3] 27.0-28.0 sec  8.62 MBytes  72.4 Mbits/sec
[  3] 28.0-29.0 sec  10.6 MBytes  89.1 Mbits/sec
[  3] 29.0-30.0 sec  12.9 MBytes   108 Mbits/sec
[  3] 30.0-31.0 sec  15.0 MBytes   126 Mbits/sec
[  3] 31.0-32.0 sec  15.0 MBytes   126 Mbits/sec
[  3] 32.0-33.0 sec  21.8 MBytes   182 Mbits/sec
[  3] 33.0-34.0 sec  21.4 MBytes   179 Mbits/sec
[  3] 34.0-35.0 sec  27.8 MBytes   233 Mbits/sec
[  3] 35.0-36.0 sec  32.6 MBytes   274 Mbits/sec
[  3] 36.0-37.0 sec  36.6 MBytes   307 Mbits/sec
[  3] 37.0-38.0 sec  36.6 MBytes   307 Mbits/sec

	The second iperf starts at about time 10.  The middle value is 1
second's throughput, so the flat throughput between roughly time 13 and
time 23 is the cwnd slow recovery.

	I've got one graph prepared already that I can post:

http://people.canonical.com/~jvosburgh/t-vs-cwnd-ssthresh.jpg

	This shows cwnd (green) and ssthresh (red) vs. time.  In this
case, the second (low RTT) iperf started at the first big drop at around
time 22 and ran for 30 seconds (its data is not on the graph).  The big
cwnd drop is actually a series of drops, but that's hard to see at this
scale.  This graph shows two of the slow recoveries, and was done on a
3.13 kernel using netem to add delay.  The cwnd and ssthresh data was
captured by systemtap when exiting tcp_ack.

>One thing you could try would be to disable CUBIC's "fast convergence" feature:
>
>  echo 0 > /sys/module/tcp_cubic/parameters/fast_convergence
>
>We have noticed that this feature can hurt performance when there is a
>high rate of random packet drops (packet drops that are not correlated
>with the sending rate of the flow in question).

	I ran the above iperf results with this disabled; it does not
appear to have any effect.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
