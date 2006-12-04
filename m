From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 14:57:56 +0100
Message-ID: <45742964.9000905@trash.net>
References: <1165158707.3517.92.camel@localhost>	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost> <45742825.8040004@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080207000702080604090901"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41649 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936865AbWLDNyr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 08:54:47 -0500
To: hadi@cyberus.ca
In-Reply-To: <45742825.8040004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080207000702080604090901
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> jamal wrote:
> 
>>All very valid points.
>>Yikes, the directionality is not something i thought clearly about or
>>tested well. I can fix this but this code will only get fuglier. How
>>about the following approach:
>>
>>I add a new callback which is passed in the invocation to walk. 
>>This callback is invoked at the end to signal the end of the walk, sort
>>of what done() does in netlink.
>>netlink doesnt use this call but pfkey does. So the burden is then moved
>>to pfkey to keep track of the stoopid count.
>>
>>Thoughts?
> 
> I think the complications come from the fact that you remeber two
> policies, but only one seems necessary.  How about this (completely
> untested) patch? It simply uses increasing sequence numbers for all
> but the last entry and uses zero for the last one.

And the same for SAs.



--------------080207000702080604090901
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 864962b..8e7c52d 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1099,7 +1099,7 @@ int xfrm_state_walk(u8 proto, int (*func
 		    void *data)
 {
 	int i;
-	struct xfrm_state *x;
+	struct xfrm_state *x, *last = NULL;
 	struct hlist_node *entry;
 	int count = 0;
 	int err = 0;
@@ -1107,24 +1107,21 @@ int xfrm_state_walk(u8 proto, int (*func
 	spin_lock_bh(&xfrm_state_lock);
 	for (i = 0; i <= xfrm_state_hmask; i++) {
 		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
-			if (xfrm_id_proto_match(x->id.proto, proto))
-				count++;
+			if (last) {
+				err = func(last, ++count, data);
+				if (err)
+					goto out;
+			}
+			if (!xfrm_id_proto_match(x->id.proto, proto))
+				continue;
+			last = x;
 		}
 	}
 	if (count == 0) {
 		err = -ENOENT;
 		goto out;
 	}
-
-	for (i = 0; i <= xfrm_state_hmask; i++) {
-		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
-			if (!xfrm_id_proto_match(x->id.proto, proto))
-				continue;
-			err = func(x, --count, data);
-			if (err)
-				goto out;
-		}
-	}
+	err = func(last, 0, data);
 out:
 	spin_unlock_bh(&xfrm_state_lock);
 	return err;

--------------080207000702080604090901--
