From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] qlcnic: Initialize mailbox cmd structure to zero.
Date: Fri, 30 May 2014 15:27:21 -0700 (PDT)
Message-ID: <20140530.152721.2164470954070022673.davem@davemloft.net>
References: <1401029702-22267-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934204AbaE3W1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 18:27:22 -0400
In-Reply-To: <1401029702-22267-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Sun, 25 May 2014 10:55:02 -0400

> o Uninitialized fields in mailbox command structure
>   caused commands to time out randomly due to garbage
>   values, so initialize it to zero.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>

The reason you ran into this problem is that some callers clear out
the command structure, and some do not.

And after your change it's even more confusing, because it is not
clear at all who is responsible for this initialization.

In my opinion it is better to have the place that allocates the
memory perform the initialization.  This means for interfaces that
take on-stack references from their caller, the caller does it.

This also avoids situations (which currently isn't happening here)
where error codes cause early function exits and as a result the
passed in variable isn't cleared out.

It also makes it so that the compiler can %100 see that the entire
object is initialized before being used, in all code paths.

Therefore, please change this bug fix to instead add the appropriate
memset()'s to qlcnic_sriov_get_vf_acl(), qlcnic_sriov_channel_cfg_cmd(),
and qlcnic_sriov_cfg_vf_guest_vlan().

Thanks.
