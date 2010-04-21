From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] netfilter: xtables: inclusion of xt_SYSRQ
Date: Wed, 21 Apr 2010 14:59:32 +0200
Message-ID: <4BCEF6B4.8090105@trash.net>
References: <1271845618-28569-1-git-send-email-jengelh@medozas.de> <1271845618-28569-2-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1271845618-28569-2-git-send-email-jengelh@medozas.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> The SYSRQ target will allow to remotely invoke sysrq on the local
> machine. Authentication is by means of a pre-shared key that can
> either be transmitted plaintext or digest-secured.

I really think this is pushing what netfilter is meant for a bit
far. Its basically abusing the firewall ruleset to offer a network
service.

I can see that its useful to have this in the kernel instead of
userspace, but why isn't this implemented as a stand-alone module?
That seems like a better design to me and also makes it more useful
by not depending on netfilter.

> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
> ---
>  net/netfilter/Kconfig    |   12 ++
>  net/netfilter/Makefile   |    1 +
>  net/netfilter/xt_SYSRQ.c |  354 ++++++++++++++++++++++++++++++++++++=
++++++++++
>  3 files changed, 367 insertions(+), 0 deletions(-)
>  create mode 100644 net/netfilter/xt_SYSRQ.c
>=20
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index 673a6c8..bfd9b6f 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -502,6 +502,18 @@ config NETFILTER_XT_TARGET_RATEEST
> =20
>  	  To compile it as a module, choose M here.  If unsure, say N.
> =20
> +config NETFILTER_XT_TARGET_SYSRQ
> +	tristate '"SYSRQ" - remote sysrq invocation'
> +	depends on NETFILTER_ADVANCED
> +	---help---
> +	This option enables the "SYSRQ" target which can be used to trigger
> +	sysrq from a remote machine using a magic UDP packet with a pre-sha=
red
> +	password. This is useful when the receiving host has locked up in a=
n
> +	Oops yet still can process incoming packets.
> +
> +	Besides plaintext packets, digest-secured SYSRQ requests will be
> +	supported when CONFIG_CRYPTO is enabled.
> +
>  config NETFILTER_XT_TARGET_TEE
>  	tristate '"TEE" - packet cloning to alternate destiantion'
>  	depends on NETFILTER_ADVANCED
> diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> index 14e3a8f..f032195 100644
> --- a/net/netfilter/Makefile
> +++ b/net/netfilter/Makefile
> @@ -56,6 +56,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) +=3D xt_N=
=46QUEUE.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) +=3D xt_NOTRACK.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_RATEEST) +=3D xt_RATEEST.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) +=3D xt_SECMARK.o
> +obj-$(CONFIG_NETFILTER_XT_TARGET_SYSRQ) +=3D xt_SYSRQ.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_TPROXY) +=3D xt_TPROXY.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_TCPMSS) +=3D xt_TCPMSS.o
>  obj-$(CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP) +=3D xt_TCPOPTSTRIP.o
> diff --git a/net/netfilter/xt_SYSRQ.c b/net/netfilter/xt_SYSRQ.c
> new file mode 100644
> index 0000000..929b204
> --- /dev/null
> +++ b/net/netfilter/xt_SYSRQ.c
> @@ -0,0 +1,354 @@
> +/*
> + *	"SYSRQ" target extension for Netfilter
> + *	Copyright =C2=A9 Jan Engelhardt <jengelh [at] medozas de>, 2008 -=
 2010
> + *
> + *	Based upon the ipt_SYSRQ idea by Marek Zalem <marek [at] terminus=
 sk>
> + *
> + *	This program is free software; you can redistribute it and/or
> + *	modify it under the terms of the GNU General Public License
> + *	version 2 or later as published by the Free Software Foundation.
> + */
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +#include <linux/in.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/module.h>
> +#include <linux/skbuff.h>
> +#include <linux/sysrq.h>
> +#include <linux/udp.h>
> +#include <linux/netfilter_ipv4/ip_tables.h>
> +#include <linux/netfilter_ipv6/ip6_tables.h>
> +#include <linux/netfilter/x_tables.h>
> +#include <linux/crypto.h>
> +#include <linux/scatterlist.h>
> +#include <net/ip.h>
> +
> +#if defined(CONFIG_CRYPTO) || defined(CRYPTO_CONFIG_MODULE)
> +#	define WITH_CRYPTO 1
> +#endif
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +#	define WITH_IPV6 1
> +#endif
> +
> +static bool sysrq_once;
> +static char sysrq_password[64];
> +static char sysrq_hash[16] =3D "sha1";
> +static long sysrq_seqno;
> +static int sysrq_debug;
> +module_param_string(password, sysrq_password, sizeof(sysrq_password)=
,
> +	S_IRUSR | S_IWUSR);
> +module_param_string(hash, sysrq_hash, sizeof(sysrq_hash), S_IRUSR);
> +module_param_named(seqno, sysrq_seqno, long, S_IRUSR | S_IWUSR);
> +module_param_named(debug, sysrq_debug, int, S_IRUSR | S_IWUSR);
> +MODULE_PARM_DESC(password, "password for remote sysrq");
> +MODULE_PARM_DESC(hash, "hash algorithm, default sha1");
> +MODULE_PARM_DESC(seqno, "sequence number for remote sysrq");
> +MODULE_PARM_DESC(debug, "debugging: 0=3Doff, 1=3Don");
> +
> +#ifdef WITH_CRYPTO
> +static struct crypto_hash *sysrq_tfm;
> +static int sysrq_digest_size;
> +static unsigned char *sysrq_digest_password;
> +static unsigned char *sysrq_digest;
> +static char *sysrq_hexdigest;
> +
> +/*
> + * The data is of the form "<requests>,<seqno>,<salt>,<hash>" where =
<requests>
> + * is a series of sysrq requests; <seqno> is a sequence number that =
must be
> + * greater than the last sequence number; <salt> is some random byte=
s; and
> + * <hash> is the hash of everything up to and including the precedin=
g ","
> + * together with the password.
> + *
> + * For example
> + *
> + *   salt=3D$RANDOM
> + *   req=3D"s,$(date +%s),$salt"
> + *   echo "$req,$(echo -n $req,secret | sha1sum | cut -c1-40)"
> + *
> + * You will want a better salt and password than that though :-)
> + */
> +static unsigned int sysrq_tg(const void *pdata, uint16_t len)
> +{
> +	const char *data =3D pdata;
> +	int i, n;
> +	struct scatterlist sg[2];
> +	struct hash_desc desc;
> +	int ret;
> +	long new_seqno =3D 0;
> +
> +	if (*sysrq_password =3D=3D '\0') {
> +		if (!sysrq_once)
> +			pr_info("No password set\n");
> +		sysrq_once =3D true;
> +		return NF_DROP;
> +	}
> +	if (len =3D=3D 0)
> +		return NF_DROP;
> +
> +	for (i =3D 0; sysrq_password[i] !=3D '\0' &&
> +	     sysrq_password[i] !=3D '\n'; ++i)
> +		/* loop */;
> +	sysrq_password[i] =3D '\0';
> +
> +	i =3D 0;
> +	for (n =3D 0; n < len - 1; ++n) {
> +		if (i =3D=3D 1 && '0' <=3D data[n] && data[n] <=3D '9')
> +			new_seqno =3D 10L * new_seqno + data[n] - '0';
> +		if (data[n] =3D=3D ',' && ++i =3D=3D 3)
> +			break;
> +	}
> +	++n;
> +	if (i !=3D 3) {
> +		if (sysrq_debug)
> +			pr_info("badly formatted request\n");
> +		return NF_DROP;
> +	}
> +	if (sysrq_seqno >=3D new_seqno) {
> +		if (sysrq_debug)
> +			pr_info("old sequence number ignored\n");
> +		return NF_DROP;
> +	}
> +
> +	desc.tfm   =3D sysrq_tfm;
> +	desc.flags =3D 0;
> +	ret =3D crypto_hash_init(&desc);
> +	if (ret !=3D 0)
> +		goto hash_fail;
> +	sg_init_table(sg, 2);
> +	sg_set_buf(&sg[0], data, n);
> +	strcpy(sysrq_digest_password, sysrq_password);
> +	i =3D strlen(sysrq_digest_password);
> +	sg_set_buf(&sg[1], sysrq_digest_password, i);
> +	ret =3D crypto_hash_digest(&desc, sg, n + i, sysrq_digest);
> +	if (ret !=3D 0)
> +		goto hash_fail;
> +
> +	for (i =3D 0; i < sysrq_digest_size; ++i) {
> +		sysrq_hexdigest[2*i] =3D
> +			"0123456789abcdef"[(sysrq_digest[i] >> 4) & 0xf];
> +		sysrq_hexdigest[2*i+1] =3D
> +			"0123456789abcdef"[sysrq_digest[i] & 0xf];
> +	}
> +	sysrq_hexdigest[2*sysrq_digest_size] =3D '\0';
> +	if (len - n < sysrq_digest_size) {
> +		if (sysrq_debug)
> +			pr_info("Short digest, expected %s\n",
> +				sysrq_hexdigest);
> +		return NF_DROP;
> +	}
> +	if (strncmp(data + n, sysrq_hexdigest, sysrq_digest_size) !=3D 0) {
> +		if (sysrq_debug)
> +			pr_info("Bad digest, expected %s\n", sysrq_hexdigest);
> +		return NF_DROP;
> +	}
> +
> +	/* Now we trust the requester */
> +	sysrq_seqno =3D new_seqno;
> +	for (i =3D 0; i < len && data[i] !=3D ','; ++i) {
> +		pr_info("SysRq %c\n", data[i]);
> +		handle_sysrq(data[i], NULL);
> +	}
> +	return NF_ACCEPT;
> +
> + hash_fail:
> +	pr_warning("digest failure\n");
> +	return NF_DROP;
> +}
> +#else
> +static unsigned int sysrq_tg(const void *pdata, uint16_t len)
> +{
> +	const char *data =3D pdata;
> +	char c;
> +
> +	if (*sysrq_password =3D=3D '\0') {
> +		if (!sysrq_once)
> +			pr_info("No password set\n");
> +		sysrq_once =3D true;
> +		return NF_DROP;
> +	}
> +
> +	if (len =3D=3D 0)
> +		return NF_DROP;
> +
> +	c =3D *data;
> +	if (strncmp(&data[1], sysrq_password, len - 1) !=3D 0) {
> +		pr_warning("Failed attempt - password mismatch\n");
> +		return NF_DROP;
> +	}
> +
> +	handle_sysrq(c, NULL);
> +	return NF_ACCEPT;
> +}
> +#endif
> +
> +static unsigned int
> +sysrq_tg4(struct sk_buff *skb, const struct xt_target_param *par)
> +{
> +	const struct iphdr *iph;
> +	const struct udphdr *udph;
> +	uint16_t len;
> +
> +	if (skb_linearize(skb) < 0)
> +		return NF_DROP;
> +
> +	iph =3D ip_hdr(skb);
> +	if (iph->protocol !=3D IPPROTO_UDP && iph->protocol !=3D IPPROTO_UD=
PLITE)
> +		return NF_DROP;
> +
> +	udph =3D (const void *)iph + ip_hdrlen(skb);
> +	len  =3D ntohs(udph->len) - sizeof(struct udphdr);
> +
> +	if (sysrq_debug)
> +		pr_info(": %pI4:%u -> :%u len=3D%u\n", &iph->saddr,
> +			htons(udph->source), htons(udph->dest), len);
> +	return sysrq_tg((void *)udph + sizeof(struct udphdr), len);
> +}
> +
> +#ifdef WITH_IPV6
> +static unsigned int
> +sysrq_tg6(struct sk_buff *skb, const struct xt_target_param *par)
> +{
> +	const struct ipv6hdr *iph;
> +	const struct udphdr *udph;
> +	unsigned short frag_off;
> +	unsigned int th_off;
> +	uint16_t len;
> +
> +	if (skb_linearize(skb) < 0)
> +		return NF_DROP;
> +
> +	iph =3D ipv6_hdr(skb);
> +	if (ipv6_find_hdr(skb, &th_off, IPPROTO_UDP, &frag_off) < 0 ||
> +	    frag_off > 0)
> +		return NF_ACCEPT; /* sink it */
> +
> +	udph =3D (const void *)iph + th_off;
> +	len  =3D ntohs(udph->len) - sizeof(struct udphdr);
> +
> +	if (sysrq_debug)
> +		pr_info("%pI6:%hu -> :%hu len=3D%u\n", &iph->saddr,
> +			ntohs(udph->source), ntohs(udph->dest), len);
> +	return sysrq_tg(udph + sizeof(struct udphdr), len);
> +}
> +#endif
> +
> +static int sysrq_tg_check(const struct xt_tgchk_param *par)
> +{
> +	if (par->target->family =3D=3D NFPROTO_IPV4) {
> +		const struct ipt_entry *entry =3D par->entryinfo;
> +
> +		if ((entry->ip.proto !=3D IPPROTO_UDP &&
> +		    entry->ip.proto !=3D IPPROTO_UDPLITE) ||
> +		    entry->ip.invflags & XT_INV_PROTO)
> +			goto out;
> +	} else if (par->target->family =3D=3D NFPROTO_IPV6) {
> +		const struct ip6t_entry *entry =3D par->entryinfo;
> +
> +		if ((entry->ipv6.proto !=3D IPPROTO_UDP &&
> +		    entry->ipv6.proto !=3D IPPROTO_UDPLITE) ||
> +		    entry->ipv6.invflags & XT_INV_PROTO)
> +			goto out;
> +	}
> +
> +	return true;
> +
> + out:
> +	pr_info("only available for UDP and UDP-Lite");
> +	return false;
> +}
> +
> +static struct xt_target sysrq_tg_reg[] __read_mostly =3D {
> +	{
> +		.name       =3D "SYSRQ",
> +		.revision   =3D 1,
> +		.family     =3D NFPROTO_IPV4,
> +		.target     =3D sysrq_tg4,
> +		.checkentry =3D sysrq_tg_check,
> +		.me         =3D THIS_MODULE,
> +	},
> +#ifdef WITH_IPV6
> +	{
> +		.name       =3D "SYSRQ",
> +		.revision   =3D 1,
> +		.family     =3D NFPROTO_IPV6,
> +		.target     =3D sysrq_tg6,
> +		.checkentry =3D sysrq_tg_check,
> +		.me         =3D THIS_MODULE,
> +	},
> +#endif
> +};
> +
> +static void sysrq_crypto_exit(void)
> +{
> +#ifdef WITH_CRYPTO
> +	if (sysrq_tfm)
> +		crypto_free_hash(sysrq_tfm);
> +	if (sysrq_digest)
> +		kfree(sysrq_digest);
> +	if (sysrq_hexdigest)
> +		kfree(sysrq_hexdigest);
> +	if (sysrq_digest_password)
> +		kfree(sysrq_digest_password);
> +#endif
> +}
> +
> +static int __init sysrq_crypto_init(void)
> +{
> +#if defined(WITH_CRYPTO)
> +	struct timeval now;
> +	int ret;
> +
> +	sysrq_tfm =3D crypto_alloc_hash(sysrq_hash, 0, CRYPTO_ALG_ASYNC);
> +	if (IS_ERR(sysrq_tfm)) {
> +		pr_err("Could not find or load %s hash\n", sysrq_hash);
> +		sysrq_tfm =3D NULL;
> +		ret =3D PTR_ERR(sysrq_tfm);
> +		goto fail;
> +	}
> +	sysrq_digest_size =3D crypto_hash_digestsize(sysrq_tfm);
> +	sysrq_digest =3D kmalloc(sysrq_digest_size, GFP_KERNEL);
> +	ret =3D -ENOMEM;
> +	if (sysrq_digest =3D=3D NULL)
> +		goto fail;
> +	sysrq_hexdigest =3D kmalloc(2 * sysrq_digest_size + 1, GFP_KERNEL);
> +	if (sysrq_hexdigest =3D=3D NULL)
> +		goto fail;
> +	sysrq_digest_password =3D kmalloc(sizeof(sysrq_password), GFP_KERNE=
L);
> +	if (sysrq_digest_password =3D=3D NULL)
> +		goto fail;
> +	do_gettimeofday(&now);
> +	sysrq_seqno =3D now.tv_sec;
> +	ret =3D xt_register_targets(sysrq_tg_reg, ARRAY_SIZE(sysrq_tg_reg))=
;
> +	if (ret < 0)
> +		goto fail;
> +	return ret;
> +
> + fail:
> +	sysrq_crypto_exit();
> +	return ret;
> +#else
> +	pr_info("compiled without crypto\n");
> +#endif
> +	return -EINVAL;
> +}
> +
> +static int __init sysrq_tg_init(void)
> +{
> +	if (sysrq_crypto_init() < 0)
> +		pr_info("starting without crypto\n");
> +	return xt_register_targets(sysrq_tg_reg, ARRAY_SIZE(sysrq_tg_reg));
> +}
> +
> +static void __exit sysrq_tg_exit(void)
> +{
> +	sysrq_crypto_exit();
> +	xt_unregister_targets(sysrq_tg_reg, ARRAY_SIZE(sysrq_tg_reg));
> +}
> +
> +module_init(sysrq_tg_init);
> +module_exit(sysrq_tg_exit);
> +MODULE_DESCRIPTION("Xtables: triggering SYSRQ remotely");
> +MODULE_AUTHOR("Jan Engelhardt <jengelh@medozas.de>");
> +MODULE_LICENSE("GPL");
> +MODULE_ALIAS("ipt_SYSRQ");
> +MODULE_ALIAS("ip6t_SYSRQ");

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
