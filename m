From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: Re: IPv6 over firewire
Date: Sat, 12 Jan 2013 11:54:47 +0100
Message-ID: <50F140F7.60503@gmail.com>
References: <50EF1AEB.1080704@gmail.com> <20130110210912.09c62d38@stein> <50F10E94.9090302@gmail.com> <20130112102452.13babc65@stein>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux1394-devel@lists.sourceforge.net, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:55035 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600Ab3ALKyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 05:54:51 -0500
Received: by mail-ee0-f41.google.com with SMTP id d41so1205935eek.14
        for <netdev@vger.kernel.org>; Sat, 12 Jan 2013 02:54:49 -0800 (PST)
In-Reply-To: <20130112102452.13babc65@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But if a new callback is needed, it doesn't have to burden the kernel=
 much:
>
>    - In the linux-kernel OOP model, there are mandatory methods as we=
ll
>      as optional methods.  A new method for RFC 3146 Neighbor Discove=
ry
>      should of course be an optional one.
>
>    - There is a downside to optional methods:  The core code which ma=
y
>      have to use the method first needs to do a NULL check of the
>      method's function pointer or needs to check a correlated
>      capabilities flag or something like that.  Such additional check=
s
>      are undesirable in hot paths, but I suppose IPv6 Neighbor Discov=
ery
>      is not a particularly hot path.

Yes, that should be true.

>
>    - There is another downside:  Each new driver method increases the
>      memory footprint of instances of respective function pointer tab=
les
>      by 4 or 8 bytes.

I can't imagine that this is a show stopper. How many instances of=20
struct netdev do we have o a typical system? I guess not the much.

>
> Both downsides can be countered somewhat by enclosing the respective
> code into #ifdef CONFIG_RFC3146_NDISC...#endif and have something lik=
e
>      select RFC3146_NDISC if IPV6 =3D y || (IPV6 =3D m && FIREWIRE_NE=
T =3D m)
> in the "config FIREWIRE_NET" section.
>
> But the new callback (if one is really needed) doesn't have to be a d=
river
> method.  It could also look about like this:
>
>      include/net/ndisc.h:
>      -extern struct ndisc_options *ndisc_parse_options(u8 *opt, int o=
pt_len,
>      -		struct ndisc_options *ndopts);
>      +extern struct ndisc_options *__ndisc_parse_options(u8 *opt,
>      +		int opt_len, struct ndisc_options *ndopts,
>      +		whatever_type *callback);
>      +
>      +static inline struct ndisc_options *ndisc_parse_options(u8 *opt=
,
>      +		int opt_len, struct ndisc_options *ndopts)
>      +{
>      +	return __ndisc_parse_options(opt, len, ndopts, NULL);
>      +}
>
>      net/ipv6/ndisc.c:
>      -struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
>      -		struct ndisc_options *ndopts)
>      +struct ndisc_options *__ndisc_parse_options(u8 *opt, int opt_le=
n,
>      +		struct ndisc_options *ndopts, whatever_type *callback)
>       {
>
> Or the (optional!) callback could be a new member of struct ndisc_opt=
ions.

Hm, right now I have no opinion on that. Where does
whatever_type *callback comes from? Is it an exported method of the=20
firewire net driver or the new function pointer in struct netdevice?

> However, does net/ipv6/ndisc.c really need to be aware of the RFC 314=
6
> Neighbor Discovery related packet header layouts?  Isn't it possible =
to
> rewrite these headers in-place in drivers/firewire/net.c?


Yes, it it possible, but yoshfuji strongly voted against rewriting ndis=
c=20
packets in firewire net driver to maintain extensibility to protocols.=20
Especially IPSEC can just not work if I rewrite the packets in the driv=
er.

Regards,

Stephan


--=20
Welchen Unterschied gibt es zwischen einem toten Hund auf der
Stra=DFe und einer =FCberfahrenen Bratsche auf der Stra=DFe? Vor dem
toten Hund gibt es Bremsspuren.
