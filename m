From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Bugme-new] [Bug 31232] New: /proc/sys/net/ipv6 has two neigh folders
Date: Wed, 16 Mar 2011 20:55:59 -0700
Message-ID: <m1oc5a2yeo.fsf@fess.ebiederm.org>
References: <bug-31232-10286@https.bugzilla.kernel.org/>
	<20110316152300.360f9240.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, sunkan@zappa.cx
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35448 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab1CQD4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2011 23:56:07 -0400
In-Reply-To: <20110316152300.360f9240.akpm@linux-foundation.org> (Andrew
	Morton's message of "Wed, 16 Mar 2011 15:23:00 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Wed, 16 Mar 2011 22:06:34 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=31232
>> 
>>            Summary: /proc/sys/net/ipv6 has two neigh folders
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 2.6.38
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: low
>>           Priority: P1
>>          Component: IPV6
>>         AssignedTo: yoshfuji@linux-ipv6.org
>>         ReportedBy: sunkan@zappa.cx
>>         Regression: No
>> 
>> 
>> I noticed when looking for other things that there are two neigh folders in
>> /proc/sys/net/ipv6
>> 
>> Reverting this commit removes the extra neigh folder:
>> http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commitdiff;h=bf36076a67db6d7423d09d861a072337866f0dd9
>> 
>> I don't know how to fix this.
>> I tried removing the ',' on the row '.child = empty,' (looking at the other
>> rows it did seem like a typo to me).
>> 
>> This did not change anything that I could see though.
>> 
>> Here is the commit I believe introduced the bug: 

Interesting.

This is definitely a bug.  I suspect it may be another symptom of the
bug I was trying to fix.  Something somewhere is messed up with the
neigh directory.

That extra neigh entry should serve as a mount point for any later neigh
entries that are registered, so the change should be fine.

I will see if I can make the time to look into this, as this new symptom
looks as nasty as the use after free problems I was seeing earlier.

Eric


>> --- a/net/ipv6/sysctl_net_ipv6.c
>> +++ b/net/ipv6/sysctl_net_ipv6.c
>> @@ -15,6 +15,8 @@
>>  #include <net/addrconf.h>
>>  #include <net/inet_frag.h>
>> 
>> +static struct ctl_table empty[1];
>> +
>>  static ctl_table ipv6_table_template[] = {
>>         {
>>                 .procname       = "route",
>> @@ -35,6 +37,12 @@ static ctl_table ipv6_table_template[] = {
>>                 .mode           = 0644,
>>                 .proc_handler   = proc_dointvec
>>         },
>> +       {
>> +               .procname       = "neigh",
>> +               .maxlen         = 0,
>> +               .mode           = 0555,
>> +               .child          = empty,
>> +       },
>>         { }
>>  };
>> 
>> @@ -152,7 +160,6 @@ static struct ctl_table_header *ip6_base;
>> 
>>  int ipv6_static_sysctl_register(void)
>>  {
>> -       static struct ctl_table empty[1];
>>         ip6_base = register_sysctl_paths(net_ipv6_ctl_path, empty);
>>         if (ip6_base == NULL)
>>                 return -ENOMEM;
>> 
