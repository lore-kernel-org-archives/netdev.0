From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] netlink: fix compilation after memory mapped
 patches
Date: Tue, 23 Apr 2013 17:24:23 +0100
Message-ID: <1366734263.4016.32.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366707353-32434-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31537 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755699Ab3DWQY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 12:24:27 -0400
In-Reply-To: <1366707353-32434-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 10:55 +0200, Nicolas Dichtel wrote:
> Depending of the kernel configuration (CONFIG_UIDGID_STRICT_TYPE_CHEC=
KS), we can
> get the following errors:
>=20
> net/netlink/af_netlink.c: In function =E2=80=98netlink_queue_mmaped_s=
kb=E2=80=99:
> net/netlink/af_netlink.c:663:14: error: incompatible types when assig=
ning to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kuid_t=E2=80=99
> net/netlink/af_netlink.c:664:14: error: incompatible types when assig=
ning to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kgid_t=E2=80=99
> net/netlink/af_netlink.c: In function =E2=80=98netlink_ring_set_copie=
d=E2=80=99:
> net/netlink/af_netlink.c:693:14: error: incompatible types when assig=
ning to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kuid_t=E2=80=99
> net/netlink/af_netlink.c:694:14: error: incompatible types when assig=
ning to type =E2=80=98__u32=E2=80=99 from type =E2=80=98kgid_t=E2=80=99
>=20
> We must use the helpers to get the uid and gid.
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/netlink/af_netlink.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 2a3e9ba..0593a9a 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -660,8 +660,8 @@ static void netlink_queue_mmaped_skb(struct sock =
*sk, struct sk_buff *skb)
>  	hdr->nm_len	=3D skb->len;
>  	hdr->nm_group	=3D NETLINK_CB(skb).dst_group;
>  	hdr->nm_pid	=3D NETLINK_CB(skb).creds.pid;
> -	hdr->nm_uid	=3D NETLINK_CB(skb).creds.uid;
> -	hdr->nm_gid	=3D NETLINK_CB(skb).creds.gid;
> +	hdr->nm_uid	=3D __kuid_val(NETLINK_CB(skb).creds.uid);
> +	hdr->nm_gid	=3D __kgid_val(NETLINK_CB(skb).creds.gid);

Shouldn't these use from_k{u,g}id_munged() like scm_recv() does?

Ben.

>  	netlink_frame_flush_dcache(hdr);
>  	netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
> =20
> @@ -690,8 +690,8 @@ static void netlink_ring_set_copied(struct sock *=
sk, struct sk_buff *skb)
>  	hdr->nm_len	=3D skb->len;
>  	hdr->nm_group	=3D NETLINK_CB(skb).dst_group;
>  	hdr->nm_pid	=3D NETLINK_CB(skb).creds.pid;
> -	hdr->nm_uid	=3D NETLINK_CB(skb).creds.uid;
> -	hdr->nm_gid	=3D NETLINK_CB(skb).creds.gid;
> +	hdr->nm_uid	=3D __kuid_val(NETLINK_CB(skb).creds.uid);
> +	hdr->nm_gid	=3D __kgid_val(NETLINK_CB(skb).creds.gid);
>  	netlink_set_status(hdr, NL_MMAP_STATUS_COPY);
>  }
> =20

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
