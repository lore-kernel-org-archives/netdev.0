From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [net PATCH 1/2] ipv4: Drop leaf from suffix pull/push functions
Date: Mon, 5 Dec 2016 15:05:01 +0000
Message-ID: <16113cf4-2a89-cf5b-1eb7-557bcc8220c0@brocade.com>
References: <20161201121605.15499.13176.stgit@ahduyck-blue-test.jf.intel.com>
 <20161201122752.15499.8184.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:59585 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751161AbcLEPFP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 10:05:15 -0500
In-Reply-To: <20161201122752.15499.8184.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/16 12:27, Alexander Duyck wrote:
> It wasn't necessary to pass a leaf in when doing the suffix updates so just
> drop it.  Instead just pass the suffix and work with that.
>
> Since we dropped the leaf there is no need to include that in the name so
> the names are updated to node_push_suffix and node_pull_suffix.
>
> Finally I noticed that the logic for pulling the suffix length back
> actually had some issues.  Specifically it would stop prematurely if there
> was a longer suffix, but it was not as long as the original suffix.  I
> updated the code to address that in node_pull_suffix.
>
> Fixes: 5405afd1a306 ("fib_trie: Add tracking value for suffix length")
> Suggested-by: Robert Shearman <rshearma@brocade.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

This addresses an issue in the current code whereby when a fib alias is 
removed from a leaf when there are other aliases remaining then the 
suffix length may not be updated in the conditions described above. This 
is because fib_remove_alias doesn't call trie_rebalance (or resize) in 
this case, as there's no need since no nodes have been added/removed.

This can be reproduced with this structure of the fib trie and by adding 
and then deleting 10.37.96.0/19:

         +-- 10.37.0.0/16 4 1 8 suffix/19
            |-- 10.37.0.0
               /24 universe UNICAST
            |-- 10.37.32.0
               /24 universe UNICAST
            |-- 10.37.64.0
               /20 universe UNICAST
            |-- 10.37.95.0
               /24 universe UNICAST
            +-- 10.37.96.0/20 2 1 2 suffix/21
               +-- 10.37.96.0/22 2 1 2 suffix/24
                  +-- 10.37.96.0/24 2 1 2 suffix/24
                     |-- 10.37.96.0
                        /32 link BROADCAST
                        /24 link UNICAST
                     +-- 10.37.96.192/26 2 0 2 suffix/28
                        |-- 10.37.96.204
                           /32 host LOCAL
                        |-- 10.37.96.255
                           /32 link BROADCAST
                  |-- 10.37.98.0
                     /25 universe UNICAST
               |-- 10.37.104.0
                  /21 universe UNICAST
            +-- 10.37.112.0/23 2 0 2 suffix/24
               |-- 10.37.112.0
                  /24 universe UNICAST
               |-- 10.37.113.0
                  /24 universe UNICAST
            |-- 10.37.223.0
               /24 universe UNICAST
            |-- 10.37.224.0
               /24 universe UNICAST

I've verified that with the fix included here that the suffix length on 
the 10.37.0.0/16 node now gets updated correctly to be /20.

Reviewed-by: Robert Shearman <rshearma@brocade.com>
Tested-by: Robert Shearman <rshearma@brocade.com>

Thanks,
Rob
