From: Rick Jones <rick.jones2@hp.com>
Subject: Re: why does DCCP SO_REUSEADDR have to be SOL_DCCP?
Date: Mon, 04 Feb 2008 10:46:30 -0800
Message-ID: <47A75D86.9050409@hp.com>
References: <47A3CA7F.8040300@hp.com> <20080202025259.GH17164@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:33104 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948AbYBDSqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 13:46:32 -0500
In-Reply-To: <20080202025259.GH17164@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaldo Carvalho de Melo wrote:
> Em Fri, Feb 01, 2008 at 05:42:23PM -0800, Rick Jones escreveu:
> 
>>Hi -
>>
>>I'm tweaking the netperf omni tests to be able to run over DCCP.  I've run 
>>across a not-unorecedented problem with getaddrinfo() not groking either 
>>SOCK_DCCP or IPPROTO_DCCP in the hints, and that I can more or less live 
>>with - I had to do a kludge for getaddrinfo() for IPPROTO_SCTP under Linux 
>>at one point and I can see how the two are not necessarily going to be in 
>>sync.
> 
> 
> See the ttcp patch where we do a xgetaddrinfo crude hack to handle dccp:
> 
> http://vger.kernel.org/~acme/dccp/ttcp.c

That is basically what netperf ends-up doing presently, although it is 
much more vocal about it :)

>>And I've worked-around no user-level include files (ie without setting 
>>__KERNEL__) define the DCCP stuff, and that is OK too, albeit somewhat 
>>inconvenient.
> 
> 
> Humm, for what? Again, see the ttcp code above:

I see that it too is making a guess for the DCCP defines.  I prefer to 
get those from the "regular" include files because several of them can 
be platform specific and netperf happens on many platforms.  If DCCP is 
still "experimental" I suppose that living with defines not being in 
user-level includes is to be expected.

>>My question though is why on earth does an SO_REUSEADDR setsockopt() 
>>against a DCCP socket have to be SOL_DCCP?  SCTP and TCP are quite happy 
>>with SOL_SOCKET, and it might be foolish consistency, but since the option 
>>_does_ begin with SO_ I'd have expected it to work for SOL_SOCKET, but 
>>(again RHEL5.1, yes, I do plan on getting upstream but have to satisfy 
>>several masters) it doesn't seem to be the case - a subsequent listen() or 
>>connect() call after an SOL_SOCKET SO_REUSEADDR against a DCCP socket 
>>leaves one SOL as it were...
> 
> 
> Strange, lemme check...
> 
>  1. sys_socketcall ->
>  2.  sys_setsockopt ->
>  3.    if (level == SOL_SOCKET) {
>  4.      sock_setsockopt:
>  5.        case SO_REUSEADDR:
>  6.          sk->sk_reuse = valbool;
>  7.    } else
>  8.      sock->ops->setsockopt = inet_dccp_ops->setsockopt =
>  9.        inet_dccp_ops->setsockopt = sock_common_setsockopt ->
> 10.          sk->sk_prot->setsockopt = dccp_v4_prot->setsockopt =
> 11.	    dccp_setsockopt
> 12.              if (level != SOL_DCCP)
> 13.                return inet_csk(sk)->icsk_af_ops->setsockopt() =
> 14.		  ip_setsockopt
> 15.              return do_dccp_setsockopt()
> 
> SO_REUSEADDR is handled in 4, if you pass SOL_SOCKET.
> 
> If instead you pass SOL_DCCP we'll go down the rabbit hole till
> do_dccp_setsockopt() and SO_REUSEADDR, that is equal to 2, will be
> interpreted as DCCP_SOCKOPT_SERVICE, that is also equal to 2, so you'll
> be setting the service, not changing the SO_REUSEADDR setting.

That is completely unexpected.  Particularly based on the implications of:

http://www.linux-foundation.org/en/Net:DCCP

> 
> The problem here is that you need to use:
> 
> setsockopt(fd, SOL_DCCP, DCCP_SOCKOPT_PACKET_SIZE, service,
>            sizeof(service));

I guess since I was going off the URL above and it doesn't mention 
that... :)  I was just blythly ass-u-me-ing that DCCP was usable as a 
"just swap the IPPROTO in your socket() call and go" sort of thing. And 
wasn't expecting to have to make additional setsockopt() calls.

> Look forward for a happy DCCP netperf bencharking session!

Looks like some very basic stuff (whatever one gets passing SOL_DCCP to 
the SO_REUSEADDR setting) is functioning in the top of trunk.  I now 
have to think about what to do wrt DCCP service types.  If I should add 
something to the parsing of -T dccp or if I should add yet another 
command-line option :)

happy benchmarking,

rick jones
