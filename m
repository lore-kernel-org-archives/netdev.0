From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [RFC] Inverse of flowi{4,6}_oif: flowi{4,6}_not_oif
Date: Tue, 2 Feb 2016 23:42:49 +0100
Message-ID: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:54482 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbcBBWmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 17:42:53 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id eeafcff0
	for <netdev@vger.kernel.org>;
	Tue, 2 Feb 2016 22:41:44 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id ecbbf148
	TLS version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=YES
	for <netdev@vger.kernel.org>;
	Tue, 2 Feb 2016 22:41:43 +0000 (UTC)
Received: by mail-wm0-f54.google.com with SMTP id 128so140082536wmz.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 14:42:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

Sometimes it is useful to ask, "what is the route for 1.2.3.4/32 if we
*exclude* routes that go out through eth8?" Currently, the only way of
doing this is to read the entire routing table in userspace, and then
reimplement all of the logic for the various tables and metrics and
complex logic of the FIB, remove the routes you want, and then
calculate the answer. This is, obviously, far from satisfactory, as
it's not really feasible to accurate reimplement that. Of course,
another obviously flawed way would be to just remove those routes for
"dev eth8", do the lookup, and then re-add them, but this is
disruptive.

The best solution for this is to add a flowi4_not_oif and
flowi6_not_oif member which looks up a route that doesn't use the
specified netdev.

What are the use cases of this? Several.

In userspace, the most obvious usage is this: OpenVPN or OpenConnect
or any other similar application receives routes from a server. It
wants to add those routes to the routing table. But, it needs to make
sure that the OpenVPN endpoint is still accessible over the actual
network interface, especially in the case of being pushed "0/1 and
128/1". So, before adding those routes, it looks up what the existing
route is, and then adds that route explicitly: "ip route add
1.2.3.4/32 via <current default route>". Then it can add routes that
might potentially override this, while keeping the tunnel working.

However, there are big problems with this naive (yet "state of the
art") approach. What if the former default route changes (because of,
say, dhclient)? In this case, the explicit route to the endpoint is
not updated. Or worse, what if several complicated changes are made at
once to the routing table? The *only* way to reliably figure out the
new explicit route to the tunnel endpoint is to remove the tunnel's
existing routes (!), query the route for the endpoint, and then re-add
them. Not only does this affect availability due to its blatant lack
of atomicity, but it also is an issue from a network security
perspective. Another problem -- which affects me personally on a daily
basis -- is: what happens when the device that previously routed the
endpoint goes down, and then back up again? This happens with wireless
cards, for example, when a laptop suspends. On an OpenVPN laptop with
"0/1 and 128/1" routes, upon resuming from suspend and reconnecting to
a wireless network, one must manually reconfigure the explicit route
to the endpoint, since it has been automatically garbage collected
when the interface went down. No, this isn't a userspace problem: as
previously mentioned, userspace cannot reliably make the calculations
necessary to add such endpoint routes without affecting availability
and/or security.

There's another use case, inside the kernel. Geneve, vxlan, and many
other tunnel devices have this copy&pasted codeblock:

        if (rt->dst.dev == dev) { /* is this necessary? */
                netdev_dbg(dev, "circular route to %pI4\n", &fl4->daddr);
                ip_rt_put(rt);
                return ERR_PTR(-ELOOP);
        }

While it remains up for debate (and potential configuration flags)
whether one would want such an "automagical" solution, it is possible
to imagine "rt->dst" here being calculated with "flowi{4,6}_not_oif"
in mind, which would eliminate this loop detection need and generally
lead to having a happier network administrator.

In private discussions with several system admins and kernel
developers alike, the response has been, "oh my God, I know - I hate
this issue. What an elegant solution! Have you written to davem &
friends about this?" to which I respond, "maybe some day I'll have the
courage..." Well, this is it guys.

So, what I propose is adding this "flowi{4,6}_not_oif", for an
extremely common and only-properly-solved-by-the-kernel problem. The
first step would be augmenting fib4 and fib6, and the second step
would be adding support for this to ip-route(8) and the rtnetlink
layer.

I stress again: there is no feasible userspace solution to this problem.

So, this [RFC] is to determine the following:

(1) Would you merge a patch that adds this functionality?
(2) Is there someone intimately familiar with the FIB who would be
willing to write this patch?

- If 1 && 2, awesome! I owe you a steak dinner.
- If !1, why? You best have quite a good alternative solution for this
issue (that doesn't include the words "install NetworkManager").
- If 1 && !2, I'll do a thorough study of the FIB code and write it myself.
- If !1 and 2, um, well, join the cause I guess.

Hope to hear from you soon.

Thanks,
Jason
