From: Dan Aloni <dan@kernelim.com>
Subject: Re: [PATCH] net: Fix NETDEV_CHANGE notifier usage causing spurious
 arp flush
Date: Wed, 2 Jul 2014 10:03:49 +0300
Message-ID: <20140702070349.GA11943@gmail.com>
References: <1404275983-7908-1-git-send-email-loicp@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	Jiri Pirko <jiri@resnulli.us>
To: Loic Prylli <loicp@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1404275983-7908-1-git-send-email-loicp@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 01, 2014 at 09:39:43PM -0700, Loic Prylli wrote:
> A bug was introduced in NETDEV_CHANGE notifier sequence causing the
> arp table to be sometimes spuriously cleared (including manual arp
> entries marked permanent), upon network link carrier changes.
> 
> The changed argument for the notifier was applied only to a single
> caller of NETDEV_CHANGE, missing among others netdev_state_change().
> So upon net_carrier events induced by the network, which are
> triggering a call to netdev_state_change(), arp_netdev_event() would
> decide whether to clear or not arp cache based on random/junk stack
> values (a kind of read buffer overflow).
[..]
>  {
>  	if (dev->flags & IFF_UP) {
> -		call_netdevice_notifiers(NETDEV_CHANGE, dev);
> +		struct netdev_notifier_change_info change_info;
> +
> +		change_info.flags_changed = 0;

I think it would be safer to do:

   struct netdev_notifier_change_info change_info = {};

So that when future fields are added to the struct and this call-site
happens to be forgotten, they will get 0 by default rather than
random stack values.

-- 
Dan Aloni
