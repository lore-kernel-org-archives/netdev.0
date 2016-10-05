From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/3] mac80211: multicast to unicast conversion
Date: Wed, 05 Oct 2016 13:58:08 +0200
Message-ID: <1475668688.4994.46.camel@sipsolutions.net>
References: <1475643324-2845-1-git-send-email-michael-dev@fami-braun.de>
         <1475643324-2845-3-git-send-email-michael-dev@fami-braun.de>
         <1475662791.4994.39.camel@sipsolutions.net>
         <1690671fb30f19c53c7883a5207c5721@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de,
        netdev <netdev@vger.kernel.org>
To: michael-dev <michael-dev@fami-braun.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48405 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752236AbcJEL6P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 07:58:15 -0400
In-Reply-To: <1690671fb30f19c53c7883a5207c5721@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-05 at 13:40 +0200, michael-dev wrote:
> Am 05.10.2016 12:19, schrieb Johannes Berg:
> > 
> > > 
> > > on both ends. Furthermore, I've seen a few mobile phone stations
> > > locally that indicate qos support but won't complete DHCP if
> > > their broadcasts are encapsulated as A-MSDU. Though they work
> > > fine with this series approach.
> > 
> > Presumably those phones also don't even try to use DMS, right?
> 
> When I traced this two years ago, almost no device indicated DMS 
> support, even though almost all seem to accepted multicast in unicast
> a-msdu frames.

Right, that's what I suspected. I'm a bit surprised they accepted
multicast in unicast A-MSDU too, though I don't actually see any big
problem with it.

> > How did you determine that it "works fine"?
> 
> First, I tested this manually using my own devices or asked friends. 
[snip

Thanks!

> > I see at least one undesirable impact of this, which DMS doesn't
> > have; it breaks a client's MUST NOT requirement from RFC 1122:
> 
> Okay, so this cannot go into linux, right?

I'm not necessarily saying that, I just think we need to be careful
documenting possibly unexpected/undesired side-effects.

> > > + * @set_ap_unicast: set the multicast to unicast flag for a AP
> > > interface
> > 
> > That API name isn't very descriptive, I'm sure we can do something
> > better there.
> 
> proposal: "request multicast packets to be trasnmitted as unicast" ?

I was thinking more of the function name ("set_ap_unicast") which by
itself makes no sense - set_multicast_to_unicast or something like that
would be better, no?

> > Also, perhaps we should structure this already like we would DMS,
> > with a per-station toggle or even list of multicast addresses?
> 
> should be possible, yes

I'm mostly handwaving though, haven't really looked at what DMS really
would require from the API, even assuming that hostapd would implement
all the action frame handling etc.

It's quite possible that on the *client* side, mac80211 should
implement the DMS client, if supported, and perhaps only if enabled by
some kind of configuration knob.

> > Was this not documented but also intended to apply to its dependent
> > VLANs?
> 
> it was intended as a per per-BSS toggle, so it applies to all
> dependent VLANs automatically.

makes sense, but you should document it in the API documentation, which
today says "for a AP interface" or so (see above)

(btw - writing that out I see that it should be "an AP interface" too)

> > 
> > > 
> > > +/* Check if multicast to unicast conversion is needed and do it.
> > > + * Returns 1 if skb was freed and should not be send out. */
> > 
> > wrong comment style :)
> 
> you mean the */ at end of line instead of on a new line?

yeah, no big deal though.

I've also mostly gone back to non-davem style with /* also on its own
line, but it's not so important. :)

> > > +	unicast = nla_data(info->attrs[NL80211_ATTR_UNICAST]);
> > 
> > What's this supposed to mean?
> 
> this was supposed to be nla_get_u8.

Shouldn't it just be nla_get_flag()? I mean, why do you have a u8 with
values 0/1 rather than just flag attribute absent/present?

Anyway, perhaps this needs to change to take DMS/per-station into
account?

Then again, this kind of setting - global multicast-to-unicast -
fundamentally *cannot* be done on a per-station basis, since if you
enable it for one station and not for another, the first station that
has it enabled would get the packets twice...

johannes
