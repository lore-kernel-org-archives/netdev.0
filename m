From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] include listenq max backlog in /proc/net/tcp
	and	include in tcp_info
Date: Tue, 11 Sep 2007 10:46:51 -0700
Message-ID: <1189532811.19000.6.camel@w-sridhar2.beaverton.ibm.com>
References: <200709102313.QAA01722@tardy.cup.hp.com>
	 <1189471180.11066.19.camel@w-sridhar2.beaverton.ibm.com>
	 <46E63121.5090607@cosmosbay.com> <46E6C9A5.8000008@hp.com>
	 <20070911191539.ff60362b.dada1@cosmosbay.com>  <46E6D1E7.2060100@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:58863 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754259AbXIKRun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 13:50:43 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8BHog8P010277
	for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 13:50:42 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8BHognh560424
	for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 13:50:42 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8BHofk0010433
	for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 13:50:42 -0400
In-Reply-To: <46E6D1E7.2060100@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-11 at 10:35 -0700, Rick Jones wrote:
> > ss command from iproute2 package ( http://linux-net.osdl.org/index.php/Iproute2 )
> > 
> > Problem with /proc/net/tcp is its quadratic time O(N^2) to output N lines...
> 
> I could see where that might be a problem.
> 
> >>>Rick, could you add this part in your patch, and add my Sign-off-by ?
> >>
> >>My pleasure.
> >>
> >>I have a small test program for the tcp_info bit - where do I go to find 
> >>how the inet diag stuff works?
> > 
> > 
> > ss state listen
> 
> hpcpc103:~# ss --version
> ss utility, iproute2-ss070313
> hpcpc103:~# ss state listen
> ss: no socket states to show with such filter.

looks like 'ss state listening' or 'ss -l' is the right syntax.

> hpcpc103:~# ss --all
> State      Recv-Q Send-Q      Local Address:Port          Peer 
> Address:Port
> LISTEN     0      128                     *:sunrpc                   *:* 
> 
> LISTEN     0      128                     *:auth                     *:* 
> 
> LISTEN     0      128                    :::ssh                     :::* 
> 
> LISTEN     0      20              127.0.0.1:smtp                     *:* 
> 
> LISTEN     0      128                     *:42137                    *:* 
> 
> 
> > 
> > 
> >>BTW, what do people think about doing the same thing with the rxqueue 
> >>and txqueue's of netstat output?
> >>
> > 
> > 
> > I dont understand this question, I thought your patch already handled this 
> > (for the txqueue, since rxqueue is already there),  as netstat uses 
> > /proc/net/tcp (unfortunatly)
> 
> Well, it doesn't seem to be the case.  This is from the same system as 
> the ss output above:
> 
> hpcpc103:~# netstat -an | grep LISTEN
> tcp        0      0 0.0.0.0:111          0.0.0.0:*               LISTEN
> tcp        0      0 0.0.0.0:113          0.0.0.0:*               LISTEN
> tcp        0      0 127.0.0.1:25         0.0.0.0:*               LISTEN
> tcp        0      0 0.0.0.0:42137        0.0.0.0:*               LISTEN
> tcp6       0      0 :::22                :::*                    LISTEN
> unix  2    [ ACC ]     STREAM   LISTENING   5666  /var/run/acpid.socket
> 
> I thought I saw some other code in there when I was stumbling around.

Yes. netstat code seems to have a explicit check for TCP_LISTEN state
and zeroing txq and rxq.
>From tcp_do_one() in netstat.c
    if (state == TCP_LISTEN) {
        time_len = 0;
        retr = 0L;
        rxq = 0L;
        txq = 0L;
    }

We should fix this. Also i think it is a good idea to update netstat to use 
INET_DIAG_INFO instead of /proc/net/tcp.

Thanks
Sridhar

