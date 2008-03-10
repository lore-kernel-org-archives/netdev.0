From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ethtool: command line support for lro
Date: Mon, 10 Mar 2008 11:29:49 -0700
Message-ID: <20080310112949.153a8cd5@extreme>
References: <1204898997.4220.41.camel@moonstone.uk.level5networks.com>
	<20080307082538.1a674ae1@extreme>
	<1204909575.4220.71.camel@moonstone.uk.level5networks.com>
	<20080307134312.037e2cf6@extreme>
	<20080310180706.GF12660@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50190 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755492AbYCJSaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2008 14:30:17 -0400
In-Reply-To: <20080310180706.GF12660@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Mar 2008 18:07:07 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> Stephen Hemminger wrote:
> > Add lro support to command in similar manner to TSO, GSO, etc.
> > The file ethtool-copy.h is updated to be sanitised version of
> > ethtool.h from 2.6.25-rc4 (ie make headers_install)
> 
> I already posted a patch to do this, though I didn't update
> ethtool-copy.h.
> 
> > Not tested on actual LRO hardware.
> 
> Mine was, and this looks very similar.
> 
> > @@ -1559,12 +1566,20 @@ static int do_goffload(int fd, struct ifreq *ifr)
> >  		allfail = 0;
> >  	}
> >  
> > +	eval.cmd = ETHTOOL_GFLAGS;
> > +	ifr->ifr_data = (caddr_t)&eval;
> > +	err = ioctl(fd, SIOCETHTOOL, ifr);
> > +	if (!err) {
> > +		lro = eval.data & ETH_FLAG_LRO;
> > +		allfail = 0;
> > +	}
> > +
> 
> To be consistent, this should print a specific error if the ioctl
> fails.

No, since most hardware won't support LRO or the flags, it makes sense not
to complain when fetching the value.

> > @@ -1641,6 +1656,30 @@ static int do_soffload(int fd, struct ifreq *ifr)
> >  			return 90;
> >  		}
> >  	}
> > +	if (off_lro_wanted >= 0) {
> > +		changed = 1;
> > +		eval.cmd = ETHTOOL_GFLAGS;
> > +		eval.data = 0;
> > +		ifr->ifr_data = (caddr_t)&eval;
> > +		err = ioctl(fd, SIOCETHTOOL, ifr);
> > +		if (err) {
> > +			perror("Cannot get device flag settings");
> > +			return 90;
> > +		}
> 
> I didn't bother fetching the existing flags because only ETH_FLAG_LRO
> is defined.  But this would be more future-proof.
> 
> > +
> > +		eval.cmd = ETHTOOL_SFLAGS;
> > +		if (off_lro_wanted == 1)
> > +			eval.data |= ETH_FLAG_LRO;
> > +		else
> > +			eval.data &= ~ETH_FLAG_LRO;
> > +			
> > +		err = ioctl(fd, SIOCETHTOOL, ifr);
> > +		if (err) {
> > +			perror("Cannot set large receive offload settings");
> > +			return 90;
> > +		}
> 
> The error return codes are unique so far, so these error paths
> should return 91 and 92, not 90.
> 
> Ben.
> 

Sure.
