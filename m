From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Thu, 05 Oct 2006 09:59:22 +0200
Message-ID: <1160035162.2728.15.camel@ux156>
References: <1159435399.2648.17.camel@ux156>
	 <1159805711.2834.67.camel@localhost.localdomain>
	 <1159947674.2817.19.camel@ux156>  <1159971561.2817.87.camel@ux156>
	 <1159984658.3287.98.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:43985 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751160AbWJEH6d
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 03:58:33 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1159984658.3287.98.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-04 at 13:57 -0400, Dan Williams wrote:

> Are we talking about config changes when some other process pushes a new
> config to the card, or when something happens over the air, like new
> association or deauth?

Well, both actually :) Yeah, we should have different groups for that.

> Is it a problem to actually push the _entire_ scan list out to clients
> over netlink?  The scan list could be quite large, maybe even a few
> kilobytes when stuff like Information Elements, ratesets, etc is
> available.  I've seen 35-item scan lists that are already around 1.5K.

35-item list at 1.5K, heh, the allocated skbs are always at least 4k so
we can just push that out in full I guess. Though scan lists with
nl80211 will be slightly larger (some genetlink overhead) than the
bit-packed WE stuff.

> Ideally, we could push the whole scan list to clients, and then we avoid
> the race between getting the scan result notification and hitting the
> card.  That said, as long as the driver does proper locking, the race
> condition shouldn't matter at all.

Heh yeah.

> I'd vote for pushing results along with the notification, because one of
> the most annoying things in the past was the inconsistency between how
> drivers reported results and what BSSID attributes they sent.  If we can
> _standardize_ the result list and its construction inside
> cfg80211/nl80211 that would be a great benefit.

Well, I'm thinking that drivers provide an iterator that provides a scan
result structure for each result and nl80211 iterates over that building
up the netlink message. That way, they just have to fill in such a
structure for each iteration, which should ease things.

> If we can't push results with the notification, at least provide some
> functions to build up the GET_SCAN reply message, which you'll likely
> have to do anyway once you implement GET_SCAN.  We _really_ need drivers
> to be consistent here.

Same thing, get_scan() gives an iterator function that the driver calls
for each result it has with the same scan result struct.

> > >  * crypto and auth support
> 
> I've done a lot of thinking about crypto/auth this morning while beating
> the hell out of the libertas 8388 driver to clean up the ENCODE support.
> 
> There are several issues here.  They can be roughly split by encryption
> algorithm.  But the big question:
> 
>     Is there a case for _multiple_ encryption algorithms enabled
>     on a single "virtual" interface at one time?
> 
> I don't think there is, and I think that just complicates things in
> d80211 anyway.  If we agree that you can only set one of [none, WEP,
> WPA] on a virtual interface at any given time, it makes the crypto
> interface for nl80211 a lot easier.

I can't see a case point for that. Although maybe for AP interfaces? But
does that make sense to have some stations with say TKIP and others with
AES, and is that even negotiable? In any case, I think a STA inside an
AP should be treated mostly like a single "STA virtual interface" which
surely doesn't need multiple algorithms.

> Part of the problem of WE right now is that there's no clear API
> separation between the different options.  You can pass some WEP options
> through when you really want to do WPA (like key indexes).  That makes
> the driver handling code for ENCODE and ENCODEEXT too complex.
> 
> Taking one-at-a-time as a given, and the pseudo-structure
> 
> struct cmd_crypto {
> 	enum crypto_alg alg;
> 	union data {
> 		none_data;
> 		wep_data;
> 		wpa_data;
> 		...
> 	};
> };
> 
> Set alg == <whatever>, set the options, and the driver will _enable_
> that crypto mode with the given options.  It makes no sense at all to,
> say, set the WEP transmit key index or WEP key when the card is in WPA
> mode or no-crypto mode.

That makes sense; in netlink it'd be represented by a message containing
a algorithm attribute and then attributes for all the other things and
not those attributes for say WPA if you use WEP.

> It's important to note that some options are independent of the initial
> operation that enabled the crypto, and need to be set later without
> triggering deauth and such.  Setting non-TX-index WEP key is one such
> operation.  I should be able to set WEP keys at indexes other than the
> transmit key index without affecting operation of the card (unless some
> hardware/firmware issue prevents this).
> 
> - No crypto
> - WEP encryption (following ops are independent of each other):
>     - Set TX key index
>     - Set privacy invoked

what is that?

>     - Set exclude unencrypted packets
>     - Set authentication mode (open, shared-key, or both)
>     - Set (or clear) WEP key 1, 2, 3, or 4
> - WPA/WPA2/IEEE8021X
>     - Jouni/others would know better and my brain is fried right now
> 
> All the WEP options should be independent attributes in nl80211.  You
> could even have a generic WEPKey attribute that is defined like so:
> 
> ATTR_WEP_KEY {
> 	enum type (one of DISABLE, TYPE_40, TYPE_104, TYPE_152)
> 	char * key_material
> 	enum index (one of DEFAULT, 1, 2, 3, 4)
> }
> 
> (I tend to think the more enums we use, and not magic numbers, the
> clearer it gets in the code.)

