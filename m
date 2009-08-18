From: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: bad nat connection tracking performance with ip_gre
Date: Tue, 18 Aug 2009 22:36:50 +0300
Message-ID: <4A8B02D2.2090400@iki.fi>
References: <4A8A7F14.3010103@iki.fi> <4A8A84AF.7050901@trash.net> <4A8AA253.8090300@iki.fi> <4A8AA63D.4000702@trash.net> <4A8AB25A.4000105@iki.fi> <4A8AC1A0.6000602@trash.net> <4A8AE76D.7040707@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58515 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbZHRTgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 15:36:50 -0400
In-Reply-To: <4A8AE76D.7040707@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Yes. But my observation was that for the same amount of packets
> sent locally the CPU usage is significantly higher than if they
> are forwarded from physical interface. That's what made me
> curious.
>=20
> If I had remember that icmp conn track entries get pruned right
> when they get icmp reply back, I would not have probably bothered
> to bug you. But that made me think it was more of generic problem
> than my patch.
>=20
> I'll also double check with oprofile the local sendto() approach=20
> where it dies.

Ok, finally figured out the difference. Looks like depending
on the sendto() / local route / forward route / my patched mrt
the skb that gets passed to ipgre_tunnel_xmit() seems to have
nfctinfo either 0 or 2. This value is not modified; nf_reset()
is called just before ip_local_out(). Looks like nf_reset()
clears nfct to NULL, but does not touch nfctinfo.

So when LOCAL_OUT hook for the GRE packet is hit, depending
where the packet came: it has nfct=3DNULL and nfctinfo=3DESTABLISHED
or NEW. This also seems to affect if that specific skb gets
the nat/OUTPUT hook called.

Is this behaviour for nf_reset() intentional?

- Timo
