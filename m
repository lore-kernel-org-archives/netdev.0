From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3] net: Define enum for the bits used in features.
Date: Thu, 9 Jun 2011 23:12:30 +0300
Message-ID: <20110609201230.GA13278@redhat.com>
References: <20110606035808.GA28858@redhat.com>
 <20110605.221537.899061768025493519.davem@davemloft.net>
 <20110606153253.GB30665@redhat.com>
 <20110606.122059.261517215690508151.davem@davemloft.net>
 <20110606203515.GA2802@redhat.com>
 <20110609164645.GA10592@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: maheshb@google.com, netdev@vger.kernel.org, therbert@google.com,
	mirqus@gmail.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755345Ab1FIUMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 16:12:18 -0400
Content-Disposition: inline
In-Reply-To: <20110609164645.GA10592@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 09, 2011 at 07:46:45PM +0300, Michael S. Tsirkin wrote:
> On Mon, Jun 06, 2011 at 11:35:15PM +0300, Michael S. Tsirkin wrote:
> > On Mon, Jun 06, 2011 at 12:20:59PM -0700, David Miller wrote:
> > > From: "Michael S. Tsirkin" <mst@redhat.com>
> > > Date: Mon, 6 Jun 2011 18:32:53 +0300
> > > 
> > > > On Sun, Jun 05, 2011 at 10:15:37PM -0700, David Miller wrote:
> > > >> Since the GSO accessors deal with mutliple bits, you can create
> > > >> special GSO specific interfaces to manipulate them.
> > > > 
> > > > Yes but it's not just GSO.
> > > > It's anything that includes more than 1 feature.
> > > > Examples:
> > > > NETIF_F_ALL_CSUM
> > > > NETIF_F_ALL_TX_OFFLOADS
> > > > NETIF_F_V6_CSUM
> > > > NETIF_F_SOFT_FEATURES
> > > > 
> > > > etc
> > > > 
> > > > Creating many accessors for each will need a lot
> > > > of code duplication ...
> > > 
> > > Yet this is something you must resolve in order to change the feature
> > > bit implementation.
> > > 
> > > Whether this issue is difficult or not to address, it has to be done
> > > either way.
> > 
> > I think I found a truly elegant solution to this
> > problem which this margin is too narrow to contain ...
> 
> OK, it looks like using variadic macros from C99 makes this
> possible, even though use of ungarded comma in macros
> below makes me cringe:
> 
> /* Set all bits in the first 64 arguments, ignore the rest */
> #define NETIF_F_OR_64( \
> 	_000, _001 , _002 , _003 , _004 , _005 , _006 , _007, \
> 	_010, _011 , _012 , _013 , _014 , _015 , _016 , _017, \
> 	_020, _021 , _022 , _023 , _024 , _025 , _026 , _027, \
> 	_030, _031 , _032 , _033 , _034 , _035 , _036 , _037, \
> 	_040, _041 , _042 , _043 , _044 , _045 , _046 , _047, \
> 	_050, _051 , _052 , _053 , _054 , _055 , _056 , _057, \
> 	_060, _061 , _062 , _063 , _064 , _065 , _066 , _067, \
> 	_070, _071 , _072 , _073 , _074 , _075 , _076 , _077, \
> 	... ) \
> 	((_000) | (_001)  | (_002)  | (_003)  | (_004)  | (_005)  | (_006)  | (_007) | \
> 	 (_010) | (_011)  | (_012)  | (_013)  | (_014)  | (_015)  | (_016)  | (_017) | \
> 	 (_020) | (_021)  | (_022)  | (_023)  | (_024)  | (_025)  | (_026)  | (_027) | \
> 	 (_030) | (_031)  | (_032)  | (_033)  | (_034)  | (_035)  | (_036)  | (_037) | \
> 	 (_040) | (_041)  | (_042)  | (_043)  | (_044)  | (_045)  | (_046)  | (_047) | \
> 	 (_050) | (_051)  | (_052)  | (_053)  | (_054)  | (_055)  | (_056)  | (_057) | \
> 	 (_060) | (_061)  | (_062)  | (_063)  | (_064)  | (_065)  | (_066)  | (_067) | \
> 	 (_070) | (_071)  | (_072)  | (_073)  | (_074)  | (_075)  | (_076)  | (_077) )
> 
> /* Verify that argument #65 is zero */
> #define NETIF_F_BUG_ON_64( \
> 	_000, _001 , _002 , _003 , _004 , _005 , _006 , _007, \
> 	_010, _011 , _012 , _013 , _014 , _015 , _016 , _017, \
> 	_020, _021 , _022 , _023 , _024 , _025 , _026 , _027, \
> 	_030, _031 , _032 , _033 , _034 , _035 , _036 , _037, \
> 	_040, _041 , _042 , _043 , _044 , _045 , _046 , _047, \
> 	_050, _051 , _052 , _053 , _054 , _055 , _056 , _057, \
> 	_060, _061 , _062 , _063 , _064 , _065 , _066 , _067, \
> 	_070, _071 , _072 , _073 , _074 , _075 , _076 , _077, \
> 	_100, ... ) \
> 	BUG_ON((_100))
> 
> /* Set multiple bits in f. At most 64 bits can be
>  * set in this way.
>  * Nested calls are padded with 0 arguments
>  * to ensure there are at least 64 of them */
> #define NETIF_F_INIT(f, ...) do { \
> 	f |= NETIF_F_OR_64(__VA_ARGS__, \
> 			0, 0, 0, 0, 0, 0, 0, 0,\
> 			0, 0, 0, 0, 0, 0, 0, 0,\
> 			0, 0, 0, 0, 0, 0, 0, 0,\
> 			0, 0, 0, 0, 0, 0, 0, 0,\
> 			0, 0, 0, 0, 0, 0, 0, 0,\
> 			0, 0, 0, 0, 0, 0, 0, 0,\
> 			0, 0, 0, 0, 0, 0, 0, 0,\
> 			0, 0, 0, 0, 0, 0, 0, 0 \
> 		       ); \
> 	NETIF_F_BUG_ON_64(__VA_ARGS__, \
> 		      0, 0, 0, 0, 0, 0, 0, 0,\
> 		      0, 0, 0, 0, 0, 0, 0, 0,\
> 		      0, 0, 0, 0, 0, 0, 0, 0,\
> 		      0, 0, 0, 0, 0, 0, 0, 0,\
> 		      0, 0, 0, 0, 0, 0, 0, 0,\
> 		      0, 0, 0, 0, 0, 0, 0, 0,\
> 		      0, 0, 0, 0, 0, 0, 0, 0,\
> 		      0, 0, 0, 0, 0, 0, 0, 0 \
> 		     ); \
> } while (0)


