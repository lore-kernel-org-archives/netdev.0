From: Rick Jones <rick.jones2@hp.com>
Subject: Re: getsockopt/setsockopt with SO_RCVBUF and SO_SNDBUF "non-standard"
 behaviour
Date: Wed, 18 Jul 2012 10:32:30 -0700
Message-ID: <5006F32E.8060405@hp.com>
References: <50052FFE.2060109@pu-pm.univ-fcomte.fr>  <5006DD6B.3030300@pu-pm.univ-fcomte.fr> <1342627875.2626.3070.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eugen Dedu <Eugen.Dedu@pu-pm.univ-fcomte.fr>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:29953 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab2GRRcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 13:32:33 -0400
In-Reply-To: <1342627875.2626.3070.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/18/2012 09:11 AM, Eric Dumazet wrote:
>
> That the way it's done on linux since day 0
>
> You can probably find a lot of pages on the web explaining the
> rationale.
>
> If your application handles UDP frames, what SO_RCVBUF should count ?
>
> If its the amount of payload bytes, you could have a pathological
> situation where an attacker sends 1-byte UDP frames fast enough and
> could consume a lot of kernel memory.
>
> Each frame consumes a fair amount of kernel memory (between 512 bytes
> and 8 Kbytes depending on the driver).
>
> So linux says : If user expect to receive  XXXX bytes, set a limit of
> _kernel_ memory used to store these bytes, and use an estimation of 100%
> of overhead. That is : allow 2*XXXX bytes to be allocated for socket
> receive buffers.

Expanding on/rewording that, in a setsockopt() call SO_RCVBUF specifies 
the data bytes and gets doubled to become the kernel/overhead byte 
limit.  Unless the doubling would be greater than net.core.rmem_max, in 
which case the limit becomes net.core.rmem_max.

But on getsockopt() SO_RCVBUF is always the kernel/overhead byte limit.

In one call it is fish.  In the other it is fowl.

Other stacks appear to keep their kernel/overhead limit quiet, keeping 
SO_RCVBUF an expression of a data limit in both setsockopt() and 
getsockopt().  With those stacks, there is I suppose the possible source 
of confusion when/if someone tests the queuing to a socket, sends "high 
overhead" packets and doesn't get to SO_RCVBUF worth of data though I 
don't recall encountering that in my "pre-linux" time.

The sometimes fish, sometimes fowl version (along with the auto tuning 
when one doesn't make setsockopt() calls) gave me fits in netperf for 
years until I finally relented and split the socket buffer size 
variables into three - what netperf's user requested via the command 
line, what it was right after the socket was created, and what it was at 
the end of the data phase of the test.

rick jones
