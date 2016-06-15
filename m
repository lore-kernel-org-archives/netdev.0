From: "Lubashev, Igor" <ilubashe@akamai.com>
Subject: RE: [PATCH] netfilter/nflog: nflog-range does not truncate packets
Date: Wed, 15 Jun 2016 15:13:15 +0000
Message-ID: <c7780b528f80417bbac319767a2ecf65@usma1ex-dag1mb5.msg.corp.akamai.com>
References: <20160602002354.GG1644@akamai.com> <20160606223106.GA1621@salvia>
 <57575367.4010604@akamai.com> <20160608121625.GA4097@salvia>
 <5759AE1B.2080500@akamai.com> <575E2B49.7090809@akamai.com>
 <20160615123945.GA3594@salvia> <57616C49.7090403@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kaber@trash.net" <kaber@trash.net>,
	"kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"Hunt, Joshua" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pai.vishwain@gmail.com" <pai.vishwain@gmail.com>
To: "Pai, Vishwanath" <vpai@akamai.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay06.akamai.com ([96.6.114.98]:33529 "EHLO
	prod-mail-xrelay06.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932700AbcFOPUD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 11:20:03 -0400
In-Reply-To: <57616C49.7090403@akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vish, Pablo,

I wonder about the value of sending more data than a client is willing to consume (setting aside the important fact that the client code crashes due to the extra data).

It seems that we should either drop the nflog-range parameter from nflog altogether (and just use the len from the client) or allow nflog-range to further *restrict* the number of bytes sent to the client.

The "further restrict" logic would make it easier to build iptables rules that vary nflog-range based on some match conditions, so a single client would get different packet length depending on what rules matched.

Thoughts?

- Igor


-----Original Message-----
From: Vishwanath Pai [mailto:vpai@akamai.com] 
Sent: Wednesday, June 15, 2016 10:55 AM
To: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: kaber@trash.net; kadlec@blackhole.kfki.hu; netfilter-devel@vger.kernel.org; coreteam@netfilter.org; Hunt, Joshua <johunt@akamai.com>; netdev@vger.kernel.org; pai.vishwain@gmail.com; Lubashev, Igor <ilubashe@akamai.com>
Subject: Re: [PATCH] netfilter/nflog: nflog-range does not truncate packets

On 06/15/2016 08:39 AM, Pablo Neira Ayuso wrote:
> But nlmsg_len should match len in this.
> 
> If we're just sending a part of the packet to userspace, then we 
> should adjust nlmsg_len to indicate exactly the netlink message length 
> that we're sending to userspace.
> 
> Is your patch triggering this nlmsg_len != len?

The value of len here is how many bytes were returned by recv. We do send the entire nlmsg_len to userspace, but recv cannot copy the full packet because the buffer is not big enough to hold this. They only allocate the buffer assuming that the packet won't be bigger than their snap len, but we send more data than their snap len and they don't handle this condition well.
