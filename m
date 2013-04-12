From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] be2net: take care of __vlan_put_tag return value
Date: Fri, 12 Apr 2013 14:55:08 -0400 (EDT)
Message-ID: <20130412.145508.740030576340567517.davem@davemloft.net>
References: <1365778164-16857-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3DLSzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 14:55:12 -0400
In-Reply-To: <1365778164-16857-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Fri, 12 Apr 2013 16:49:24 +0200

> The driver should use return value of __vlan_put_tag with appropriate
> NULL-check instead of old skb pointer.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

I'll apply this patch but there is some strangeness with the
logic that controls these code paths.

The call to be_insert_vlan_in_pkt() is guarded by:

	be_vlan_tag_chk(adapter, skb)

which evaluates to:

	vlan_tx_tag_present(skb) || adapter->pvid

But the __vlan_put_tag() call is guarded by only one of those two
conditions:

	vlan_tx_tag_present(skb)

One of these two is wrong and should be corrected.

I suspect that we have several layers of bugs here, in that
we need to do __vlan_put_tag() in the adapter->pvid case but
that means that tag determination needs to have some
adapter->pvid logic added to it.

Or, if for some reason the adapter->pvid case doesn't apply to
this HW bug, the test guarding the be_insert_vlan_in_pkt() call
should be changed to vlan_tx_tag_present() and a big comment
added explaining why adapter->pvid is not being considered.
