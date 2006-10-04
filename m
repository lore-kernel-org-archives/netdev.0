From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Wed, 04 Oct 2006 13:57:38 -0400
Message-ID: <1159984658.3287.98.camel@localhost.localdomain>
References: <1159435399.2648.17.camel@ux156>
	 <1159805711.2834.67.camel@localhost.localdomain>
	 <1159947674.2817.19.camel@ux156>  <1159971561.2817.87.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56486 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1161813AbWJDSBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 14:01:44 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1159971561.2817.87.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-04 at 16:19 +0200, Johannes Berg wrote:
> On Wed, 2006-10-04 at 09:41 +0200, Johannes Berg wrote:
> 
> > I don't really have an explicit ToDo list, but here are a few points
> > that come to mind
> >  * notification support when parameters change multicast a netlink
> >    message to all subscribers of that group
> 
> I think we'll want at least two groups here:
>  - scan results
>  - configuration changes
> 
> can anyone think of more? NM might like to listen for config changes and
> scan events, but most tools won't be that much concerned about config
> changes... current wireless events are subsumed here as well.

Are we talking about config changes when some other process pushes a new
config to the card, or when something happens over the air, like new
association or deauth?

> >  * transmit status notification support for packet injection (sort of
> >    ties in with the first point)
> 
> This should be a matter of saving the socket id of the requesting
> nl80211 packet in the request structure, and having d80211/the driver
> keep track of it and pass it back with the tx status structure to an
> cfg80211_transmit_status(). Maybe a second cookie would be good too if
> we ever gain packet injection capabilities over something other than
> netlink. Thoughts?
> 
> >  * scan results (also somewhat related to the first point)
> 
> Should cfg80211 do the chore of keeping track of the whole scan results?
> On the other hand, that doesn't seem to be doable with legacy hardware
> that does all the scanning. So probably one call for
>    cfg80211_notify_scan()
> that takes a new scan result structure (taking a single BSSID etc.) and
> notifies all listeners.
> The same structure is used for get_scan() from the wiphy ops in an
> iterator interface like some other calls.

Is it a problem to actually push the _entire_ scan list out to clients
over netlink?  The scan list could be quite large, maybe even a few
kilobytes when stuff like Information Elements, ratesets, etc is
available.  I've seen 35-item scan lists that are already around 1.5K.

Ideally, we could push the whole scan list to clients, and then we avoid
the race between getting the scan result notification and hitting the
card.  That said, as long as the driver does proper locking, the race
condition shouldn't matter at all.

I'd vote for pushing results along with the notification, because one of
the most annoying things in the past was the inconsistency between how
drivers reported results and what BSSID attributes they sent.  If we can
_standardize_ the result list and its construction inside
cfg80211/nl80211 that would be a great benefit.

If we can't push results with the notification, at least provide some
functions to build up the GET_SCAN reply message, which you'll likely
have to do anyway once you implement GET_SCAN.  We _really_ need drivers
to be consistent here.

> >  * crypto and auth support

I've done a lot of thinking about crypto/auth this morning while beating
the hell out of the libertas 8388 driver to clean up the ENCODE support.

There are several issues here.  They can be roughly split by encryption
algorithm.  But the big question:

    Is there a case for _multiple_ encryption algorithms enabled
    on a single "virtual" interface at one time?

I don't think there is, and I think that just complicates things in
d80211 anyway.  If we agree that you can only set one of [none, WEP,
WPA] on a virtual interface at any given time, it makes the crypto
interface for nl80211 a lot easier.

Part of the problem of WE right now is that there's no clear API
separation between the different options.  You can pass some WEP options
through when you really want to do WPA (like key indexes).  That makes
the driver handling code for ENCODE and ENCODEEXT too complex.

Taking one-at-a-time as a given, and the pseudo-structure

struct cmd_crypto {
	enum crypto_alg alg;
	union data {
		none_data;
		wep_data;
		wpa_data;
		...
	};
};

Set alg == <whatever>, set the options, and the driver will _enable_
that crypto mode with the given options.  It makes no sense at all to,
say, set the WEP transmit key index or WEP key when the card is in WPA
mode or no-crypto mode.

It's important to note that some options are independent of the initial
operation that enabled the crypto, and need to be set later without
triggering deauth and such.  Setting non-TX-index WEP key is one such
operation.  I should be able to set WEP keys at indexes other than the
transmit key index without affecting operation of the card (unless some
hardware/firmware issue prevents this).

