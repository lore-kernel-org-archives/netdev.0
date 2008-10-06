From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH 00/32] Swap over NFS - v19
Date: Mon, 06 Oct 2008 11:34:30 +0530
Message-ID: <48E9AA6E.3080608@suse.de>
References: <20081002130504.927878499@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:46005 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627AbYJFGDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 02:03:11 -0400
In-Reply-To: <20081002130504.927878499@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra wrote:
> Patches are against: v2.6.27-rc5-mm1
>=20
> This release features more comments and (hopefully) better Changelogs=
=2E
> Also the netns stuff got sorted and ipv6 will now build=20

Except for this one I think ;-)

net/netfilter/core.c: In function =E2=80=98nf_hook_slow=E2=80=99:
net/netfilter/core.c:191: error: =E2=80=98pskb=E2=80=99 undeclared (fir=
st use in this
function)

> and not oops on boot ;-)

The culprit is emergency-nf_queue.patch. The following change fixes the
build error for me.

Index: linux-2.6.26/net/netfilter/core.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.26.orig/net/netfilter/core.c
+++ linux-2.6.26/net/netfilter/core.c
@@ -184,9 +184,12 @@ next_hook:
                ret =3D 1;
                goto unlock;
        } else if (verdict =3D=3D NF_DROP) {
+drop:
                kfree_skb(skb);
                ret =3D -EPERM;
        } else if ((verdict & NF_VERDICT_MASK) =3D=3D NF_QUEUE) {
+               if (skb_emergency(skb))
+                       goto drop;
                if (!nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
                              verdict >> NF_VERDICT_BITS))
                        goto next_hook;


Thanks,

--=20
Suresh Jayaraman
