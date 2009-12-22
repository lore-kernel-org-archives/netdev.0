From: "Akkipeddi, Srinivas" <sakkiped@starentnetworks.com>
Subject: Deadlock in IPv6 code while garbage collection on the rwlock protecting the routing tree.
Date: Tue, 22 Dec 2009 16:57:05 -0500
Message-ID: <4D35478224365146822AE9E3AD4A26660E89A49E@exchtewks3.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Johnson, David" <djohnson@starentnetworks.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.starentnetworks.com ([63.118.244.150]:36158 "EHLO
	mx1.starentnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbZLVV5J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 16:57:09 -0500
Received: from exchtewks1.starentnetworks.com (exchtewks1.starentnetworks.com [10.2.4.28]) by mx1.starentnetworks.com with ESMTP id oNBzdsoWFSFHoSdU for <netdev@vger.kernel.org>; Tue, 22 Dec 2009 16:57:06 -0500 (EST)
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I came across a deadlock scenario in the latest IPv6 code. I am trying
to fix this and any inputs are really appreciated. 

The deadlock happens when ROUTER-PREF is configured. This happens when
trying to do a write_lock_bh on the rwlock protecting the routing tree
during garbage collection.

The routing tree is read protected (read_lock_bh(&table->tb6_lock))
using the rwlock when performing a ip6_route_input or  ip6_route_output
( "ip6_pol_route"). During route selection (rt6_select), if a neighbor
solicit is sent (ndisc_send_ns), a dst_entry is allocated
(icmp6_dst_alloc calls dst_alloc). 
The garbage collection (fib6_run_gc) will be triggered if the number of
dst-entries is more than the threshold (dst_alloc). During garbage
collection, all the routing trees are cleaned up (fib6_clean_all). Here
we try to take write protect each routing tree (
write_lock_bh(&table->tb6_lock)). But one of the trees is already read
protected. 

The garbage collection is anyways triggered from "icmp6_dst_alloc" with
the call to fib6_force_start_gc. Since it is triggered, we might not
want to call the "fib6_run_gc" from dst_alloc for this case but there is
no way to figure this out in the "dst_alloc" routine.


Thanks
Srinivas

 



This email and any attachments may contain legally privileged and/or confidential information of Starent Networks, Corp. and is intended only for the individual or entity named in the message.  The information transmitted may not be used to create or change any contractual obligations of Starent Networks, Corp.  Any review, retransmission, dissemination or other use of, or taking of any action in reliance upon this e-mail and its attachments by persons or entities other than the intended recipient is prohibited. If you are not the intended recipient, please notify the sender immediately -- by replying to this message or by sending an email to postmaster@starentnetworks.com -- and destroy all copies of this message and any attachments without reading or disclosing their contents. Thank you.
 
