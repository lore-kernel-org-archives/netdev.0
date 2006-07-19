From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 3/9] d80211: better deallocation of mdev
Date: Wed, 19 Jul 2006 12:15:01 +0200
Message-ID: <20060719121501.7be3ddce@griffin.suse.cz>
References: <20060718154523.E380E483BC@silver.suse.cz>
	<C86180A8C204554D8A3323D8F6B0A29F01565A43@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41625 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964785AbWGSKPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 06:15:05 -0400
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F01565A43@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Jul 2006 20:07:34 -0700, Simon Barber wrote:
> I have been thinking about a slightly different approach for the master
> device. Since the master device represents the physical hardware, I am
> thinking that the hardware driver could register the master device
> directly itself. It would use the normal netdev_register call to do so.

How will you allocate structures for 802.11 specific data? You will
require the driver to call some ieee80211_allocate function anyway, so
you will probably want to leave allocation of net_device structure to
this function too. And it is probably better to have correspondent
ieee80211_register function to prevent confusion (even if the only thing
done in ieee80211_register is calling netdev_register).

> Received frames would be marked as having a protocol type of 802.11, and
> the 802.11 code would register itself as a protocol handler for this
> protocol type. Now netif_rx() could be used within the hardware driver
> to pass frames to the kernel 802.11 code

How will you pass data like signal strength or rate to 802.11 stack?

> - this has the benefit of
> better performance for the hardirq/softirq transition than the current
> scheme.

I don't see much benefit in this. Instead of rewriting big part of the
stack (and drivers as well) for questionable performance gain I would
rather see a work on putting the stack to mainline - the only blockers
left are SMP safety and stack<->hostapd netlink protocol. Oh, and better
communication with tools like NetworkManager.

> On the transmit side - currently the 802.11 code does much
> processing within the hard_start_xmit function on the master device. I
> would move all this processing into the 802.11 qdisc - putting it into
> the dequeue function.

This makes sense, especially fragmentation is a good candidate (and this
implies nearly the whole processing needs to be moved there as well).
Though most of these problems will vanish when the Ethernet<->802.11
conversion routines are removed and the stack starts working with native
802.11 frames.

> Now the hard_start_xmit function would be the real
> hardware drivers transmit function.

No need for this.

I also think that moving xmit processing to qdisc doesn't need to be
done now. It can be done without changing drivers, so we can do it after
the stack goes into mainline.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
