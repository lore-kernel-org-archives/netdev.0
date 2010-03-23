From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [Bug 15582] New: BUG: unable to handle kernel NULL pointer
 dereference at 0000000000000028
Date: Tue, 23 Mar 2010 11:32:19 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F254E49A854@orsmsx501.amr.corp.intel.com>
References: <bug-15582-27@http.bugzilla.kernel.org/>
	<20100322161416.c4b369f9.akpm@linux-foundation.org>
 <20100322.210043.66718554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kaber@trash.net" <kaber@trash.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stivi@kity.pl" <stivi@kity.pl>
To: David Miller <davem@davemloft.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42512 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382Ab0CWScW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 14:32:22 -0400
In-Reply-To: <20100322.210043.66718554.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Mon, 22 Mar 2010 16:14:16 -0700
> 
>> 
>> (switched to email.  Please respond via emailed reply-to-all, not
>> via the bugzilla web interface). 
>> 
>> On Fri, 19 Mar 2010 12:01:10 GMT
>> bugzilla-daemon@bugzilla.kernel.org wrote:
>> 
>>> http://bugzilla.kernel.org/show_bug.cgi?id=15582
>>> 
>>>            Summary: BUG: unable to handle kernel NULL pointer
>>>                     dereference at 0000000000000028
>> 
>> A bug in igb or the vlan code, I guess.
> 
> Hmmm, should have been fixed by:
> 
> commit d1c76af9e2434fac3add561e26c61b06503de986
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Mon Mar 16 10:50:02 2009 -0700
> 
>     GRO: Move netpoll checks to correct location
> 
> 
> ...
> 
> Nevermind, the backtrace signature is different for this
> one.

Actually I think this may be a bug in igb_receive_skb.  My guess would be that promiscuous mode is somehow being enabled which is turning off the vlan filtering and as a result we are probably picking up vlan traffic when we have no vlans registered.  The null pointer in that case would be adapter->vlgrp.

The patch below should address it.  However I suspect it will get mangled by our email system here so I don't believe it will apply.  I have also sent a copy of to Jeff to pull into his tree for testing and submission.

Thanks,

Alex

---

This change makes it so that vlan_gro_receive is only used if vlans have been
registered to the adapter structure.  Previously we were just sending all vlan
tagged frames in via this function but this results in a null pointer
dereference when vlans are not registered.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/igb/igb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 45a0e4f..7855f71 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5110,7 +5110,7 @@ static void igb_receive_skb(struct igb_q_vector *q_vector,
 {
 	struct igb_adapter *adapter = q_vector->adapter;
 
-	if (vlan_tag)
+	if (vlan_tag && adapter->vlgrp)
 		vlan_gro_receive(&q_vector->napi, adapter->vlgrp,
 		                 vlan_tag, skb);
 	else