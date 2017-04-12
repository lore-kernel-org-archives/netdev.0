From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 3/3] mac80211: support bpf monitor filter
Date: Wed, 12 Apr 2017 17:25:29 +0200
Message-ID: <1492010729.2855.16.camel@sipsolutions.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
         <20170412110726.9689-3-johannes@sipsolutions.net>
         <1492007347.2855.12.camel@sipsolutions.net>
         <20170412.112212.441025205054195351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170412.112212.441025205054195351.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-04-12 at 11:22 -0400, David Miller wrote:
> From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date: Wed, 12 Apr 2017 16:29:07 +0200
> 
> > On Wed, 2017-04-12 at 13:07 +0200, Johannes Berg wrote:
> >> 
> >>  struct ieee80211_if_mntr {
> >>      u32 flags;
> >> 
> > [...]
> > +     bool deliver;
> > 
> > That's ... broken for multi-queue RX. I haven't really found a good
> > other way to do it. The best way will likely be to copy the SKB the
> > first time it's needed, build the radiotap header, and then keep a
> > reference to it to be able to clone it later if it's needed again.
> 
> If you don't recurse into the receive path for different devices
> before you are done with this boolean, simply make a global per-cpu
> boolean and use that.

No, that won't work. We don't recurse, but this is a per-interface
bool, as we can have multiple monitor interfaces (possibly with
different filters).

The problem comes from the fact that I did

for_each_interface()
	iface.deliver = run_bpf_program();

if (nobody_wanted_it)
	return;

skb = build_monitor_skb()

for_each_interface()
	if (iface.monitor)
		deliver(skb);


What I should be doing is something like this:

for_each_interface() {
	if (run_bpf_program()) {
		if (!skb)
			skb = build_monitor_skb();
		deliver(skb);
	}
}

where deliver() does skb_clone() internally or so.

johannes
