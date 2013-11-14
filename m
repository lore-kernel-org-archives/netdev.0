From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH] rds: fix local ping DoS
Date: Thu, 14 Nov 2013 07:45:37 -0600
Message-ID: <5284D401.1020307@akamai.com>
References: <1384391743-9342-1-git-send-email-johunt@akamai.com> <20131114.020355.1973894145326845195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"venkat.x.venkatsubra@oracle.com" <venkat.x.venkatsubra@oracle.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jjolly@suse.com" <jjolly@suse.com>,
	"fenlason@redhat.com" <fenlason@redhat.com>,
	"honli@redhat.com" <honli@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:44206 "EHLO
	prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752932Ab3KNNpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 08:45:42 -0500
In-Reply-To: <20131114.020355.1973894145326845195.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2013 01:03 AM, David Miller wrote:
> From: Josh Hunt <johunt@akamai.com>
> Date: Wed, 13 Nov 2013 17:15:43 -0800
>
>> The rds_ib_xmit function in net/rds/ib_send.c in the Reliable Datagram Sockets
>> (RDS) protocol implementation allows local users to cause a denial of service
>> (BUG_ON and kernel panic) by establishing an RDS connection with the source
>> IP address equal to the IPoIB interface's own IP address, as demonstrated by
>> rds-ping.
>>
>> A local unprivileged user could use this flaw to crash the system.
>>
>> CVE-2012-2372
>>
>> Reported-by: Honggang Li <honli@redhat.com>
>> Signed-off-by: Josh Hunt <johunt@akamai.com>
>
> I'm sorry I can't apply this.  This commit message needs to be much
> less terse and explain things more.
>
> First of all, why is the "off % RDS_FRAG_SIZE" important?
>
> And, even more importantly, why is is OK to avoid this assertion just
> because we're going over loopback?
>
> Furthermore, why doesn't net/rds/iw_send.c:rds_iw_xmit() have the same
> exact problem?  It makes the same exact assertion check.
>
> I know this RDS code is a steaming pile of poo, but that doesn't mean
> we just randomly adjust assertions to make crashes go away without
> sufficient understanding of exactly what's going on.
>
> Thanks.
>

Sure understandable questions. Unfortunately I don't have the hardware 
to properly debug and analyze. I was just trying to get this through on 
the assumption that the previous attempts just failed due to incorrect 
submission procedures and lack of a reproducible testcase. If nothing 
else this whole thing brought out the testcase :)

Testcase from Honggang's earlier mail:
<snip>
The test case is very simple:
Steps to Reproduce:
1. yum install -y rds-tools

2. [root@rdma3 ~]# ifconfig ib0 | grep 'inet addr'
           inet addr:172.31.0.3  Bcast:172.31.0.255  Mask:255.255.255.0

3. [root@rdma3 ~]# /usr/bin/rds-ping 172.31.0.3  <<<< kernel panic (You
may need to wait for a few seconds before the kernel panic.)

This bug can be reproduced with Mellanox HCAs (mlx4_ib.ko and mthca.ko),
QLogic HCA (ib_qib.ko). I did not test the QLogic HCA running "ib_ipath.ko".
</snip>

Perhaps Venkat or someone else with the hardware mentioned can provide a 
better explanation and better solution to the crash.

Josh
