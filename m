From: Mike Walker <walkerstop@gmail.com>
Subject: Layer 2 over IPv6 GRE and path MTU discovery
Date: Fri, 14 Oct 2016 15:31:17 -0700
Message-ID: <CAP4E3ZHKR74d3mPaa-kJ5y1-AXsj4cnMWjAFu++jBnb0FiHgJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:36740 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753378AbcJNWbS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 18:31:18 -0400
Received: by mail-qt0-f173.google.com with SMTP id m5so83244856qtb.3
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 15:31:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using a layer 2 GREv6 tunnel (ip6gretap), I am using a Linux
bridge to push Ethernet frames from an Ethernet port to the GREv6
device.

Here is an example of the topology:

PC -> eth0 -> grebridge -> gre6dev -> (internet) -> GRE endpoint -> Remote host

In this case, the PC connected to the Ethernet port is using IPv6 to
communicate with the remote host, so the source and destination IP of
the traffic being sent by the PC are both IPv6 addresses.  So we have
an IPv6 header, Ethernet header, then GRE header once the
encapsulation is done.

Sometimes these packets are too large for the GRE tunnel's MTU.  When
this happens, the router's kernel wants to send an ICMP "packet too
big" error message back to the PC.

However, the router has no routing information for the PC.  The path
from the PC to the remote host is all supposed to be layer 2.  The
router is not configured to route traffic to the PC or the remote
host, only to bridge the layer 2 frames.

What happens then is Linux tries to send an ICMP error, it can't find
the route, or else it sends it to its default route, none of which do
any good.

If the PC doesn't get this ICMP error, it will not know why the
packets were dropped, or it won't even know they were dropped.  It's
an ICMP blackhole scenario right?

So, one solution I tried was hacking the kernel so that if it's trying
to send this ICMP "packet too big" error to a host, and we know it's a
layer 2 GRE tunnel, instead of the normal logic, force the ICMP error
message to be sent back out via the network interface the offending
packet was received on.

This mostly worked, the PC recieves the ICMP error and adjusts its
path MTU, so in the future it will know to fragment the packet if it's
too big.

Problem is, I don't know what source IP and mac address I should be
using when I send back this ICMP error to the PC.  Normally this
network path doesn't have any layer 3 address, and even the mac
address normally is transparent / unknown to the PC.  For my prototype
I simply set the source IP of the ICMP error to whatever was the
destination IP of the packet that was too big.  I let the kernel use
the mac address of either the bridge or eth0.

I couldn't seem to find any RFC that says how this should be handled.
Any ideas?
