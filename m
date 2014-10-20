From: James Carlson <carlsonj@workingcode.com>
Subject: Re: Routing BUG with ppp over l2tp
Date: Mon, 20 Oct 2014 13:19:40 -0400
Message-ID: <5445442C.8080508@workingcode.com>
References: <Pine.LNX.4.44L0.1410201152580.2403-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Alan Stern <stern@rowland.harvard.edu>,
	James Chapman <jchapman@katalix.com>,
	Michal Ostrowski <mostrows@earthlink.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.44L0.1410201152580.2403-100000@iolanthe.rowland.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/14 12:39, Alan Stern wrote:
> As far as I can tell, the problem is caused by bad routing.  The kernel
> gets confused because the IP address assigned by the VPN server to the
> server's end of the ppp tunnel is the _same_ as the server's actual IP
> address.

Indeed!  That's pretty darned lame behavior by that peer.  It would
probably be workable if you had a virtual router instance and were able
to put the L2TP connection in one routing instance and the PPP
connection in another routing instance, but that's likely not at all
simple to achieve.

> Unfortunately, I can't work around this problem by reconfiguring the
> VPN server -- there's no way to tell it to use a different IP address
> for its end of the VPN tunnel.  Furthermore, the server works just fine
> with clients running Windows or OS-X.

Really?  That seems ... improbable.

> So it looks like the problem has to be fixed either in the kernel or in 
> the way pppd sets up its routing entry.  Can you guys help?

I think the easiest solution is to configure pppd to lie to the kernel
about the remote address.  Who cares what the remote address is on a
point-to-point link anyway?

There's currently no option to do this, but the code change in ipcp_up()
in pppd/ipcp.c would be rather simple.  Just make the "noremoteip" code
run all the time:

/* Deliberately falsify the remote address.  We don't care. */
ho->hisaddr = htonl(0x0aa00002);

As long as you don't need to contact that specific remote server using
the badly-assigned "internal" VPN address and can live with the fact
that you'll either go through the regular Internet to that address or be
forced to use some other address configured on that server, you should
be good.

(The address I used above is 10.160.0.2.  That was one of the internal
DNS server addresses provided in the log you posted.  It's not necessary
that the address used here is exactly that, but it may well be helpful.)

If you can't do that for some reason, then I suppose it would be
possible to use IP Chains (or whatever the packet-modification tool du
jure is used in your Linux distribution) to nail up an exception so that
the outside packets go to the outside interface and the inside ones go
to the PPP interface.  Doing that likely requires selecting on (at
least!) source address, so it's messy and ugly and possibly error-prone,
but it might be doable.

Otherwise, contact the maintainer of that VPN server.  It's just plain
old broken, and life's too short for broken software.

-- 
James Carlson         42.703N 71.076W         <carlsonj@workingcode.com>
