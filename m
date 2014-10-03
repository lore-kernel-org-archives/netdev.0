From: Florian Fainelli <f.fainelli@gmail.com>
Subject: HW bridging support using notifiers?
Date: Thu, 02 Oct 2014 18:48:57 -0700
Message-ID: <542E0089.5050005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, stephen@networkplumber.org,
	andy@greyhouse.net, tgraf@suug.ch, nbd@openwrt.org,
	john.r.fastabend@intel.com, edumazet@google.com,
	vyasevic@redhat.com, buytenh@wantstofly.org,
	sfeldma@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:61523 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbaJCBtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 21:49:01 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so571881pab.32
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 18:49:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am taking a look at adding HW bridging support to DSA, in way that's
usable outside of DSA.

Lennert's approach in 2008 [1] looks conceptually good to me,as he
noted, it uses a bunch of new ndo's which is not only limiting to one
ndo implementer per struct net_device, but also is mostly consuming the
information from the bridge layer, while the ndo is an action

So here's what I am up to now:

- use the NETDEV_JOIN notifier to discover when a bridge port is added
- use the NETDEV_LEAVE notifier, still need to verify this does not
break netconsole as indicated in net/bridge/br_if.c
- use the NETDEV_CHANGEINFODATA notifier to notify about STP state changes

Now, this raises a bunch of questions:

- we would need a getter to return the stp state of a given network
device when called with NETDEV_CHANGEINFODATA, is that acceptable? This
would be the first function exported by the bridge layer to expose
internal data

NB: this also raises the question of the race condition and locking
within br_set_stp_state() and when the network devices notifier callback
runs

- or do we need a new network device notifier accepting an opaque
pointer which could provide us with the data we what, something like
this: call_netdevices_notifier_data(NETDEV_CHANGEINFODATA, dev, info),
where info would be a structure/union telling what's this data about

Let me know what you think, thanks!

[1]: http://patchwork.ozlabs.org/patch/16578/
--
Florian
