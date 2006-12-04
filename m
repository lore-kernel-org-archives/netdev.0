From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 16:57:13 +0100
Message-ID: <45744559.1000108@trash.net>
References: <1165158707.3517.92.camel@localhost>	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost>	 <45742825.8040004@trash.net>  <45742964.9000905@trash.net>	 <1165240725.3664.72.camel@localhost>  <1165241100.3664.75.camel@localhost> <1165246635.3643.6.camel@localhost> <457444E0.8060801@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080209010505090406040800"
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47791 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937045AbWLDPyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 10:54:06 -0500
In-Reply-To: <457444E0.8060801@trash.net>
To: unlisted-recipients:; (no To-header on input)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080209010505090406040800
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> jamal wrote:
> 
>>All the way down, you call func with a NULL entry. You could add a check
>>to make sure it only gets invoked when last is not null, but the result
>>is in such a case, you will never send a 0 count element. I am sure
>>there could be other tricky scenarios like this that could be
>>constructed.
>>
>>Thoughts.
> 
> 
> Double sending can't happen, but you're right about potentially
> sending a NULL ptr when after setting it to NULL we don't find
> any other matching elements.
> 
> This patch should fix it (and is even simpler), by moving the
> check for pol->type != type before sending, we make sure that
> last always contains a valid element unless count == 0.
> 
> Also fixed an incorrect gcc warning about last_dir potentially
> being used uninitialized.


And again for SAs ..


--------------080209010505090406040800
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 864962b..a5877f8 100644
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
+			if (!xfrm_id_proto_match(x->id.proto, proto))
+				continue;
+			if (last) {
+				err = func(last, ++count, data);
+				if (err)
+					goto out;
+			}
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

--------------080209010505090406040800--
