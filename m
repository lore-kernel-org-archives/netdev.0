From: =?UTF-8?B?TWFydGluIE1PS1JFSsWg?= <mmokrejs@ribosome.natur.cuni.cz>
Subject: Re: [PATCH] net: fix setsockopt() locking errors
Date: Mon, 26 Jan 2009 22:30:30 +0100
Message-ID: <497E2B76.4030901@ribosome.natur.cuni.cz>
References: <20090126115012.GA5620@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Vegard Nossum <vegard.nossum@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ribosome.natur.cuni.cz ([195.113.57.20]:36815 "EHLO
	ribosome.natur.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbZAZVhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 16:37:14 -0500
In-Reply-To: <20090126115012.GA5620@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch really did not help:
http://bugzilla.kernel.org/show_bug.cgi?id=12515#c5
Martin

Jarek Poplawski wrote:
> On 24-01-2009 23:49, Vegard Nossum wrote:
>> Hi,
>>
>> This survives basic testing here, but I don't know what that counts for
>> when I couldn't reproduce the lockdep report in the first place. Please
>> review.
>>
>>
>> Vegard
>>
>>
>> From cc8bcd1c4fd219a31d6d191aefa4b4b57dadb9b0 Mon Sep 17 00:00:00 2001
>> From: Vegard Nossum <vegard.nossum@gmail.com>
>> Date: Sat, 24 Jan 2009 22:44:16 +0100
>> Subject: [PATCH] net: fix setsockopt() locking errors
>> MIME-Version: 1.0
>> Content-Type: text/plain; charset=utf-8
>> Content-Transfer-Encoding: 8bit
>>
>> Martin MOKREJ.  <mmokrejs@ribosome.natur.cuni.cz> reported:
>>> =======================================================
>>> [ INFO: possible circular locking dependency detected ]
>>> 2.6.29-rc2-git1 #1
>>> -------------------------------------------------------
>>> tcpdump/3734 is trying to acquire lock:
>>>  (&mm->mmap_sem){----}, at: [<c1053294>] might_fault+0x30/0x6b
>>>
>>> but task is already holding lock:
>>>  (sk_lock-AF_PACKET){--..}, at: [<c12798c8>] sock_setsockopt+0x12b/0x4a4
>>>
>>> which lock already depends on the new lock.
>> It turns out that sock_setsockopt() is calling copy_from_user() while
>> holding the lock on the socket.
> 
> I guess it has been like this for some time, so it would be nice to
> mention what scenario happens here, or IOW what exactly needs to get
> these locks in reverse order.
> 
>> We fix it by splitting the ioctl code
>> so that one switch handles the ioctls that have their own code for
>> reading from userspace, and one switch handles the cases that require
>> no additional reading.
>>
>> Reported-by: Martin MOKREJ.  <mmokrejs@ribosome.natur.cuni.cz>
>> Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
>> ---
>>  net/core/sock.c |  134 +++++++++++++++++++++++++++++++++++-------------------
>>  1 files changed, 87 insertions(+), 47 deletions(-)
>>
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index f3a0d08..6bd618d 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -424,6 +424,80 @@ out:
>>  	return ret;
>>  }
>>  
>> +static int sock_linger(struct sock *sk, char __user *optval, int optlen)
> ...
>> +static int sock_set_rcvtimeo(struct sock *sk, char __user *optval, int optlen)
>> +{
>> +	int ret;
>> +	long rcvtimeo;
>> +
>> +	ret = sock_set_timeout(&rcvtimeo, optval, optlen);
> 
> A check for error is needed here and below.
> 
[cut]
