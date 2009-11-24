From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/4] veth: move loopback logic to common location
Date: Tue, 24 Nov 2009 19:28:58 +0100
Message-ID: <200911241928.59456.arnd@arndb.de>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <4B0C1031.4050803@trash.net> <m1aayb6bfg.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	virtualization@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Anna Fischer <anna.fischer@hp.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Patrick Mullaney <pmullaney@novell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933906AbZKXSaY@vger.kernel.org>
In-Reply-To: <m1aayb6bfg.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 24 November 2009, Eric W. Biederman wrote:
> I don't quite follow what you intend with dev_queue_xmit when the macvlan
> is in one namespace and the real physical device is in another.  Are
> you mentioning that the packet classifier runs in the namespace where
> the primary device lives with packets from a different namespace?

I treat internal and external delivery very differently, the three
cases are:

1. skb from real device to macvlan (macvlan_handle_frame): basically
unchanged from before, except avoiding duplicate broadcasts. All
skbs end up in netif_rx(vlan->dev) without clearing any data.
We catch the frame in netif_receive_skb before it interacts with the
namespace of the real device.

2. skb to external device (macvlan_start_xmit): if the destination
is external, we just end up in dev_queue_xmit, with skb->dev set to
the external device but no other changes. The data is already on the
way out at this stage, so the namespace should not matter any more.

3. internal delivery: an skb from one macvlan to another gets always
sent through dev_forward_skb, which is supposed to clear anything
that must not leave the namespace.

Does this make sense?

	Arnd <><
