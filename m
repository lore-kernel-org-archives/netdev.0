From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] bridge: set is_local and is_static before
 fdb entry is added to the fdb hashtable
Date: Wed, 28 Oct 2015 14:02:07 +0900
Message-ID: <20151028140207.741e62f0@samsung9>
References: <1445957576-33386-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nikolay@cumulusnetworks.com,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34007 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbbJ1FCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 01:02:14 -0400
Received: by padhk11 with SMTP id hk11so244935887pad.1
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 22:02:13 -0700 (PDT)
In-Reply-To: <1445957576-33386-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Oct 2015 07:52:56 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Problem Description:
> We can add fdbs pointing to the bridge with NULL ->dst but that has a
> few race conditions because br_fdb_insert() is used which first creates
> the fdb and then, after the fdb has been published/linked, sets
> "is_local" to 1 and in that time frame if a packet arrives for that fdb
> it may see it as non-local and either do a NULL ptr dereference in
> br_forward() or attach the fdb to the port where it arrived, and later
> br_fdb_insert() will make it local thus getting a wrong fdb entry.
> Call chain br_handle_frame_finish() -> br_forward():
> But in br_handle_frame_finish() in order to call br_forward() the dst
> should not be local i.e. skb != NULL, whenever the dst is
> found to be local skb is set to NULL so we can't forward it,
> and here comes the problem since it's running only
> with RCU when forwarding packets it can see the entry before "is_local"
> is set to 1 and actually try to dereference NULL.
> The main issue is that if someone sends a packet to the switch while
> it's adding the entry which points to the bridge device, it may
> dereference NULL ptr. This is needed now after we can add fdbs
> pointing to the bridge.  This poses a problem for
> br_fdb_update() as well, while someone's adding a bridge fdb, but
> before it has is_local == 1, it might get moved to a port if it comes
> as a source mac and then it may get its "is_local" set to 1
> 
> This patch changes fdb_create to take is_local and is_static as
> arguments to set these values in the fdb entry before it is added to the
> hash. Also adds null check for port in br_forward.
> 
> Fixes: 3741873b4f73 ("bridge: allow adding of fdb entries pointing to the bridge device")
> Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
