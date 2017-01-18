From: Alexander Heinlein <alexander.heinlein@secunet.com>
Subject: Re: [PATCH] ip/xfrm: Fix deleteall when having many policies
 installed
Date: Wed, 18 Jan 2017 09:00:59 +0100
Message-ID: <795bb467-bacd-ddd2-69f7-368cdaede296@secunet.com>
References: <d056322e-7c23-7e19-3bdb-4afa5f04e409@secunet.com>
 <20170117084412.0bff48bb@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37264 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751293AbdARIBq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 03:01:46 -0500
In-Reply-To: <20170117084412.0bff48bb@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2017 05:44 PM, Stephen Hemminger wrote:
> What happens when many many policies are installed?
> It looks like your patch would silently stop deleting.
> Does the the code flush all of them?

Yes, it flushes all of them. xfrm_policy_list_or_deleteall() performs
multiple rounds until there are no more policies left to delete
(xb.nlmsg_count becomes 0).

The previous code failed with
> Policy buffer overflow
> Delete-all terminated
upon reaching the end of the buffer. This already happens for 102
policies on my system.

The new code fills the buffer, sends the corresponding netlink message
and then re-checks for remaining policies to delete.

You can check the old and new behavior via the following commands:
# for((i=0;i<255;++i)); do ip x p a src 0.0.0.$i dst 127.0.0.0/24 dev lo
dir out action allow priority 10000; done
# ip -s -s x p deleteall action allow priority 10000

Regards
Alex