- No crypto
- WEP encryption (following ops are independent of each other):
    - Set TX key index
    - Set privacy invoked
    - Set exclude unencrypted packets
    - Set authentication mode (open, shared-key, or both)
    - Set (or clear) WEP key 1, 2, 3, or 4
- WPA/WPA2/IEEE8021X
    - Jouni/others would know better and my brain is fried right now

All the WEP options should be independent attributes in nl80211.  You
could even have a generic WEPKey attribute that is defined like so:

ATTR_WEP_KEY {
	enum type (one of DISABLE, TYPE_40, TYPE_104, TYPE_152)
	char * key_material
	enum index (one of DEFAULT, 1, 2, 3, 4)
}

(I tend to think the more enums we use, and not magic numbers, the
clearer it gets in the code.)

That way, you can attach as many key attribues (or as few) as you wish.
You could set all 4 keys at one time.  You could set 1 now and 1 later.

> I really need someone to help me out with this one. So far I've seen
> that we have commands for
>  * getting crypto capabilities (several orthogonal issues, crypto
>    algorithms as well as auth algorithms as well as key management?)
>  * setting keys for both rx and tx
>     - up to 4 default keys

Some cards, like older aironet ones, can only do 1 key.  I don't want to
pollute nl80211 with limitations like that though, so the driver can
just return -EINVAL if the card doesn't support it.  I don't think it
pays to have capability bits for something as far down in the driver
implementation as this. 

>     - setting WPA key(s?)
>     - setting sta pairwise key (AP)
>     - setting group key (AP, same as for STA?)
>  * setting the WPA IE(s)
>  * authentication (WE sticks so much into that call that I can't pull it
>    apart, what exactly is needed?) looks like it needs (sub)commands for

Much of this comes from the Mind Of Jouni, so he's best qualified to
comment...

My impression of ENCODE and ENCODEEXT was that they were _just_ for
setting keying material (except in the case of WEP where you set the
auth mode open/shared too), and that AUTH was for higher level stuff.

>     - allowed wpa versions (why is this AUTH??)

Can you do both WPA and WPA2 at the same time?  You can certainly
advertise both a WPA IE and an RSN IE at the same time.  Is it possible
to auth both types of clients?

>     - setting pairwise and group ciphers (again.. AUTH??)

Note that ENCODEEXT has a group key flag IW_ENCODE_EXT_GROUP_KEY too.
The pairwise and group cipher stuff in AUTH only sets the cipher _type_,
not the actual key material AFAICT.

------------

I think there's a lot of room to rework the API here.  It seems you can
more or less mix & match authentication, encryption, and key management,
with some restrictions.  I definitely don't know this as well as people
like Jouni so I'm likely to be wrong about some stuff, but here goes to
start with:

* None
    - Crypto: None
    - 802.11 Auth: Open System

* Static WEP
    - Keys: up to 4 group keys
    - Crypto: WEP-40, WEP-104, WEP-152, WEP-256
    - 802.11 Auth: Open System or Shared Key
    - Key Mgmt/Auth: none

* Dynamic WEP (LEAP?)
    - Keys: up to 4 group keys
    - Crypto: WEP-40, WEP-104, WEP-152, WEP-256
    - 802.11 Auth: Open System (only?)
    - Key Mgmt/Auth: IEEE 802.1x with LEAP or EAP

* WPA PSK
    - Keys: pairwise & group
    - Use WPA IEs
    - 802.11 Auth: Open System
    - Crypto: TKIP or CCMP
    - Key Mgmt/Auth: WPA-PSK (elided 802.1x)

* WPA Enterprise
    - Keys: pairwise & group
    - Use WPA IEs
    - 802.11 Auth: Open System
    - Crypto: TKIP or CCMP
    - Key Mgmt/Auth: WPA-EAP (full 802.1x)

* WPA2 PSK
    - Keys: pairwise & group
    - Use RSN IEs
    - 802.11 Auth: Open System
    - Crypto: TKIP or CCMP
    - Key Mgmt/Auth: WPA-PSK (elided 802.1x)

* WPA2 Enterprise
    - Keys: pairwise & group
    - Use RSN IEs
    - 802.11 Auth: Open System
    - Crypto: TKIP or CCMP
    - Key Mgmt/Auth: WPA-EAP (full 802.1x)

Wheee!  So you basically have a bunch of buckets and you just pull shit
out of them at random, stick it all together, and you've got a wireless
connection :)  Thank you, Cisco.  Thank you, Wi-Fi Alliance.

Dan


