From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 29 Dec 2015 07:32:29 -0500
Message-ID: <20151229123229.GA22743@oracle.com>
References: <5682665A.7090102@list.ru>
 <20151229115821.GA9352@oracle.com>
 <56827759.8020605@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36759 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbbL2Mcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 07:32:35 -0500
Content-Disposition: inline
In-Reply-To: <56827759.8020605@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/29/15 15:06), Stas Sergeev wrote:
> Router on 192.168.8.1 is just a PC with ubuntu, w/o any special
> software. I'd be very surprised if it does so. As I understand,
> linux would accept such ICMP redirect only from the router, or
> could someone else also send them?

If someone elase can spoof redirects on your network, you have
a much bigger network management problem- at that point, how can you
trust anything, e.g., a default rdisc rtradv?

> But what worries me more, is the question:
> Should the linux kernel really silently accept those, breaking
> the routing in a completely unexpected ways? Isn't it a bug?

How is the receiver supposed to know that the redirect was "bad"?

In your example, you claimed that

a "good" redirect was:
     ip route get 91.189.89.237
     91.189.89.237 via 192.168.8.1 dev eth0  src 192.168.10.202
         cache

but a "bad" one was:

    ip route get 91.189.89.238
    91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
        cache <redirected>

Its not clear to me what the netmask on eth0 is - is this a /16
(in which case both redirs are "good" as far as the receiver can tell)?
Are the 2 gws also on a /16? or something longer?

> The sanity check against netmask looks trivial, so why it is not there?

According to rfc1812 (pg 82-84)

   Routers MUST NOT generate a Redirect Message unless all the following
   conditions are met:

   o The packet is being forwarded out the same physical interface that
      it was received from,

   o The IP source address in the packet is on the same Logical IP
      (sub)network as the next-hop IP address, and

   o The packet does not contain an IP source route option.

The second condition seems to have been violated by the router. I 
suppose it might not hurt if the receiver can do some sanity checking
on the redirect but this might not eliminate every error, since
it might not be possible to detect netmask mismatch in every case.

--Sowmini
