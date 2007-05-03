From: Guennadi Liakhovetski <gl@dsa-ac.de>
Subject: ppp_generic.c recursive spinlock_bh(&pch->downl)
Date: Thu, 3 May 2007 10:12:10 +0200 (CEST)
Message-ID: <Pine.LNX.4.63.0705030923590.19781@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: irda-users@lists.sourceforge.net, netdev@vger.kernel.org,
	Samuel Ortiz <samuel@sortiz.org>
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dsa-ac.de ([62.112.80.99]:38565 "EHLO mail.dsa-ac.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750968AbXECIMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 04:12:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

This has been discussed on these lists since some time already, but as we 
don't seem to come to a proper fix, I decided to summarize our problem 
once again.

A short summary from the ppp PoV:

ppp_push()
{
	spin_lock_bh(&pch->downl);
	pch->chan->ops->start_xmit(pch->chan, skb)
	{
		...
		ppp_output_wakeup()
		{
			ppp_channel_push()
			{
				spin_lock_bh(&pch->downl);
BANG!...

This happens with IrNET. So, the question is, is it legitimate to call 
ppp_channel_push() from the .start_xmit() method? How do other ppp drivers 
do it? Looks like, for examplke, ppp_async checks explicitly for 
recursion, synctty does a try_spinlock_bh()... Is it just a bug in IrNET 
and one just cannot do this, or is there a simple fix for this?

Samuel's suggestion is to offload the call to ppp_output_wakeup() to the 
keventd workqueue, but we haven't been able to make this work properly so 
far.

I have a dirty workaround, whereby I explicitly verify recursion in 
ppp_channel_push(). This works, but it doesn't seem to be a good solution.

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany
