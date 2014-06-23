From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: [PATCHv2 net-next 2/4] bridge: adhere to querier
 election mechanism specified by RFCs
Date: Mon, 23 Jun 2014 07:58:21 +0530
Message-ID: <CADAe=+KViC7uej0KM4TrQXxrk-amU7CX73buviMU17jpQm61bw@mail.gmail.com>
References: <1400994205-31165-1-git-send-email-linus.luessing@web.de>
	<1400994205-31165-3-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=001a1134eda82b9a5d04fc779b8d
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	b.a.t.m.a.n@lists.open-mesh.org
To: =?UTF-8?Q?Linus_L=C3=BCssing?= <linus.luessing@web.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1400994205-31165-3-git-send-email-linus.luessing@web.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--001a1134eda82b9a5d04fc779b8d
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Luessing,

As per RFC 4541, snooping switches send query with source address as
0.0.0.0 since port in a L2 switch doesn't have ip-address configured.

With current changes linux bridge will always select a querier who sends a
query message with 0.0.0.0. Right ?

+       if (ntohl(saddr) <=3D ntohl(br->ip4_querier.addr.u.ip4))
+               goto update;

Currently linux bridge sends a query message with source address as
0.0.0.0. Right ?

What should be the expected behaviour ?




Regards,
Ajith
--------------------------------------------
codingfreak.blogspot.com


On Sun, May 25, 2014 at 10:33 AM, Linus L=C3=BCssing <linus.luessing@web.de=
>
wrote:

