From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 1/2] netfilter_queue: enable UID/GID socket info
 retrieval
Date: Fri, 20 Dec 2013 10:26:38 +0100
Message-ID: <20131220092638.GA9122@localhost>
References: <1387451007-14363-1-git-send-email-valentina.giusti@bmw-carit.de>
 <1387451007-14363-2-git-send-email-valentina.giusti@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	fw@strlen.de, eric.dumazet@gmail.com, tgraf@redhat.com,
	jpa@google.com, davem@davemloft.net, daniel.wagner@bmw-carit.de,
	Valentina Giusti <valentina.giusti@oss.bmw-carit.de>
To: valentina.giusti@bmw-carit.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45799 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754952Ab3LTJ0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 04:26:46 -0500
Content-Disposition: inline
In-Reply-To: <1387451007-14363-2-git-send-email-valentina.giusti@bmw-carit.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Dec 19, 2013 at 12:03:26PM +0100, valentina.giusti@bmw-carit.de=
 wrote:
> From: Valentina Giusti <valentina.giusti@oss.bmw-carit.de>
>=20
> Thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b388 =
(udp: ipv4:
> Add udp early demux) it is now possible to parse UID and GID socket i=
nfo
> also for incoming TCP and UDP connections. Having this info available=
, it
> is convenient to let NFQUEUE parse it in order to improve and refine =
the
> traffic analysis in userspace.
>=20
> Signed-off-by: Valentina Giusti <valentina.giusti@bmw-carit.de>
> ---
>  include/uapi/linux/netfilter/nfnetlink_queue.h |  5 ++++-
>  net/netfilter/nfnetlink_queue_core.c           | 31 ++++++++++++++++=
++++++++++
>  2 files changed, 35 insertions(+), 1 deletion(-)
>=20
> diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/include=
/uapi/linux/netfilter/nfnetlink_queue.h
> index 0132bad..8dd819e 100644
> --- a/include/uapi/linux/netfilter/nfnetlink_queue.h
> +++ b/include/uapi/linux/netfilter/nfnetlink_queue.h
> @@ -47,6 +47,8 @@ enum nfqnl_attr_type {
>  	NFQA_CAP_LEN,			/* __u32 length of captured packet */
>  	NFQA_SKB_INFO,			/* __u32 skb meta information */
>  	NFQA_EXP,			/* nf_conntrack_netlink.h */
> +	NFQA_UID,			/* __u32 sk uid */
> +	NFQA_GID,			/* __u32 sk gid */
> =20
>  	__NFQA_MAX
>  };
> @@ -99,7 +101,8 @@ enum nfqnl_attr_config {
>  #define NFQA_CFG_F_FAIL_OPEN			(1 << 0)
>  #define NFQA_CFG_F_CONNTRACK			(1 << 1)
>  #define NFQA_CFG_F_GSO				(1 << 2)
> -#define NFQA_CFG_F_MAX				(1 << 3)
> +#define NFQA_CFG_F_UID_GID			(1 << 3)
> +#define NFQA_CFG_F_MAX				(1 << 4)
> =20
>  /* flags for NFQA_SKB_INFO */
>  /* packet appears to have wrong checksums, but they are ok */
> diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfn=
etlink_queue_core.c
> index 21258cf..2cdef07 100644
> --- a/net/netfilter/nfnetlink_queue_core.c
> +++ b/net/netfilter/nfnetlink_queue_core.c
> @@ -297,6 +297,29 @@ nfqnl_put_packet_info(struct sk_buff *nlskb, str=
uct sk_buff *packet,
>  	return flags ? nla_put_be32(nlskb, NFQA_SKB_INFO, htonl(flags)) : 0=
;
>  }
> =20
> +static int nfqnl_put_sk_uidgid(struct sk_buff *skb, struct sock *sk)
> +{
> +	const struct cred *cred;
> +
> +	if (sk && sk->sk_state !=3D TCP_TIME_WAIT) {
> +		read_lock_bh(&sk->sk_callback_lock);
> +		if (sk->sk_socket && sk->sk_socket->file) {
> +			cred =3D sk->sk_socket->file->f_cred;
> +			if (nla_put_u32(skb, NFQA_UID, htonl(cred->fsuid)))

I'm hitting this compilation error here:

net/netfilter/nfnetlink_queue_core.c: In function =E2=80=98nfqnl_put_sk=
_uidgid=E2=80=99:
net/netfilter/nfnetlink_queue_core.c:308:4: error: aggregate value used=
 where an integer was expected

It seems that in recent kernels you have to use:

        from_kuid_munged(&init_user_ns, cred->fsuid);

to retrieve the integer that represents the uid.

Please,=20


> +				goto nla_put_failure;
> +			if (nla_put_u32(skb, NFQA_GID, htonl(cred->fsgid)))
                                    ^^^

Minor nitpick: This has to be _be32 otherwise sparse will complain
(spotted by Florian Westphal).

Make sure you patch is also clean when running make C=3D2.

Also remove the extra checking for socket that Florian mentioned and
resubmit. Thanks.
