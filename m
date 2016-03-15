From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] rds-tcp: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Tue, 15 Mar 2016 11:09:50 -0700
Message-ID: <1458065390.31401.45.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160315151248.GJ11063@oracle.com>
	 <56E83A6D.6060904@oracle.com> <20160315165800.GL11063@oracle.com>
	 <1458062294.31401.37.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160315173011.GM11063@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: santosh shilimkar <santosh.shilimkar@oracle.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34306 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932212AbcCOSJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 14:09:52 -0400
Received: by mail-pf0-f180.google.com with SMTP id x3so38451997pfb.1
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 11:09:52 -0700 (PDT)
In-Reply-To: <20160315173011.GM11063@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-15 at 13:30 -0400, Sowmini Varadhan wrote:
> On (03/15/16 10:18), Eric Dumazet wrote:
> > 
> > Look at SO_SNDBUF and SO_RCVBUF implementation.
> > 
> > sk->sk_sndbuf = max_t(u32, val * 2, SOCK_MIN_SNDBUF);
> > 
> > sk->sk_rcvbuf = max_t(u32, val * 2, SOCK_MIN_RCVBUF);
> > 
> > kernel definitely has some logic here.
> 
> Ok, I can do the same thing (and we do this consistently across
> all drivers?)
> 
> > If you believe SOCK_MIN_SNDBUF and/or SOCK_MIN_RCVBUF are wrong, please
> > elaborate.
> 
> I dont recall suggesting that.

You said "just as user-space SO_SNDBUF allows ridiculous values
for buffer size.."

So I understood you believe SOCK_MIN_SNDBUF and/or SOCK_MIN_RCVBUF are
ridiculous ;)


> 
> BTW, when I tried it, doing a SO_SNDBUF of 1 from uspace does not return
> an error. It merely sets the buffer size to 4608 (as reported by
> getsockopt in my env. I think the getsockopt value is impacted by
> many factors).

I pointed to you the actual code.

sk->sk_sndbuf = max_t(u32, val * 2, SOCK_MIN_SNDBUF);


No error is returned. kernel enforces a minimal value.

#define SOCK_MIN_SNDBUF         (TCP_SKB_MIN_TRUESIZE * 2)
#define TCP_SKB_MIN_TRUESIZE    (2048 + SKB_DATA_ALIGN(sizeof(struct
sk_buff)))

-> 2 * (2048 + 256) = 4608  given current sk_buff overhead (that might
change in linux 5.4 ... )

But again if your sysctl allows to set a value below SOCK_MIN_SNDBUF,
that might be a problem, because stack could have a hidden bug for very
small values of sndbuf/rcvbuf. 
