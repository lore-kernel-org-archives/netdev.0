From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Thu, 26 Oct 2006 10:35:33 -0400
Message-ID: <1161873333.2927.9.camel@localhost.localdomain>
References: <20061024140212.GB17543@devicescape.com>
	 <C86180A8C204554D8A3323D8F6B0A29F018523A5@dhost002-46.dex002.intermedia.net>
	 <43e72e890610241503r692975dfx65b2eab987ffbb3d@mail.gmail.com>
	 <200610241853.03135.flamingice@sourmilk.net>
	 <43e72e890610251043y22fb9ce6ne5e036dd58f36505@mail.gmail.com>
	 <1161813628.8884.14.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Simon Barber <simon@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44735 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1423352AbWJZOgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 10:36:39 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1161813628.8884.14.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-10-26 at 00:00 +0200, Johannes Berg wrote:
> On Wed, 2006-10-25 at 13:43 -0400, Luis R. Rodriguez wrote:
> 
> > I guess my hope was that d80211 would just be more than a softmac
> > implementation. When I hear wireless stack I don't think "softmac
> > implementation", I think a robust set of headers and device
> > definitions which all wireless devices can share.
> 
> Not just that, a bunch of library functions for example for crypto would
> be nice too. That's part of why I've been proposing that the tkip stuff
> be library functions that the drivers can call if required, instead of
> the bitfields.
> 
> Currently, there's lot of top-down stuff in d80211, it does things which
> depend on flags and then instructs the driver to do something. This is
> good for a bunch of things, but in some cases where devices vary wildly
> it may be better to go for library functions instead. IMHO the TKIP key
> computation is such a case, it's trivial for a driver to call phase1 and
> phase2 when required.
> 
> > Also I thought we'd ditch WE as it seems we keep fixing it with gum
> > (as seen by Linville's latest ABI compatibility fix). 
> 
> Well, that was sort of necessary.
> 
> > If that wasn't
> > the case then I'm suggesting it -- can we consider ditching WE?
> 
> Well, no. We can make it a second-class citizen like I did with the
> cfg80211 work where I made it just one userspace interface for cfg80211
> which admittedly sometimes strange behaviour, but it's still there and
> current operations should still work with it (and I'd consider not
> working a bug except if userspace never calls 'commit' and expects
> things to work)
> 
> > I'd say lets just go for a
> > userspace MLME as its already written but I seriously think we need to
> > ditch replace WE first.
> 
> It seems no one has a plan on what to do though.
> 
>  - Jiri's trying to fix the SMP issues. That's great.
>  - Jiri also would like to expand ieee80211_conf.c, the stuff I
>    started for cfg80211
>  - I'd like to see a header cleanup, it's necessary. Part of the problem
>    here is all the sub-ioctl WE foo. Clean that up by moving them into
>    cfg80211 as required, there's basically one user, wpa_supplicant (and
>    maybe hostapd), screw the others if there are any

While wpa_supplicant is certainly the main client for stuff directly
related to setting up a connection, there are quite a few other users of
general WE calls to pull information out of the card, or to receive scan
events.  So if you want maximum compatibility for a limited amount of
work, you can probably consider wpa_supplicant the only client of

(s = set, g = get)

1) [s|g] ENCODEEXT
2) [s|g] AUTH
3) [s|g] MLME
4) [s] RATE
5) [s] FREQ
6) [s] SENS
7) [s] AP
8) [s|g] RTS
9) [s|g] FRAG
10)[s|g] GENIE
11)[s|g] PMKSA

Notable exceptions:
1) [s|g] ENCODE
2) [s|g] MODE (other stuff turns on promiscuous mode)
3) [s|g] SCAN (other stuff needs to do this too)
4) [s|g] POWER (power management does this, not wpa_supplicant)

Of course lots of stuff needs to get RATE, ESSID, AP, FREQ, etc.

Dan

>  - fix people's minds to not expect a perfect solution immediately but
>    accept something that can be expanded on later. I think we need to
>    accept some breakage in our development trees to get anywhere at all.
> 
> Actually, the last point should be first.
> 
> Enough rant from me for today,
> johannes

