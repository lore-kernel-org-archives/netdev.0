From: jamal <hadi@cyberus.ca>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: 29 Sep 2004 10:08:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096466925.1022.43.camel@jzny.localdomain>
References: <1093904088.1043.12.camel@jzny.localdomain>
	 <20040830154430.769d1d59.davem@redhat.com>
	 <1093906592.1037.32.camel@jzny.localdomain>
	 <20040830160052.548c4846.davem@redhat.com>
	 <1093916592.1037.51.camel@jzny.localdomain>
	 <20040830191716.0d002f91.davem@redhat.com>
	 <1093919823.1043.80.camel@jzny.localdomain>
	 <20040830212910.78047bcd.davem@davemloft.net>
	 <20040929003656.GX31616@rei.reeler.org>
	 <1096426464.1045.133.camel@jzny.localdomain>
	 <20040929124832.GA9634@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040929124832.GA9634@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-09-29 at 08:48, Thomas Graf wrote:
> * jamal <1096426464.1045.133.camel@jzny.localdomain> 2004-09-28 22:54
> > Lets do it on gnet stats though so we can make it more accessible.
> > I think your granularity maybe too thin: bytes,packets, drops
> > may need to be in the same TLV.
> 
> I partially agree as long as no structs visible to userspace will
> ever change after introduction.
> 

Note, this comes as a lesson from the current TC_STAT maintainance
headache. We messed up there but didnt have the hindsight we do now.
Adding a new user space visible entry becomes a matter of intrioducing 
a new TLV.

> I'd really like to avoid maintaining different structs for collection
> and transfer which must be kept in sync.

As a general principle i agree with you - this is why tc_stat got us in
trouble to begin with. The side effect is the cost of TLV 32 bit header
to transport a 32 bit or worse 8 bit. 
Putting entries into semantical groups will help reduce the overhead but
should only be done when makes sense to do so.
ex i see someone counting packets will also count bytes and maybe count
drops. Essentially if things dont make sense grouping, then dont group.
Later we figure it was a mistake, sure add a new TLV.
The problem with tc_stat is it was too fat.

> Having the application do its own struct and fill it based on
> if (tb[TCA_STATS_*]) conditions avoids all possible compatibility 
> issues. It would be possible for the application to choose between
> the original and a _64 variant if we ever introduce them.

Well, same principle applies to XSTAT; but thats app specific.

> So this would be my approach:
> 
> Leave gnet_stats as-is and extend it as needed but hide it from
> userspace.

Its too fat ;-> I dont see why an action which doesnt queue need to
have access to queue stats.

> Extend gen_copy_stats to add a nested TLV for every stat in
> the structure. We could even introduce a bitmap to allow the
> struct gnet_stats user to define which statistics are defined
> and which aren't. This way we could avoid the mess with pfifo
> and bfifo both using backlog but with a different unit in mind
> (packets/bytes).
> 

I think we should kill gnet_stat in its current form. The lessons of
tc_stat still haunt me.

> > do you have cycles to run with that patch?
> 
> Yes, it is related to my work so it's not a problem.

Thanks. We can talk offline then.

cheers,
jamal
