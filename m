From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 10/27] ixgb: Don't check for vlan group on transmit
Date: Sun, 12 Dec 2010 17:00:41 -0800
Message-ID: <AANLkTi=mi7pSRXrOyiFx75Feuo29tpw9bJbvHf0BrC_s@mail.gmail.com>
References: <1292048241-22026-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1292048241-22026-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, Emil Tantilov <emil.s.tantilov@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:47075 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783Ab0LMBAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 20:00:42 -0500
Received: by fxm18 with SMTP id 18so5728179fxm.2
        for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 17:00:41 -0800 (PST)
In-Reply-To: <1292048241-22026-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 10, 2010 at 10:17 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Emil Tantilov <emil.s.tantilov@intel.com>
>
> Based on a patch from Jesse Gross.
>
> Enable vlan tag insertion even when vlan group is not configured.
>
> For ixgb HW both CTRL0.VME and VLE bit in the Tx descriptor need to be set
> in order to enable HW acceleration.
>
> Introduced separate functions for enabling/disabling of vlan tag stripping
> similar to ixgbe.

Thanks for working on this.  However, I don't think that this patch
actually does what it says.

In ixgb_xmit_frame() it's still checking whether adapter->vlgrp is
non-null before inserting a tag, so it will drop tags unless a vlan
group is configured.  Also, since it's not currently possible to
toggle NETIF_F_HW_VLAN_RX, vlan stripping will never get disabled.
This is actually a regression since before vlan stripping would get
disabled if no vlan group was configured.  Now, vlan headers will get
silently dropped if there is no vlan group.

Regardless of that, I still think this is a useful change on the road
towards adopting the new vlan interfaces, the problem is just that
currently it's halfway in between the old and the new.  Given that, it
would obviously be much better to move all the way over the new when
addressing this.

Out of curiosity, is the implication of this that vlan insertion on
transmit and stripping on receive are always configured together?  I
don't have hardware supported by this driver but when I worked on
ixgbe (which is at least superficially similar in this area) I didn't
have any problems configuring them independently.

Thanks.
