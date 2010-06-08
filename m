From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH][RFC] Introduction to sk_buff state checking
Date: Mon, 7 Jun 2010 17:30:46 -0700
Message-ID: <20100608003046.GA29325@dvomlehn-lnx2.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: to@dvomlehn-lnx2.corp.sa.net, "netdev@vger.kernel.org"@cisco.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:56263 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab0FHAaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 20:30:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add state checking for sk_buffs

Several common errors in sk_buff usage can be caught by maintaining and
checking the sk_buff state. States are: free, allocated, and queued. Simply
reporting an error is not sufficient; it may be the previous state change
that was erroneous. Thus, the ability to record the location of the previous
state change is essential.

This patch was previously submitted and David Miller objected to to the
overhead of recording the previous state change. Specifically, he wrote:

	The specifics are that if you showed me something that
	added a "u16", at most, I'd go to bat for you and support
	your work going upstream.

With only three states, only two bits are required to record the current
state but recording the location of the call that changed the state in
no more than 14 bits posed an interesting challenge. This patchset contains
the infrastructure required to map between a small value, the "callsite ID",
and the location of the call. 

There are four patches in this patchset:
1.	This introduction
2.	A patch allowing the site of a call to be passed over multiple calls
	without modifying the intervening functions.
3.	A patch providing infrastructure that allows the location of a call,
	the "callsite ID" to be encoded in a small integer.
4.	Modifications to the sk_buff functions to add the two-bit state
	and a 14-bit callsite ID, check the state, and report failures.
	
Restrictions
o	Call site IDs are never reused, so it is possible to exceed the
	maximum number of IDs by having a large number of call locations.
	In addition, it does not recognize that the same module has been
	unloaded and reloaded, so calls from the reloaded module will be
	assigned new IDs. Detection of incorrect operations on an sk_buff
	is not affected by exhaustion of call site IDs, but it may not be
	possible to determine the location of the last operation.
	CONFIG_DEBUG_SKB_ID_SIZE is set to reduce the sk_buff growth to 16
	bits and should handle most cases. It could be made larger to allow
	more call site IDs, if necessary.
o	The callsite structures for a module will be freed when that module
	is unloaded, even though sk_buffs may be using IDs corresponding to
	those call sites. To allow useful error reporting, the call site
	information in a module being unloaded is copied. If a module is
	unloaded and CONFIG_CALLSITE_TERSE is enabled, the address of
	the call site is not longer valid, so only the function name and
	offset are printed. If CONFIG_CALLSITE_TERSE is enabled and the
	is loaded, the address is also reported.

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
