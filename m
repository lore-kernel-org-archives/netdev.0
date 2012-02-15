From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Traffic shaping with netkey
Date: Wed, 15 Feb 2012 05:40:14 -0500
Message-ID: <1329302414.6479.18.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:63154 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755978Ab2BOKkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 05:40:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I'm finally making some progress on our 95 percentile
traffic shaping project.  The last major area of exploration has been
handling all kinds of VPN traffic - netkey, KLIPS, OpenVPN.  netkey has
proven the most challenging with its double pass through the same
interface.  After several days playing in the lab, I'd like to share my
observations to see if they are as they should be or if I mangled my
testing!

The challenge has been classifying the netkey traffic.  Ingress has
proven easier than egress surprisingly.  I redirected all ingress to an
ifb interface.  I needed to create a separate, relatively unlimited HFSC
service curve for the ESP traffic, but then was able to use a tc filter
to properly classify the decrypted packets.  I find I can also use
CONNMARK to classify the decrypted packets on ingress.

Egress has been a challenge.  Perhaps it is extra complicated because I
needed to redirect all egress traffic to an ifb interface, too, so that
traffic coming off the tun and ipsec interfaces would land in the same
queues as the netkey traffic.  The only was I could do this for egress
was to use the iptables CLASSIFY target. That seemed to properly
classify the netkey traffic before it was encrypted.  tc filters did not
seem to catch the packet before it was encrypted; perhaps this is
because the filters are operating on the ifb interface and the packet
has been encrypted/encapsulated before handing it off to ifb.

Most surprisingly, I found I could not use CONNMARK for egress netkey
traffic.  I could see that SYN packet triggered the rule to mark the
connection and I see tons of packets hitting the restore mark rule but
all the traffic is going to the default HFSC queue rather than being
properly classified.

Is this to be expected, viz., that CLASSIFY works on ifb redirected
netkey egress traffic but tc filters and CONNMARK do not? Thanks - John
