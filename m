From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Tue, 27 Mar 2007 20:27:44 -0400
Message-ID: <4609B680.7070601@psc.edu>
References: <20070327214754.GA11677@dag-work> <20070327.153025.45876618.davem@davemloft.net> <4609A42A.4040304@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dagriego@gmail.com,
	davem@davemloft.ne, netdev@vger.kernel.org
To: Mark Huth <mhuth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:62661 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934147AbXC1AdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 20:33:05 -0400
In-Reply-To: <4609A42A.4040304@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Huth wrote:
> 
> 
> David Miller wrote:
>> From: dagriego@gmail.com (David Griego)
>> Date: Tue, 27 Mar 2007 14:47:54 -0700
>>
>>  
>>> Adds an IOCTL for aborting established TCP connections, and is
>>> designed to be an HA performance improvement for cleaning up, failure 
>>> notification, and application termination.
>>>
>>> Signed-off-by:  David Griego <dagriego@gmail.com>
>>>     
>>
>> SO_LINGER with a zero linger time plus close() isn't working
>> properly?
>>
>> There is no reason for this ioctl at all.  Either existing
>> facilities provide what you need or what you want is a
>> protocol violation we can't do.
>>   
> Actually, there are legitimate uses for this sort of API.  The patch 
> allows an administrator to kill specific connections that are in use by 
> other applications, where the close is not available, since the socket 
> is owned by another process.  Say one of your large applications has 
> hundreds or even thousands of open connections and you have determined 
> that a particular connection is causing trouble.  This API allows the 
> admin to kill that particular connection, and doesn't appear to violate 
> any RFC offhand, since an abort is sent  to the peer.
> 
> One may argue that the applications should be modified, but that is not 
> always possible in the case of various ISVs.  As Linux gains market 
> share in the large server market, more and more applications are being 
> ported from other platforms that have this sort of 
> management/administrative interfaces.
> 
> Mark Huth

I also believe this is a useful thing to have.  I'm not 100% sure this 
ioctl is the way to go, but it seems reasonable.  This directly 
corresponds to writing deleteTcb to the tcpConnectionState variable in 
the TCP MIB (RFC 4022).  I don't think it constitutes a protocol violation.

As a concrete example of a way I've used this type of feature is to 
defend against a netkill [1] style attack, where the defense involves 
making decisions about which connections to kill when memory gets 
scarce.  It makes sense to do this with a system daemon, since an admin 
might have an arbitrarily complicated policy as to which applications 
and peers have priority for the memory.  This is too complicated to 
distribute and enforce across all applications.  You could do this in 
the kernel, but why if you don't have to?

   -John

[1] http://shlang.com/netkill/
