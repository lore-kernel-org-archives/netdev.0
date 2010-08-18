From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Wed, 18 Aug 2010 17:22:08 +0200
Message-ID: <1282144928.2194.104.camel@edumazet-laptop>
References: <E1OljPK-0006rQ-00.xeb-mail-ru@f238.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42050 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995Ab0HRPWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 11:22:13 -0400
Received: by wwi17 with SMTP id 17so963804wwi.1
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 08:22:12 -0700 (PDT)
In-Reply-To: <E1OljPK-0006rQ-00.xeb-mail-ru@f238.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 18:14 +0400, Dmitry Kozlov a =C3=A9=
crit :
> This patch contains:
> 1. pptp driver
> 2. gre demultiplexer driver for demultiplexing gre packets with diffe=
rent gre version
>    so ip_gre and pptp may coexists
> 3. ip_gre modification
> 4. other stuff
>=20
> Changes from patch v4:
> 1. using spinlock instead mutex
> 2. fixed coding style issues
>=20

> +static int __init pptp_init_module(void)
> +{
> +	int err =3D 0;
> +	printk(KERN_INFO "PPTP driver version " PPTP_DRIVER_VERSION "\n");
> +
> +	if (gre_add_protocol(&gre_pptp_protocol, GREPROTO_PPTP) < 0) {
> +		printk(KERN_INFO "PPTP: can't add protocol\n");
> +		goto out;
> +	}
> +
> +	err =3D proto_register(&pptp_sk_proto, 0);
> +	if (err) {
> +		printk(KERN_INFO "PPTP: can't register sk_proto\n");
> +		goto out_inet_del_protocol;
> +	}
> +
> +	err =3D register_pppox_proto(PX_PROTO_PPTP, &pppox_pptp_proto);
> +	if (err) {
> +		printk(KERN_INFO "PPTP: can't register pppox_proto\n");
> +		goto out_unregister_sk_proto;
> +	}
> +
> +	callid_sock =3D (struct pppox_sock **)vmalloc((MAX_CALLID + 1) * si=
zeof(void *));
> +	memset(callid_sock, 0, (MAX_CALLID + 1) * sizeof(void *));
> +
> +out:
> +	return err;
> +out_unregister_sk_proto:
> +	proto_unregister(&pptp_sk_proto);
> +out_inet_del_protocol:
> +	gre_del_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
> +	return err;
> +}



1) Please test return from vmalloc(), it can be NULL

Also, if you need to clear it, you might call=20

__vmalloc(size, GFP_KERNEL | __GFP_ZERO, PAGE_KERNEL);

(and result is already cleared)


2) For new code, it's advised to use :

pr_err(xxx) instead of printk(KERN_ERR xxx)
pr_info(xxx) instead of printk(KERN_INFO xxx)


3) After skb_dst_drop(skb), you dont need to call skb_dst_set(skb,
NULL), as it is already done (for example in pptp_rcv())

4) Since you touch some includes, you also can use __packed
instead of __attribute__ ((__packed__))


5) I feel a bit uncomfortable with lookup_chan_dst()

+static int lookup_chan_dst(__u16 call_id, __be32 d_addr)
+{
+       struct pppox_sock *sock;
+       struct pptp_opt *opt;
+       int i;
+
+       rcu_read_lock();
+       for (i =3D find_next_bit(callid_bitmap, MAX_CALLID, 1); i < MAX=
_CALLID; i =3D find_next_bit(callid_bitmap, MAX_CALLID, i + 1)) {

Split this too long line please, its really awful

+               sock =3D rcu_dereference(callid_sock[i]);
+               opt =3D &sock->proto.pptp;
+               if (opt->dst_addr.call_id =3D=3D call_id && opt->dst_ad=
dr.sin_addr.s_addr =3D=3D d_addr)
+                       break;
+       }
+       rcu_read_unlock();
+
+       return i < MAX_CALLID;
+}

Once you get a bit in bitmask, and rcu_dereference(callid_sock[i]),
there is no guarantee sock is not NULL.

You should add a test.
If sock is not NULL, then you have the guarantee (thanks to RCU) that
pointer is safe until the rcu_read_unlock()


Thanks