> MLDv1 (RFC2710 section 6), MLDv2 (RFC3810 section 7.6.2), IGMPv2
> (RFC2236 section 3) and IGMPv3 (RFC3376 section 6.6.2) specify that the
> querier with lowest source address shall become the selected
> querier.
>
> So far the bridge stopped its querier as soon as it heard another
> querier regardless of its source address. This results in the "wrong"
> querier potentially becoming the active querier or a potential,
> unnecessary querying delay.
>
> With this patch the bridge memorizes the source address of the currently
> selected querier and ignores queries from queriers with a higher source
> address than the currently selected one. This slight optimization is
> supposed to make it more RFC compliant (but is rather uncritical and
> therefore probably not necessary to be queued for stable kernels).
>
> Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
> ---
>  net/bridge/br_multicast.c |  101
> +++++++++++++++++++++++++++++++++++++++------
>  net/bridge/br_private.h   |    7 ++++
>  2 files changed, 95 insertions(+), 13 deletions(-)
>
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 5ccac62..b3f17c9 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -789,6 +789,18 @@ static void br_ip6_multicast_querier_expired(unsigne=
d
> long data)
>  }
>  #endif
>
> +static void br_multicast_select_own_querier(struct net_bridge *br,
> +                                           struct br_ip *ip,
> +                                           struct sk_buff *skb)
> +{
> +       if (ip->proto =3D=3D htons(ETH_P_IP))
> +               br->ip4_querier.addr.u.ip4 =3D ip_hdr(skb)->saddr;
> +#if IS_ENABLED(CONFIG_IPV6)
> +       else
> +               br->ip6_querier.addr.u.ip6 =3D ipv6_hdr(skb)->saddr;
> +#endif
> +}
> +
>  static void __br_multicast_send_query(struct net_bridge *br,
>                                       struct net_bridge_port *port,
>                                       struct br_ip *ip)
> @@ -804,8 +816,10 @@ static void __br_multicast_send_query(struct
> net_bridge *br,
>                 skb->dev =3D port->dev;
>                 NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL,
> skb->dev,
>                         dev_queue_xmit);
> -       } else
> +       } else {
> +               br_multicast_select_own_querier(br, ip, skb);
>                 netif_rx(skb);
> +       }
>  }
>
>  static void br_multicast_send_query(struct net_bridge *br,
> @@ -1065,6 +1079,62 @@ static int br_ip6_multicast_mld2_report(struct
> net_bridge *br,
>  }
>  #endif
>
> +static bool br_ip4_multicast_select_querier(struct net_bridge *br,
> +                                           __be32 saddr)
> +{
> +       if (!timer_pending(&br->ip4_own_query.timer) &&
> +           !timer_pending(&br->ip4_other_query.timer))
> +               goto update;
> +
> +       if (!br->ip4_querier.addr.u.ip4)
> +               goto update;
> +
> +       if (ntohl(saddr) <=3D ntohl(br->ip4_querier.addr.u.ip4))
> +               goto update;
> +
> +       return false;
> +
> +update:
> +       br->ip4_querier.addr.u.ip4 =3D saddr;
> +
> +       return true;
> +}
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +static bool br_ip6_multicast_select_querier(struct net_bridge *br,
> +                                           struct in6_addr *saddr)
> +{
> +       if (!timer_pending(&br->ip6_own_query.timer) &&
> +           !timer_pending(&br->ip6_other_query.timer))
> +               goto update;
> +
> +       if (ipv6_addr_cmp(saddr, &br->ip6_querier.addr.u.ip6) <=3D 0)
> +               goto update;
> +
> +       return false;
> +
> +update:
> +       br->ip6_querier.addr.u.ip6 =3D *saddr;
> +
> +       return true;
> +}
> +#endif
> +
> +static bool br_multicast_select_querier(struct net_bridge *br,
> +                                       struct br_ip *saddr)
> +{
> +       switch (saddr->proto) {
> +       case htons(ETH_P_IP):
> +               return br_ip4_multicast_select_querier(br, saddr->u.ip4);
> +#if IS_ENABLED(CONFIG_IPV6)
> +       case htons(ETH_P_IPV6):
> +               return br_ip6_multicast_select_querier(br, &saddr->u.ip6)=
;
> +#endif
> +       }
> +
> +       return false;
> +}
> +
>  static void
>  br_multicast_update_query_timer(struct net_bridge *br,
>                                 struct bridge_mcast_other_query *query,
> @@ -1127,15 +1197,13 @@ timer:
>  static void br_multicast_query_received(struct net_bridge *br,
>                                         struct net_bridge_port *port,
>                                         struct bridge_mcast_other_query
> *query,
> -                                       int saddr,
> -                                       bool is_general_query,
> +                                       struct br_ip *saddr,
>                                         unsigned long max_delay)
>  {
> -       if (saddr && is_general_query)
> -               br_multicast_update_query_timer(br, query, max_delay);
> -       else if (timer_pending(&query->timer))
> +       if (!br_multicast_select_querier(br, saddr))
>                 return;
>
> +       br_multicast_update_query_timer(br, query, max_delay);
>         br_multicast_mark_router(br, port);
>  }
>
> @@ -1150,6 +1218,7 @@ static int br_ip4_multicast_query(struct net_bridge
> *br,
>         struct igmpv3_query *ih3;
>         struct net_bridge_port_group *p;
>         struct net_bridge_port_group __rcu **pp;
> +       struct br_ip saddr;
>         unsigned long max_delay;
>         unsigned long now =3D jiffies;
>         __be32 group;
> @@ -1191,11 +1260,14 @@ static int br_ip4_multicast_query(struct
> net_bridge *br,
>                 goto out;
>         }
>
> -       br_multicast_query_received(br, port, &br->ip4_other_query,
> -                                   !!iph->saddr, !group, max_delay);
> +       if (!group) {
> +               saddr.proto =3D htons(ETH_P_IP);
> +               saddr.u.ip4 =3D iph->saddr;
>
> -       if (!group)
> +               br_multicast_query_received(br, port, &br->ip4_other_quer=
y,
> +                                           &saddr, max_delay);
>                 goto out;
> +       }
>
>         mp =3D br_mdb_ip4_get(mlock_dereference(br->mdb, br), group, vid)=
;
>         if (!mp)
> @@ -1235,6 +1307,7 @@ static int br_ip6_multicast_query(struct net_bridge
> *br,
>         struct mld2_query *mld2q;
>         struct net_bridge_port_group *p;
>         struct net_bridge_port_group __rcu **pp;
> +       struct br_ip saddr;
>         unsigned long max_delay;
>         unsigned long now =3D jiffies;
>         const struct in6_addr *group =3D NULL;
> @@ -1283,12 +1356,14 @@ static int br_ip6_multicast_query(struct
> net_bridge *br,
>                 goto out;
>         }
>
> -       br_multicast_query_received(br, port, &br->ip6_other_query,
> -                                   !ipv6_addr_any(&ip6h->saddr),
> -                                   is_general_query, max_delay);
> +       if (is_general_query) {
> +               saddr.proto =3D htons(ETH_P_IPV6);
> +               saddr.u.ip6 =3D ip6h->saddr;
>
> -       if (!group)
> +               br_multicast_query_received(br, port, &br->ip6_other_quer=
y,
> +                                           &saddr, max_delay);
>                 goto out;
> +       }
>
>         mp =3D br_mdb_ip6_get(mlock_dereference(br->mdb, br), group, vid)=
;
>         if (!mp)
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index f186ce8..bc1803b 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -78,6 +78,11 @@ struct bridge_mcast_other_query {
>         struct timer_list               timer;
>         unsigned long                   delay_time;
>  };
> +
> +/* selected querier */
> +struct bridge_mcast_querier {
> +       struct br_ip addr;
> +};
>  #endif
>
>  struct net_port_vlans {
> @@ -284,9 +289,11 @@ struct net_bridge
>         struct timer_list               multicast_router_timer;
>         struct bridge_mcast_other_query ip4_other_query;
>         struct bridge_mcast_own_query   ip4_own_query;
> +       struct bridge_mcast_querier     ip4_querier;
>  #if IS_ENABLED(CONFIG_IPV6)
>         struct bridge_mcast_other_query ip6_other_query;
>         struct bridge_mcast_own_query   ip6_own_query;
> +       struct bridge_mcast_querier     ip6_querier;
>  #endif /* IS_ENABLED(CONFIG_IPV6) */
>  #endif
>
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--001a1134eda82b9a5d04fc779b8d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div><div><div>Hi Luessing,<br><br></div>As per RFC 4=
541, snooping switches send query with source address as 0.0.0.0 since port=
 in a L2 switch doesn&#39;t have ip-address configured.<br><br></div>With c=
urrent changes linux bridge will always select a querier who sends a query =
message with 0.0.0.0. Right ?<br>

<br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (ntohl(saddr) &lt;=3D ntohl(br=
-&gt;ip4_querier.addr.u.ip4))<br>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 goto update;<br><br></div>Cur=
rently linux bridge sends a query message with source address as 0.0.0.0. R=
ight ?<br><br></div><div>

What should be the expected behaviour ?<br></div><div><br><br></div></div><=
div class=3D"gmail_extra"><br clear=3D"all"><div><br>Regards,<br>Ajith<br>-=
-------------------------------------------<br><a href=3D"http://codingfrea=
k.blogspot.com" target=3D"_blank">codingfreak.blogspot.com</a></div>


<br><br><div class=3D"gmail_quote">On Sun, May 25, 2014 at 10:33 AM, Linus =
L=C3=BCssing <span dir=3D"ltr">&lt;<a href=3D"mailto:linus.luessing@web.de"=
 target=3D"_blank">linus.luessing@web.de</a>&gt;</span> wrote:<br><blockquo=
te class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc so=
lid;padding-left:1ex">

MLDv1 (RFC2710 section 6), MLDv2 (RFC3810 section 7.6.2), IGMPv2<br>
(RFC2236 section 3) and IGMPv3 (RFC3376 section 6.6.2) specify that the<br>
querier with lowest source address shall become the selected<br>
querier.<br>
<br>
So far the bridge stopped its querier as soon as it heard another<br>
querier regardless of its source address. This results in the &quot;wrong&q=
uot;<br>
querier potentially becoming the active querier or a potential,<br>
unnecessary querying delay.<br>
<br>
With this patch the bridge memorizes the source address of the currently<br=
>
selected querier and ignores queries from queriers with a higher source<br>
address than the currently selected one. This slight optimization is<br>
supposed to make it more RFC compliant (but is rather uncritical and<br>
therefore probably not necessary to be queued for stable kernels).<br>
<br>
Signed-off-by: Linus L=C3=BCssing &lt;<a href=3D"mailto:linus.luessing@web.=
de">linus.luessing@web.de</a>&gt;<br>
---<br>
=C2=A0net/bridge/br_multicast.c | =C2=A0101 +++++++++++++++++++++++++++++++=
++++++++------<br>
=C2=A0net/bridge/br_private.h =C2=A0 | =C2=A0 =C2=A07 ++++<br>
=C2=A02 files changed, 95 insertions(+), 13 deletions(-)<br>
<br>
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c<br>
index 5ccac62..b3f17c9 100644<br>
--- a/net/bridge/br_multicast.c<br>
+++ b/net/bridge/br_multicast.c<br>
@@ -789,6 +789,18 @@ static void br_ip6_multicast_querier_expired(unsigned =
long data)<br>
=C2=A0}<br>
=C2=A0#endif<br>
<br>
+static void br_multicast_select_own_querier(struct net_bridge *br,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s=
truct br_ip *ip,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s=
truct sk_buff *skb)<br>
+{<br>
+ =C2=A0 =C2=A0 =C2=A0 if (ip-&gt;proto =3D=3D htons(ETH_P_IP))<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 br-&gt;ip4_querier.addr.=
u.ip4 =3D ip_hdr(skb)-&gt;saddr;<br>
+#if IS_ENABLED(CONFIG_IPV6)<br>
+ =C2=A0 =C2=A0 =C2=A0 else<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 br-&gt;ip6_querier.addr.=
u.ip6 =3D ipv6_hdr(skb)-&gt;saddr;<br>
+#endif<br>
+}<br>
+<br>
=C2=A0static void __br_multicast_send_query(struct net_bridge *br,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct net_brid=
ge_port *port,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct br_ip *i=
p)<br>
@@ -804,8 +816,10 @@ static void __br_multicast_send_query(struct net_bridg=
e *br,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb-&gt;dev =3D por=
t-&gt;dev;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 NF_HOOK(NFPROTO_BRI=
DGE, NF_BR_LOCAL_OUT, skb, NULL, skb-&gt;dev,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 dev_queue_xmit);<br>
- =C2=A0 =C2=A0 =C2=A0 } else<br>
+ =C2=A0 =C2=A0 =C2=A0 } else {<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 br_multicast_select_own_=
querier(br, ip, skb);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netif_rx(skb);<br>
+ =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0}<br>
<br>
=C2=A0static void br_multicast_send_query(struct net_bridge *br,<br>
@@ -1065,6 +1079,62 @@ static int br_ip6_multicast_mld2_report(struct net_b=
ridge *br,<br>
=C2=A0}<br>
=C2=A0#endif<br>
<br>
+static bool br_ip4_multicast_select_querier(struct net_bridge *br,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 _=
_be32 saddr)<br>
+{<br>
+ =C2=A0 =C2=A0 =C2=A0 if (!timer_pending(&amp;br-&gt;ip4_own_query.timer) =
&amp;&amp;<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !timer_pending(&amp;br-&gt;ip4_other_q=
uery.timer))<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto update;<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 if (!br-&gt;ip4_querier.addr.u.ip4)<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto update;<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 if (ntohl(saddr) &lt;=3D ntohl(br-&gt;ip4_querier.ad=
dr.u.ip4))<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto update;<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 return false;<br>
+<br>
+update:<br>
+ =C2=A0 =C2=A0 =C2=A0 br-&gt;ip4_querier.addr.u.ip4 =3D saddr;<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 return true;<br>
+}<br>
+<br>
+#if IS_ENABLED(CONFIG_IPV6)<br>
+static bool br_ip6_multicast_select_querier(struct net_bridge *br,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s=
truct in6_addr *saddr)<br>
+{<br>
+ =C2=A0 =C2=A0 =C2=A0 if (!timer_pending(&amp;br-&gt;ip6_own_query.timer) =
&amp;&amp;<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !timer_pending(&amp;br-&gt;ip6_other_q=
uery.timer))<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto update;<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 if (ipv6_addr_cmp(saddr, &amp;br-&gt;ip6_querier.add=
r.u.ip6) &lt;=3D 0)<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto update;<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 return false;<br>
+<br>
+update:<br>
+ =C2=A0 =C2=A0 =C2=A0 br-&gt;ip6_querier.addr.u.ip6 =3D *saddr;<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 return true;<br>
+}<br>
+#endif<br>
+<br>
+static bool br_multicast_select_querier(struct net_bridge *br,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct br_ip *s=
addr)<br>
+{<br>
+ =C2=A0 =C2=A0 =C2=A0 switch (saddr-&gt;proto) {<br>
+ =C2=A0 =C2=A0 =C2=A0 case htons(ETH_P_IP):<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return br_ip4_multicast_=
select_querier(br, saddr-&gt;u.ip4);<br>
+#if IS_ENABLED(CONFIG_IPV6)<br>
+ =C2=A0 =C2=A0 =C2=A0 case htons(ETH_P_IPV6):<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return br_ip6_multicast_=
select_querier(br, &amp;saddr-&gt;u.ip6);<br>
+#endif<br>
+ =C2=A0 =C2=A0 =C2=A0 }<br>
+<br>
+ =C2=A0 =C2=A0 =C2=A0 return false;<br>
+}<br>
+<br>
=C2=A0static void<br>
=C2=A0br_multicast_update_query_timer(struct net_bridge *br,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct bridge_mcast_other_query *que=
ry,<br>
@@ -1127,15 +1197,13 @@ timer:<br>
=C2=A0static void br_multicast_query_received(struct net_bridge *br,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct n=
et_bridge_port *port,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct b=
ridge_mcast_other_query *query,<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int saddr,<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bool is_general=
_query,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct br_ip *s=
addr,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned=
 long max_delay)<br>
=C2=A0{<br>
- =C2=A0 =C2=A0 =C2=A0 if (saddr &amp;&amp; is_general_query)<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 br_multicast_update_quer=
y_timer(br, query, max_delay);<br>
- =C2=A0 =C2=A0 =C2=A0 else if (timer_pending(&amp;query-&gt;timer))<br>
+ =C2=A0 =C2=A0 =C2=A0 if (!br_multicast_select_querier(br, saddr))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;<br>
<br>
+ =C2=A0 =C2=A0 =C2=A0 br_multicast_update_query_timer(br, query, max_delay=
);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 br_multicast_mark_router(br, port);<br>
=C2=A0}<br>
<br>
@@ -1150,6 +1218,7 @@ static int br_ip4_multicast_query(struct net_bridge *=
br,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct igmpv3_query *ih3;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct net_bridge_port_group *p;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct net_bridge_port_group __rcu **pp;<br>
+ =C2=A0 =C2=A0 =C2=A0 struct br_ip saddr;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long max_delay;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long now =3D jiffies;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 __be32 group;<br>
@@ -1191,11 +1260,14 @@ static int br_ip4_multicast_query(struct net_bridge=
 *br,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
- =C2=A0 =C2=A0 =C2=A0 br_multicast_query_received(br, port, &amp;br-&gt;ip=
4_other_query,<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !!iph-&gt;saddr, !group, max_=
delay);<br>
+ =C2=A0 =C2=A0 =C2=A0 if (!group) {<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 saddr.proto =3D htons(ET=
H_P_IP);<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 saddr.u.ip4 =3D iph-&gt;=
saddr;<br>
<br>
- =C2=A0 =C2=A0 =C2=A0 if (!group)<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 br_multicast_query_recei=
ved(br, port, &amp;br-&gt;ip4_other_query,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &=
amp;saddr, max_delay);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;<br>
+ =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 mp =3D br_mdb_ip4_get(mlock_dereference(br-&gt;=
mdb, br), group, vid);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!mp)<br>
@@ -1235,6 +1307,7 @@ static int br_ip6_multicast_query(struct net_bridge *=
br,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct mld2_query *mld2q;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct net_bridge_port_group *p;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct net_bridge_port_group __rcu **pp;<br>
+ =C2=A0 =C2=A0 =C2=A0 struct br_ip saddr;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long max_delay;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long now =3D jiffies;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 const struct in6_addr *group =3D NULL;<br>
@@ -1283,12 +1356,14 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
- =C2=A0 =C2=A0 =C2=A0 br_multicast_query_received(br, port, &amp;br-&gt;ip=
6_other_query,<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 !ipv6_addr_any(&amp;ip6h-&gt;=
saddr),<br>
- =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 is_general_query, max_delay);=
<br>
+ =C2=A0 =C2=A0 =C2=A0 if (is_general_query) {<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 saddr.proto =3D htons(ET=
H_P_IPV6);<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 saddr.u.ip6 =3D ip6h-&gt=
;saddr;<br>
<br>
- =C2=A0 =C2=A0 =C2=A0 if (!group)<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 br_multicast_query_recei=
ved(br, port, &amp;br-&gt;ip6_other_query,<br>
+ =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &=
amp;saddr, max_delay);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;<br>
+ =C2=A0 =C2=A0 =C2=A0 }<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 mp =3D br_mdb_ip6_get(mlock_dereference(br-&gt;=
mdb, br), group, vid);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!mp)<br>
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h<br>
index f186ce8..bc1803b 100644<br>
--- a/net/bridge/br_private.h<br>
+++ b/net/bridge/br_private.h<br>
@@ -78,6 +78,11 @@ struct bridge_mcast_other_query {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct timer_list =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 timer;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 delay_time;<br>
=C2=A0};<br>
+<br>
+/* selected querier */<br>
+struct bridge_mcast_querier {<br>
+ =C2=A0 =C2=A0 =C2=A0 struct br_ip addr;<br>
+};<br>
=C2=A0#endif<br>
<br>
=C2=A0struct net_port_vlans {<br>
@@ -284,9 +289,11 @@ struct net_bridge<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct timer_list =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 multicast_router_timer;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct bridge_mcast_other_query ip4_other_query=
;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct bridge_mcast_own_query =C2=A0 ip4_own_qu=
ery;<br>
+ =C2=A0 =C2=A0 =C2=A0 struct bridge_mcast_querier =C2=A0 =C2=A0 ip4_querie=
r;<br>
=C2=A0#if IS_ENABLED(CONFIG_IPV6)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct bridge_mcast_other_query ip6_other_query=
;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct bridge_mcast_own_query =C2=A0 ip6_own_qu=
ery;<br>
+ =C2=A0 =C2=A0 =C2=A0 struct bridge_mcast_querier =C2=A0 =C2=A0 ip6_querie=
r;<br>
=C2=A0#endif /* IS_ENABLED(CONFIG_IPV6) */<br>
=C2=A0#endif<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
1.7.10.4<br>
<br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe netdev&quot;=
 in<br>
the body of a message to <a href=3D"mailto:majordomo@vger.kernel.org">major=
domo@vger.kernel.org</a><br>
More majordomo info at =C2=A0<a href=3D"http://vger.kernel.org/majordomo-in=
fo.html" target=3D"_blank">http://vger.kernel.org/majordomo-info.html</a><b=
r>
</font></span></blockquote></div><br></div>

--001a1134eda82b9a5d04fc779b8d--