Yeah. I'd probably add an ATTR_KEY_INDEX and ATTR_KEY_MATERIAL and
ATTR_WEP_TYPE which are to be used together with ATTR_KEY_TYPE==WEP, for
AES you'd also use ATTR_KEY_MATERIAL but not the others, etc.

> That way, you can attach as many key attribues (or as few) as you wish.
> You could set all 4 keys at one time.  You could set 1 now and 1 later.

Hm, I don't see why you need to set 4 keys at a time and it somewhat
complicates the netlink API.

> > I really need someone to help me out with this one. So far I've seen
> > that we have commands for
> >  * getting crypto capabilities (several orthogonal issues, crypto
> >    algorithms as well as auth algorithms as well as key management?)
> >  * setting keys for both rx and tx
> >     - up to 4 default keys
> 
> Some cards, like older aironet ones, can only do 1 key.  I don't want to
> pollute nl80211 with limitations like that though, so the driver can
> just return -EINVAL if the card doesn't support it.  I don't think it
> pays to have capability bits for something as far down in the driver
> implementation as this. 

Yeah, that's fine, drivers can return errors all the time.

> >     - setting WPA key(s?)
> >     - setting sta pairwise key (AP)
> >     - setting group key (AP, same as for STA?)
> >  * setting the WPA IE(s)
> >  * authentication (WE sticks so much into that call that I can't pull it
> >    apart, what exactly is needed?) looks like it needs (sub)commands for
> 
> Much of this comes from the Mind Of Jouni, so he's best qualified to
> comment...

:)

> My impression of ENCODE and ENCODEEXT was that they were _just_ for
> setting keying material (except in the case of WEP where you set the
> auth mode open/shared too), and that AUTH was for higher level stuff.
> 
> >     - allowed wpa versions (why is this AUTH??)
> 
> Can you do both WPA and WPA2 at the same time?  You can certainly
> advertise both a WPA IE and an RSN IE at the same time.  Is it possible
> to auth both types of clients?

I have no idea. Jouni?

> >     - setting pairwise and group ciphers (again.. AUTH??)
> 
> Note that ENCODEEXT has a group key flag IW_ENCODE_EXT_GROUP_KEY too.
> The pairwise and group cipher stuff in AUTH only sets the cipher _type_,
> not the actual key material AFAICT.

Eh, ok.

> I think there's a lot of room to rework the API here.  It seems you can
> more or less mix & match authentication, encryption, and key management,
> with some restrictions.  I definitely don't know this as well as people
> like Jouni so I'm likely to be wrong about some stuff, but here goes to
> start with:
> 
> * None
>     - Crypto: None
>     - 802.11 Auth: Open System
> 
> * Static WEP
>     - Keys: up to 4 group keys
>     - Crypto: WEP-40, WEP-104, WEP-152, WEP-256
>     - 802.11 Auth: Open System or Shared Key
>     - Key Mgmt/Auth: none
> 
> * Dynamic WEP (LEAP?)
>     - Keys: up to 4 group keys
>     - Crypto: WEP-40, WEP-104, WEP-152, WEP-256
>     - 802.11 Auth: Open System (only?)
>     - Key Mgmt/Auth: IEEE 802.1x with LEAP or EAP
> 
> * WPA PSK
>     - Keys: pairwise & group
>     - Use WPA IEs
>     - 802.11 Auth: Open System
>     - Crypto: TKIP or CCMP
>     - Key Mgmt/Auth: WPA-PSK (elided 802.1x)
> 
> * WPA Enterprise
>     - Keys: pairwise & group
>     - Use WPA IEs
>     - 802.11 Auth: Open System
>     - Crypto: TKIP or CCMP
>     - Key Mgmt/Auth: WPA-EAP (full 802.1x)
> 
> * WPA2 PSK
>     - Keys: pairwise & group
>     - Use RSN IEs
>     - 802.11 Auth: Open System
>     - Crypto: TKIP or CCMP
>     - Key Mgmt/Auth: WPA-PSK (elided 802.1x)
> 
> * WPA2 Enterprise
>     - Keys: pairwise & group
>     - Use RSN IEs
>     - 802.11 Auth: Open System
>     - Crypto: TKIP or CCMP
>     - Key Mgmt/Auth: WPA-EAP (full 802.1x)
> 
> Wheee!  So you basically have a bunch of buckets and you just pull shit
> out of them at random, stick it all together, and you've got a wireless
> connection :)  Thank you, Cisco.  Thank you, Wi-Fi Alliance.

:)

I'll have to think about this for a bit, but thanks again for your
comments :)

johannes
