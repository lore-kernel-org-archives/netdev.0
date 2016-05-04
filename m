From: "Evgeny Cherkashin" <Eugene.Crosser@ru.ibm.com>
Subject: Re: [PATCH net] igmp: fix byte order in /proc/net/igmp output
Date: Wed, 4 May 2016 13:35:51 +0000
Message-ID: <201605041336.u44DaCGZ029899@d06av12.portsmouth.uk.ibm.com>
References: <1462367616.5535.340.camel@edumazet-glaptop3.roam.corp.google.com>,<1462363884-34968-1-git-send-email-Eugene.Crosser@ru.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: crosser@average.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp05.uk.ibm.com ([195.75.94.101]:37245 "EHLO
	e06smtp05.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbcEDNg3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 09:36:29 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <eugene.crosser@ru.ibm.com>;
	Wed, 4 May 2016 14:36:26 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 43F1E1B08074
	for <netdev@vger.kernel.org>; Wed,  4 May 2016 14:37:06 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u44DaFZf393568
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 13:36:15 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u44DaFcS029935
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 07:36:15 -0600
Received: from d50lp32.co.us.ibm.com (d50lp32.boulder.ibm.com [9.17.249.36])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id u44DaCGZ029899
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 07:36:14 -0600
Received: from localhost
	by d50lp32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <eugene.crosser@ru.ibm.com>;
	Wed, 4 May 2016 07:36:12 -0600
Received: from /spool/local
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <netdev@vger.kernel.org> from <eugene.crosser@ru.ibm.com>;
	Wed, 4 May 2016 13:35:54 -0000
In-Reply-To: <1462367616.5535.340.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Eric Dumazet <eric.dumazet@gmail.com> wrote: -----

>To: Evgeny Cherkashin/Russia/IBM@IBMRU
>From: Eric Dumazet <eric.dumazet@gmail.com>
>Date: 2016-05-04 16:13
>Cc: crosser@average.org, netdev@vger.kernel.org
>Subject: Re: [PATCH net] igmp: fix byte order in /proc/net/igmp
>output
>
>On Wed, 2016-05-04 at 14:11 +0200, Eugene Crosser wrote:
>> /proc/net/igmp is a readonly attribute that shows multicast groups
>> to which different network interfaces are subscribed. Among other
>> things, it displays `multiaddr` which is a 32 bit
>network-byte-order
>> field, in hexadecimal format. Prior to this patch, the field was
>> displayed as an integer, resulting in reverse byte order on little
>> endian architectures. This patch converts it with ntohl() for
>display
>> the same way as this is done for the /proc/net/mcfilter attribute.
>> 
>> The patch changes (corrects) user-visible behaviour.
>> 
>> Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
>> ---
>>  net/ipv4/igmp.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
>> index b3086cf..f9d2139 100644
>> --- a/net/ipv4/igmp.c
>> +++ b/net/ipv4/igmp.c
>> @@ -2722,7 +2722,7 @@ static int igmp_mc_seq_show(struct seq_file
>*seq, void *v)
>>  		delta = im->timer.expires - jiffies;
>>  		seq_printf(seq,
>>  			   "\t\t\t\t%08X %5d %d:%08lX\t\t%d\n",
>> -			   im->multiaddr, im->users,
>> +			   ntohl(im->multiaddr), im->users,
>>  			   im->tm_running,
>>  			   im->tm_running ? jiffies_delta_to_clock_t(delta) : 0,
>>  			   im->reporter);
>
>
>I do not believe we can change this. This is unfortunately too late.
>
>/proc/net/tcp has the same 'issue' or if you prefer, well known
>behavior.
>
>Such change would break basically all /proc/net/igmp users.

I understand that. It is unfortunate though that the byte order is not _just_ wrong, it's _different_ on BE and LE machines...
Oh well.

Thanks,

Eugene
