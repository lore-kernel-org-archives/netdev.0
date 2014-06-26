From: Octavian Purdila <octavian.purdila@intel.com>
Subject: Re: [RFC net-next 03/12] net: remove inet6_reqsk_alloc
Date: Thu, 26 Jun 2014 18:13:39 +0300
Message-ID: <CAE1zotKPoiu9mEw5-EggOPzPjdat=VyBHfHRXA+-Y9Z6ZF=aHA@mail.gmail.com>
References: <1403548969-12303-1-git-send-email-octavian.purdila@intel.com>
	<1403548969-12303-4-git-send-email-octavian.purdila@intel.com>
	<20140625.161733.1604668220222889933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:50794 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893AbaFZPNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 11:13:44 -0400
Received: by mail-wg0-f41.google.com with SMTP id a1so3638515wgh.0
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 08:13:39 -0700 (PDT)
In-Reply-To: <20140625.161733.1604668220222889933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 26, 2014 at 2:17 AM, David Miller <davem@davemloft.net> wrote:
> From: Octavian Purdila <octavian.purdila@intel.com>
> Date: Mon, 23 Jun 2014 21:42:40 +0300
>
>> Since pktops is only used for IPv6 only and opts is used for IPv4
>> only, we can move these fields into a union and this allows us to drop
>> the inet6_reqsk_alloc function as after this change it becomes
>> equivalent with inet_reqsk_alloc.
>>
>> This patch also fixes an kmemcheck issue in the IPv6 stack: the flags
>> field was not annotated after a request_sock was allocated.
>>
>> Signed-off-by: Octavian Purdila <octavian.purdila@intel.com>
>
> What about ipv4 mapped ipv6 connections?  I don't think it's safe to
> share the space for these two fields.

I've spent some time researching this and I don't think that it
matters for request_sock if we do have an ipv4 mapped ipv6 connection.
In this case all of the request_sock calls will be processed with
tcp_v4_ (or dccp_v4_) functions and there is no overlap with tcp_v6_
functions. And all tcp_v4_ functions use opts while the tcp_v6_
functions use pktopts.

Later when we switch to the full socket (in tcp_v6_syn_recv_sock), for
the ipv4 mapped case ireq->pktopts is not touched and
newsk->pktoptions is set to NULL.

I have used the same connections per second test to check ipv4 mapped
sockets and it did not trigger any issues so far.
