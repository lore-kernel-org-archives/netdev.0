From: "Zhouyi Zhou" <yizhouzhou@ict.ac.cn>
Subject: Re: Re: [PATCH V7] netfilter: h323: avoid potential attack
Date: Thu, 17 Mar 2016 14:41:29 +0800 (GMT+08:00)
Message-ID: <1b9fc79.23ab4.153834ebe7a.Coremail.yizhouzhou@ict.ac.cn>
References: <1455984239-5807-1-git-send-email-zhouzhouyi@gmail.com>
 <20160312121902.GA2398@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Zhouyi Zhou" <zhouzhouyi@gmail.com>, eric.dumazet@gmail.com,
	kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, fw@strlen.de,
	gnomes@lxorguk.ukuu.org.uk, sergei.shtylyov@cogentembedded.com
To: "Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.cstnet.cn ([159.226.251.25]:56653 "EHLO cstnet.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752728AbcCQGuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 02:50:12 -0400
In-Reply-To: <20160312121902.GA2398@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Pablo for reviewing
> From: "Pablo Neira Ayuso" <pablo@netfilter.org>
> Sent Time: Saturday, March 12, 2016
> To: "Zhouyi Zhou" <zhouzhouyi@gmail.com>

> On Sun, Feb 21, 2016 at 12:03:59AM +0800, Zhouyi Zhou wrote:
> > I think hackers chould build a malicious h323 packet to overflow
(iph->ihl * 4 + th->doff * 4);
> You cannot trust the information that is available in the header. If
> this is bogus this check will be defeated. That's why we pass this
> protoff parameters to each function.
The length of IP header is checked in the function nf_conntrack_in which calls
get_l4proto hook to detect bogus ip header. 
There is no where in the call stack to the function set_addr to check bogus
TCP header, and my code does the job:
+		th = (void *)iph + iph->ihl * 4;
+		datalen = skb->len - (iph->ihl * 4 + th->doff * 4);
+		/* check offset overflow */
+		if (addroff > datalen)
+			return  -1;
if th->doff be too big addroff will greater than datalen.
> 
> You also refer to get_h225_addr() in your description. That function
> always copies 4 or 16 bytes, so I would appreciate if you can describe
> the possible issue further.
The problem of get_h225_addr lies in bogus taddr->ipAddress.ip, if this value
is too big, it may make the pointer p point to no exist address.
(gdb) list 686
681                       struct h323_ct_state *ctstate)
682     {
683             const unsigned char *p;
684             int len;
685
686             switch (taddr->choice) {
687             case eTransportAddress_ipAddress:
688                     if (nf_ct_l3num(ct) != AF_INET)
689                             return 0;
690                     p = data + taddr->ipAddress.ip;

Thanks for your time and effort
Cheers
Zhouyi
