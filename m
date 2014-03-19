From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Wed, 19 Mar 2014 08:56:49 +0200
Message-ID: <CAF1J0HPsadLPbwxEJuvqAY9bGNYx46r2xS8XQbF0qtz_oqMoow@mail.gmail.com>
References: <1395055050-20874-1-git-send-email-mike.rapoport@ravellosystems.com>
	<CAJZOPZLN0SmB7xcLXWOnC2GoDfGhJ5N-T1zA4S4Pg+ikqyFnig@mail.gmail.com>
	<CAF1J0HNOSKvRpjxN9+fs25mVDqo9wh==c-ZuS1i7CaWAnrCEgA@mail.gmail.com>
	<20140318.232027.1528407849060824608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <or.gerlitz@gmail.com>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:44132 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756228AbaCSHDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 03:03:48 -0400
Received: by mail-qg0-f44.google.com with SMTP id a108so24529910qge.3
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 00:03:47 -0700 (PDT)
In-Reply-To: <20140318.232027.1528407849060824608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 11:20:27PM -0400, David Miller wrote:
> From: Mike Rapoport <mike.rapoport@ravellosystems.com>
> Date: Tue, 18 Mar 2014 17:51:23 +0200
>
> > On Tue, Mar 18, 2014 at 5:10 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> >> On Mon, Mar 17, 2014 at 1:17 PM, Mike Rapoport
> >> <mike.rapoport@ravellosystems.com> wrote:
> >>> If the vxlan interface is created without group definition, there is a
> >>> panic on the first packet reception:
> >>>
> >>> $ ip link add dev vxlan0 type vxlan id 1
> >>> $ ip addr add dev vxlan0 10.0.0.1/24
> >>> $ ip link set up dev vxlan0
> >>>
> >>>   BUG: unable to handle kernel paging request at 0000000100000103
> >>>   IP: [<ffffffff8143435b>] ipv6_rcv+0xfa/0x399
> >>
> >> Hi Mike,
> >>
> >> So this bug/fix is for 3.14 and also earlier kernels?
> >
> > I think the bug was introduced by addition of ipv6 to vxlan, which was
> > merged in 3.12.
>
> How did this code behave before ipv6 support was added?

With IPv4 only the outer IP header was just ip_hdr(skb).
The relevantange from ipv6 support patch is this:

@@ -917,9 +1053,20 @@ static void vxlan_rcv(struct vxlan_sock *vs,
                goto drop;

        /* Re-examine inner Ethernet packet */
-       oip = ip_hdr(skb);
+       if (remote_ip->sa.sa_family == AF_INET) {
+               oip = ip_hdr(skb);
+               saddr.sin.sin_addr.s_addr = oip->saddr;
+               saddr.sa.sa_family = AF_INET;
+#if IS_ENABLED(CONFIG_IPV6)
+       } else {
+               oip6 = ipv6_hdr(skb);
+               saddr.sin6.sin6_addr = oip6->saddr;
+               saddr.sa.sa_family = AF_INET6;
+#endif
+       }
+

--
Sincerely yours,
Mike.
