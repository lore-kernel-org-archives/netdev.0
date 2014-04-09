From: Edward Cree <ecree@solarflare.com>
Subject: Re: udp: Question about busy_poll change
Date: Wed, 9 Apr 2014 17:20:04 +0100
Message-ID: <53457334.1030602@solarflare.com>
References: <53455581.7060209@solarflare.com> <20140409145129.GA4002@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Shawn Bohrer <sbohrer@rgmadvisors.com>,
	Jonathan Cooper <jcooper@solarflare.com>,
	<eric.dumazet@gmail.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60641 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933354AbaDIQUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 12:20:10 -0400
In-Reply-To: <20140409145129.GA4002@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/14 15:51, Shawn Bohrer wrote:
> I believe the sfc case where you only have a single NAPI context is
> also valid and it seems reasonable to me that if you can detect that
> specific case that busy polling could be allowed.  I'm not sure how to
> detect this.  I'm sure patches are welcome.
I think that to detect this we would have to have (a) a flag in the
struct sock to say that "this socket is bound to a real address" (ie.
not INADDR_ANY, multicast or anycast), (b) a flag in the skb to say that
"the driver that received this packet only uses one NAPI context per
intf.  Then if a && b you can fill in sk_napi_id even on unconnected
sockets.  If this sounds reasonable, I'll put a patch together.
> If we are spinning on a NAPI context and a packet arrives in a
> different rx queue then you'll get unpredictable latencies and
> out of order packets.  For the people using this feature that is
> probably not desirable.
A further question is, what happens if the user removes the IP address
from one interface and adds it to another?  AFAICT they will keep
busy_polling the old NAPI context until a packet is received on the new
interface and updates sk->sk_napi_id; and this is still the case even if
the socket is connected.  Of course this could be a case of "don't do
that then", but I can imagine some kind of hot-failover setup doing this.
This is also why we'd need a flag in the skb and can't just find out at
bind() time what the driver is and whether it uses multiple NAPI
contexts - because when the socket moves interface, it could end up on a
different driver.
