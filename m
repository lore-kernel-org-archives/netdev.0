From: Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Tue, 30 Aug 2011 16:23:14 +1200
Message-ID: <5DE4D38D-82A8-413B-98A4-A544C40D3827@gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com> <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com> <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com> <4E5C3B47.1050809@freedesktop.org> <CA+mtBx-j_+mrNpntR7CfYOromDnM-ZGzvebpUCjC8Qf14X6u9g@mail.gmail.com> <CAJ-Vmonwur-SXddNwjPEidCMqes+PwbRWFBddfdwTp2jOMu64g@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJ-Vmonwur-SXddNwjPEidCMqes+PwbRWFBddfdwTp2jOMu64g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 30/08/2011, at 3:42 PM, Adrian Chadd wrote:

> On 30 August 2011 11:34, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> 
>> The generalization of BQL would be to set the queue limit in terms of
>> a cost function implemented by the driver.  The cost function would
>> most likely be an estimate of time to transmit a packet.  

That's a great idea.  Best that it be in nanoseconds, we may well have some seriously fast network interfaces to deal with.

>> So C(P)
>> could represent cost of a packet, sum(C(P) for P queued) is aggregate
>> cost of queue packets, and queue limit is the maximum cost sum.  For
>> wired Ethernet, number of bytes in packet might be a reasonable
>> function (although framing cost could be included, but I'm not sure
>> that would make a material difference).  For wireless, maybe the
>> function could be more complex possibly taking multicast, previous
>> history of transmission times, or other arbitrary characteristics of
>> the packet into account...
>> 
>> I can post a new patch with this generalization if this is interesting.
> 
> As I said before, I think this is the kind of thing the rate control
> code needs to get its dirty hands into.
> 
> With 802.11 you have to care about the PHY side of things too, so your
> cost suddenly would include the PER for combinations of {remote node,
> antenna setup, TX rate, sub-frame length, aggregate length}, etc. Do
> you choose that up front and then match a cost to it, or do you
> involve the rate control code in deciding a "good enough" way of
> handling what's on the queue by making rate decisions, then implement
> random/weighted/etc drop of what's left? Do you do some weighted/etc
> drop beforehand in the face of congestion, then pass what's left to
> the rate control code, then discard the rest?

Since Minstrel already knows an estimate of the PER to each remote node (expressed in terms of success probability per shot, so there's a bit of math to do), and the stack knows about transmit times, implementing a way to ask the question isn't particularly hard.  Other rate controls could make up their own guesstimates based on whatever factors they want to use.

However, that's going to change rapidly, so I suggest that we want some backlog grooming on a regular basis (like, after each rate control iteration) that might well reevaluate and drop or mark packets that are already in the queues.

> 
> C(P) is going to be quite variable - a full frame retransmit of a 4ms
> long aggregate frame is SUM(exponential backoff, grab the air,
> preamble, header, 4ms, etc. for each pass.)
> 
> 
> Adrian

Indeed.

Andrew

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
