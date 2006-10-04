From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Wed, 04 Oct 2006 16:19:20 +0200
Message-ID: <1159971561.2817.87.camel@ux156>
References: <1159435399.2648.17.camel@ux156>
	 <1159805711.2834.67.camel@localhost.localdomain>
	 <1159947674.2817.19.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:15042 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161029AbWJDOTL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 10:19:11 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1159947674.2817.19.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-04 at 09:41 +0200, Johannes Berg wrote:

> I don't really have an explicit ToDo list, but here are a few points
> that come to mind
>  * notification support when parameters change multicast a netlink
>    message to all subscribers of that group

I think we'll want at least two groups here:
 - scan results
 - configuration changes

can anyone think of more? NM might like to listen for config changes and
scan events, but most tools won't be that much concerned about config
changes... current wireless events are subsumed here as well.

>  * transmit status notification support for packet injection (sort of
>    ties in with the first point)

This should be a matter of saving the socket id of the requesting
nl80211 packet in the request structure, and having d80211/the driver
keep track of it and pass it back with the tx status structure to an
cfg80211_transmit_status(). Maybe a second cookie would be good too if
we ever gain packet injection capabilities over something other than
netlink. Thoughts?

>  * scan results (also somewhat related to the first point)

Should cfg80211 do the chore of keeping track of the whole scan results?
On the other hand, that doesn't seem to be doable with legacy hardware
that does all the scanning. So probably one call for
   cfg80211_notify_scan()
that takes a new scan result structure (taking a single BSSID etc.) and
notifies all listeners.
The same structure is used for get_scan() from the wiphy ops in an
iterator interface like some other calls.

>  * crypto and auth support

I really need someone to help me out with this one. So far I've seen
that we have commands for
 * getting crypto capabilities (several orthogonal issues, crypto
   algorithms as well as auth algorithms as well as key management?)
 * setting keys for both rx and tx
    - up to 4 default keys
    - setting WPA key(s?)
    - setting sta pairwise key (AP)
    - setting group key (AP, same as for STA?)
 * setting the WPA IE(s)
 * authentication (WE sticks so much into that call that I can't pull it
   apart, what exactly is needed?) looks like it needs (sub)commands for
    - allowed wpa versions (why is this AUTH??)
    - setting pairwise and group ciphers (again.. AUTH??)
    - setting key management (again.. AUTH??)
    - authentication algorithm (whew, something that really is auth)
    - roaming control (haha, already covered)
 * more?

johannes
