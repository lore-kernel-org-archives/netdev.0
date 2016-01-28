From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates
 [mac80211]
Date: Thu, 28 Jan 2016 23:12:35 +0100
Message-ID: <1454019155.2332.15.camel@sipsolutions.net>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
	 <1453983185.2217.12.camel@sipsolutions.net>
	 <CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
	 <1454013625.2332.9.camel@sipsolutions.net>
	 <CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
	 <CA+55aFzF0gWfvmE+6ZcHmjnO4xp-oVAQ5SWxYJhOzns2ocgCsw@mail.gmail.com>
	 (sfid-20160128_230454_551008_3AE61B48)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+55aFzF0gWfvmE+6ZcHmjnO4xp-oVAQ5SWxYJhOzns2ocgCsw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20160128_230454_551008_3AE61B48)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-01-28 at 14:04 -0800, Linus Torvalds wrote:
>=C2=A0
> Well, it "makes a difference" in the sense that the warning goes
> away.
> But it doesn't make things work. In fact, it might be making things
> worse.

Heh, ok.

> Because with that patch, the wireless still authenticates and
> associates, but then it doesn't even get an IP address, so now even
> dhcp doesn't work. Of course, I was surprised that it worked last
> time, and I'm not 100% sure it did work consistently. I'll re-test
> without the patch, just to make sure, but it doesn't really seem to
> improve on anything.
>=20

It makes some sense, here's some speculation:

VHT rates are MCS 0-9. If the rate scaling decides to use only VHT
MCSes with a VHT-capable peer, then it stands to reason it might still
start at 0, but forget to set the VHT_MCS flag, so it would really use
rate index 0 from the table, which is 6 MBps. Then, it would see that
"working" (since it's not the right thing) and scale up until it hits
MCS 8 or 9, which is no longer a valid rate (those are only 0-7).

Since the suggested changes make it worse, we can assume that this is
not the only place where VHT is simply completely broken, and fixing
VHT here will instead uncover a bug elsewhere, that was previously not
happening because we never got to real VHT rates.

Your best workaround may just be to ignore VHT for now - clearly it's
broken so using "just" HT (which is likely not that much of a penalty
anyway since you're apparently not using 80 MHz) will be much better.

Go into

_rtl_init_hw_vht_capab()

and just remove or stub out the entire contents of that (or you could
just remove the "vht_supported=3Dtrue" if you feel like it.)

That should get it to HT only, which is likely tested and working
better.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
