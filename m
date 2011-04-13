From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: ipv4: add IPPROTO_ICMP socket kind
Date: Wed, 13 Apr 2011 13:29:49 +0300
Message-ID: <BANLkTi=ogJg_uJqsJFpnwnnr6LS+SFT3Vg@mail.gmail.com>
References: <20110409101514.GA4262@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>,
	Solar Designer <solar@openwall.com>,
	Kees Cook <kees.cook@canonical.com>,
	Dan Rosenberg <dan.j.rosenberg@gmail.com>,
	Eugene Teo <eugene@redhat.com>,
	Nelson Elhage <nelhage@ksplice.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Pekka Savola <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110409101514.GA4262@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 9, 2011 at 1:15 PM, Vasiliy Kulikov <segoon@openwall.com> w=
rote:
> This patch adds IPPROTO_ICMP socket kind.

> + =A0 =A0 =A0 seq_printf(f, "%5d: %08X:%04X %08X:%04X"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 " %02X %08X:%08X %02X:%08lX %08X %5d %8=
d %lu %d %p %d%n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bucket, src, srcp, dest, destp, sp->sk_=
state,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_wmem_alloc_get(sp),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_rmem_alloc_get(sp),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino=
(sp),

These zeroes can be embedded into format string for slightly faster pri=
nting.

> +static const struct file_operations ping_seq_fops =3D {
> + =A0 =A0 =A0 .owner =A0 =A0 =A0 =A0 =A0=3D THIS_MODULE,

Unnecessary line.
->owner is unused for proc files, this is not documented anywhere, but
it's unused.

> + =A0 =A0 =A0 .open =A0 =A0 =A0 =A0 =A0 =3D ping_seq_open,
> + =A0 =A0 =A0 .read =A0 =A0 =A0 =A0 =A0 =3D seq_read,
> + =A0 =A0 =A0 .llseek =A0 =A0 =A0 =A0 =3D seq_lseek,
> + =A0 =A0 =A0 .release =A0 =A0 =A0 =A0=3D seq_release_net,
> +};
> +
> +static const char ping_proc_name[] =3D "icmp";

Ewww :-)
Does not compiler create only one string?

> +static int ping_proc_register(struct net *net)
> +{
> + =A0 =A0 =A0 struct proc_dir_entry *p;
> + =A0 =A0 =A0 int rc =3D 0;
> +
> + =A0 =A0 =A0 p =3D proc_create_data(ping_proc_name, S_IRUGO, net->pr=
oc_net,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&ping_seq_fo=
ps, NULL);

There is proc_net_fops_create().

> + =A0 =A0 =A0 if (!p)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D -ENOMEM;
> + =A0 =A0 =A0 return rc;
> +}

> @@ -680,6 +747,15 @@ static struct ctl_table ipv4_net_table[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.proc_handler =A0 =3D proc_dointvec
> =A0 =A0 =A0 =A0},
> +#ifdef CONFIG_IP_PING
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .procname =A0 =A0 =A0 =3D "ping_group_r=
ange",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =A0 =A0 =A0 =A0 =A0 =3D &init_net=
=2Eipv4.sysctl_ping_group_range,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .maxlen =A0 =A0 =A0 =A0 =3D sizeof(init=
_net.ipv4.sysctl_ping_group_range),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =A0 =A0 =A0 =A0 =A0 =3D 0644,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .proc_handler =A0 =3D ipv4_ping_group_r=
ange,
> + =A0 =A0 =A0 },
> +#endif
> =A0 =A0 =A0 =A0{ }
> =A0};
>
> @@ -714,8 +790,22 @@ static __net_init int ipv4_sysctl_init_net(struc=
t net *net)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&net->ipv4.sysctl_icmp=
_ratemask;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0table[6].data =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&net->ipv4.sysctl_rt_c=
ache_rebuild_count;
> +#ifdef CONFIG_IP_PING
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 table[7].data =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &net->ipv4.sysctl_ping_=
group_range;
> +#endif

Now I understand it's not related, but next sysctl will have
"table[8].data =3D ..." line which is off-by-one if CONFIG_IP_PING=3Dn.
