From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Thu, 13 Apr 2017 21:22:21 +0200
Message-ID: <1492111341.29526.5.camel@sipsolutions.net>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
         <20170413042036.GA46229@ast-mbp.thefacebook.com>
         <20170413.113722.2174945057832588335.davem@davemloft.net>
         (sfid-20170413_173731_037765_D7037ED0)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58964 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751808AbdDMTW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 15:22:28 -0400
In-Reply-To: <20170413.113722.2174945057832588335.davem@davemloft.net> (sfid-20170413_173731_037765_D7037ED0)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-13 at 11:37 -0400, David Miller wrote:

> If the capability is variable, it must be communicated to the user
> somehow at program load time.
> 
> We are consistently finding that there is this real need to
> communicate XDP capabilities, or somehow verify that the needs
> of an XDP program can be satisfied by a given implementation.

Technically, once you know the capability of the *driver*, the verifier
should be able to check if the *program* is compatible. So if the
driver can guarantee "you always get 2k accessible", the verifier can
check that you don't access more than xdb->data + 2047, similar to how
it verifies that you don't access beyond xdb->data_end.

> And eth_get_headlen() only pulls protocol headers, which precludes
> XDP inspecting anything below TCP/UDP/etc.  This is also not
> reasonable.
> 
> Right now, as it stands, we have to assume the program can
> potentially be interested in the entire packet.

I agree with this though, it's not reasonable to have wildly varying
implementations here that may or may not be able to access almost
anything. The totally degenerate case would be having no skb header at
all, which is also still entirely valid from the network stack's POV.

> We can only optimize this and elide things when we have a facility in
> the future for the program to express it's needs precisely.  I think
> we will have to add some control structure to XDP programs that can
> be filled in for this purpose.

Like I said above, I think this is something that you can possibly
determine in the verifier.

So if, for example, the verifier notices that the program never
accesses anything but the first few bytes, then it would seem valid to
run with only that much pulled into the skb header.

OTOH, it might depend on the frame data itself, if the program does
something like

xdp->data[xdp->data[0] & 0xf]

(read or write, doesn't really matter) so then the verifier would have
to take the maximum possible value there into account.

johannes
