From: Cong Wang <amwang@redhat.com>
Subject: Re: [net-next,v5,2/3] bridge: only expire the mdb entry when query
 is received
Date: Fri, 21 Jun 2013 15:31:41 +0800
Message-ID: <1371799901.32026.5.camel@cr0>
References: <1369209176-6841-2-git-send-email-amwang@redhat.com>
	 <20130618120338.GA9063@Linus-Debian>
	 <20130619044438.GA8174@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@web.de>,
	netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62032 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933901Ab3FUHcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 03:32:09 -0400
In-Reply-To: <20130619044438.GA8174@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 12:44 +0800, Herbert Xu wrote:
> On Tue, Jun 18, 2013 at 02:03:38PM +0200, Linus L=C3=BCssing wrote:
> > Hi Amerigo,
> >=20
> > I just tested these three patches on top of 3.10-rc6 (thanks for
> > looking into these issues so far!) but unfortunately I'm still
> > having problems if there is no querier on the link:
> >=20
> > We will never discover a multicast listener which sends its
> > startup MLD reports before being attached to the bridge port.
> >=20
> > I had reported that issue two months ago to Herbert's patch which
> > changed the querier default [1].
> >=20
> > I guess in such a scenario where neither our querier is activated
> > nor could we detect any querier, then the only safe thing we can
> > do is to disable the bridge multicast snooping, isn't it?
>=20
> If we have seen no queries then we should simply flood.  The fact
> that we don't currently is a bug.

Something like this?

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 1b8b8b8..df49d14 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -105,6 +105,10 @@ int br_handle_frame_finish(struct sk_buff *skb)
                        if ((mdst && mdst->mglist) ||
                            br_multicast_is_router(br))
                                skb2 =3D skb;
+                       else if (hlist_empty(&br->router_list)) {
+                               unicast =3D false;
+                               goto flood;
+                       }
                        br_multicast_forward(mdst, skb, skb2);
                        skb =3D NULL;
                        if (!skb2)
@@ -121,6 +125,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
                skb =3D NULL;
        }
=20
+flood:
        if (skb) {
                if (dst) {
                        dst->used =3D jiffies;
