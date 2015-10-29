From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next RFC] mpls: support for dead routes
Date: Thu, 29 Oct 2015 16:53:29 +0000
Message-ID: <56324F09.2060103@brocade.com>
References: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:47979 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757070AbbJ2Qxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 12:53:41 -0400
In-Reply-To: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/10/15 15:49, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Adds support for both RTNH_F_DEAD and RTNH_F_LINKDOWN flags.
> This resembles ipv4 fib code. I also picked fib_rebalance from
> ipv4. Enabled weights support for nexthop, just because the
> infrastructure is already there.
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> I want to get this in before net-next closes as promised.
> I have tested it for the dead/linkdown flags. The multipath selection
> and hash calculation in the face of dead routes needs some more
> work. I am short on cycles this week and thought of getting some
> early feedback. Hence sending this out as RFC. I will continue with some
> more testing.  Robert, I am using your hash algo but it needs some more
> work with dead routes. If you already have any thoughts on this, i will
> take them. thanks!.

If you were to sort the array of nexthops (and by implication via 
addresses) by their non-deadness keeping a count of the alive nexthops, 
then there's no need to resort to an O(n) algorithm for selecting the 
nexthop, and no need to store per-nh flags.

E.g. before eth0 link down:

+----------------------+
| rt_nhn = 3           |
| rt_nhn_alive = 3     |
+----------------------+
| nh 0:                |
| dev = eth0, ...      |
+----------------------+
| nh 1:                |
| dev = eth1, ...      |
+----------------------+
| nh 2:                |
| dev = eth0, ...      |
+----------------------+
| vias ...             |
+----------------------+

after eth0 link down:

+----------------------+
| rt_nhn = 3           |
| rt_nhn_alive = 1     |
+----------------------+
| nh 0:                |
| dev = eth1, ...      |
+----------------------+
| nh 1:                |
| dev = eth0, ...      |
+----------------------+
| nh 2:                |
| dev = eth0, ...      |
+----------------------+
| vias ...             |
+----------------------+

The mpls_select_multipath algorithm just then needs to be changed to use 
rt_nhn_alive instead of rt_nhn and will work otherwise as-is.

On link down you'll need to alloc a new route for RCU-safety, but you 
can presumably just do a kmemdup to reduce the amount of code you have 
to write and sort the nexthops in the copy. Link up will be similar.

Then on the mpls_dump_route, if the index of the nexthop is >= 
rt_nhn_alive then the path is link-down. If the nh_dev is NULL then 
generate RTNH_F_DEAD|RTNH_F_LINKDOWN for the flags, otherwise just 
RTNH_F_LINKDOWN.

This would use less memory and be faster for forwarding.

Thanks,
Rob
