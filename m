From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v12 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Mon, 7 May 2012 13:56:12 +0200
Message-ID: <20120507115612.GA31110@1984>
References: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com>
 <201205071020.44449.hans.schillstrom@ericsson.com>
 <20120507090328.GA27650@1984>
 <201205071114.35324.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201205071114.35324.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 07, 2012 at 11:14:34AM +0200, Hans Schillstrom wrote:
> > > We have plenty of rules where just source port mask is zero.
> > > and the dest-port-mask is 0xfffc (or 0xffff)
> > 
> > 0xffff and 0x0000 means on/off respectively.
> > 
> > Still curious, how can 0xfffc be useful?
> 
> That's a special case where an appl is using 4 ports.
> But in general, have not seen other than "on/off" except for above.

I see. Well I'm fine with this way to switch on/off things, just
wanted some clafication.

Still one final thing I'd like to remove before inclusion:

+       union hmark_ports       port_mask;
+       union hmark_ports       port_set;
+       __u32                   spi_mask;
+       __u32                   spi_set;

the spi_mask seems redundant. The port_mask already provides u32 for
it.

In case you want to support different masks for AH/ESP and TCP, you
could do the following:

iptables -I PREROUTING -t mangle -p esp -j HARK --spi-mask 0xffff0000
iptables -I PREROUTING -t mangle -p tcp -j HARK --port-mask 0xfffc

Any objection?

Yes, you'll have to change user-space again, but we have time for
that.

> > > > I'm also telling this because I think that ICMP support will be
> > > > easier to add if port masking is removed.
> > > > 
> > > > [...]
> > > > > This is what I have done.
> > > > >
> > > > > - I reduced the code size a little bit by combining the hmark_ct_set_htuple_ipvX into one func.
> > > > >   by adding a hmark_addr6_mask() and hmark_addr_any_mask()
> > > > >   Note that using "otuple->src.l3num" as param 1 in both src and dst is not a typo.
> > > > >   (it's not set in the rtuple)
> > > > 
> > > > Good one, this made the code even smaller.
> > > > 
> > > > > - Made the if (dst < src) swap() in the hmark_hash() since it should be used by every caller.
> > > > 
> > > > Not really, you don't need for the conntrack part. The original tuple
> > > > is always the same, not matter where the packet is coming from. I have
> > > > removed this again so it only affects packet-based hashing.
> > > 
> > > Yes original tuple is always the same but not always less than the rtuple.
> > > If you have two nodes that should produce the same hmark,
> > > one with conntrack an one without you must make a compare to make it consistent.
> > 
> > I see, for consistency still makes sense although this seems to me
> > like still strange configuration. In what scenario would you use two
> > different approaches?
> 
> In the way that we use HMARK,
> in the incomming path there is conntrack disabled in the contrainer, 
> for the outgoing patch i.e. at the payloads there is conntrack used.
> In that case the --hmark-ct makes life easier.

That's still not enough to guarantee that the mark will be consistent
if NAT is in user, but I don't mind recovering the swap and add some
comment on the code to explain this if this makes your life easier.
