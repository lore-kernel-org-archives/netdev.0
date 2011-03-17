From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: build breakage due to br_multicast.c referencing
 ipv6_dev_get_saddr()
Date: Thu, 17 Mar 2011 09:23:02 +0100
Message-ID: <1300350182.10164.678.camel@edumazet-laptop>
References: <4D80BC5B0200007800036D85@vpn.id2.novell.com>
	 <20110316082441.45db3018@nehalam>
	 <4D81CDF6020000780003700B@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	davem@davemloft.net, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linus.luessing@web.de
To: Jan Beulich <JBeulich@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:65348 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab1CQIXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 04:23:09 -0400
Received: by fxm17 with SMTP id 17so2451989fxm.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 01:23:08 -0700 (PDT)
In-Reply-To: <4D81CDF6020000780003700B@vpn.id2.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 mars 2011 =C3=A0 08:01 +0000, Jan Beulich a =C3=A9crit :
> >>> On 16.03.11 at 16:24, Stephen Hemminger <shemminger@linux-foundat=
ion.org>
> wrote:
> > On Wed, 16 Mar 2011 12:34:19 +0000
> > "Jan Beulich" <JBeulich@novell.com> wrote:
> >=20
> >> With BRIDGE=3Dy and IPV6=3Dm commit
> >> fe29ec41aaa51902aebd63658dfb04fe6fea8be5 ("bridge: Use IPv6
> >> link-local address for multicast listener queries") causes the bui=
ld to
> >> break.
> >=20
> > Rather than continue with the config games, lets just make the nece=
ssary
> > ipv6 pieces accessible.
>=20
> The below (however ugly it may look) seems to do the trick for me,
> for this particular symbol. Possibly other symbols need doing the
> same (didn't check which ones e.g. infiniband depends on), so
> some sort of abstraction might be desirable to make the whole
> thing look less ugly.

You should check how things are properly done with RCU, because you mus=
t
make sure the module unload wont delete text another cpu is using.

net code usually use synchronize_{rcu|net}() calls.


example :

net/ipv4/netfilter/nf_nat_sip.c

static void __exit nf_nat_sip_fini(void)
{
        rcu_assign_pointer(nf_nat_sip_hook, NULL);
        rcu_assign_pointer(nf_nat_sip_seq_adjust_hook, NULL);
        rcu_assign_pointer(nf_nat_sip_expect_hook, NULL);
        rcu_assign_pointer(nf_nat_sdp_addr_hook, NULL);
        rcu_assign_pointer(nf_nat_sdp_port_hook, NULL);
        rcu_assign_pointer(nf_nat_sdp_session_hook, NULL);
        rcu_assign_pointer(nf_nat_sdp_media_hook, NULL);
        synchronize_rcu();
}



