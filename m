From: Dan Williams <dcbw@redhat.com>
Subject: Re: Where Linux 802.11x support needs work
Date: Tue, 25 Jan 2005 23:03:51 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0501252224000.4275@devserv.devel.redhat.com>
References: <20050126024039.GA25326@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Dan Williams <dcbw@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@hpl.hp.com>
In-Reply-To: <20050126024039.GA25326@bougret.hpl.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005, Jean Tourrilhes wrote:
> 	You know already that in Linux things happen by pushing
> patches around, not by "showing leadership" (whatever that
> means). Driver authors will always do their own thing, nobody can
> prevent them, and it's actually a good thing as it creates inovation
> and the best ideas can then be folded back into the official API. Yes,
> I believe in the bottom up approach (cheers).

Quite true, and I don't think that's a bad approach, I just think that 
adding general WPA support to WEAPI a bit earlier might have saved some 
trouble.  Since most driver writers have their drivers in the kernel, and 
since the kernel can enforce usage of the WEAPI on the driver, it seems 
like the WEAPI would be a good place to standardize new stuff like WPA 
that's been around for a while and is supported by a fair # of chipsets.  
Furthermore, if an API were in place, then driver writers could write to 
that API and not have to invent one themselves.  Of course, the API would 
need to change and evolve as driver writers ran into limitations and 
whatnot.  So I guess its a toss-up, either way (waiting till later, or 
starting sooner) both driver writers and user-applications have to change 
code around.  But I completely agree that flexibility is of great 
importance here.

> > o  Quality values vary wildly or are absent
> >      - Average and max quality levels for almost all drivers are
> >         artificial and don't come from the the card in any way
> 
> 	Those can't come from the hardware, they may only come from
> the spec, when available.
> 	The idea with "average" and "max" would be that application
> authors would feed back driver authors as to what to
> use. Unfortunately, it did not happen, especially that apps decided to
> ignore them.

My frustration here (and why I've pretty much stopped trying to fix it) is 
basically twofold:
1) If the card only reports dBm, I cannot try to calculate the 
signal-to-noise ratio without getting the correct noise level.  Only the 
card can provide that, and quite a few do not.
2) The API here is a bit confusing and lacks some documentation.  Since we 
have the 8-bit value for the quality, the driver has the choice of either 
0 - 255 (which seems to be what Airo uses) or -128 - +128 (which others 
use).  I could not really deduce what the values that various drivers 
return is, and how to convert that to a percentage value.

For quality data, we have qual.qual, qual.level, and qual.noise.  Its not 
completely clear what each of those values is (though if I had to guess, 
I'd assume qual.qual = %-age value, qual.level = dBm of current signal, 
qual.noise = dBm of current noise threshold).

The breakdown:
ipw2200: fairly sane
ipw2100: fairly sane, but no scan quality data
airo: only qual.level on scans (qual.qual/qual.noise = 0), for normal
      quality uses a lot of magic numbers.  No way to get a percentage
      value out of this driver.
atmel: magic numbers tied to one hardware version.  No scan quality data.
orinoco: magic numbers
madwifi: doesn't seem to implement SIOCGIWSTATS

As far as I understand the comments in iwlib.c, all drivers do something 
different for the qual.qual/qual.level/qual.noise fields, WRT the 
signed/unsigned debate.  Airo seems to use 0 - 255, others seem to use 
-128 - +128, etc.  We need to standardize signal strength and quality data 
among the drivers.

> > o  Frequency values vary wildly from iw_get_range
> >   1) prism54 uses completely different exponent values than airo
> >   2) airo, atmel, orinoco are the same
> 
> 	Nobody in their right mind would use iwfreq for anything, it's
> just used to go across the kernel interface. Once in userspace, just
> use the iw_freq2float() and iw_float2freq() to convert to double, and
> then it's all normalised.
> 	If you need it, I can donate you those two functions under LGPL.

AFAIK, those functions are exposed in iwlib, no?  I think I'm already 
using them in NetworkManager.  I was using get/set frequency calls (which 
only madwifi actually seems to support) to ensure that the card jumps to 
the correct frequency in Ad-Hoc mode, which it didn't always seem to do.

> > o  Not all drivers have correct netlink support, if they even have it
> 
> 	Note that netlink make only sense in Managed mode, it does not
> make sense in Ad-Hoc or Master mode. That make things a bit more messy
> to implement.
> 	In the interim, for driver that don't support netlink you can
> check the value of the AP address.

True, but some tools like wpa_supplicant seem to use the netlink sockets 
stuff to trigger auth/encryption capability checks since certain auth 
algorithms send challenge packets to you when you auth/assoc to the AP.  
In any case, I'm not actually using any netlink sockets support in NM 
since its just to flaky between drivers.

