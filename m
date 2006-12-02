From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: XFRM changing the view of xfrm_aevent_id
Date: Sat, 02 Dec 2006 06:09:08 -0500
Message-ID: <1165057748.3564.1.camel@localhost>
References: <1164983872.3562.45.camel@localhost>
	 <20061201.200858.25157271.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-56zMA56yVHfvpdIA8P/e"
Cc: hidden@balabit.hu, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:47826 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1162349AbWLBLJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 06:09:13 -0500
Received: by py-out-1112.google.com with SMTP id a29so1962144pyi
        for <netdev@vger.kernel.org>; Sat, 02 Dec 2006 03:09:12 -0800 (PST)
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061201.200858.25157271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-56zMA56yVHfvpdIA8P/e
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2006-01-12 at 20:08 -0800, David Miller wrote:

> 
> Let's change it now while we still can.
> 
> A few months from now, I will probably not give the same
> answer :)

:-> Ok, here it is ...

cheers,
jamal


--=-56zMA56yVHfvpdIA8P/e
Content-Disposition: attachment; filename=aevent-break
Content-Type: text/plain; name=aevent-break; charset=us-ascii
Content-Transfer-Encoding: 7bit

[XFRM] fix aevent structuring to be more complete

aevents can not uniquely identify an SA. We break the ABI with
this patch, but consensus is that since it is not yet utilized
by any (known) application then it is fine (better do it now than
later).

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 4bacaeb2cea3c6684f9b3acc54f71958bb2c25c5
tree c5f416a504abdb7583b799fec5245495c462bc92
parent 5465ae68b5ec11b2820db3f9b4c6fd94f113da44
author Jamal Hadi Salim <hadi@cyberus.ca> Sat, 02 Dec 2006 06:05:42 -0500
committer Jamal Hadi Salim <hadi@cyberus.ca> Sat, 02 Dec 2006 06:05:42 -0500

 Documentation/networking/xfrm_sync.txt |    5 ++++-
 include/linux/xfrm.h                   |    2 ++
 net/xfrm/xfrm_user.c                   |    4 +++-
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/xfrm_sync.txt b/Documentation/networking/xfrm_sync.txt
index 8be626f..fb88f1d 100644
--- a/Documentation/networking/xfrm_sync.txt
+++ b/Documentation/networking/xfrm_sync.txt
@@ -47,10 +47,13 @@ aevent_id structure looks like:
 
    struct xfrm_aevent_id {
              struct xfrm_usersa_id           sa_id;
+             xfrm_address_t                  saddr;
              __u32                           flags;
+             __u32                           reqid;
    };
 
-xfrm_usersa_id in this message layout identifies the SA.
+The unique SA is identified by the combination of xfrm_usersa_id, 
+reqid and saddr.
 
 flags are used to indicate different things. The possible
 flags are:
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 7907c42..088ba81 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -289,7 +289,9 @@ struct xfrm_usersa_id {
 
 struct xfrm_aevent_id {
 	struct xfrm_usersa_id		sa_id;
+	xfrm_address_t			saddr;
 	__u32				flags;
+	__u32				reqid;
 };
 
 struct xfrm_userspi_info {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 055b72f..6f97665 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1281,10 +1281,12 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, struct km_eve
 	id = NLMSG_DATA(nlh);
 	nlh->nlmsg_flags = 0;
 
-	id->sa_id.daddr = x->id.daddr;
+	memcpy(&id->sa_id.daddr, &x->id.daddr,sizeof(x->id.daddr));
 	id->sa_id.spi = x->id.spi;
 	id->sa_id.family = x->props.family;
 	id->sa_id.proto = x->id.proto;
+	memcpy(&id->saddr, &x->props.saddr,sizeof(x->props.saddr));
+	id->reqid = x->props.reqid;
 	id->flags = c->data.aevent;
 
 	RTA_PUT(skb, XFRMA_REPLAY_VAL, sizeof(x->replay), &x->replay);

--=-56zMA56yVHfvpdIA8P/e--

