From: Jiri Benc <jbenc@suse.cz>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Wed, 10 May 2006 12:42:17 +0200
Message-ID: <20060510124217.0d3810bd@griffin.suse.cz>
References: <200605061401.01795.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:16044 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964895AbWEJKmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 06:42:19 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200605061401.01795.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 6 May 2006 14:00:58 +0200, Ivo van Doorn wrote:
> In rt2x00 the config() handler schedules all configuration changes by using a workqueue,
> this is required since several configuration changes in rt2x00 need sleeping and for
> USB devices all register access requires sleeping. And the config() handler is often
> called from interrupt context so it complains a lot when the workqueue is not used.
> 
> This seemed fine, untill the radio_enabled field was introduced to the configuration structure.
> When the radio_enable field is set, the radio must be enabled, but enabling
> the radio is something that can (at least in rt2x00) fail. So scheduling the enabling of the radio
> to the workqueue is not something that is desired since the stack can not be notified that the
> device is not able to enable the radio.

This is probably more general problem. I can imagine a card that will
need to sleep to switch channels and can fail. This doesn't matter now
(as we cannot handle failure in switching channels) but it should be
solved in some way.

Currently, only switching channels is made in interrupt context. You can
depend on this for now.

> Moving the enabling of the radio outside the workqueue function and into the config()
> handler results in scheduling while atomic issues since the enabling of the radio requires
> sleeping for both PCI and USB devices.

Or am I wrong? I see no place when radio_enabled is changed in interrupt context.

> Instead of using a config field radio_enabled, wouldn't it be better to add 2 handlers
> to the ieee80211_hw structure, something like enable_radio() and disable_radio()?
> If these functions are called from normal context the dscape stack can still enable
> and disable the radio whenever it is desired, and it is able to check the return value
> to see if the request has actually succeeded.

I don't think this is the best idea. In such case we would need to move
almost all the stuff from ieee80211_conf to separate functions. This is
something we don't want.

> What I am wondering about afterwards is what exactly should happen when the open()
> and stop() handlers are being called? Because those are basicly intented to enable
> and stop the radio as well. I checked bcm43xx to see what they do, and they don't seem
> to check the radio_enabled field, so I don't know what they do besides enabling the radio.

open and stop callbacks are obsolete. They were replaced by
add_interface and remove_interface callbacks and will be removed after
drivers are converted to use the new callbacks.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