Checking the AP MAC address isn't really good enough, since cards have 
different semantics here.  Some cards seem to update the MAC address only 
when you've successfully authed/assoced to the AP, while others don't 
really care as long as you've pointed your card at the ESSID.  For 
example, airo driver won't set a valid ESSID on the card until the auth 
mode is correct (ie OpenSystem/SharedKey), while others (madwifi, atmel) 
will happily show a valid MAC address even if your WEP key is wrong (airo 
will still show invalid in this instance).

The only way that I've found to guarantee a link to an access point is to 
set the ESSID, and then check over a period of 10 seconds or so for a 
valid AP MAC address on the card for at least 6 seconds, and then try to 
DHCP.  If you're in Open System and DHCP fails, then you fall back to 
Shared Key and get a link, try DHCP again, etc.

What would work better is if all cards supported netlink, so that I could 
at least tell when the _card_ thought it was connected and then stop the 
whole "wait for 10s until card has link" type of deal.  Furthermore, some 
cards re-load their firmware when you set the ESSID on them, which means 
you have to wait at least 2 or 3 seconds before any value on the card is 
actually valid.  There are liberal usleep (x) sprinkled throughout places 
in NetworkManager where I have to wait for cards to bring themselves back 
up before I can do anything with them.  Even a netlink message of "I'm the 
firmware, I'm ready for business" would be an improvement for this 
problem.

> > o  Not all drivers support wirless scanning
> >   1) orinoco driver mainly, support is upstream and is being slowly
> >      merged into the kernel driver
> 
> 	Just for your info, I was the one who originally authored the
> Scanning patch for the Orinoco driver (based on other patches). After
> that many people improved on it.

Yep, I see your stamp all over the code :)  In any case, I think Dave 
Gibson was busy for a while and just never quite got around to getting the 
scanning support merged.  He seems to be doing that now though.  I tried 
to help at one point, but was using the wrong orinoco branch.  I haven't 
taken the time to extract the scanning code again however and repost that, 
because it depends on most every other change in the upstream orinoco 
drivers (better firmware capability detection, iwspy support, etc).

> > o  Ad-Hoc mode support is quite flaky or absent from most drivers
> 
> 	Low priority for most vendors, firwmares are only lightly tested.

Yeah, I don't expect much to happen here but it would be nice.  FWIW, at 
least madwifi and atmel seem to work OK here.

> > o  WPA support is lacking or just in-progress, needs much help
> 
> 	Preliminary patch is on my web page :
> http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html#wext
> 	Jouni is the main author, as he is doing the supplicant. He
> told me that he want to make a few additional changes. WPA is quite
> complex and therefore I would prefer to make sure it's right.

I plan to make NetworkManager talk to wpa_supplicant at some near-future 
point, I've had some long emails with Jouni about the wpa_supplicant 
interface and how to work with it.  I was a bit horrified to discover that 
the Open 802.1x project actually patches drivers (ok, I'm not 100% sure, 
but there are patches against kernel drivers in their CVS at least).  
However, if they have to patch kernel drivers, that probably means there's 
some capability that they need that should be in the drivers anyway, so it 
might be useful to look into those patches and see what can be 
cherry-picked to improve driver quality.

> 	Note that various other people have their own todo list. Jeff
> also has things he has in minds. I have (few) patches on my web
> pages. Driver authors also have their wishes.

True, but I'm not sure how many of those wishes/todo lists are actually 
well-known or public.  I don't really see any great momentum in the Linux 
802.11x world, but more a hodge-podge of improvements.  I was hoping that 
the post today could help  direct a bit more attention and effort at Linux 
802.11x stuff so we could try to clean it up and improve it.  I don't 
think enough people focus on this right now, and as Linux moves more 
towards mainstream we need to be as foolproof as possible.  Furthermore, 
we need to develop a clear API for driver writers so that hardware 
companies have fewer excuses to develop open-source drivers.  Obviously 
they all have tons of experience writing to NDIS/WDM, and that's fairly 
understood.  But I believe that Linux wireless driver APIs are much less 
understood and documented.

> 	One of the big item not mentionned by you is the in-kernel
> 802.11 stack (native frames and management). If done right, I guess it
> would mostly be transparent to you...

You know, I was thinking of it and I just forgot to put it on the list.  
If you're including madwifi and ipw2x00, we have a grand total of what, 3 
or 4 802.11 stacks in the kernel at the same time?  (madwifi, 
orinoco/hermes, ipw2x00, linux-wlan-ng)

Cheers,
Dan
