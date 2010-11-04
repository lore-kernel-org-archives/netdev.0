From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v14 06/17] Use callback to deal with skb_release_data()
 specially.
Date: Thu, 04 Nov 2010 10:07:43 +0100
Message-ID: <1288861663.2659.47.camel@edumazet-laptop>
References: <1288861513-5707-1-git-send-email-xiaohui.xin@intel.com>
	 <bd4abd1568dfc75daed6713f9a568bf0f895de4b.1288860477.git.xiaohui.xin@intel.com>
	 <1288861465.2659.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55409 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754202Ab0KDJHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 05:07:47 -0400
In-Reply-To: <1288861465.2659.44.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 04 novembre 2010 =C3=A0 10:04 +0100, Eric Dumazet a =C3=A9crit=
 :

> Hmm, I suggest you read the comment two lines above.
>=20
> If destructor_arg is now cleared each time we allocate a new skb, the=
n,
> please move it before dataref in shinfo structure, so that the follow=
ing
> memset() does the job efficiently...


Something like :

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e6ba898..2dca504 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -195,6 +195,9 @@ struct skb_shared_info {
 	__be32          ip6_frag_id;
 	__u8		tx_flags;
 	struct sk_buff	*frag_list;
+	/* Intermediate layers must ensure that destructor_arg
+	 * remains valid until skb destructor */
+	void		*destructor_arg;
 	struct skb_shared_hwtstamps hwtstamps;
=20
 	/*
@@ -202,9 +205,6 @@ struct skb_shared_info {
 	 */
 	atomic_t	dataref;
=20
-	/* Intermediate layers must ensure that destructor_arg
-	 * remains valid until skb destructor */
-	void *		destructor_arg;
 	/* must be last field, see pskb_expand_head() */
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };



