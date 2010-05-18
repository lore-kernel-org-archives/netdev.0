From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: RE: get beyond 1Gbps with pktgen on 10Gb nic?
Date: Tue, 18 May 2010 04:14:35 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497EFC00D@MILEXCH2.ds.jdsu.net>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D752C7@MILEXCH2.ds.jdsu.net>
	<1273584925.2107.6.camel@achroite.uk.solarflarecom.com>
	<4BE97DD7.7000704@candelatech.com>
	<4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D85C81@MILEXCH2.ds.jdsu.net>
 <AANLkTilZseWJCHnDXSjwUYol7ewXewIhMJG-tqWO_C86@mail.gmail.com>
 <4BEAF44E.8090201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og110.obsmtp.com ([64.18.2.173]:59310 "HELO
	exprod7og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756476Ab0ERLPq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 07:15:46 -0400
In-Reply-To: <4BEAF44E.8090201@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi rick:

do you mean "TCP_NODELAY" will send with packet size as I expect

without this option,netperf might sent packet with large size? (but eventually it will be splitted into MTU size?)

thanks
jon


-----Original Message-----
From: Rick Jones [mailto:rick.jones2@hp.com] 
Sent: Thursday, May 13, 2010 2:33 AM
To: Jesse Brandeburg
Cc: Jon Zhou; Ben Greear; Ben Hutchings; netdev@vger.kernel.org
Subject: Re: get beyond 1Gbps with pktgen on 10Gb nic?

Jesse Brandeburg wrote:
> On Tue, May 11, 2010 at 9:00 PM, Jon Zhou <Jon.Zhou@jdsu.com> wrote:
> 
>> I just used multi netperf instances to reach 900K pps/8Gb+ traffic on the
>> Broadcom 10G nic:

>>
>>command:
>>
>>for i in 1 2 3 4 5 6 7 8 9 10
>>do
>>netperf -l 60 -H 192.168.0.53 -- -m 60 -s 100M -S 100M &
>>done

100 Megabytes seems a trifle excessive as a socket buffer size.  I would suggest 
  lopping-off a few zeros and use 1M instead.  Or, one can let linux auto-tune 
the socket buffers/windows - just don't accept the socket buffer size reported 
by the classic netperf command - it is from the initial creation of the socket. 
  To get what it became by the end of the test one should use the "omni" tests. 
  Contact me offlist or via netperf-talk in the netperf.org domain for more on that.

>> the msg size was assigned as 64 bytes, but when I checked the file captured
>> by tcpdump, found that netperf sent many frames which are large than 64
>> bytes(i.e.4000-10K+ bytes) and these frames were truncated by tcpdump.
>>
>> so that the actual avg packet size is around 1500 bytes, but what I want is
>> avg packet: 300-400 bytes and reach 5Gb+.
>>
>>does it make sense?
> 
> 
> if you set the TCP_NODELAY (to disable nagle) option on netperf 

If he was seeing 4K to 10K byte frames in his tcpdump, that was likely TSO above 
and beyond nagle.  I was going to say it also suggests he was running tcpdump on 
the sending side rather than the receiver, but then there is LRO/GRO isn't there...

> (check netperf -t TCP_STREAM -- -h) then you should be able to control packet
>  size.

Or at least influence it meaningfully :)  If he was seeing 4K to 10K byte frames 
in his tcpdump, that was likely TSO above and beyond nagle.If there are packet 
losses and retransmissions, the retransmissions, which may or may not include 
new data may be larger.

The "netperf -t TCP_STREAM -- -h" to get test-specific help shown by Jesse will 
show the option you need to add to set TCP_NODELAY.  For additional descriptions 
of netperf command options:

http://www.netperf.org/svn/netperf2/tags/netperf-2.4.5/doc/netperf.html

For "quick and dirty" testing, the loop as it appears above is "ok" but I would 
suggest abusing the confidence intervals code to minimize the skew error:

http://www.netperf.org/svn/netperf2/tags/netperf-2.4.5/doc/netperf.html#Using-Netperf-to-Measure-Aggregate-Performance

happy benchmarking,

rick jones

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

