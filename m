From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [RFC] d80211 LED handling
Date: Thu, 17 Aug 2006 17:30:30 +0200
Message-ID: <20060817173030.6510e96d@griffin.suse.cz>
References: <44DC3809.10705@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:11232 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965151AbWHQPac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 11:30:32 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44DC3809.10705@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 11 Aug 2006 09:55:53 +0200, Johannes Berg wrote:
> However, I'm not sure where I should call the _init and _exit functions 
> and if I really should be using the local struct. It seems I shouldn't 
> be and should be using the master interface directly or something.

Leds are not interface-specific but card-specific, so using
ieee80211_local is the right way.

Comments:

How is the driver supposed to add its led handlers?

Using generic led triggers is probably interesting for cases when system
has some separate led. It won't help drivers which need to handle leds
on the card itself. In the former case you may want all of wireless
cards in the system to be connected to one led. I don't see how this is
easily possible with this patch. In the latter case, you want to call
callback provided by the driver and not to use generic led triggers at
all.

> [...]
> +config D80211_LEDS
> +	bool "Enable LED triggers"
> +	select LEDS_TRIGGERS

Is it really necessary to have this as a configurable option?

> [...]
> +	name = (char*) local->rx_led+1;

This doesn't seem correct.

> +	snprintf(name, IFNAMSIZ + 2, "%srx", local->mdev->name);

Name of interface may change at any time. Using it for fixed identifier
is not a good idea. In addition, nothing prevents you from ending up
with two different led triggers with the same name:

1. modprobe card1
2. ieee80211_led_init(card1)	<- card1 is "wmaster0"
3. ip link set wmaster0 name mysupercard
4. modprobe card2
5. ieee80211_led_init(card2)	<- card2 is "wmaster0"

> +	if (led_trigger_register(local->rx_led)) {
> [...]

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
