From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH]: double SAs are created when using AH and ESP together
Date: Fri, 9 Mar 2007 17:14:54 -0600
Message-ID: <200703092314.l29NEsre023870@faith.austin.ibm.com>
Cc: davem@davemloft.net, eparis@redhat.com,
	herbert@gondor.apana.org.au, jmorris@namei.org, paul.moore@hp.com,
	vyekkirala@TrustedCS.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:41577 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767649AbXCIXbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 18:31:12 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l29NV9Is003425
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 18:31:09 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l29NV6Et161434
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 18:31:06 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l29NUtEa025700
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2007 18:30:56 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-03-06 at 14:40 -0500, James Morris wrote:
On Tue, 6 Mar 2007, Joy Latten wrote:
> 
> > > I saw something similar to this some time ago when testing various 
> > > failure modes, and discused it with Herbert.
> > > 
> > > IIRC, there's a larval SA which is not torn down properly by Racoon once 
> > > the full SA is established, and the larval SA keeps resending until it 
> > > times out.
> > > 
> > Ok, good to know. 
> > I thought a bit more about this last night but am not
> > sure best way to fix it. Perhaps a way to keep larval
> > SA around until all SAs resulting from xfrm_vec[xfrm_nr]
> > are established... oh well, just thinking out loud... :-) 
> 
> I think the solution, if this actually the problem, is for the userland 
> code to maintain the SAs.
 
Gotta agree. :-)

I noticed that in xfrm_state_add we look for the larval SA in a few
places without checking for protocol match. So when using both 
AH and ESP, whichever one gets added first, deletes the larval SA. 
It seems AH always gets added first and ESP is always the larval 
SA's protocol since the xfrm->tmpl has it first. Thus causing the
additional km_query()

Adding the check eliminates the double SA creation. 
I know this may not seem like a complete solution and I will 
continue to test and be on the lookout, but isn't having the
check a good thing? So far I have tested SAs with just ESP, just AH
and with both and all seems ok. 

Please let me know if this patch is ok. 
My kernel was 2.6.20-rc3-git3.

Joy 

Signed-off-by: Joy Latten <latten@austin.ibm.com>

diff -urpN linux-2.6.20.orig/net/xfrm/xfrm_state.c linux-2.6.20.patch/net/xfrm/xfrm_state.c
--- linux-2.6.20.orig/net/xfrm/xfrm_state.c	2007-03-08 17:39:14.000000000 -0600
+++ linux-2.6.20.patch/net/xfrm/xfrm_state.c	2007-03-09 11:03:25.000000000 -0600
@@ -704,7 +704,8 @@ static struct xfrm_state *__find_acq_cor
 		    x->props.mode   != mode ||
 		    x->props.family != family ||
 		    x->km.state     != XFRM_STATE_ACQ ||
-		    x->id.spi       != 0)
+		    x->id.spi       != 0 ||
+		    x->id.proto	    != proto)
 			continue;
 
 		switch (family) {
@@ -801,7 +802,8 @@ int xfrm_state_add(struct xfrm_state *x)
 
 	if (use_spi && x->km.seq) {
 		x1 = __xfrm_find_acq_byseq(x->km.seq);
-		if (x1 && xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family)) {
+		if (x1 && ((x1->id.proto != x->id.proto) ||
+		    xfrm_addr_cmp(&x1->id.daddr, &x->id.daddr, family))) {
 			xfrm_state_put(x1);
 			x1 = NULL;
 		}
