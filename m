From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: nf_ct_sctp: minimal multihoming
 support
Date: Wed, 15 Jul 2015 17:35:08 -0300
Message-ID: <20150715203508.GA14704@localhost.localdomain>
References: <20150714122311.8DA8EA0C9A@unicorn.suse.cz>
 <20150714134203.GG25674@breakpoint.cc>
 <20150714164225.GB8478@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150714164225.GB8478@unicorn.suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Jul 14, 2015 at 06:42:25PM +0200, Michal Kubecek wrote:
> On Tue, Jul 14, 2015 at 03:42:03PM +0200, Florian Westphal wrote:
> > Michal Kubecek <mkubecek@suse.cz> wrote:
> > > +	case SCTP_CID_HEARTBEAT:
> > > +		pr_debug("SCTP_CID_HEARTBEAT");
> > > +		i = 9;
> > > +		break;
> > > +	case SCTP_CID_HEARTBEAT_ACK:
> > > +		pr_debug("SCTP_CID_HEARTBEAT_ACK");
> > > +		i = 10;
> > > +		break;
> > >  	default:
> > >  		/* Other chunks like DATA, SACK, HEARTBEAT and
> > >  		its ACK do not cause a change in state */
> > > @@ -329,6 +351,8 @@ static int sctp_packet(struct nf_conn *ct,
> > >  	    !test_bit(SCTP_CID_COOKIE_ECHO, map) &&
> > >  	    !test_bit(SCTP_CID_ABORT, map) &&
> > >  	    !test_bit(SCTP_CID_SHUTDOWN_ACK, map) &&
> > > +	    !test_bit(SCTP_CID_HEARTBEAT, map) &&
> > > +	    !test_bit(SCTP_CID_HEARTBEAT_ACK, map) &&
> > >  	    sh->vtag != ct->proto.sctp.vtag[dir]) {
> > >  		pr_debug("Verification tag check failed\n");
> > >  		goto out;
> > > @@ -357,6 +381,16 @@ static int sctp_packet(struct nf_conn *ct,
> > >  			/* Sec 8.5.1 (D) */
> > >  			if (sh->vtag != ct->proto.sctp.vtag[dir])
> > >  				goto out_unlock;
> > > +		} else if (sch->type == SCTP_CID_HEARTBEAT ||
> > > +			   sch->type == SCTP_CID_HEARTBEAT_ACK) {
> > > +			if (ct->proto.sctp.vtag[dir] == 0) {
> > > +				pr_debug("Setting vtag %x for dir %d\n",
> > > +					 sh->vtag, dir);
> > > +				ct->proto.sctp.vtag[dir] = sh->vtag;
> > 
> > Could you please elaborate on the [dir] == 0 test?
> > 
> > I see this might happen for SCTP_CID_HEARTBEAT_ACK, but why is this
> > needed for SCTP_CID_HEARTBEAT ?
> > 
> > We found a conntrack entry so shouldn't the vtag[dir] already be > 0?
> 
> Yes, you are right. This was originally intended to handle the case when
> a HEARTBEAT in the reply direction is seen before the HEARTBEAT-ACK but
> such HEARTBEAT would be dropped anyway in current version.

And we have to keep the first vtag attempted because otherwise an
attacker could just probe for the right one until she gets a reply.

IOW, if a different vtag is attempted, we should drop it as the packet
doesn't belong to that association/conntrack entry.

As vtags are always != 0 in such case, that's a way to know if we
already have that information or not.

> On the other hand, an alternative would be
> 
> 		} else if (sch->type == SCTP_CID_HEARTBEAT_ACK &&
> 			   ct->proto.sctp.vtag[dir] == 0) {
> 			pr_debug("Setting vtag %x for dir %d\n",
> 				 sh->vtag, dir);
> 			ct->proto.sctp.vtag[dir] = sh->vtag;
> 		} else if ((sch->type == SCTP_CID_HEARTBEAT ||
> 			    sch->type == SCTP_CID_HEARTBEAT_ACK) &&
> 			   sh->vtag != ct->proto.sctp.vtag[dir]) {
> 			pr_debug("Verification tag check failed\n");
> 			goto out_unlock;
> 		}
> 
> I'm not sure it looks better.

Now it seems swapped, we should save the tag on HB and check on
HB_ACK only and would have to check against !dir entry. Like:

comments with // here are just informative on this email and may not
necessary in the code

 		} else if (sch->type == SCTP_CID_HEARTBEAT)
			if (!sh->vtag || sh->vtag != ct->proto.sctp.vtag[!dir]) {
				/* Invalid */
				goto out_unlock;
			}
 			else if (!ct->proto.sctp.vtag[!dir]) {
 				pr_debug("Setting vtag %x for dir %d\n",
 					 sh->vtag, dir);
				// by saving it on !dir direction, we
				// don't have to enable HB_ACK on that
				// if() above of exceptions, just HB
				// itself
 				ct->proto.sctp.vtag[!dir] = sh->vtag;
			}
			// fallthrough: no action because it's a vtag we
			// have already seen
 		} else if (sch->type == SCTP_CID_HEARTBEAT_ACK) {
			// it's guaranteed tht sh->vtag == ct->proto.sctp.vtag[dir]
			// by the if() of the exceptions above, so we
			// just have to check for vtag == 0
 			if (!sh->vtag) {
	 			pr_debug("Verification tag check failed\n");
 				goto out_unlock;
			}
			// ok, it's hand-shaked, now save it on the
			// other direction too so that further packets
			// can pass that check
			// if there was a vtag crossed some when, we
			// don't care as this one is now established.
 			ct->proto.sctp.vtag[dir] = sh->vtag;
 		}

I was also working on such implementation. Please give me some time to
map one thing to another. 

  Marcelo

