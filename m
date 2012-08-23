From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: First pass at MSG_FASTOPEN support in top-of-trunk netperf
Date: Thu, 23 Aug 2012 07:15:15 -0700
Message-ID: <CAFbMe2MY11VoXbGPDcLzHiHBzskoQk6eL1S9VWV5Vd1u0aRjNw@mail.gmail.com>
References: <5020739A.3060809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35429 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610Ab2HWOPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 10:15:17 -0400
Received: by lbbgj3 with SMTP id gj3so467537lbb.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 07:15:15 -0700 (PDT)
In-Reply-To: <5020739A.3060809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rick,

On Mon, Aug 6, 2012 at 6:47 PM, Rick Jones <rick.jones2@hp.com> wrote:
> Folks -
>
> I have just checked-in to the top-of-trunk netperf
> (http://www.netperf.org/svn/netperf2/trunk) some changes which enable use of
> sendto(MSG_FASTOPEN) in a TCP_CRR test.  While I was checking the system
> calls I noticed that netperf was calling enable_enobufs() for every migrated
> test, not just a UDP_STREAM test (the one where it is needed), so I fixed
> that at the same time.  Baseline is taken with the fix in place.
>
> MSG_FASTOPEN is used when one adds a test-specific -F option to the netperf
> command line:
>
> netperf -t TCP_CRR -H <destination> -- -F
>
> Just testing the client side from a VM on my workstation (running a net-next
> pulled just before 16:30 Pacific time) to my workstation itself I notice the
> following:
>
> Without MSG_FASTOPEN:
> raj@tardy-ubuntu-1204:~/netperf2_trunk$ src/netperf -H tardy.usa.hp.com -t
> TCP_CRR -i 3,30
> MIGRATED TCP Connect/Request/Response TEST from 0.0.0.0 (0.0.0.0) port 0
> AF_INET to tardy.usa.hp.com () port 0 AF_INET : +/-2.500% @ 99% conf.  :
> demo
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
>
> 16384  87380  1        1       10.00    2092.33
> 16384  87380
>
> With MSG_FASTOPEN
> raj@tardy-ubuntu-1204:~/netperf2_trunk$ src/netperf -H tardy.usa.hp.com -t
> TCP_CRR -i 3,30 -- -F
> MIGRATED TCP Connect/Request/Response TEST from 0.0.0.0 (0.0.0.0) port 0
> AF_INET to tardy.usa.hp.com () port 0 AF_INET : +/-2.500% @ 99% conf.  :
> demo
> !!! WARNING
> !!! Desired confidence was not achieved within the specified iterations.
> !!! This implies that there was variability in the test environment that
> !!! must be investigated before going further.
> !!! Confidence intervals: Throughput      : 6.565%
> !!!                       Local CPU util  : 0.000%
> !!!                       Remote CPU util : 0.000%
>
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
>
> 16384  87380  1        1       10.00    2590.18
> 16384  87380
>
> There was a ~25% increase in TCP_CRR performance, even without the server
> actually accepting the magic TCP option.  Is that actually expected?

I have a locally enhanced netperf for TCP_CRR over Fast Open and I've
 noticed the numbers can change drastically between runs. I have not got
the time to investigate why. (Does it have to do with scheduler and CPU
locality?) How consistent is your perf number?

I plan to submit the server side code soon and will work with you to add
the server side support to TCP_CRR (it requires a new TCP_FASTOPEN
socket option to enable Fast Open on a listener.)

Thanks,

Jerry

> Admittedly, it eliminates a connect() call, but the sequence before was:
>
> socket()
> getsockopt(SO_SNDBUF)
> getsockopt(SO_RCVBUF)
> setsockopt(SO_REUSEADDR)
> bind()
> connect()
> sendto(4, "n", 1, 0, NULL, 0)           = 1
> recvfrom(4, "n", 1, 0, NULL, NULL)      = 1
> recvfrom(4, "", 1, 0, NULL, NULL)       = 0
> close(4)
>
> and with MSG_FASTOPEN only the connect() goes away.  Unless connect() is
> really heavy compared to what sendto(MSG_FASTOPEN) does or something else
> has changed wrt behaviour.
>
> Anyway, feel free to kick the tires on the netperf changes and let me know
> of any problems you encounter.
>
> happy benchmarking,
>
> rick jones
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
