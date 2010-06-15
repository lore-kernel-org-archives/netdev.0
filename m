From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/2] ehea: fix delayed packet processing
Date: Tue, 15 Jun 2010 09:45:47 -0700
Message-ID: <6663.1276620347@death.nxdomain.ibm.com>
References: <201006151735.17258.ossthema@de.ibm.com>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, linux-kernel@vger.kernel.org,
	tklein@linux.ibm.com, Andre Detsch <adetsch@br.ibm.com>,
	themann@de.ibm.com
To: "Jan-Bernd Themann" <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:40426 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643Ab0FOQqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 12:46:10 -0400
In-reply-to: <201006151735.17258.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan-Bernd Themann <ossthema@de.ibm.com> wrote:

>In the eHEA poll function an rmb() is required. Without that some packets
>on the receive queue are not seen and thus delayed until the next interrupt
>is handled for the same receive queue.
>
>Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>

	To add a bit of background, this could manifest during a netperf
TCP_RR or UDP_RR on an otherwise idle network.  TCP would occasionally
retransmit, but then both the original segment and the retransmission
would simultaneously appear at the receiver.  For UDP_RR, message sizes
in excess of the mtu would occasionally "lose" an IP fragment, and
eventually IP reassembly would time out.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>---
>Patch created against 2.6.35-rc3
>
> drivers/net/ehea/ehea_main.c |    1 +
> 1 files changed, 1 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
>index f547894..fd890fa 100644
>--- a/drivers/net/ehea/ehea_main.c
>+++ b/drivers/net/ehea/ehea_main.c
>@@ -867,6 +867,7 @@ static int ehea_poll(struct napi_struct *napi, int budget)
> 		ehea_reset_cq_ep(pr->send_cq);
> 		ehea_reset_cq_n1(pr->recv_cq);
> 		ehea_reset_cq_n1(pr->send_cq);
>+		rmb();
> 		cqe = ehea_poll_rq1(pr->qp, &wqe_index);
> 		cqe_skb = ehea_poll_cq(pr->send_cq);
>
>-- 
>1.7.0
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
