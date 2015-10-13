From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Issue with /proc/sys/net/ipv4/tcp_mem
Date: Mon, 12 Oct 2015 18:44:39 -0700
Message-ID: <1444700679.21657.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <561B7F98.1040809@huawei.com>
	 <87io6coxg1.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wangyufen <wangyufen@huawei.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35203 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932100AbbJMBon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 21:44:43 -0400
Received: by pabve7 with SMTP id ve7so4385317pab.2
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 18:44:42 -0700 (PDT)
In-Reply-To: <87io6coxg1.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-10-12 at 11:37 -0500, Eric W. Biederman wrote:
> wangyufen <wangyufen@huawei.com> writes:
> 
> > Hi,
> >
> > I tried on linux-4.1:
> >     linux:~# cat /proc/sys/net/ipv4/tcp_mem 
> >     8388608	12582912	16777216
> >     linux:~# echo 1234 >/proc/sys/net/ipv4/tcp_mem 
> >     -bash: echo: write error: Invalid argument
> >     linux:~# cat /proc/sys/net/ipv4/tcp_mem 
> >     1234	12582912	16777216
> >
> > the echo operation got error, but value already written to tcp_mem.
> >
> > I checked, patch f594d63199688ad568fb caused the issue.
> 
> 
> If your problem is that you can not write a single value and instead
> have to write all three values I don't know what to tell you.  I don't
> see how that could have ever worked.
> 
> Certainly the commit you pointed at did not change that behavior.

I would not be so sure.
Above commit added a regression for partial writes.
If a write() returns an error like EINVAL, we expect no change occurred.

Prior code was calling proc_doulongvec_minmax() using a temporary array,
and updated tcp_mem[0 .. 2] only of proc_doulongvec_minmax() returned 0

       ret = proc_doulongvec_minmax(&tmp, write, buffer, lenp, ppos);
       if (ret)
               return ret;

#ifdef CONFIG_MEMCG_KMEM
	// deleted for clarity
#endif

       net->ipv4.sysctl_tcp_mem[0] = vec[0];
       net->ipv4.sysctl_tcp_mem[1] = vec[1];
       net->ipv4.sysctl_tcp_mem[2] = vec[2];

       return 0;

We could argue it is a bug in proc_doulongvec_minmax().
This helper probably should allocate a temp buffer,
as we have the same issue with udp_mem[].
