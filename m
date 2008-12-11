From: "Kay Sievers" <kay.sievers@vrfy.org>
Subject: Re: [Bugme-new] [Bug 12201] New: long wait in call_usermodehelper() / queue_work() / wait_for_completion()
Date: Thu, 11 Dec 2008 23:48:32 +0100
Message-ID: <ac3eb2510812111448s7c700199ia2e57834f91c02a@mail.gmail.com>
References: <bug-12201-10286@http.bugzilla.kernel.org/>
	 <20081211143758.510b51b6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mike@nauticaltech.com, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Al Viro" <viro@zeniv.linux.org.uk>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:64501 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759408AbYLKW4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 17:56:10 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1094163rvb.1
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 14:56:10 -0800 (PST)
In-Reply-To: <20081211143758.510b51b6.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2008 at 23:37, Andrew Morton <akpm@linux-foundation.org> wrote:
>> As I continued to dig deeper (using lots of printks), I found that these delays
>> were caused by the netlink_create() code calling request_module() to find/load
>> a module for AUDIT support which doesn't exist.
>>
>> Continuing to dig, I found that request_module() uses call_usermodehelper() to
>> run /sbin/modprobe to find/load the module.
>>
>> The farthest I got is that after the process is created, we call
>> wait_for_completion() to get the result of that process.  This waiting process
>> takes 1-2 seconds.
>>
>> The big problem in troubleshooting here is that this only starts to happen
>> after the server has been online for a while (10 days maybe) and serving lots
>> of traffic.  The delay gradually builds up and maxes out at around 2 seconds.
>>
>> If I manually call /sbin/modprobe on the commandline and provide it the same
>> arguments that call_usermodehelper() uses, the command returns instantly 100%
>> of the time (assuming server has been on for a while).
>>
>> If I write a small pilot program that calls socket(PF_NETLINK, SOCK_RAW,
>> NETLINK_AUDIT), it will delay by 1-2 seconds 100% of the time (assuming server
>> has been online for a while).  Certain protocol types given to socket() have
>> zero delay (because no module needs to be loaded).
>>
>> Steps to reproduce:
>> Once server has been online for a while, a simple call to socket(PF_NETLINK,
>> SOCK_RAW, NETLINK_AUDIT) shows the problem.

If you replace /sbin/modprobe in the kernel module loader, does the
delay go away:
  echo /bin/true > /proc/sys/kernel/modprobe
?

Kay
