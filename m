From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: Multicast snooping fixes and suggestions
Date: Thu, 17 Feb 2011 19:17:50 +0100
Message-ID: <1297966672-3457-1-git-send-email-linus.luessing@web.de>
References: <20110215154128.2a28632c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110215154128.2a28632c@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> These look correct. Did you test them with real traffic?

Yes, I did. With these patches the hashlist and linked lists per port
are being filled correctly for IPv6 - initially. Verified that with
both some printk()s for the per port mglists as well as with vlc. With
patch 5/5 this also worked fine with transient link local addresses,
verified that with 'vlc -vvv "udp://@[ff12::123%eth1]"' on a device
connected to the other one with the bridge and could stream
a video as expected with no multicast traffic on any other bridge port.

However, the MLD queries are/were still broken, the queries initiated
by the bridge device do not get a response from the multicast listeners.
The following additional, attached patches fix this issue.


Last but not least, there are still a couple of bugs I could observe:
- I have attached a laptop with two interfaces with a multicast listener
  each to another PC playing with the bridge device. With the fixes
  below, the laptop sends a multicast listener report to the other PC
  on each interface, however these reports' IPv6 header's source addresses
  seem to be a random one from any of the laptop's two interfaces'
  link local addresses (which has to be a bug in the IPv6 code, as
  this one is generating the reports and not the bridge code) as long
  as it matches the selected multicast address (which was ff12::123 in
  this case).
- If there is no multicast listener present, then the multicast packets
  get flooded on all bridge ports.

And two issues with a little lower priority, I suppose:
- Packets do not get delivered to the bridge interface itself when
  a multicast listener has been started on this bridge interface
  (might be related to http://www.spinics.net/lists/linux-net/msg17556.html,
  so possibly a bug in the IPv6 code again).
~ Quitting of a multicast listener with a MLDv2 message is interpreted as
  a join, resulting in relatively long timeouts - but this MLDv1
  interpretation of MLDv2 messages seems to be intended so far due to its
  simplicity according to the comment in the code.

Cheers, Linus
