From: Marcelo Ricardo Leitner <marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH nf-next] netfilter: nf_ct_sctp: minimal multihoming
 support
Date: Thu, 16 Jul 2015 10:18:40 -0300
Message-ID: <20150716131839.GA21634@localhost.localdomain>
References: <20150714122311.8DA8EA0C9A@unicorn.suse.cz>
 <20150714134203.GG25674@breakpoint.cc>
 <20150714164225.GB8478@unicorn.suse.cz>
 <20150715203508.GA14704@localhost.localdomain>
 <20150716120512.GA7200@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Jozsef Kadlecsik <kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Michal Kubecek <mkubecek-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150716120512.GA7200-OEaqT8BN2ewCVLCxKZUutA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 16, 2015 at 02:05:12PM +0200, Michal Kubecek wrote:
> On Wed, Jul 15, 2015 at 05:35:08PM -0300, Marcelo Ricardo Leitner wrote:
> > Hi,
> > 
> > On Tue, Jul 14, 2015 at 06:42:25PM +0200, Michal Kubecek wrote:
> > > On Tue, Jul 14, 2015 at 03:42:03PM +0200, Florian Westphal wrote:
> > > > Michal Kubecek <mkubecek-AlSwsSmVLrQ@public.gmane.org> wrote:
> > > > > +	case SCTP_CID_HEARTBEAT:
> > > > > +		pr_debug("SCTP_CID_HEARTBEAT");
> > > > > +		i = 9;
> > > > > +		break;
> > > > > +	case SCTP_CID_HEARTBEAT_ACK:
> > > > > +		pr_debug("SCTP_CID_HEARTBEAT_ACK");
> > > > > +		i = 10;
> > > > > +		break;
> > > > >  	default:
> > > > >  		/* Other chunks like DATA, SACK, HEARTBEAT and
> > > > >  		its ACK do not cause a change in state */
> > > > > @@ -329,6 +351,8 @@ static int sctp_packet(struct nf_conn *ct,
> > > > >  	    !test_bit(SCTP_CID_COOKIE_ECHO, map) &&
> > > > >  	    !test_bit(SCTP_CID_ABORT, map) &&
> > > > >  	    !test_bit(SCTP_CID_SHUTDOWN_ACK, map) &&
> > > > > +	    !test_bit(SCTP_CID_HEARTBEAT, map) &&
> > > > > +	    !test_bit(SCTP_CID_HEARTBEAT_ACK, map) &&
> > > > >  	    sh->vtag != ct->proto.sctp.vtag[dir]) {
> > > > >  		pr_debug("Verification tag check failed\n");
> > > > >  		goto out;
> > > > > @@ -357,6 +381,16 @@ static int sctp_packet(struct nf_conn *ct,
> > > > >  			/* Sec 8.5.1 (D) */
> > > > >  			if (sh->vtag != ct->proto.sctp.vtag[dir])
> > > > >  				goto out_unlock;
> > > > > +		} else if (sch->type == SCTP_CID_HEARTBEAT ||
> > > > > +			   sch->type == SCTP_CID_HEARTBEAT_ACK) {
> > > > > +			if (ct->proto.sctp.vtag[dir] == 0) {
> > > > > +				pr_debug("Setting vtag %x for dir %d\n",
> > > > > +					 sh->vtag, dir);
> > > > > +				ct->proto.sctp.vtag[dir] = sh->vtag;
> > > > 
> > > > Could you please elaborate on the [dir] == 0 test?
> > > > 
> > > > I see this might happen for SCTP_CID_HEARTBEAT_ACK, but why is this
> > > > needed for SCTP_CID_HEARTBEAT ?
> > > > 
> > > > We found a conntrack entry so shouldn't the vtag[dir] already be > 0?
> > > 
> > > Yes, you are right. This was originally intended to handle the case when
> > > a HEARTBEAT in the reply direction is seen before the HEARTBEAT-ACK but
> > > such HEARTBEAT would be dropped anyway in current version.
> > 
> > And we have to keep the first vtag attempted because otherwise an
> > attacker could just probe for the right one until she gets a reply.
> > 
> > IOW, if a different vtag is attempted, we should drop it as the packet
> > doesn't belong to that association/conntrack entry.
> > 
> > As vtags are always != 0 in such case, that's a way to know if we
> > already have that information or not.
> > 
> > > On the other hand, an alternative would be
> > > 
> > > 		} else if (sch->type == SCTP_CID_HEARTBEAT_ACK &&
> > > 			   ct->proto.sctp.vtag[dir] == 0) {
> > > 			pr_debug("Setting vtag %x for dir %d\n",
> > > 				 sh->vtag, dir);
> > > 			ct->proto.sctp.vtag[dir] = sh->vtag;
> > > 		} else if ((sch->type == SCTP_CID_HEARTBEAT ||
> > > 			    sch->type == SCTP_CID_HEARTBEAT_ACK) &&
> > > 			   sh->vtag != ct->proto.sctp.vtag[dir]) {
> > > 			pr_debug("Verification tag check failed\n");
> > > 			goto out_unlock;
> > > 		}
> > > 
> > > I'm not sure it looks better.
> > 
> > Now it seems swapped, we should save the tag on HB and check on
> > HB_ACK only and would have to check against !dir entry. Like:
> 
> I forgot to include the explanation of vtag setting/checking logic into
> the commit message. It is supposed to work like this:
> 
> Normally, vtag is set from the INIT chunk for the reply direction and
> from the INIT-ACK chunk for the originating direction (i.e. each of
> these defines vtag value for the opposite direction). For secondary

Erf, indeed. I totally confused it and thought they would be equal on
both directions.

> conntracks, we can't rely on seeing INIT/INIT-ACK and even if we have
> seen them, we would need to connect two different conntracks. Therefore
> simplified logic is applied: vtag of first packet in each direction
> (HEARTBEAT in the originating and HEARTBEAT-ACK in reply direction) is
> saved and all following packets in that direction are compared with this
> saved value. While INIT and INIT-ACK define vtag for the opposite
> direction (that's where "!dir" comes from), vtags extracted from
> HEARTBEAT and HEARTBEAT-ACK are always for their direction. And we have
> to check vtags on packets with HEARTBEAT chunks as well because their
> vtags should match vtag of the first (set in sctp_new()).

Yes, that's pretty much it. Original code reads better here then.

Thanks,
Marcelo
