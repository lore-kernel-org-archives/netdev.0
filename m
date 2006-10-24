From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 2/3] adds ieee80211_regdomains support
Date: Tue, 24 Oct 2006 13:10:50 -0400
Message-ID: <43e72e890610241010h3cfa4003u76fbd6a2b3083697@mail.gmail.com>
References: <43e72e890610231547k3cf6c590r4abd0a6fe7965fda@mail.gmail.com>
	 <1161678798.2840.9.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:7255 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S965170AbWJXRKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 13:10:52 -0400
Received: by wr-out-0506.google.com with SMTP id 55so557959wri
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2006 10:10:51 -0700 (PDT)
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <1161678798.2840.9.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/06, Johannes Berg <johannes@sipsolutions.net> wrote:
>
> > and adds support for PtMP (Point
> > to MultiPoint) and PtP (Point to Point) type restrictions.
>
> What are those restrictions?

I'm glad you asked. Here's a quote from:

http://university.cyberarmy.net/kb/tiki-index.php?page=The+Power+of+802.11

"In the 2.4Ghz ISM band the FCC stipulates that the creation of PtMP
links be subject to the following restrictions:


    * EIRP must not exceed 4W (36dBm)
    * IR must not exceed 1W (30dBm)
    * For every 3dBi of antenna gain after the first 6 "free" dBi the
IR must be decreased by 3dBi (the 1:1 rule)


For PtP links that rule is thusly augmented:


    * IR is limited to 1W (30dBm)
    * For every 3dBi after the first 6 of antenna gain the IR must be
decreased by 1dBi (the 3:1 rule)

One thing to notice about the rules for the PtP link is that it does
not stipulate a maximum EIRP and significantly reduces the penalty for
adding antenna gain. In this situation it would be acceptable to have
an IR of 25dBm and with a directional antenna adding 21dBm of gain
giving us an EIRP of 46dBm or 40W. This is why it is very important to
stay away from the front of highly directional antennae. If you have
ever wondered what it would be like to squeeze yourself into a
microwave and have it turned on...
"

The restrictions defined in this regulatory module are designed first
to tackle PtMP links restrictions but keeps in mind PtP link subband
restrictions as well for further advancements. This would ultimately
complete regulatory domain support. To support PtP links well though
we'd need some further stack enhancements and modifications. Currently
I separate PtP and PtMP link restrictions by putting them on separate
subband linked list on the regulatory domain. Antenna gain is device
specific and for manufacturer's sake and user's hacker's sake we
should allow for:

1. Device specific definition of the manufacturer's default antenna gain and...
2. Allow the user to modify this antenna gain in case they modify the
antenna. Our due dillegence comes from at least providing built-in
regulatory framework and allowing the malleability of the malleable
components of such restrictions. If antenna gain is modified we should
accordingly modify the device's IR -- notice this requires changes
even for PtMP link restrictions as well but support without this was
what I was thinking for Phase I of this module.

(1) is covered under d80211.h on the ieee80211_conf struct, u8
antenna_max but this is a subband restriction not an entire device
restriction. If we want to add this support immediately we can add IR
to the subband definition.
(2) needs further enhancements on the stack, namely that making IR
dynamic based on the device's antenna gain.

All this requires a lot of changes. What I'd suggest first is to adopt
PtMP link restrictions without supporting dynamic IRs based on antenna
gains until Phase II. In Phase II I was hoping we'd tackle this and a
userspace daemon through nl80211/cfg80211. d80211 is due to go stable,
I was hoping regulatory domains under phase I would be one last
addition to it before going stable and Phase II can be the focus for a
v2 of a stable d80211.

> Similar comments here, why do you build the list at module init time
> instead of having it static?

It made the code cleaner, feel free to modify if there are benefits
through a static approach. I originally attempted a static array
approach here but ran into problems quickly due to the dynamic nature
of the data structures required for regulatory domains and was having
a headache dealing with all the nasty macros to build this statically.
I'd suggest we keep things as is unless we have a complete clear
understanding of all requirements of regulatory domains. Regulatory
domains are not really well documented and this perhaps is the best
break down of them that I've seen so far.

> Also, do we really need all this data in the kernel?

Another great question. At first I actually wanted all this in
userspace but after some consideration figured it'd be best to
introduce in the kernel instead. Here are some considerations made me
change my mindl:

1. Regulatory restrictions affects the PHY's behaviour directly
2. IEEE-802.11D is a standard which all wireless stacks should
hopefully and eventually support. It is based on regulatory domains
which dictate how the PHY should work.
3. I believe the benefit in speed of having the regulatory
restrictions in the kernel outweight the overhead of having this in
the kernel
4. Introduction of a userspace daemon to update all regulatory domains
seems like a heavy restriction to immediately force every distribution
on. Also there is simply no clear "World" regulatory domain that
everyone can live peacefully with. An easier way to introduce
regulatory domains would be to have the most popular regulatory
domains built-in and slowly support userspace communication to update
and manage the regulatory db.

So, ultimately userspace should be the place for all this but -- not
yet, and even after we've ironed out a new userpsace API for wireless
device communication (nl80211 and cfg80211 I'm hoping) we should still
consider if the benefits of having this in the kernel outweigh the
overhead. For now I think we should stick to supporting this in the
kernel with a list of most common regulatory domains defined and
supported as optional (as the supplied Kconfig defines). Another idea
that I didn't yet complete was to let the user supply the alpha3
country code at kernel config and depending on this select the
required regdomain. Current Kconfig implementation makes this pretty
messy though.

  Luis
