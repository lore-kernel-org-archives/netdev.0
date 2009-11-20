From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] RDMA/addr: Use appropriate locking with for_each_netdev()
Date: Fri, 20 Nov 2009 06:28:00 +0100
Message-ID: <4B0628E0.6000404@gmail.com>
References: <4AF8EBA4.2070102@gmail.com>	<D5E1FB213939498DBFFEB5A3B83C08AD@amr.corp.intel.com> <adaocn8x6j7.fsf@roland-alpha.cisco.com> <8C10E584257A46DB9A0AD193520CF4A7@amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Roland Dreier'" <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8C10E584257A46DB9A0AD193520CF4A7-Zpru7NauK7drdx17CPfAsdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sean Hefty a =E9crit :
>> Would it be possible for you to take Eric's patch as the first in yo=
ur
>> set (keeping his From: of course) and base your fixes on top of that=
?
>=20
> Will do.
>=20

Any news of this patch ?

We need it for 2.6.32 and also to prepare 2.6.33 with upcoming patches.

Thanks

[PATCH] RDMA/addr: Use appropriate locking with for_each_netdev()

for_each_netdev() should be used with RTNL or dev_base_lock held,
or risk a crash.

Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/core/addr.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/a=
ddr.c
index bd07803..5ca0b2c 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -131,6 +131,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct=
 rdma_dev_addr *dev_addr)
=20
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
+		read_lock(&dev_base_lock);
 		for_each_netdev(&init_net, dev) {
 			if (ipv6_chk_addr(&init_net,
 					  &((struct sockaddr_in6 *) addr)->sin6_addr,
@@ -139,6 +140,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct=
 rdma_dev_addr *dev_addr)
 				break;
 			}
 		}
+		read_unlock(&dev_base_lock);
 		break;
 #endif
 	}
@@ -391,15 +393,17 @@ static int addr_resolve_local(struct sockaddr *sr=
c_in,
 	{
 		struct in6_addr *a;
=20
+		read_lock(&dev_base_lock);
 		for_each_netdev(&init_net, dev)
 			if (ipv6_chk_addr(&init_net,
 					  &((struct sockaddr_in6 *) dst_in)->sin6_addr,
 					  dev, 1))
 				break;
=20
-		if (!dev)
+		if (!dev) {
+			read_unlock(&dev_base_lock);
 			return -EADDRNOTAVAIL;
-
+		}
 		a =3D &((struct sockaddr_in6 *) src_in)->sin6_addr;
=20
 		if (ipv6_addr_any(a)) {
@@ -416,6 +420,7 @@ static int addr_resolve_local(struct sockaddr *src_=
in,
 			if (!ret)
 				memcpy(addr->dst_dev_addr, dev->dev_addr, MAX_ADDR_LEN);
 		}
+		read_unlock(&dev_base_lock);
 		break;
 	}
 #endif

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
