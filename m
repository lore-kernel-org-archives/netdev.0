From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] netfilter: nf_conntrack_sctp: fix build warning
Date: Mon, 24 Nov 2008 20:35:16 +0800
Message-ID: <20081124123516.GB12944@localhost>
References: <20081123113315.GA16697@localhost> <20081123.135955.202482968.davem@davemloft.net> <20081124000652.GA5424@localhost> <4929FEA9.9090801@cn.fujitsu.com> <20081124011727.GA6462@localhost> <492A9CB4.3060004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <492A9CB4.3060004@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2008 at 02:23:16PM +0200, Patrick McHardy wrote:
> Wu Fengguang wrote:
> >> print some debug info would be better?
> >=20
> > Like this one?
> > +		pr_debug("Empty sctp packet\n");
> >=20
> > Fengguang
> > ---
> > netfilter: nf_conntrack_sctp: fix build warning
> >=20
> > net/netfilter/nf_conntrack_proto_sctp.c: In function =E2=80=98sctp_=
packet=E2=80=99:
> > net/netfilter/nf_conntrack_proto_sctp.c:376: warning: array subscri=
pt is above array bounds
>=20
> The warning is bogus, so we don't need a pr_debug() there.
> I've applied your first patch with an unlikely() added and
> a comment stating that the warning is bogus.

Thank you! I was expecting some better solution (and learn a bit) ;-)

> commit a3e2913ffd3dec7f6975f680035670261ad5f56e
> Author: Wu Fengguang <wfg@linux.intel.com>
> Date:   Mon Nov 24 13:18:00 2008 +0100
>=20
>     netfilter: nf_conntrack_sctp: fix build warning
>    =20
>     net/netfilter/nf_conntrack_proto_sctp.c: In function 'sctp_packet=
':
>     net/netfilter/nf_conntrack_proto_sctp.c:376: warning: array subsc=
ript is above array bounds
>    =20
>     [Patrick; add unlikely and comment stating that the warning is bo=
gus]
>    =20
>     Signed-off-by: Wu Fengguang <wfg@linux.intel.com>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
>=20
> diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/=
nf_conntrack_proto_sctp.c
> index c2bd457..1259ec6 100644
> --- a/net/netfilter/nf_conntrack_proto_sctp.c
> +++ b/net/netfilter/nf_conntrack_proto_sctp.c
> @@ -373,6 +373,12 @@ static int sctp_packet(struct nf_conn *ct,
>  	}
>  	write_unlock_bh(&sctp_lock);
> =20
> +	/* Avoid bogus warning, gcc doesn't realize do_basic_checks()
> +	 * guarantees that there is at least one SCTP chunk.
> +	 */
> +	if (unlikely(new_state =3D=3D SCTP_CONNTRACK_MAX))
> +		goto out;
> +

If do_basic_checks() guarantees that, why not Initialize new_state to 0=
?

---
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf=
_conntrack_proto_sctp.c
index ae8c260..218137d 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -317,7 +317,11 @@ static int sctp_packet(struct nf_conn *ct,
 		goto out;
 	}
=20
-	old_state =3D new_state =3D SCTP_CONNTRACK_MAX;
+	/* Avoid bogus warning, gcc doesn't realize do_basic_checks()
+	 * guarantees that there is at least one SCTP chunk.
+	 */
+	old_state =3D new_state =3D 0;
+
 	write_lock_bh(&sctp_lock);
 	for_each_sctp_chunk (skb, sch, _sch, offset, dataoff, count) {
 		/* Special cases of Verification tag check (Sec 8.5.1) */
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
