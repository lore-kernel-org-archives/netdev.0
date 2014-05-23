From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 06:47:23 -0700
Message-ID: <1400852843.5367.191.camel@edumazet-glaptop2.roam.corp.google.com>
References: <537E4AFD.20304@mentor.com>
		<1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com>
		<063D6719AE5E284EB5DD2968C1650D6D1724C490@AcuExch.aculab.com>
	 <87r43k4yhe.fsf@nemi.mork.no>
	 <063D6719AE5E284EB5DD2968C1650D6D1724C7A1@AcuExch.aculab.com>
	 <537F2D53.5020408@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	=?ISO-8859-1?Q?=27Bj=F8rn?= Mork' <bjorn@mork.no>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"kamal@canonical.com" <kamal@canonical.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"mszeredi@suse.cz" <mszeredi@suse.cz>,
	"fw@strlen.de" <fw@strlen.de>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537F2D53.5020408@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-05-23 at 12:13 +0100, Jim Baxter wrote:

> What are the side effects of changing the truesize, if the original
> uncloned skb has the full truesize then isn't the potential memory usage
> still counted for the avoidance of OOM?

Nope. This can be disastrous.

A malicious remote peer can crash your host by sending specially cooked
TCP messages.

Send messages with one byte of payload, and out of order so that they
cant be consumed by receiver, and cant be coalesced/collapsed.

If you claim the true size is sizeof(sk_buff) + 512, TCP stack will
accumulate these messages in out of order queue, and will not bother
with them, unless you hit sk_rcvbuf limit.

But in reality these messages uses sizeof(sk_buff) + 32768 bytes.

Divide your physical memory by 32768 : How many such messages will fit
in memory before the host crashes ?

I've seen that kind of attacks in real cases.

Even the fast clones sk_buff mismatch can be noticed. Luckily a 10%
error has no severe impact.

TCP stack uses fast clones, and current stack gives them a truesize of
2048 + sizeof(sk_buff), while it really should be 2048 +
2*sizeof(sk_buff)

Luckily, GSO/TSO tends to reduce the error, as skbs overhead is lower.
