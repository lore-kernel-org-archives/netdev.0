From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 12:43:33 -0500
Message-ID: <1165254213.3643.25.camel@localhost>
References: <1165158707.3517.92.camel@localhost>
	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost>
	 <45742825.8040004@trash.net>  <45742964.9000905@trash.net>
	 <1165240725.3664.72.camel@localhost>  <1165241100.3664.75.camel@localhost>
	 <1165246635.3643.6.camel@localhost>  <457444E0.8060801@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-xQJeVWBSj5byHU2TZUuN"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:31345 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933420AbWLDRnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 12:43:37 -0500
Received: by wx-out-0506.google.com with SMTP id h27so3862048wxd
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 09:43:36 -0800 (PST)
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <457444E0.8060801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-xQJeVWBSj5byHU2TZUuN
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2006-04-12 at 16:55 +0100, Patrick McHardy wrote:


> This patch should fix it (and is even simpler), by moving the
> check for pol->type != type before sending, we make sure that
> last always contains a valid element unless count == 0.
> 
> Also fixed an incorrect gcc warning about last_dir potentially
> being used uninitialized.


Ok, both looked good except for the test of a single entry.
This was because you would break out of the loop with count of 0.
The patch against yours would look like something attached for the state
case. Dont forget there are two spots on the policy side of things;->

You can either submit both patches or i could later today. If you do,
please look at some of the comments i made in the first patch and
include them. 
Just from the outset the numbers improvement looked the same as the way
i had it.

With these changes, 40K SPDs and 20K SAs dumping (subpolicies compiled
out)

---
speedopolis:~# time ./ip x state

real    0m1.985s
user    0m0.000s
sys     0m1.984s


speedopolis:~# time ./ip x policy

real    0m7.901s
user    0m0.008s
sys     0m7.896s
---

As a reference point, the old numbers:

---
speedopolis:~# ./ip xf pol

real    0m13.496s
user    0m0.000s
sys     0m13.493s
speedopolis:~#
speedopolis:~# time ./ip xf sta

real    0m5.321s
user    0m0.004s
sys     0m5.316s

----


Thanks a lot for your efforts Patrick.

cheers,
jamal

--=-xQJeVWBSj5byHU2TZUuN
Content-Disposition: attachment; filename=state-patch
Content-Type: text/x-patch; name=state-patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

--- a/net/xfrm/xfrm_state.c	2006-12-04 12:06:23.000000000 -0500
+++ b/net/xfrm/xfrm_state.c	2006-12-04 12:07:09.000000000 -0500
@@ -1159,11 +1159,12 @@
 			if (!xfrm_id_proto_match(x->id.proto, proto))
 				continue;
 			if (last) {
-				err = func(last, ++count, data);
+				err = func(last, count, data);
 				if (err)
 					goto out;
 			}
 			last = x;
+			count++;
 		}
 	}
 	if (count == 0) {

--=-xQJeVWBSj5byHU2TZUuN--

