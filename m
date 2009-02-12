From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG] SNAT sometimes allows packets to pass through unchanged
Date: Thu, 12 Feb 2009 06:18:42 +0100
Message-ID: <4993B132.80908@trash.net>
References: <Pine.LNX.4.44L0.0902111151040.3231-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39916 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbZBLFSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 00:18:47 -0500
In-Reply-To: <Pine.LNX.4.44L0.0902111151040.3231-100000@iolanthe.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Stern wrote:
> I'm seeing some strange behavior on my firewall, which is running 
> Fedora 8's version of 2.6.26.  Every so often a packet with a private 
> source address is sent out the public interface unchanged, when it 
> should be dropped.
> 
> This happens when internal hosts are slow to close their end of a TCP 
> connection.  For example:
> 
> 	Internal host A (using a private address) initiates a TCP
> 	connection to an external server B.
> 
> 	Data is sent back and forth.
> 
> 	External host B sends a FIN and host A responds with ACK.
> 
> 	Several minutes later (after the tracking for this connection
> 	has expired), host A sends a FIN to host B.  This packet
> 	goes through the firewall unchanged and is sent out the
> 	public interface with the private source address intact.
> 
> Now I would expect that such packets would be dropped, because they 
> don't belong to an existing connection and they can't be the start of a 
> new connection.  The fact that this doesn't happen indicates there is a 
> bug in the netfilter code somewhere.

If the connection has already timed out (from conntracks perspective),
it has lost its state. Unless connection pickup is enabled, the packet 
will be marked as INVALID because it doesn't belong to a connection.
You can control dropping of these packets yourself by adding the
appropriate "-m state --state INVALID" rules. That said, there were
some bugs in the past few releases that caused some bad interaction
between TCP and TCP conntrack (not sure anymore which one of both was
to blame). Its possible that this is the root cause for this, so
you might want to consider a kernel update.
