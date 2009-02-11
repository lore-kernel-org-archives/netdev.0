From: Alan Stern <stern@rowland.harvard.edu>
Subject: [BUG] SNAT sometimes allows packets to pass through unchanged
Date: Wed, 11 Feb 2009 12:37:25 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.0902111151040.3231-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kernel development list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:37059 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755457AbZBKRh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 12:37:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm seeing some strange behavior on my firewall, which is running 
Fedora 8's version of 2.6.26.  Every so often a packet with a private 
source address is sent out the public interface unchanged, when it 
should be dropped.

This happens when internal hosts are slow to close their end of a TCP 
connection.  For example:

	Internal host A (using a private address) initiates a TCP
	connection to an external server B.

	Data is sent back and forth.

	External host B sends a FIN and host A responds with ACK.

	Several minutes later (after the tracking for this connection
	has expired), host A sends a FIN to host B.  This packet
	goes through the firewall unchanged and is sent out the
	public interface with the private source address intact.

Now I would expect that such packets would be dropped, because they 
don't belong to an existing connection and they can't be the start of a 
new connection.  The fact that this doesn't happen indicates there is a 
bug in the netfilter code somewhere.

For reference, here is a lightly-edited extract from my iptables 
script on the firewall:

------------------------------------------------------------------------
# Use SNAT for new outgoing connections from private addresses.
OUTIP=...  # The IP address of the firewall's public interface, eth1
iptables -t nat -N startnat
iptables -t nat -A startnat -p tcp -j SNAT --to-source $OUTIP:7000-65500
iptables -t nat -A startnat -p udp -j SNAT --to-source $OUTIP:7000-65500
iptables -t nat -A startnat -p icmp -j SNAT --to-source $OUTIP
iptables -t nat -A startnat -j DROP

iptables -t nat -A POSTROUTING -o eth1 -s 10.0.0.0/8 -j startnat
------------------------------------------------------------------------

Can anyone help figure out what's wrong?

Alan Stern

