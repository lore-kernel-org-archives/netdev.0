From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: prints bogus hoplimit
Date: Wed, 18 Mar 2009 18:01:06 -0700
Message-ID: <20090318180106.5115c0aa@nehalam>
References: <alpine.LSU.2.00.0902241125020.329@fbirervta.pbzchgretzou.qr>
	<20090318151216.60cd0363@nehalam>
	<20090318.175109.14058201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53987 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbZCSBBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 21:01:16 -0400
In-Reply-To: <20090318.175109.14058201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Mar 2009 17:51:09 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 18 Mar 2009 15:12:16 -0700
> 
> > On Tue, 24 Feb 2009 11:27:52 +0100 (CET)
> > Jan Engelhardt <jengelh@medozas.de> wrote:
> > 
> > > 
> > > $ ip -6 r
> > > fc00::/7 dev rtl0  proto kernel  metric 256  mtu 1500 advmss 1440 
> > > hoplimit 4294967295
> > > 
> > > Most likely, "hoplimit -1" would be the right number, though I am not 
> > > sure if simply changing %u by %d is a correct thing to do, since it 
> > > would affect all fields.
>  ...
> > > diff --git a/ip/iproute.c b/ip/iproute.c
> > > index 6a2ea05..91a8cc0 100644
> > > --- a/ip/iproute.c
> > > +++ b/ip/iproute.c
> > > @@ -507,7 +507,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
> > >  
> > >  			if (i != RTAX_RTT && i != RTAX_RTTVAR &&
> > >  			    i != RTAX_RTO_MIN)
> > > -				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
> > > +				fprintf(fp, " %d", *(unsigned*)RTA_DATA(mxrta[i]));
> > >  			else {
> > >  				unsigned long long val = *(unsigned*)RTA_DATA(mxrta[i]);
> > >  
> > 
> > No fix the kernel please.
> 
> I don't know what you mean by this Stephen.  Why don't you take
> a look at when and why the kernel uses '-1'?
> 
> "-1" is the hoplimit the kernel uses in the dst metric to mean
> "use the default".
> 
> So this iproute patch is absolutely correct, or alternatively, iproute
> can print "default" when it sees '-1'.
> 

if I create route with:
   ip route add ... hoplimit 0
then to do
   ip route show 
one would expect the hoplimit in the show to match the add ??
Whether the kernel fudges it in rt6_fill or utility has special case
code really doesn't matter.

The correct patch in utility would be something like:

diff --git a/ip/iproute.c b/ip/iproute.c
index 6a2ea05..bf0f31b 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -493,6 +493,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			mxlock = *(unsigned*)RTA_DATA(mxrta[RTAX_LOCK]);
 
 		for (i=2; i<= RTAX_MAX; i++) {
+			unsigned val;
+
 			if (mxrta[i] == NULL)
 				continue;
 			if (!hz)
@@ -505,21 +507,31 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			if (mxlock & (1<<i))
 				fprintf(fp, " lock");
 
-			if (i != RTAX_RTT && i != RTAX_RTTVAR &&
-			    i != RTAX_RTO_MIN)
-				fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
-			else {
-				unsigned long long val = *(unsigned*)RTA_DATA(mxrta[i]);
+			val = *(unsigned*)RTA_DATA(mxrta[i]);
+			switch (i) {
+			case RTAX_HOPLIMIT:
+				if ((long)val == -1)
+					val = 0;
+				/* fall through */
+			default:
+				fprintf(fp, " %u", val);
+				break;
 
+			case RTAX_RTT:
+			case RTAX_RTTVAR:
+			case RTAX_RTO_MIN:
 				val *= 1000;
 				if (i == RTAX_RTT)
 					val /= 8;
 				else if (i == RTAX_RTTVAR)
 					val /= 4;
+
 				if (val >= hz)
-					fprintf(fp, " %llums", val/hz);
+					fprintf(fp, " %llums",
+						(unsigned long long) val / hz);
 				else
-					fprintf(fp, " %.2fms", (float)val/hz);
+					fprintf(fp, " %.2fms", 
+						(double)val / hz);
 			}
 		}
 	}

