From: Jouni Malinen <j@w1.fi>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Mon, 17 Dec 2007 20:18:10 -0800
Message-ID: <20071218041810.GB5698@jm.kir.nu>
References: <1197483844.6558.158.camel@johannes.berg> <20071214050808.GE5698@jm.kir.nu> <1197634385.16079.34.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1197634385.16079.34.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 14, 2007 at 01:13:05PM +0100, Johannes Berg wrote:
> > Is there any way for an user space application to figure out whether a
> > received EAPOL frame was encrypted? In theory, WPA/WPA2 Authenticators
> > (e.g., hostapd) should verify that the frame was encrypted if pairwise
> > keys are set (whereas IEEE 802.1X Authenticator accepts unencrypted
> > EAPOL frames).
> 
> Unfortunately not. Does that really matter? It seems that the
> verification whether the frame was encrypted would either be "always
> require encryption when pairwise keys in use" (which this patch doesn't
> do right now but could trivially be done) or simply "don't care since it
> doesn't really matter".

In theory, yes, this does matter and the implementation does not comply
with the standard if we do not verify this for WPA/WPA2/IEEE 802.11 RSN.
However, I do not believe there is any real security issue in not doing
so and even worse, some client implementations end up using unencrypted
EAPOL frames when they should really be encrypted..

hostapd has a place in the implementation where this information could
be processed, but I did not actually ever enable such validation because
of the potential interoperability issues. Likewise, wpa_supplicant does
not validate this either.

In other words, this would be kind of nice to have feature in the kernel
interface, but not really something that would be strictly required from
security view point.

> > Did you/someone already verify that the Linux bridge code does not
> > bridge EAPOL frames? The use of a separate interface for this removed
> > the need for doing such filtering based on ethertype, but with EAPOL
> > frames using the same netdev with other data frames, the bridge code
> > should filter these out (mainly the PAE group addressed ones, but if I
> > remember correctly, IEEE 802.1X specified all frames using EAPOL
> > ethertype not to be bridged).
> 
> Actually, 802.1X doesn't specify that, as I said previously it
> *recommends* it in C.3.3 (not C.1.1 as the 802.11 specs lead you to
> believe). Also, a patch to do this was rejected by Stephen Hemminger, so
> I decided to only pass up EAPOL frames that are either for our own
> unicast address or the link-local eapol address, both of which won't be
> bridged.

It is a "must" requirement, but apparently only in informative clause of
IEEE 802.1X. However, this is a real issue and if the bridging code
cannot be changed to do this, so dropping multicast/broadcast EAPOL
frames in mac80211 (in both RX and TX direction) sounds reasonable
workaround to prevent cases where wireless clients could otherwise mess
with other IEEE 802.1X authentications (e.g., for the wired port of an
AP).


PS.

I added the C.3.3 vs. C.1.1 issue to my pending comments for the next
IEEE 802.11 maintenance task group (TGmb). Should you find any other
issues with IEEE Std 802.11-2007, I can add them to that list so that
they can eventually be fixed.

-- 
Jouni Malinen                                            PGP id EFC895FA
