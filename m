From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: Re: [PATCHv6 iproute 2/2] Interface group as new ip link option
Date: Fri, 23 Nov 2007 14:25:47 +0100
Message-ID: <20071123132547.GB31342@innominate.com>
References: <11955644701165-git-send-email-panther@balabit.hu> <1195564470928-git-send-email-panther@balabit.hu> <11955644702451-git-send-email-panther@balabit.hu> <11955644701536-git-send-email-panther@balabit.hu> <11955644702194-git-send-email-panther@balabit.hu> <1195564470805-git-send-email-panther@balabit.hu> <11955644701808-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11955644701808-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2007 at 02:14:30PM +0100, Laszlo Attila Toth wrote:
> Interfaces can be grouped and each group has an unique positive integ=
er ID.
> It can be set via ip link. Symbolic names can be specified in
> /etc/iproute2/rt_ifgroup.
=20
> diff --git a/include/rt_names.h b/include/rt_names.h
> index 07a10e0..72c5247 100644
> --- a/include/rt_names.h
> +++ b/include/rt_names.h
> @@ -8,11 +8,13 @@ char* rtnl_rtscope_n2a(int id, char *buf, int len);
>  char* rtnl_rttable_n2a(__u32 id, char *buf, int len);
>  char* rtnl_rtrealm_n2a(int id, char *buf, int len);
>  char* rtnl_dsfield_n2a(int id, char *buf, int len);
> +char* rtnl_ifgroup_n2a(int id, char *buf, int len);
>  int rtnl_rtprot_a2n(__u32 *id, char *arg);
>  int rtnl_rtscope_a2n(__u32 *id, char *arg);
>  int rtnl_rttable_a2n(__u32 *id, char *arg);
>  int rtnl_rtrealm_a2n(__u32 *id, char *arg);
>  int rtnl_dsfield_a2n(__u32 *id, char *arg);
> +int rtnl_ifgroup_a2n(__u32 *id, char *arg);

Shouldn't rtnl_ifgroup_n2a() using __u32 for "id"? It is actually hande=
d
a __u32 value.

> diff --git a/lib/rt_names.c b/lib/rt_names.c
> index 8d019a0..a067e74 100644
> --- a/lib/rt_names.c
> +++ b/lib/rt_names.c
> @@ -446,3 +446,65 @@ int rtnl_dsfield_a2n(__u32 *id, char *arg)
>  	return 0;
>  }
> =20
> +static char * rtnl_rtifgroup_tab[256] =3D {
> +	"0",
> +};
> +
> +static int rtnl_rtifgroup_init;
> +
> +static void rtnl_rtifgroup_initialize(void)
> +{
> +	rtnl_rtifgroup_init =3D 1;
> +	rtnl_tab_initialize("/etc/iproute2/rt_ifgroup",
> +			    rtnl_rtifgroup_tab, 256);
> +}
> +
> +char * rtnl_ifgroup_n2a(int id, char *buf, int len)
> +{
> +	if (id<0 || id>=3D256) {
> +		snprintf(buf, len, "%d", id);
> +		return buf;
> +	}

Shouldn't we better use "hex" here? "hex" is used for values up to 255
and iptables matches use hex for all values as well.
(__u32 change proposed above will make "id<0" pointless.)

> +	if (!rtnl_rtifgroup_tab[id]) {
> +		if (!rtnl_rtifgroup_init)
> +			rtnl_rtifgroup_initialize();
> +	}
> +	if (rtnl_rtifgroup_tab[id])
> +		return rtnl_rtifgroup_tab[id];
> +	snprintf(buf, len, "0x%02x", id);
> +	return buf;
> +}

> +int rtnl_ifgroup_a2n(__u32 *id, char *arg)
> +{
> +	static char *cache =3D NULL;
> +	static unsigned long res;
> +	char *end;
> +	int i;
> +
> +	if (cache && strcmp(cache, arg) =3D=3D 0) {
> +		*id =3D res;
> +		return 0;
> +	}
> +
> +	if (!rtnl_rtifgroup_init)
> +		rtnl_rtifgroup_initialize();
> +
> +	for (i=3D0; i<256; i++) {
> +		if (rtnl_rtifgroup_tab[i] &&
> +		    strcmp(rtnl_rtifgroup_tab[i], arg) =3D=3D 0) {
> +			cache =3D rtnl_rtifgroup_tab[i];
> +			res =3D i;
> +			*id =3D res;
> +			return 0;
> +		}
> +	}
> +
> +	res =3D strtoul(arg, &end, 16);

Why should we hardcode base 16 here. strtoul can handle dec and hex
(0x..) just fine. The iptables matches are usign strtoul(,,0) as
well.

> +	if (!end || end =3D=3D arg || *end || res > 255)
> +		return -1;

Why do you restrict to values <=3D255? iptables match does not limit
and I do not really understand why I should restrict the values here.
(Even if they may not have a textual representation.)

Best regards,
	Lutz
--=20
Dr.-Ing. Lutz J=E4nicke
CTO
Innominate Security Technologies AG  /protecting industrial networks/
tel: +49.30.6392-3308
fax: +49.30.6392-3307
Albert-Einstein-Str. 14
D-12489 Berlin, Germany
www.innominate.com

Register Court: AG Charlottenburg, HR B 81603
Management Board: Joachim Fietz, Dirk Seewald
Chairman of the Supervisory Board: Edward M. Stadum

-----------------------------------------------------------------------=
-----

Visit us at the SPS/IPC/Drives in Nuremberg / Germany

27 - 29 November 2007, Hall 9, Stand 9-141

-----------------------------------------------------------------------=
-----
-
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
