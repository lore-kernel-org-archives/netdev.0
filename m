From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IP ID check (flush_id) in inet_gro_receive is necessary or
 =?UTF-8?Q?not=EF=BC=9F?=
Date: Tue, 28 Jun 2016 06:57:09 +0200
Message-ID: <1467089829.6850.181.camel@edumazet-glaptop3.roam.corp.google.com>
References: <5771FFA1.3050306@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, aduyck@mirantis.com,
	hkchu@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tan Xiaojun <tanxiaojun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5771FFA1.3050306@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-06-28 at 12:40 +0800, Tan Xiaojun wrote:
> Hi everyone,
> 
> 	I'm sorry to bother you. But I was confused.
> 
> 	The IP ID check (flush_id) in inet_gro_receive is only used by
> tcp_gro_receive, and in tcp_gro_receive we have tcphdr check to ensure
> the order of skbs,
> 	like below:
> 
> 	flush |= (__force int)(th->ack_seq ^ th2->ack_seq);
> 	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);
> 
> 	So if I remove the IP ID check in inet_gro_receive, there will be a
> problem ? And under what circumstances ?

You probably missed a recent patch ?

commit 1530545ed64b42e87acb43c0c16401bd1ebae6bf
Author: Alexander Duyck <aduyck@mirantis.com>
Date:   Sun Apr 10 21:44:57 2016 -0400

    GRO: Add support for TCP with fixed IPv4 ID field, limit tunnel IP ID values
    
    This patch does two things.
    
    First it allows TCP to aggregate TCP frames with a fixed IPv4 ID field.  As
    a result we should now be able to aggregate flows that were converted from
    IPv6 to IPv4.  In addition this allows us more flexibility for future
    implementations of segmentation as we may be able to use a fixed IP ID when
    segmenting the flow.
    
    The second thing this does is that it places limitations on the outer IPv4
    ID header in the case of tunneled frames.  Specifically it forces the IP ID
    to be incrementing by 1 unless the DF bit is set in the outer IPv4 header.
    This way we can avoid creating overlapping series of IP IDs that could
    possibly be fragmented if the frame goes through GRO and is then
    resegmented via GSO.
    
    Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
