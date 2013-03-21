From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: reduce net_rx_action() latency to 2 HZ
Date: Thu, 21 Mar 2013 08:27:27 -0700
Message-ID: <1363879647.4431.8.camel@edumazet-glaptop>
References: <1362503713.15793.121.camel@edumazet-glaptop>
	 <CAP=VYLrvXREA=HGnnUCi2N77yRdktQDop1PpzJkveXDihJ3DOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>, Tom Herbert <therbert@google.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLrvXREA=HGnnUCi2N77yRdktQDop1PpzJkveXDihJ3DOw@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-03-21 at 11:03 -0400, Paul Gortmaker wrote:
> [CC'ing stable & Willy - for the older releases not fed by
> http://patchwork.ozlabs.org/bundle/davem/stable/ ]
> 
> On Tue, Mar 5, 2013 at 12:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazt@google.com>
> >
> > We should use time_after_eq() to get maximum latency of two ticks,
> > instead of three.
> >
> > Bug added in commit 24f8b2385 (net: increase receive packet quantum)
> 
> I'm not sure what applications would notice the extra tick, but 24f8b takes
> us back to 2.6.29.  It cherry picks cleanly onto 2.6.34, so it probably also
> does the same for Willy's 2.6.32 longterm too.
> 
> Commit is now mainline d114a3338747255518 - v3.9-rc3~36^2~34.

BQL (Bytes Queue Limit) relies on TX completion being run often, and
Qdisc being serviced often as well. If net_rx_action() hogs the cpu,
net_tx_action() is delayed and NIC can stall.

I wrote this patch because I was investigating a regression when a
Google application began using BQL enabled kernels.

About the latency in itself, following commit is way more interesting.

commit c10d73671ad30f5 (softirq: reduce latencies)

As without it, I could trigger more than 50ms latencies for the poor
user thread interrupted by softirq processing.
