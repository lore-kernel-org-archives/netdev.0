From: "Marcus D. Leech" <mleech@ripnet.com>
Subject: Possible bug: SO_TIMESTAMPING 2.6.30+
Date: Mon, 09 Nov 2009 19:40:30 -0500
Message-ID: <4AF8B67E.3030604@ripnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ripnet.com ([66.78.99.10]:3939 "EHLO mx1.ripnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016AbZKJAv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2009 19:51:27 -0500
Received: from localhost.localdomain (unverified [142.46.209.36]) by mx1.ripnet.com
  (Vircom SMTPRS 4.7.840.5) with ESMTP id <B0488650418@mx1.ripnet.com>
  (prot=TLS1-S cifer=RC4-128 hash=MD5-128 exch=RSA-1024 verify=NOT) for <netdev@vger.kernel.org>;
  Mon, 9 Nov 2009 19:40:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've searched both the LKML archives, and the patchsets for kernels 
since 2.6.30 to see if
   this problem has been observed.

I have an Ethernet driver that supports hardware timestamping, and it 
has been working
   swimmingly well for several months using the SO_TIMESTAMPING 
infrastructure that
   Patrick Ohly put in the kernel starting around 2.6.30.

What I've discovered, that really causes me to pull my hair out, is that 
packets that are
   either AF_INET6 or AF_PACKET, *are not* getting Tx (transmit) 
timestamps.  Diving into
   the driver, I've discovered that the sk_buffs associated with these 
packets *dont* have
   the appropriate skb_tx state in the skb:

               shtx = skb_tx(skb);
               if (shtx->hardware)
               {
                        /* Do the timestamping thing */
                }

Now the puzzling thing is that the socket that originates these packets 
has SO_TIMESTAMPING
   turned on, and was created as an AF_INET6 socket, but carries both V4 
and V6 traffic.  The
   V4 traffic skbs  have  shtx->hardware  true appropriately,  but the 
V6 traffic doesn't.  Using
   Wireshark, I can clearly see the V6 packets leaving the interface, so 
it's not like they're
   getting routed somewhere else, and debugging in the driver *clearly* 
shows that V4 packets
   have shtx->hardware, while the V6 ones (from the SAME SOCKET) do not.

I know that Patrick Ohly has essentially moved on from doing the 
SO_TIMESTAMPING stuff, so
   who's maintaining it now?

When I look at the V6 udp code, it seems to call the same udp_sendmsg() 
function that V4
   uses, which appears to support Tx timestamping the way it should.

Any clues anyone?
