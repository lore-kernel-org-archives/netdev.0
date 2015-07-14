From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH nf-next] netfilter: nf_ct_sctp: minimal multihoming
 support
Date: Tue, 14 Jul 2015 18:42:25 +0200
Message-ID: <20150714164225.GB8478@unicorn.suse.cz>
References: <20150714122311.8DA8EA0C9A@unicorn.suse.cz>
 <20150714134203.GG25674@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150714134203.GG25674@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 14, 2015 at 03:42:03PM +0200, Florian Westphal wrote:
> Michal Kubecek <mkubecek@suse.cz> wrote:
> > +	case SCTP_CID_HEARTBEAT:
> > +		pr_debug("SCTP_CID_HEARTBEAT");
> > +		i = 9;
> > +		break;
> > +	case SCTP_CID_HEARTBEAT_ACK:
> > +		pr_debug("SCTP_CID_HEARTBEAT_ACK");
> > +		i = 10;
> > +		break;
> >  	default:
> >  		/* Other chunks like DATA, SACK, HEARTBEAT and
> >  		its ACK do not cause a change in state */
> > @@ -329,6 +351,8 @@ static int sctp_packet(struct nf_conn *ct,
> >  	    !test_bit(SCTP_CID_COOKIE_ECHO, map) &&
> >  	    !test_bit(SCTP_CID_ABORT, map) &&
> >  	    !test_bit(SCTP_CID_SHUTDOWN_ACK, map) &&
> > +	    !test_bit(SCTP_CID_HEARTBEAT, map) &&
> > +	    !test_bit(SCTP_CID_HEARTBEAT_ACK, map) &&
> >  	    sh->vtag != ct->proto.sctp.vtag[dir]) {
> >  		pr_debug("Verification tag check failed\n");
> >  		goto out;
> > @@ -357,6 +381,16 @@ static int sctp_packet(struct nf_conn *ct,
> >  			/* Sec 8.5.1 (D) */
> >  			if (sh->vtag != ct->proto.sctp.vtag[dir])
> >  				goto out_unlock;
> > +		} else if (sch->type == SCTP_CID_HEARTBEAT ||
> > +			   sch->type == SCTP_CID_HEARTBEAT_ACK) {
> > +			if (ct->proto.sctp.vtag[dir] == 0) {
> > +				pr_debug("Setting vtag %x for dir %d\n",
> > +					 sh->vtag, dir);
> > +				ct->proto.sctp.vtag[dir] = sh->vtag;
> 
> Could you please elaborate on the [dir] == 0 test?
> 
> I see this might happen for SCTP_CID_HEARTBEAT_ACK, but why is this
> needed for SCTP_CID_HEARTBEAT ?
> 
> We found a conntrack entry so shouldn't the vtag[dir] already be > 0?

Yes, you are right. This was originally intended to handle the case when
a HEARTBEAT in the reply direction is seen before the HEARTBEAT-ACK but
such HEARTBEAT would be dropped anyway in current version.

On the other hand, an alternative would be

		} else if (sch->type == SCTP_CID_HEARTBEAT_ACK &&
			   ct->proto.sctp.vtag[dir] == 0) {
			pr_debug("Setting vtag %x for dir %d\n",
				 sh->vtag, dir);
			ct->proto.sctp.vtag[dir] = sh->vtag;
		} else if ((sch->type == SCTP_CID_HEARTBEAT ||
			    sch->type == SCTP_CID_HEARTBEAT_ACK) &&
			   sh->vtag != ct->proto.sctp.vtag[dir]) {
			pr_debug("Verification tag check failed\n");
			goto out_unlock;
		}

I'm not sure it looks better.

Michal Kubecek
