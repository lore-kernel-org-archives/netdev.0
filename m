From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 1/2] netfilter_queue: enable UID/GID socket info
 retrieval
Date: Fri, 20 Dec 2013 10:29:26 +0100
Message-ID: <20131220092926.GA9275@localhost>
References: <1387451007-14363-1-git-send-email-valentina.giusti@bmw-carit.de>
 <1387451007-14363-2-git-send-email-valentina.giusti@bmw-carit.de>
 <20131220092638.GA9122@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	fw@strlen.de, eric.dumazet@gmail.com, tgraf@redhat.com,
	jpa@google.com, davem@davemloft.net, daniel.wagner@bmw-carit.de,
	Valentina Giusti <valentina.giusti@oss.bmw-carit.de>
To: valentina.giusti@bmw-carit.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46593 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753501Ab3LTJ3a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 04:29:30 -0500
Content-Disposition: inline
In-Reply-To: <20131220092638.GA9122@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 10:26:38AM +0100, Pablo Neira Ayuso wrote:
> Hi,
>=20
> On Thu, Dec 19, 2013 at 12:03:26PM +0100, valentina.giusti@bmw-carit.=
de wrote:
> > From: Valentina Giusti <valentina.giusti@oss.bmw-carit.de>
> >=20
> > Thanks to commits 41063e9 (ipv4: Early TCP socket demux) and 421b38=
8 (udp: ipv4:
> > Add udp early demux) it is now possible to parse UID and GID socket=
 info
> > also for incoming TCP and UDP connections. Having this info availab=
le, it
> > is convenient to let NFQUEUE parse it in order to improve and refin=
e the
> > traffic analysis in userspace.
> >=20
> > Signed-off-by: Valentina Giusti <valentina.giusti@bmw-carit.de>
> > ---
> >  include/uapi/linux/netfilter/nfnetlink_queue.h |  5 ++++-
> >  net/netfilter/nfnetlink_queue_core.c           | 31 ++++++++++++++=
++++++++++++
> >  2 files changed, 35 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/include/uapi/linux/netfilter/nfnetlink_queue.h b/inclu=
de/uapi/linux/netfilter/nfnetlink_queue.h
> > index 0132bad..8dd819e 100644
> > --- a/include/uapi/linux/netfilter/nfnetlink_queue.h
> > +++ b/include/uapi/linux/netfilter/nfnetlink_queue.h
> > @@ -47,6 +47,8 @@ enum nfqnl_attr_type {
> >  	NFQA_CAP_LEN,			/* __u32 length of captured packet */
> >  	NFQA_SKB_INFO,			/* __u32 skb meta information */
> >  	NFQA_EXP,			/* nf_conntrack_netlink.h */
> > +	NFQA_UID,			/* __u32 sk uid */
> > +	NFQA_GID,			/* __u32 sk gid */
> > =20
> >  	__NFQA_MAX
> >  };
> > @@ -99,7 +101,8 @@ enum nfqnl_attr_config {
> >  #define NFQA_CFG_F_FAIL_OPEN			(1 << 0)
> >  #define NFQA_CFG_F_CONNTRACK			(1 << 1)
> >  #define NFQA_CFG_F_GSO				(1 << 2)
> > -#define NFQA_CFG_F_MAX				(1 << 3)
> > +#define NFQA_CFG_F_UID_GID			(1 << 3)
> > +#define NFQA_CFG_F_MAX				(1 << 4)
> > =20
> >  /* flags for NFQA_SKB_INFO */
> >  /* packet appears to have wrong checksums, but they are ok */
> > diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/n=
fnetlink_queue_core.c
> > index 21258cf..2cdef07 100644
> > --- a/net/netfilter/nfnetlink_queue_core.c
> > +++ b/net/netfilter/nfnetlink_queue_core.c
> > @@ -297,6 +297,29 @@ nfqnl_put_packet_info(struct sk_buff *nlskb, s=
truct sk_buff *packet,
> >  	return flags ? nla_put_be32(nlskb, NFQA_SKB_INFO, htonl(flags)) :=
 0;
> >  }
> > =20
> > +static int nfqnl_put_sk_uidgid(struct sk_buff *skb, struct sock *s=
k)
> > +{
> > +	const struct cred *cred;
> > +
> > +	if (sk && sk->sk_state !=3D TCP_TIME_WAIT) {
> > +		read_lock_bh(&sk->sk_callback_lock);
> > +		if (sk->sk_socket && sk->sk_socket->file) {
> > +			cred =3D sk->sk_socket->file->f_cred;
> > +			if (nla_put_u32(skb, NFQA_UID, htonl(cred->fsuid)))
>=20
> I'm hitting this compilation error here:
>=20
> net/netfilter/nfnetlink_queue_core.c: In function =E2=80=98nfqnl_put_=
sk_uidgid=E2=80=99:
> net/netfilter/nfnetlink_queue_core.c:308:4: error: aggregate value us=
ed where an integer was expected
>=20
> It seems that in recent kernels you have to use:
>=20
>         from_kuid_munged(&init_user_ns, cred->fsuid);
>=20
> to retrieve the integer that represents the uid.
>=20
> Please,=20

sorry, I left this sentence incomplete, I was telling... Please, test
your patches with current git trees :-). Thanks.
