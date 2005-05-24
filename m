From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netem: fix logic bug in reorder conditional
Date: Tue, 24 May 2005 09:57:07 -0700
Message-ID: <20050524095707.678f77ba@dxpl.pdx.osdl.net>
References: <20050519151254.79afe7e7@dxpl.pdx.osdl.net>
	<682bc30a05052116005bc813a2@mail.gmail.com>
	<20050523104342.78b1032d@dxpl.pdx.osdl.net>
	<682bc30a050523135534b38b8b@mail.gmail.com>
	<20050523140055.127f1a9f@dxpl.pdx.osdl.net>
	<682bc30a050524084136fa2fe3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julio Kriger <juliokriger@gmail.com>
In-Reply-To: <682bc30a050524084136fa2fe3@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 24 May 2005 12:41:11 -0300
Julio Kriger <juliokriger@gmail.com> wrote:

> > > 2) If I set latency = 50ms and a jitter = 300ms, tabledist can give me
> > > a negative number. This value is addes to cb->time_to_send, so it
> > > could change it to a negative value. Should we only accept positives
> > > number before add it to cb->time_to_send? or will
> > > q->qdisc->enqueue(skb, q->qdisc) put the package on the queue in a
> > > special way so it will be handled "before" other packages alrealy on
> > > the queue but with gretaer time_to_send?
> > 
> > probably should bound the value to 0 before the addition, to avoid large
> > wraparound problems, but since enqueue checks for for time it will work
> > as long as delta less than 2^32/2.
> > 
> 
> I think the value should be restricted to be positive and greater than
> zero. Becuase if a negative number is allowed we will be "losing"
> packages to be reordered, hence we will not be reordering, say 25%, of
> packages instead we will be reordering about 15%.
> In other words, packages that should be reordered will not be
> reordered because its new time to send will be the same as the old
> time to send.
> Regards,
> Julio

The problem is that the user specification (latency 50ms +/- 300ms with reordering) 
is problematic. Just like specifying reordering without delay (and a fast connection).

I chose to keep the original method of reordering by putting things at front of the
queue. Another alternative would be to keep a side-stack of packets to wait for
reordering. The problem with that is that if no following packet arrives, we end up
holding onto the last packet forever; and that would be bad.
