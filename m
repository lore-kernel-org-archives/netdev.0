From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Thu, 26 Mar 2015 00:44:27 -0700
Message-ID: <CAE4R7bCtpaonLeRiX9s3yFisONDQUv9z_EOBcGTdgTGLEjC7vA@mail.gmail.com>
References: <20150323002215.GA6074@roeck-us.net>
	<550F6D7D.7030403@gmail.com>
	<550F8102.7040701@roeck-us.net>
	<550F8600.2020300@gmail.com>
	<550F8987.5070600@roeck-us.net>
	<5510498D.5010001@cumulusnetworks.com>
	<CAE4R7bCcMtrKmiGaLqVMfERQxYZW3WD1vF2rts9+CE7ZZ0_BVQ@mail.gmail.com>
	<20150324142921.GA2026@nanopsycho.orion>
	<20150324160126.GA17104@roeck-us.net>
	<5511A29F.5010006@cumulusnetworks.com>
	<20150324175825.GA1465@roeck-us.net>
	<CAE4R7bAoGeFdNAUqMR-RmQWTtfSy0t+e4f187an_BVVVR2tDnw@mail.gmail.com>
	<CAGVrzcZ+QywZxe4P2bcnBLG9mXUDARNzNyXF1yTOV9tnAcx=PQ@mail.gmail.com>
	<CAE4R7bBeFg9v-CnUJU-0pe8ZS4AYXQNAGNTcvCrHdZ1ggYmOPA@mail.gmail.com>
	<5512E9EC.5020504@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:33054 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbbCZHo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 03:44:28 -0400
Received: by qgfa8 with SMTP id a8so79365602qgf.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 00:44:27 -0700 (PDT)
In-Reply-To: <5512E9EC.5020504@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015 at 10:01 AM, roopa <roopa@cumulusnetworks.com> wrote:

[cut]

So just to keep the discussion alive (because we really need to solve
this problem), my current thinking is back to Roopa's RFC patch to
mark the skb to avoid fwding in bridge driver.  One idea (sorry if
this was already suggested, thread is long) is to use
swdev_parent_id_get op in the following way:

1) when port interface is added to bridge, bridge calls
swdev_parent_id_get() on port to get switch id.
swdev_parent_id_get() needs to be modified to work on stacked drivers.
For example, if a bond is the new bridge port, swdev_parent_id_get()
on the bond interface should get switch_id for bond member.  We stash
the switch_id in the bridge port private structure for later
comparison.

2) port driver knows the switch_id for the port, so any pkts it sends
up to the CPU which has already been flooded/fwded by the device are
marked with the switch_id.  So the skb is marked, somehow.  Some
options:

  a) add a new skb switch_id field that's wrapped with
CONFIG_NET_SWITCHDEV; seems bad, to add a new field.
  b) put switch_id into skb->cb, but not sure how this doesn't get
stomped on by upper drivers, or how
      bridge knows if something valid is in there or not.  Too bad we
don't have a TLV format for skb->cb, so
      layers could pile things on.  But 48 bytes isn't much to play with.
  c) squash switch_id into u32 skb->mark.  We loose information here
and could collide between switch_ids.

3) bridge driver, in br_flood(), does check if skb switch_id mark
matches dst port switch_id.  If so, skips fwding pkt to that port.
The switch_id compare check compares switch_id len and contents.  If
skb has no switch_id mark, then compare can be skipped.


The only tough part is figuring out 2).  Just need someway to stuff
switch_id into skb.  With bridge driver doing match on switch_id on a
per-packet basis, we can support Florian's case where sometimes we
want the bridge driver to fwd pkts (in those cases, the driver just
leaves skb switch_id mark empty).   Mixed offloaded and non-offloaded
ports works because switch_id comparison fails for non-offload ports.
Same for mixed switches bridged together.  The per-pkt overhead
concerns are minimized.

-scott