One thing I realized is there's no reason for
NETIF_F_INIT to get the ellipsis ... as we don't want users
to pass arbitrary lists of features, just the
predefined sets. So this can be a simpler:

 #define NETIF_F_INIT(f, bits) do { \
 	f |= NETIF_F_OR_64(bits, \
 			0, 0, 0, 0, 0, 0, 0, 0,\
 			0, 0, 0, 0, 0, 0, 0, 0,\
 			0, 0, 0, 0, 0, 0, 0, 0,\
 			0, 0, 0, 0, 0, 0, 0, 0,\
 			0, 0, 0, 0, 0, 0, 0, 0,\
 			0, 0, 0, 0, 0, 0, 0, 0,\
 			0, 0, 0, 0, 0, 0, 0, 0,\
 			0, 0, 0, 0, 0, 0, 0, 0 \
 		       ); 

> And now:
> #define NETIF_F_GSO_SOFTWARE	 NETIF_F_TSO , NETIF_F_TSO_ECN , \
> 				 NETIF_F_TSO6 , NETIF_F_UFO
> 
> 
> which makes
> 
> 	NETIF_F_INIT(z, NETIF_F_GSO_SOFTWARE);
> 
> work as expected, and set all necessary bits,
> so all we need to do is replace
> 	z = NETIF_F_GSO_SOFTWARE;
> with call to macro above.
> 
> At most 64 different bits can be passed in this way
> but NETIF_F_BUG_ON_64 above checks that.
> If we want more than 64 bits, we just update
> these macro definitions.
> 
> It seems that behaviour above is guaranteed by the language spec,
> specifically the argument prescan rule.
> Any C99 experts want to comment on this?

OK, the confirmation was located in C99 standard,
chapter 6.10.3.1 Argument substitution.

> I have my doubts about whether the above is way too clever
> even if it works. What do others think?
> 
> 
> > -- 
> > MST
