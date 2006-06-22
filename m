From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/7] NetLabel: core network changes
Date: Thu, 22 Jun 2006 02:07:48 -0700 (PDT)
Message-ID: <20060622.020748.85685000.davem@davemloft.net>
References: <20060621194234.979661000@flek.zko.hp.com>
	<20060621200030.880930000@flek.zko.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: redhat-lspp@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	sds@epoch.ncsc.mil, jmorris@redhat.com, sgrubb@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
To: paul.moore@hp.com
In-Reply-To: <20060621200030.880930000@flek.zko.hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: paul.moore@hp.com
Date: Wed, 21 Jun 2006 15:42:37 -0400

> Index: linux-2.6.17.i686-quilt/net/ipv4/Makefile
> ===================================================================
> --- linux-2.6.17.i686-quilt.orig/net/ipv4/Makefile
> +++ linux-2.6.17.i686-quilt/net/ipv4/Makefile
> @@ -42,6 +42,9 @@ obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybl
>  obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
>  obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
>  obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
> +ifeq ($(CONFIG_NETLABEL_CIPSOV4),y)
> +obj-y += cipso_ipv4.o
> +endif

Why not "obj-$CONFIG_NETLABEL_CIPSOV4 += cipso_ipv4.o"?

The whole idea behind the obj-$CONFIG_OPTION technique is
to avoid conditionals all over the makefile.

> Index: linux-2.6.17.i686-quilt/net/ipv4/af_inet.c
> ===================================================================
> --- linux-2.6.17.i686-quilt.orig/net/ipv4/af_inet.c
> +++ linux-2.6.17.i686-quilt/net/ipv4/af_inet.c
> @@ -114,6 +114,7 @@
>  #ifdef CONFIG_IP_MROUTE
>  #include <linux/mroute.h>
>  #endif
> +#include <net/netlabel.h>
>  
>  DEFINE_SNMP_STAT(struct linux_mib, net_statistics) __read_mostly;
>  
> @@ -616,6 +617,8 @@ int inet_accept(struct socket *sock, str
>  
>  	sock_graft(sk2, newsock);
>  
> +	netlbl_socket_inet_accept(sock, newsock);
> +
>  	newsock->state = SS_CONNECTED;
>  	err = 0;
>  	release_sock(sk2);

Neither the netlabel.h header not the implementation of
the netlbl_socket_inet_accept() function exist at this
point in your patch set.

At each patch point, the tree must build and function
properly.

This means you have to split up and order your changes
correctly, gradually building up the infrastructure and
then finally plugging it in and making use of it.

Nobody can test your work in an incremental fashion, and
thus it's not possible to determine if a bug or behavior
gets introduced at patch 2, 3 or 4, for example.

> +		        if (cipso_v4_validate(&optptr)) {
> +				pp_ptr = optptr;
> +				goto error;
> +			}
> +			break;

Same thing here, cipso_v4_validate() doesn't exist in the
tree at this point in the patch set, so the tree doesn't
build after applying this patch.

Please split up your submission properly.

I really can't sanely review the rest of this until you dice up your
changes properly.
