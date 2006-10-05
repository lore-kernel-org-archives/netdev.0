From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [RFC] cfg80211 and nl80211
Date: Thu, 5 Oct 2006 09:20:06 -0700
Message-ID: <20061005162006.GC17517@instant802.com>
References: <1159435399.2648.17.camel@ux156> <1159805711.2834.67.camel@localhost.localdomain> <1159947674.2817.19.camel@ux156> <1159971561.2817.87.camel@ux156> <1159984658.3287.98.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-45.dex002.intermedia.net ([64.78.21.137]:53058 "EHLO
	dhost002-45.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751301AbWJEQUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 12:20:21 -0400
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1159984658.3287.98.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 04, 2006 at 01:57:38PM -0400, Dan Williams wrote:
> On Wed, 2006-10-04 at 16:19 +0200, Johannes Berg wrote:
> > On Wed, 2006-10-04 at 09:41 +0200, Johannes Berg wrote:

> > Should cfg80211 do the chore of keeping track of the whole scan results?
> > On the other hand, that doesn't seem to be doable with legacy hardware
> > that does all the scanning. So probably one call for
> >    cfg80211_notify_scan()
> > that takes a new scan result structure (taking a single BSSID etc.) and
> > notifies all listeners.
> > The same structure is used for get_scan() from the wiphy ops in an
> > iterator interface like some other calls.
> 
> Is it a problem to actually push the _entire_ scan list out to clients
> over netlink?  The scan list could be quite large, maybe even a few
> kilobytes when stuff like Information Elements, ratesets, etc is
> available.  I've seen 35-item scan lists that are already around 1.5K.

1.5 KB sounds like a small scan result set to me.. I'm hitting 100+
BSSes at work (well, not really your normal environment ;-), and 50 at
home.. These go way beyond 1.5 KB; closer to 32 KB at times, I'd guess.

> There are several issues here.  They can be roughly split by encryption
> algorithm.  But the big question:
> 
>     Is there a case for _multiple_ encryption algorithms enabled
>     on a single "virtual" interface at one time?

What exactly do you mean with this? WPA allows different STAs associated
with an AP to use different unicast encryption algorithms. This means
that a client may need to use CCMP with key index 0 for unicast and TKIP
with key index 1 for multicast.

> Taking one-at-a-time as a given, and the pseudo-structure
> 
> struct cmd_crypto {
> 	enum crypto_alg alg;
> 	union data {
> 		none_data;
> 		wep_data;
> 		wpa_data;

wep vs. wpa in crypto configuration does not make sense to me. WPA uses
multiple ciphers; even WEP is allowed for group keys..

> Set alg == <whatever>, set the options, and the driver will _enable_
> that crypto mode with the given options.  It makes no sense at all to,
> say, set the WEP transmit key index or WEP key when the card is in WPA
> mode or no-crypto mode.

What is this "WPA" mode? Please note that IEEE 802.11i allows WEP to be
used for group (multicast/broadcast) keys.. WPA should not be mixed in
here with encryption key configuration. The are different encryption
algorithms, like WEP, TKIP, CCMP, and they need to have keys and other
parameters like key index and seq# configured. This is regardless of
whether WPA is used or not.

> It's important to note that some options are independent of the initial
> operation that enabled the crypto, and need to be set later without
> triggering deauth and such.  Setting non-TX-index WEP key is one such
> operation.  I should be able to set WEP keys at indexes other than the
> transmit key index without affecting operation of the card (unless some
> hardware/firmware issue prevents this).

And same for TKIP and CCMP.

> - WEP encryption (following ops are independent of each other):
>     - Set TX key index
>     - Set privacy invoked

These two are not WEP specific in any way.

>     - Set exclude unencrypted packets

I would consider this more as a global variable for the BSS to match
with dot11ExcludeUnecrypted variable defined in IEEE 802.11. In theory,
this is not specific to WEP, but in practice, only WEP is sometimes used
in mode which allows both encrypted and unencrypted frames.

>     - Set authentication mode (open, shared-key, or both)

Not really WEP specific. Shared Key authentication can only be used with
static WEP keys, but still, this configuration is not really part of
crypto configuration. In addition, Cisco uses a proprietary "Network
EAP" authentication algorithm and IEEE 802.11r is adding a new
authentication algorithm, so there are more options to this
configuration variable.

>     - Set (or clear) WEP key 1, 2, 3, or 4

Not specific to WEP.

> - WPA/WPA2/IEEE8021X
>     - Jouni/others would know better and my brain is fried right now

This item should not be WPA/WPA2/IEEE8021X, but TKIP/CCMP, i.e.,
ciphers like WEP.. Just like with WEP, there would need to be key index
parameter. Default TX key could be set with separate operation (it is
valid to switch between two keys without changing either one). TKIP and
CCMP will also need options for setting and getting the sequence number
for replay protection (TSC/PN).

In other words, WEP, TKIP, CCMP (and likely all future ciphers added to
802.11) would be using the same configuration interface with same set of
parameters. Some of these parameters are just ignored for some of the
ciphers (e.g., WEP does not really need seq# get/set).

> All the WEP options should be independent attributes in nl80211.  You
> could even have a generic WEPKey attribute that is defined like so:
> 
> ATTR_WEP_KEY {
> 	enum type (one of DISABLE, TYPE_40, TYPE_104, TYPE_152)

I would rather use key length than come up with enum that needs to be
changed whenever some vendor comes up with the great (yeah, right)
security improvement by using a new WEP key length. In addition, this
would mean that the same field can be shared (just like key_material)
with all ciphers..

> 	char * key_material

unsigned/u8

> 	enum index (one of DEFAULT, 1, 2, 3, 4)

This is not specific to WEP, so could be shared with other algorithms..
None of the ATTR_WEP_KEY fields were actually specific to WEP.. Take a
look at struct iw_encode_ext to see the needed parameters..

> Some cards, like older aironet ones, can only do 1 key.  I don't want to
> pollute nl80211 with limitations like that though, so the driver can
> just return -EINVAL if the card doesn't support it.  I don't think it
> pays to have capability bits for something as far down in the driver
> implementation as this. 

Actually, this particular case could be nice to include in capability
flags if someone were interested enough to implement WPA with Group Key
only keys, i.e., this case is described in WPA/IEEE 802.11i as an
exception and authenticator/supplicant would need to behave differently
with it. Then again, I've never really needed this or have even heard a
request to implement it, so maybe it can by ignored now.

> My impression of ENCODE and ENCODEEXT was that they were _just_ for
> setting keying material (except in the case of WEP where you set the
> auth mode open/shared too), and that AUTH was for higher level stuff.

I think it is a design flaw to use ENCODE for open/shared auth_alg
configuration and I never really understood that part of WE. That's why
authentication algorithm was added separately in WE-19.

IW_AUTH_* is just a subtyped way of being able to configure parameters
without having to add a new ioctl for every one. They are not really
tied to authentication, so the name is not exactly correct.

> >     - allowed wpa versions (why is this AUTH??)
> 
> Can you do both WPA and WPA2 at the same time?  You can certainly
> advertise both a WPA IE and an RSN IE at the same time.  Is it possible
> to auth both types of clients?

Sure you can. APs can have multiple stations and some of them can use
WPA while others are using WPA2 (IEEE 802.11i/RSN).

> >     - setting pairwise and group ciphers (again.. AUTH??)
> 
> Note that ENCODEEXT has a group key flag IW_ENCODE_EXT_GROUP_KEY too.
> The pairwise and group cipher stuff in AUTH only sets the cipher _type_,
> not the actual key material AFAICT.

These parameters in IW_AUTH_ are for setting the allowed cipher suites.
They are only used with drivers that generate WPA/RSN IE internally.

> * Static WEP
>     - Keys: up to 4 group keys
>     - Crypto: WEP-40, WEP-104, WEP-152, WEP-256
>     - 802.11 Auth: Open System or Shared Key
>     - Key Mgmt/Auth: none

Static key mapping keys could be used, even though that is not very
commonly used part of IEEE 802.11. In other words, there is individual
WEP keys and up to four default keys.

> * Dynamic WEP (LEAP?)
>     - Keys: up to 4 group keys
>     - Crypto: WEP-40, WEP-104, WEP-152, WEP-256
>     - 802.11 Auth: Open System (only?)
>     - Key Mgmt/Auth: IEEE 802.1x with LEAP or EAP

LEAP is an EAP method just like TLS, PEAP, etc. (it just happens to not
follow the standard, but.. well, close enough). This should have the
same keys as "Static WEP", i.e., possibly multiple individual (unicast)
keys. In addition, thanks to Cisco, there's "Network EAP" authentication
algorithm and possibility of using non-zero key indexes for unicast
keys..

> * WPA PSK
>     - Keys: pairwise & group
>     - Use WPA IEs
>     - 802.11 Auth: Open System
>     - Crypto: TKIP or CCMP
>     - Key Mgmt/Auth: WPA-PSK (elided 802.1x)
> 

There are pairwise keys and up to four group keys (Notice the pattern?
this is same as WEP above..).

> * WPA Enterprise
> * WPA2 PSK
> * WPA2 Enterprise

And these have the exact same encryption options as WPA-PSK. In other
words, encryption keys should be handled separately from
auth_alg/key_mgmt configuration.

-- 
Jouni Malinen                                            PGP id EFC895FA
