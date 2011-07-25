From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/7] More sane neigh infrastructure
Date: Mon, 25 Jul 2011 03:01:09 -0700 (PDT)
Message-ID: <20110725.030109.1723861338142084129.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375Ab1GYKDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 06:03:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Roland, this is a first pass at the kind of thing I was
talking about with you last week.

ATM and Infiniband both need to do their own kind of
signaling, either in place of (ATM) or in addition to
(IPoIB) the generic ARP negotiation.

ATM wants to push everything to a userspace atmarpd daemon,
and override all of the usual ARP signalling.  It replaces
the neigh_table used by ARP completely in order to accomplish
this.

IPoIB triggers it's signalling by hooking in at transmit time, and
adding a neigh parms destruction hook to free up and release it's
private per-neigh state.

I think both cases can be consolidated into one kind of scheme,
and these patches provide the infrastructure and convert ATM
over as an example.

Devices provide up to three things:

1) netdev->neighpriv_len, length of per-neighbour device private
   state, accessible via neighbour_priv(neigh)

2) net_device_ops->ndo_neigh_construct(), invoked right after
   neigh_tbl->constructor(), can fail

3) net_device_ops->ndo_neigh_destroy(), invoked right before
   we release neigh->parms and kfree_rcu() the neigh object.
   It could return errors but I'm not checking for them
   currently and I can't think what we could possibly do
   in response at this point in the code.  Maybe this gets
   changed to return "void" eventually.

As a result ATM CLIP no longer overrides the IPV4 ARP table, and
I'm convinced IPoIB could behave similarly, override the
neigh_ops in a device neigh constructor, and avoid all of the
hooks at transmit time and instead trigger the key signalling
at neigh->output and friends.

If IPoIB can get converted to this new stuff, then we can get
rid of the ->ndo_neigh_setup() netdev op which only exists to
facilitate IPoIB hooking in a destructor for it's neigh state.
