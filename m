From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] Fw: Intermittent SCTP multihoming breakage
Date: Mon, 05 Feb 2007 11:39:19 -0500
Message-ID: <45C75DB7.1060704@hp.com>
References: <E096369D937D3A4DB271B382850C5C5F44E22D@pysmail.eicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Sridhar Samudrala <sri@us.ibm.com>
To: Steve Hill <steve.hill@dialogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:55144 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751679AbXBEQjc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 11:39:32 -0500
In-Reply-To: <E096369D937D3A4DB271B382850C5C5F44E22D@pysmail.eicon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Hill wrote:
> Vlad Yasevich wrote on 25 January 2007 16:33:
> 
>> Can you try the attached patch and let me know if the problem is
>> fixed.  You can try reducing rto_max or path_max_retrans to get the
>> failover to happen a little faster. 
> 
> Sorry for the delay - I've been on vacation for the past week.
> 
> I've tried applying the patch.  However, the failure still seems to
> happen in the original test system with a patched kernel.  A look at the
> network traffic shows that the receiving side is still returning a
> gap-ack, the chunks in the gap are never resent and I don't see a
> FORWARD TSN for them.

Once you start simulating the network failure, how long do you wait?

If you have not changed rto_max and path_max_retrans, you can end up
waiting quite a while for the full path switchover.  This will also
severely slow down your retransmissions...

Try reducing /proc/sys/net/sctp/rto_max to say 6000ms (6 seconds).  It
defaults to (60000 ms or 1 minute).  That reduction means that the
retransmit timeout will max out at 6 seconds.

The problem is that you will not see the FORWARD TSN on the alternate
path until the original path is marked down.  That requires us to
exceed the path_max_retrans counter
(/proc/sys/net/sctp/path_max_retrans).  This means that you will see
the gap grow until a time when the rto exceeds the data expiry time.
At this pint, you will not see any new data sent, since it will expire
before being sent.  So, it will look to you like nothing is happening.

The gap will be closed once the FWD-TSN is transmitted over the
alternate transport.

-vlad

> 
>  - Steve Hill
>    Software Engineer
>    Dialogic
>    Fordingbridge, Hampshire, UK
>    +44-1425-651392
>    steve.hill@dialogic.com
> 
> -------------------------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier.
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> Lksctp-developers mailing list
> Lksctp-developers@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/lksctp-developers
> 


