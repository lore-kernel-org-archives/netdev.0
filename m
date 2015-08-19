From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next] xfrm: Use VRF master index if output device
 is enslaved
Date: Wed, 19 Aug 2015 22:36:59 +0200
Message-ID: <20150819203659.GA11165@secunet.com>
References: <1439913296-6026-1-git-send-email-dsa@cumulusnetworks.com>
 <0723F8F1-7349-45FF-BE9C-D2667DA28E0A@cumulusnetworks.com>
 <55D4CC8B.1080306@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	<netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37064 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257AbbHSUhC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 16:37:02 -0400
Content-Disposition: inline
In-Reply-To: <55D4CC8B.1080306@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 11:35:55AM -0700, David Ahern wrote:
> >
> >I think you should use the new vrf_master_index() helper that acquir=
es rcu because
> >it looks possible to call ->decode_session() without rcu read lock, =
e.g. in the hold_timer
> >function xfrm_policy_queue_process(), though I haven=E2=80=99t teste=
d it and might be missing
> >something. :-)
>=20
> I was digging into code paths yesterday. Today I added WARN_ON and
> seems like the rcu_read_lock is held:
>=20
>         if (skb_dst(skb)) {
> WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
>                 oif =3D vrf_master_ifindex_rcu(skb_dst(skb)->dev) ?
>                         : skb_dst(skb)->dev->ifindex;
> pr_info("_decode_session: oif %d skb_dst(skb)->dev->ifindex %d\n",
> oif, skb_dst(skb)->dev->ifindex);
>         }
>=20
> I get the printk, but not the WARN_ON splat.

Well, this depends on the codepath that called xfrm_decode_session().
It really think it was not called through xfrm_policy_queue_process()
because this codepath is just used if the sysctl xfrm_larval_drop is sw=
itched
off (on by default) and the required xfrm_state is not yet established.
