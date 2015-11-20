From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Fri, 20 Nov 2015 09:19:25 +0900
Message-ID: <CAKD1Yr0Es9JqdDi_05Kif=TyCSA+n7yDHUNr-ND-SD4j4p=D9A@mail.gmail.com>
References: <1447879416.562854.443622857.62708268@webmail.messagingengine.com>
 <20151118.224919.452852815199526735.davem@davemloft.net> <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
 <20151119.005318.838757439536205791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:36493 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161228AbbKTATq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 19:19:46 -0500
Received: by ykdr82 with SMTP id r82so135517316ykd.3
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 16:19:45 -0800 (PST)
In-Reply-To: <20151119.005318.838757439536205791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2015 at 2:53 PM, David Miller <davem@davemloft.net> wrote:
> What I object to is userspace making reachability decisions, not
> whether SOCK_DESTROY closes the socket in one way or the other.

To be fair: userspace already makes reachability decisions. Using
iptables and ip rules, it can configure arbitrarily complex policies
such as "cause new TCP connections from port 12742 to port 443 by UID
12345 to fail with fast ECONNRESET". Userspace can change those
policies at any time.

I think what's new in this patchset is that today userspace can only
do that at connection establishment time; this patchset would allow
re-evaluating reachability for established connections as well.

But I do think this is needed. In addition to the "network
disconnected" and "VPN connected" examples, I already provided here's
another example where it's hard for the kernel to make reachability
decisions.

Android and iOS have settings that the user can use to allow or
disallow an app from using cellular data. If the user disables cell
data for app X, userspace will tell the kernel to drop all that app's
packets, but it can't prevent an app from hanging on read() or write()
on a socket that the app already had (e.g., one it had opened before
the user changed the setting and had left open for latency reasons).

In this case, userspace knows that that app's connections are now
unusable because it configured an iptables rule to block them. The
kernel doesn't really know until it the time comes to send a packet,
and maybe not even then.
