From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours:
	ip6_dst_lookup_tail NULL crash
Date: Tue, 9 Sep 2008 07:32:15 -0400
Message-ID: <20080909113215.GB5991@hmsreliant.think-freely.org>
References: <20080831111304.d57b9f5a.akpm@linux-foundation.org> <20080907181109.GA2466@2ka.mipt.ru> <200809072119.50307.rdenis@simphalempin.com> <20080908.131547.26037628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rdenis@simphalempin.com, johnpol@2ka.mipt.ru,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58116 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216AbYIILeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 07:34:25 -0400
Content-Disposition: inline
In-Reply-To: <20080908.131547.26037628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 01:15:47PM -0700, David Miller wrote:
> From: R=E9mi Denis-Courmont <rdenis@simphalempin.com>
> Date: Sun, 7 Sep 2008 21:19:49 +0300
>=20
> > Le dimanche 7 septembre 2008 21:11:09 Evgeniy Polyakov, vous avez =E9=
crit=A0:
> > > Since dst entry is allowed not to have neighbour entry, flush it =
just
> > > like with incomplete one. This drops performance of your applicat=
ion
> > > with more than 1024 neighbours to 1024 messages, to fix it you sh=
ould
> > > tune ipv6 routing parameters (gc intervals, gc threshold, maximum=
 number
> > > of entries and so on). There may be another problem with perfoman=
ce
> > > though, at least I was able to bump it 10 times with different se=
ttings,
> > > but still two times smaller than with 4k neighbours.
> >=20
> > That looks like a trivial local DoS against the IPv6 stack though?
> >=20
> > Especially in the case that the interface has IFF_NOARP, that seems=
 like a=20
> > weird limitation. Oh well...
>=20
> It's less of a DoS than the NULL pointer deref we get now, isn't it? =
:-)
>=20
> But I don't like this patch for several reasons:
>=20
> 1) Slapping on a NULL check in response to a OOPS at that exact
>    location is usually a very big red flag, and deserves high scrutin=
y
>    instead of blind acceptance.
>=20
> 2) Looking at the indentation of this DAD code block (it's all one ta=
b
>    too much) it's obviously a very shitty cut and paste job.  If the
>    coding style was too difficult to get right, what does this say
>    about that change that brought the code here, semantically? :-/
>=20
>    This means we should figure out how this code got to this place,
>    and what kind of invariants existed at the old location that might
>    make this dst->neighbour dereference valid, and what implications
>    there are for the fact that it can now be NULL.
>=20
> Really, we really need to understand much more deeply this situation.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

Here you go, patch to correct the indentation in that optimistic dad cl=
ause.
Also adds the NULL pointer check for dst->neighbour.  Fixes the reporte=
d oops
and my complete inabilty to determine proper code indentation :)

Best
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 ip6_output.c |   64 +++++++++++++++++++++++++++++---------------------=
---------
 1 file changed, 32 insertions(+), 32 deletions(-)



diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a4402de..e6671bd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -943,39 +943,39 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	}
=20
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
-		/*
-		 * Here if the dst entry we've looked up
-		 * has a neighbour entry that is in the INCOMPLETE
-		 * state and the src address from the flow is
-		 * marked as OPTIMISTIC, we release the found
-		 * dst entry and replace it instead with the
-		 * dst entry of the nexthop router
-		 */
-		if (!((*dst)->neighbour->nud_state & NUD_VALID)) {
-			struct inet6_ifaddr *ifp;
-			struct flowi fl_gw;
-			int redirect;
-
-			ifp =3D ipv6_get_ifaddr(net, &fl->fl6_src,
-					      (*dst)->dev, 1);
-
-			redirect =3D (ifp && ifp->flags & IFA_F_OPTIMISTIC);
-			if (ifp)
-				in6_ifa_put(ifp);
-
-			if (redirect) {
-				/*
-				 * We need to get the dst entry for the
-				 * default router instead
-				 */
-				dst_release(*dst);
-				memcpy(&fl_gw, fl, sizeof(struct flowi));
-				memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
-				*dst =3D ip6_route_output(net, sk, &fl_gw);
-				if ((err =3D (*dst)->error))
-					goto out_err_release;
-			}
+	/*
+	 * Here if the dst entry we've looked up
+	 * has a neighbour entry that is in the INCOMPLETE
+	 * state and the src address from the flow is
+	 * marked as OPTIMISTIC, we release the found
+	 * dst entry and replace it instead with the
+	 * dst entry of the nexthop router
+	 */
+	if (dst->neighbour && !((*dst)->neighbour->nud_state & NUD_VALID)) {
+		struct inet6_ifaddr *ifp;
+		struct flowi fl_gw;
+		int redirect;
+
+		ifp =3D ipv6_get_ifaddr(net, &fl->fl6_src,
+				      (*dst)->dev, 1);
+
+		redirect =3D (ifp && ifp->flags & IFA_F_OPTIMISTIC);
+		if (ifp)
+			in6_ifa_put(ifp);
+
+		if (redirect) {
+			/*
+			 * We need to get the dst entry for the
+			 * default router instead
+			 */
+			dst_release(*dst);
+			memcpy(&fl_gw, fl, sizeof(struct flowi));
+			memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
+			*dst =3D ip6_route_output(net, sk, &fl_gw);
+			if ((err =3D (*dst)->error))
+				goto out_err_release;
 		}
+	}
 #endif
=20
 	return 0;
--=20
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
