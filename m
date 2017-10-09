From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 41/47] netfilter: convert hook list to an array
Date: Mon, 9 Oct 2017 11:31:32 +0200
Message-ID: <20171009093132.GA7150@breakpoint.cc>
References: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
 <1504478574-13281-6-git-send-email-pablo@netfilter.org>
 <81603cbd-603d-1d93-a29a-1174fc826dec@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org, Aaron Conole <aconole@bytheb.org>,
        Florian Westphal <fw@strlen.de>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53416 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751636AbdJIJbl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 05:31:41 -0400
Content-Disposition: inline
In-Reply-To: <81603cbd-603d-1d93-a29a-1174fc826dec@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tariq Toukan <tariqt@mellanox.com> wrote:
> On 04/09/2017 1:42 AM, Pablo Neira Ayuso wrote:
> >From: Aaron Conole <aconole@bytheb.org>
> >
> >This converts the storage and layout of netfilter hook entries from a
> >linked list to an array.  After this commit, hook entries will be
> >stored adjacent in memory.  The next pointer is no longer required.
> >
> >The ops pointers are stored at the end of the array as they are only
> >used in the register/unregister path and in the legacy br_netfilter code.
> >
> >nf_unregister_net_hooks() is slower than needed as it just calls
> >nf_unregister_net_hook in a loop (i.e. at least n synchronize_net()
> >calls), this will be addressed in followup patch.
> >
> >Test setup:
> >  - ixgbe 10gbit
> >  - netperf UDP_STREAM, 64 byte packets
> >  - 5 hooks: (raw + mangle prerouting, mangle+filter input, inet filter):
> >empty mangle and raw prerouting, mangle and filter input hooks:
> >353.9
> >this patch:
> >364.2
> >
> >Signed-off-by: Aaron Conole <aconole@bytheb.org>
> >Signed-off-by: Florian Westphal <fw@strlen.de>
> >Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> >---
> 
> Hi,
> 
> We experience a regression in server with iommu enabled.
> After installing kernel and rebooting the server, it crashes during boot.
> Please see trace below.
> 
> Bisecting points to this patch.

Hmm, strange because

> [   25.907811] BUG: unable to handle kernel NULL pointer dereference at
> 000000000000003c
> [   25.907828] IP: _raw_read_lock_bh+0x15/0x40

... this says that ebt_table is NULL (0x3c is the offset of the rwlock).

If you don't have that fix already, does
https://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git/commit/?id=e6b72ee88a56bcfe63f72e9c30766484c45bec72

netfilter: ebtables: fix race condition in frame_filter_net_init()

resolve this bug for you?
