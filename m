From: "Jan Beulich" <JBeulich@novell.com>
Subject: build breakage due to br_multicast.c referencing
	 ipv6_dev_get_saddr()
Date: Wed, 16 Mar 2011 12:34:19 +0000
Message-ID: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <shemminger@linux-foundation.org>,
	<bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>
To: <linus.luessing@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With BRIDGE=y and IPV6=m commit
fe29ec41aaa51902aebd63658dfb04fe6fea8be5 ("bridge: Use IPv6
link-local address for multicast listener queries") causes the build to
break.

Similary, even if both are =m, but ipv6.ko got blacklisted (as is
happening in various SuSE distros when disabling IPv6), there's
a runtime problem since bridge.ko then won't load anymore due
to the missing symbol.

I note that infiniband appears to have had a similar problem
(didn't verify whether they have other dependencies on ipv6.ko),
resolved by an odd looking dependency of INFINIBAND_ADDR_TRANS
on !(INFINIBAND = y && IPV6 = m).

IP_VS also seems to have a similar issue.

Resolving this the infiniband way seems rather undesirable to me.
Instead I would think that this and any similar dependency should
get resolved via placing a stub pointer in net/ipv6/addrconf_core.c
(for this particular case), and having ipv6.ko set the pointer to the
actual implementation.

Otherwise, namely in distro kernels, pure IPv4 environments
pointlessly load the (huge) ipv6.ko just to satisfy symbol
references that would never get called.

One unrelated other observation with this change of yours:
daddr is an input argument to ipv6_dev_get_saddr(), yet
it gets initialized only after the function was called. Is that
really correct?

Thanks, Jan

