From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Thu, 3 Sep 2009 13:35:29 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909031331020.29881@V090114053VZO-1>
References: <4A98132C.8090105@gmail.com> <20090828.233858.256193304.davem@davemloft.net> <4A9BBD8E.2010303@gmail.com> <20090901.184121.06750444.davem@davemloft.net> <4A9E849A.30105@gmail.com> <4A9EF113.9030102@gmail.com> <alpine.DEB.1.10.0909031255490.27903@V090114053VZO-1>
 <4A9FCEC5.80409@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, sri@us.ibm.com,
	dlstevens@us.ibm.com, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com, mtk.manpages@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:37700 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753291AbZICOk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 10:40:26 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 811A782C812
	for <netdev@vger.kernel.org>; Thu,  3 Sep 2009 10:42:10 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Tlq+JEv2+KQQ for <netdev@vger.kernel.org>;
	Thu,  3 Sep 2009 10:42:10 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9D55482C816
	for <netdev@vger.kernel.org>; Thu,  3 Sep 2009 10:38:14 -0400 (EDT)
In-Reply-To: <4A9FCEC5.80409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 3 Sep 2009, Eric Dumazet wrote:

> >> --- a/net/ipv4/udp.c
> >> +++ b/net/ipv4/udp.c
> >> @@ -561,12 +561,18 @@ static int udp_push_pending_frames(struct sock *sk)
> >>
> >>  send:
> >>  	err = ip_push_pending_frames(sk);
> >> +	if (err) {
> >> +		if (err == -ENOBUFS && !inet->recverr) {
> >> +			UDP_INC_STATS_USER(sock_net(sk),
> >> +					   UDP_MIB_SNDBUFERRORS, is_udplite);
> >
> > This means that we now do not increment SNDBUFERRORS if IP_RECVERR is set.
> >
> > I think it would be better to move UDP_INC_STATS_USER before the if
> > statement. That will also simplify the code further.
> >
> >
>
> I believe you already said this once Christoph on a previous patch, and I
> replied that in case of IP_RECVERR set, udp_push_pending_frames()
> returns -ENOBUFS to its caller : udp_sendmsg()

Ahhh. I see. Would it not be better to have a single location where the
SNDBUFERRORS are accounted for? Check for -ENOBUFS before the code in
udp_sendmsg()? Hmmm.. The control flow is a bit complicated there...

