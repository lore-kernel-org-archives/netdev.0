From: Milan Kocian <milon@wq.cz>
Subject: Re: [PATCH 1/1] ipv6: corrects sended rtnetlink message
Date: Wed, 29 Aug 2007 23:51:19 +0200
Message-ID: <20070829215119.GB15856@wq.cz>
References: <20070815143322.GA25640@wq.cz> <20070821.002058.102575162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wq.cz ([82.202.95.52]:34626 "EHLO nt.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761229AbXH2W2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 18:28:30 -0400
Content-Disposition: inline
In-Reply-To: <20070821.002058.102575162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 21, 2007 at 12:20:58AM -0700, David Miller wrote:
> From: Milan Kocian <milon@wq.cz>
> Date: Wed, 15 Aug 2007 16:33:22 +0200
> 
> > ipv6 sends a RTM_DELLINK netlink message on both events: NETDEV_DOWN,
> > NETDEV_UNREGISTER. Corrected by sending RTM_NEWLINK on NETDEV_DOWN event
> > and RTM_DELLINK on NETDEV_UNREGISTER event.
> 
> Why would we indicate that a new device has appeared on NETDEV_DOWN?
> 
> I don't see any sense in saying "RTM_NEWLINK" for a removal, it's
> for additions.
> 
Sorry for my late reply. I was out.

Because RTM_NEWLINK is used to notify about device status change
(as I see in net/core/rtnetlink.c) and RTM_DELLINK to inform about
NETDEV_UNREGISTER. Why should it be else in ipv6 subsystem ? And
userspace programs (quagga) suppose it. Now userspace get two rtnetlink's
'LINK' messages on 'ip l s down' event. First is RTM_NEWLINK from 
net/core/rtnetlink.c and second is RTM_DELLINK from ipv6.

quagga story:
On NEWLINK (flag IFF_UP is down) message quagga flushes all routes from RIB
but leaves ip adresses. On DELLINK message q. flushes routes and addresses.
On 'ip l s up' event ipv6 sends addresses and routes again but ipv4 not
(it sends only routes). Thus q. stays without knowledge about ipv4's addresses
after 'ip l s down/up' commands.

git change:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=979ad663125af4be120697263038bb06ddbb83b4

So from this point of view I tried to synchronize types of messages
on the same events.

IMHO second possibility is to remove rtnetlink notification about
NETDEV_DOWN/_UNREGISTER from ipv6 subsystem because it is duplicate message.

regards,

milon

