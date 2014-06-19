From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on retransmit window
Date: Wed, 18 Jun 2014 18:52:23 -0700
Message-ID: <11392.1403142743@localhost.localdomain>
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
Received: from youngberry.canonical.com ([91.189.89.112]:35631 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756836AbaFSBwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 21:52:38 -0400
In-reply-to: <CADVnQy=qdaB7GEK8Ggenr92ckjwM3jOdsS18KEQver=9haWmCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neal Cardwell <ncardwell@google.com> wrote:

>On Tue, Jun 17, 2014 at 8:38 PM, Jay Vosburgh
><jay.vosburgh@canonical.com> wrote:
[...]
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

	Ok, I ran a test today that demonstrates the slow cwnd growth.
The sending machine is 3.15-rc8 (net-next as of about two weeks ago),
the receiver is Ubuntu 3.13.0-24.

	The test involves adding 40 ms of delay in and out from machine
A with netem, then running iperf from A to B.  Once the iperf reaches a
steady cwnd, on B, I add an iptables rule to drop 1 packet out of every
1000 coming from A, then remove the rule after 10 seconds.  The behavior
resulting from this closely matches what I see on the real systems.

	I captured packets from both ends, running it twice, the second
time with GSO, GRO and TSO disabled.

	The iperf output is as follows:

[  3]  5.0- 6.0 sec  33.6 MBytes   282 Mbits/sec
[  3]  6.0- 7.0 sec  33.8 MBytes   283 Mbits/sec
[  3]  7.0- 8.0 sec  27.0 MBytes   226 Mbits/sec
[  3]  8.0- 9.0 sec  23.2 MBytes   195 Mbits/sec
[  3]  9.0-10.0 sec  17.4 MBytes   146 Mbits/sec
[  3] 10.0-11.0 sec  13.9 MBytes   116 Mbits/sec
[  3] 11.0-12.0 sec  10.4 MBytes  87.0 Mbits/sec
[  3] 12.0-13.0 sec  6.38 MBytes  53.5 Mbits/sec
[  3] 13.0-14.0 sec  5.75 MBytes  48.2 Mbits/sec
[  3] 14.0-15.0 sec  4.75 MBytes  39.8 Mbits/sec
[  3] 15.0-16.0 sec  3.12 MBytes  26.2 Mbits/sec
[  3] 16.0-17.0 sec  4.38 MBytes  36.7 Mbits/sec
[  3] 17.0-18.0 sec  3.12 MBytes  26.2 Mbits/sec
[  3] 18.0-19.0 sec  3.12 MBytes  26.2 Mbits/sec
[  3] 19.0-20.0 sec  4.25 MBytes  35.7 Mbits/sec
[  3] 20.0-21.0 sec  3.12 MBytes  26.2 Mbits/sec
[  3] 21.0-22.0 sec  3.25 MBytes  27.3 Mbits/sec
[  3] 22.0-23.0 sec  4.25 MBytes  35.7 Mbits/sec
[  3] 23.0-24.0 sec  3.12 MBytes  26.2 Mbits/sec
[  3] 24.0-25.0 sec  4.12 MBytes  34.6 Mbits/sec
[  3] 25.0-26.0 sec  4.50 MBytes  37.7 Mbits/sec
[  3] 26.0-27.0 sec  4.50 MBytes  37.7 Mbits/sec
[  3] 27.0-28.0 sec  5.88 MBytes  49.3 Mbits/sec
[  3] 28.0-29.0 sec  7.12 MBytes  59.8 Mbits/sec
[  3] 29.0-30.0 sec  7.38 MBytes  61.9 Mbits/sec
[  3] 30.0-31.0 sec  10.0 MBytes  83.9 Mbits/sec
[  3] 31.0-32.0 sec  11.6 MBytes  97.5 Mbits/sec
[  3] 32.0-33.0 sec  15.5 MBytes   130 Mbits/sec
[  3] 33.0-34.0 sec  17.2 MBytes   145 Mbits/sec
[  3] 34.0-35.0 sec  20.0 MBytes   168 Mbits/sec
[  3] 35.0-36.0 sec  25.5 MBytes   214 Mbits/sec
[  3] 36.0-37.0 sec  29.8 MBytes   250 Mbits/sec
[  3] 37.0-38.0 sec  32.2 MBytes   271 Mbits/sec
[  3] 38.0-39.0 sec  32.4 MBytes   272 Mbits/sec

	For the above run, the iptables drop rule went in at about time
7, and was removed 10 seconds later, so recovery began at about time 17.
The second run is similar, although the exact start times differ.

	The full data (two runs, each with packet capture from both ends
and the iperf output) can be found at:

http://people.canonical.com/~jvosburgh/tcp-slow-recovery.tar.bz2

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
