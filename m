From: "Santiago Font Arquer" <sfa.linux@gmail.com>
Subject: PROBLEM: skb_clone SMP race?
Date: Wed, 10 Oct 2007 11:00:19 +0200
Message-ID: <dfad5c650710100200s1369fd96x50ffc5fbffb2e6d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:27287 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbXJJJAW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 05:00:22 -0400
Received: by wa-out-1112.google.com with SMTP id v27so162214wah
        for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 02:00:22 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
   I'm studying the implementation of sk_buff and I think there's a
possible race condition in skb_clone (2.6.22.9)
   The code is:


struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
{
 struct sk_buff *n;

 n =3D skb + 1;
 if (skb->fclone =3D=3D SKB_FCLONE_ORIG &&
    n->fclone =3D=3D SKB_FCLONE_UNAVAILABLE) {
 atomic_t *fclone_ref =3D (atomic_t *) (n + 1);
 n->fclone =3D SKB_FCLONE_CLONE;
 atomic_inc(fclone_ref);
 } else {
 n =3D kmem_cache_alloc(skbuff_head_cache, gfp_mask);
 if (!n)
  return NULL;
 n->fclone =3D SKB_FCLONE_UNAVAILABLE;
 }

   If an skb with fast clone available (first "if" true) has
references in different CPUs (skb->users>1) (I do not find explicit
checks for this to be impossible), if skb_clone is called
simultaneously over that skb, both callers can get the same clone (the
"fast" clone) and different problems follow: wrong "clone_skb->users"
(1 as expected by the caller, but it should be, to be true, 2),
fclone_ref set to 3 involving further problems, ...

  IMO, the same problem arises although the calls to skb_clone are
not simultaneous: there isn=B4t a memory barrier after the change of
"n->fclone" to guarantee the visibility of that change to other CPUs
(but that barrier will not solve anything; I mentioned this only to
reflect another reason I see for the race to happen).

  Is that correct? Thank you in advance.


       Santiago Font Arquer
