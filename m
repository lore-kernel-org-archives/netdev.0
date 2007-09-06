From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/1] ipv6: corrects sended rtnetlink message
Date: Thu, 6 Sep 2007 12:47:11 +0200
Message-ID: <20070906104711.GV18480@postel.suug.ch>
References: <20070815143322.GA25640@wq.cz> <20070821.002058.102575162.davem@davemloft.net> <20070829215119.GB15856@wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42732 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615AbXIFKqv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 06:46:51 -0400
Content-Disposition: inline
In-Reply-To: <20070829215119.GB15856@wq.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Milan Kocian <milon@wq.cz> 2007-08-29 23:51
> Because RTM_NEWLINK is used to notify about device status change
> (as I see in net/core/rtnetlink.c) and RTM_DELLINK to inform about
> NETDEV_UNREGISTER. Why should it be else in ipv6 subsystem ? And
> userspace programs (quagga) suppose it. Now userspace get two rtnetlink's
> 'LINK' messages on 'ip l s down' event. First is RTM_NEWLINK from 
> net/core/rtnetlink.c and second is RTM_DELLINK from ipv6.

The logic behind is quite simple, we notify via RTM_NEWLINK whenever
a device changes any of its attributes.

> quagga story:
> On NEWLINK (flag IFF_UP is down) message quagga flushes all routes from RIB
> but leaves ip adresses. On DELLINK message q. flushes routes and addresses.
> On 'ip l s up' event ipv6 sends addresses and routes again but ipv4 not
> (it sends only routes). Thus q. stays without knowledge about ipv4's addresses
> after 'ip l s down/up' commands.
> 
> git change:
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=979ad663125af4be120697263038bb06ddbb83b4

It is arguable whether this change is correct, the purpose is clearly
to notify that IPv6 is no longer available on this interface without
implying anything beyond that.

Fortunately, all unregister events have the ifi_change field set to ~0U
whereas the "IPv6 disabled" notification sets the ifi_chagne field to
0 making it trivial to differ between the two cases. So quagga can
simply ignore (RTM_DELLINK && !ifi_change) notifications.

> IMHO second possibility is to remove rtnetlink notification about
> NETDEV_DOWN/_UNREGISTER from ipv6 subsystem because it is duplicate message.

Please make sure nobody is relying on this notification, IPv6 includes
more information in link messages, someone may be relying on this. If
not, feel free to remove the notification.
