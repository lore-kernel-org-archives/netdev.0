From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 25 Jan 2012 09:37:04 +0100
Message-ID: <1327480624.14373.51.camel@edumazet-laptop>
References: <20120123.134352.1621146585245670953.davem@davemloft.net>
	 <CAGsizzJnQ6b6eSC0ZnAtFguU7_xDfWFPSY6L4DWXc24F+Ts2XQ@mail.gmail.com>
	 <CAOzFzEjE7b-Y+_vOWeBKbHDkURRcYXomSTcwB91vKHVWQxBVsg@mail.gmail.com>
	 <20120124.230203.1478271172075708903.davem@davemloft.net>
	 <CAEP_g=9H9dV9=qtFPh4YeTNQ-t+UZGw-YqZ6hFWVNXjFy+GCZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	joseph.glanville@orionvm.com.au, steweg@ynet.sk,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEP_g=9H9dV9=qtFPh4YeTNQ-t+UZGw-YqZ6hFWVNXjFy+GCZg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 24 janvier 2012 =C3=A0 23:11 -0800, Jesse Gross a =C3=A9crit :

> I think it's actually the opposite - Open vSwitch can be used to
> implement this type of thing as well as for many other use cases.  On
> the other hand, even when implementing a multipoint L2 solution it ca=
n
> be useful to have additional levels of control but you can't do that
> with this patch because it essentially statically glues together
> tunneling and bridging.

Unless you can provide a working solution in a very short time, this
patch is a pragmatic one.

Code is not perfect and could be improved (for example using a helper
function to keep ipgre_rcv() shorter and reduce indentation level)

Stefan, could you move this code out of ipgre_rcv() ?


+#ifdef CONFIG_NET_IPGRE_BRIDGE
+                       if (ipv4_is_multicast(tunnel->parms.iph.daddr))=
 {
+                               tethhdr =3D eth_hdr(skb);
+                               if (!is_multicast_ether_addr(
+                                       tethhdr->h_source)) {
+                                       head =3D &tunnel->hash[
+                                               ipgre_tap_bridge_hash(
+                                                       tethhdr->h_sour=
ce)];
+                                       entry =3D ipgre_tap_bridge_find=
_rcu(head,
+                                               tethhdr->h_source);
+                                       if (likely(entry)) {
+                                               entry->raddr =3D orig_s=
ource;
+                                               entry->updated =3D jiff=
ies;
+                                       } else {
+                                         spin_lock(&tunnel->hash_lock)=
;
+                                         if (!ipgre_tap_bridge_find(he=
ad,
+                                               tethhdr->h_source))
+                                               ipgre_tap_bridge_create=
(
+                                                       head,
+                                                       orig_source,
+                                                       tethhdr->h_sour=
ce);
+                                         spin_unlock(&tunnel->hash_loc=
k);
+                                       }
+                               }
+                       }
+#endif
