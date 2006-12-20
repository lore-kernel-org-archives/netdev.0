From: "Nick Kossifidis" <mickflemm@gmail.com>
Subject: d80211 ieee80211_channel and operating modes...
Date: Wed, 20 Dec 2006 07:05:11 +0200
Message-ID: <40f31dec0612192105n4d61d777j92d278955642dbe2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:39219 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964871AbWLTFFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 00:05:12 -0500
Received: by wx-out-0506.google.com with SMTP id h27so1898437wxd
        for <netdev@vger.kernel.org>; Tue, 19 Dec 2006 21:05:11 -0800 (PST)
To: "David Kimdon" <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, linville@tuxdriver.com, jbenc@suse.cz
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello ppl ;-)

Why have both frequency and channel inside ieee80211_channel ? We can
have only frequency and have a function map the frequency to the
current ieee channel...

net80211 has a function that does that maping and works fine...

/*
 * Convert MHz frequency to IEEE channel number.
 */
u_int
ieee80211_mhz2ieee(u_int freq, u_int flags)
{
       if (flags & IEEE80211_CHAN_2GHZ) {      /* 2GHz band */
               if (freq == 2484)               /* Japan */
                       return 14;
               if ((freq >= 2412) && (freq < 2484)) /* don't number
non-IEEE channels */
                       return (freq - 2407) / 5;
               return 0;
       } else if (flags & IEEE80211_CHAN_5GHZ) {       /* 5Ghz band */
               if ((freq >= 5150) && (freq <= 5825))   /* don't number
non-IEEE channels */
                       return (freq - 5000) / 5;
               return 0;
       } else {
               /* something is fishy, don't do anything */
               return 0;
       }
}

Also ieee80211_channel should contain more infos about the channel, eg
the band it's on (5Ghz / 2Ghz) and the modulation (OFDM/CCK etc to be
able to link that channel with a specific rate table), see
ieee80211_radiotap.h...

/* Channel flags. */
#define	IEEE80211_CHAN_TURBO	0x0010	/* Turbo channel */
#define	IEEE80211_CHAN_CCK	0x0020	/* CCK channel */
#define	IEEE80211_CHAN_OFDM	0x0040	/* OFDM channel */
#define	IEEE80211_CHAN_2GHZ	0x0080	/* 2 GHz spectrum channel. */
#define	IEEE80211_CHAN_5GHZ	0x0100	/* 5 GHz spectrum channel */
#define	IEEE80211_CHAN_PASSIVE	0x0200	/* Only passive scan allowed */
#define	IEEE80211_CHAN_DYN	0x0400	/* Dynamic CCK-OFDM channel */
#define	IEEE80211_CHAN_GFSK	0x0800	/* GFSK channel (FHSS PHY) */

those flags can be added in ieee80211_channel->flag...

This makes easier for low-level drivers to do various calculations by
just using ieee80211_channel. Since an int is reserved anyway let's
make use of it ;-)

Finaly you have MODE_ATHEROS_TURBO but you have no special rate flag
for it, if it's something special /atheros-only it should have a
special rate flag so it won't be treated as IEEE80211_RATE_TURBO. Imho
modes should be pows of two and used as flags, it is more abstract
that way, eg athturbog = MODE_ATHEROS_TURBO|MODE_IEEE80211G and
athturboa = MODE_IEEE80211A|MODE_ATHEROS_TURBO (why you have TURBOG
for g but TURBO for a ? it complicates things, in binary hal they have
TURBO_108A and TURBO_108G). We can also have vendor-specific flags,
eg. MODE_ATHEROS or MODE_PRISM since "turbo" modes are implemented in
different way by each vendor.

This would also make queries to each driver easier since they can
report which modes do they support simply by returning an int.


Thanx for your time
Nick
