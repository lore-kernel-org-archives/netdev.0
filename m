From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v2] ipt_REJECT: can't work with bridges
Date: Wed, 4 Aug 2010 07:54:43 +0800
Message-ID: <AANLkTimozCTLQDFRFH92Q3yJ6ZZD5bSCoTkMRDpQ9ybV@mail.gmail.com>
References: <1278314214-18469-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1278314214-18469-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 5, 2010 at 3:16 PM, Changli Gao <xiaosuo@gmail.com> wrote:
> ipt_REJECT: can't work with bridges
>
> ip_route_me_harder can't create the route cache when the outdev is th=
e same with
> the indev for the skbs whichout a valid protocol set.
>
> __mkroute_input functions has this check:
> 1998 =A0 =A0 =A0 =A0 if (skb->protocol !=3D htons(ETH_P_IP)) {
> 1999 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Not IP (i.e. ARP). Do not cre=
ate route, if it is
> 2000 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* invalid for proxy arp. DNAT=
 routes are always valid.
> 2001 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> 2002 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Proxy arp feature have been=
 extended to allow, ARP
> 2003 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* replies back to the same in=
terface, to support
> 2004 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Private VLAN switch technol=
ogies. See arp.c.
> 2005 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> 2006 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (out_dev =3D=3D in_dev &&
> 2007 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IN_DEV_PROXY_ARP_PVLAN(i=
n_dev) =3D=3D 0) {
> 2008 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> 2009 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto cleanup;
> 2010 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> 2011 =A0 =A0 =A0 =A0 }
>
> This patch gives the new skb a valid protocol to bypass this check. I=
n order to
> make ipt_REJECT work with bridges, you also need to enable ip_forward=
=2E
>
> This patch also fixes a regression. When we used skb_copy_expand(), w=
e didn't
> have this issue stated above, as the protocol was properly set. In fa=
ct, the
> regression also affects TC classification and packet sockets.
>
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
> =A0net/ipv4/netfilter/ipt_REJECT.c | =A0 =A01 +
> =A01 file changed, 1 insertion(+)
> diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt=
_REJECT.c
> index bbbd273..60b8832 100644
> --- a/net/ipv4/netfilter/ipt_REJECT.c
> +++ b/net/ipv4/netfilter/ipt_REJECT.c
> @@ -111,6 +111,7 @@ static void send_reset(struct sk_buff *oldskb, in=
t hook)
> =A0 =A0 =A0 =A0/* ip_route_me_harder expects skb->dst to be set */
> =A0 =A0 =A0 =A0skb_dst_set_noref(nskb, skb_dst(oldskb));
>
> + =A0 =A0 =A0 nskb->protocol =3D htons(ETH_P_IP);
> =A0 =A0 =A0 =A0if (ip_route_me_harder(nskb, addr_type))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto free_nskb;
>
>

This bugfix patch seems missed, or I need to respin it? Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
