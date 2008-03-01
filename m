From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Patch: [NET]: Remove CONFIG_PROC_FS depency for pcounter inuse
Date: Sat, 01 Mar 2008 06:19:51 +0100
Message-ID: <47C8E777.5050804@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090703010805030202040303"
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-fb.rzone.de ([81.169.146.163]:15728 "EHLO
	mo-p00-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbYCAFwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 00:52:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090703010805030202040303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

attached you'll find a patch that fixes the depency that has been 
introduced in commit 65f7651788e18fadb2fbb7276af935d7871e1803 ([NET]: 
prot_inuse cleanups and optimizations).

As the inuse counters are only used by internet protocols right now, 
using CONFIG_INET would have been more obvious to recognize this illegal 
optimization here. Going a bit deeper into this problem we can see, that 
the pcounters are ONLY used for the internet protocols BUT initialized 
for ALL protocols in proto_[un|]register() in net/core/sock.c.

This forces all network protocols to initialize the pcounters and 
therefore request dynamic percpu memory even when it is not used at all.

I would suggest to

1. move the ..._inuse_[init|free]() stuff from sock.c to af_inet[|6].c 
and his friends

OR

2. add new parameters to proto_[un|]register() like 'alloc_inuse' and 
'free_inuse'

My favourite sollution would be the second one but before creating a 
patch for one of these suggestions, i wanted to ask for your opinion or 
if there is any 'even nicer' idea from your side.

Regards,
Oliver

--------------090703010805030202040303
Content-Type: text/x-patch;
 name="remove_config_proc_fs_depency_for_pcounter_inuse.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="remove_config_proc_fs_depency_for_pcounter_inuse.patch"


[NET]: Remove CONFIG_PROC_FS depency for pcounter inuse

The pcounters are initialized for each protocol and could also be used outside
CONFIG_INET context which forces CONFIG_PROC_FS to be set.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>

diff --git a/include/net/sock.h b/include/net/sock.h
index fd98760..505ac6f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -552,9 +552,7 @@ struct proto {
 	int			(*get_port)(struct sock *sk, unsigned short snum);
 
 	/* Keeping track of sockets in use */
-#ifdef CONFIG_PROC_FS
 	struct pcounter		inuse;
-#endif
 
 	/* Memory pressure */
 	void			(*enter_memory_pressure)(void);

--------------090703010805030202040303--
