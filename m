From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
 feature-negotiation patches
Date: Mon, 08 Sep 2008 17:32:50 -0700 (PDT)
Message-ID: <20080908.173250.204419507.davem@davemloft.net>
References: <20080902.230655.89921076.davem@davemloft.net>
	<20080903081839.GA9001@gerrit.erg.abdn.ac.uk>
	<20080904061511.GA30756@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752867AbYIIAc4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 20:32:56 -0400
In-Reply-To: <20080904061511.GA30756@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 4 Sep 2008 08:15:11 +0200

> This is an update with regard to Wei's comments. I have re-synched 
> 
> 	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree `dccp']
> 	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=shortlog;h=dccp
> 
> Also did some testing with a client that only supports CCID 2/3 talking to a client supporting
> CCID 2/3/4. They could still negotiate and settle for a common CCID.

I pulled and resolved all of the conflicts, but this build warning I'm
now getting from ccid3.h has got to go:

/*
 * The t_delta parameter (RFC 3448, 4.6): delays of less than %USEC_PER_MSEC are
 * rounded down to 0, since sk_reset_timer() here uses millisecond granularity.
 * Hence we can use a constant t_delta = %USEC_PER_MSEC when HZ >= 500. A coarse
 * resolution of HZ < 500 means that the error is below one timer tick (t_gran)
 * when using the constant t_delta  =  t_gran / 2  =  %USEC_PER_SEC / (2 * HZ).
 */
#if (HZ >= 500)
# define TFRC_T_DELTA		   USEC_PER_MSEC
#else
# define TFRC_T_DELTA		   (USEC_PER_SEC / (2 * HZ))
#warning Coarse CONFIG_HZ resolution -- higher value recommended for TFRC.
#endif

Don't warn about crap like this, instead convert the code over to hrtimers.

This kernel being built, even with HZ=100, can do nanosecond timers on
my systems, but that's only if you would make proper use of them.
