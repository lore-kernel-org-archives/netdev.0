From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11058] New: DEADLOOP in kernel network module
Date: Tue, 8 Jul 2008 21:00:14 -0700
Message-ID: <20080708210014.a1d3baf8.akpm@linux-foundation.org>
References: <bug-11058-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: hemao77@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40584 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750757AbYGIEFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 00:05:38 -0400
In-Reply-To: <bug-11058-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue,  8 Jul 2008 20:13:20 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11058
> 
>            Summary: DEADLOOP in kernel network module
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.16.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: hemao77@gmail.com
> 
> 
> Latest working kernel version:2.6.16.1
> Earliest failing kernel version:2.6.16.1
> Distribution:FC3
> Hardware Environment:
> Software Environment:
> 
> Problem Description:
> 
> We have seen a deadloop in softirq and we got the cause by creating and
> analysising the core dump of the kernel.I dont know where to submit a patch ,
> so I report it here,wish you can apply it to furthur version of linux kernel.
> 
> The Cause:
> 
> Both  ctnetlink_del_conntrack() and the tcp_packet() run
> the code below:
> 
>     if (del_timer(&ct->timeout))                /*deactive the timer*/
>        ct->timeout.function((unsigned long) ct);/*remove conntrack from
> conntrack table*/
> 
> the ctnetlink_del_conntrack() context is:
> ................
>         if (cda[CTA_ID-1]) {
>                 u_int32_t id = ntohl(*(u_int32_t *)NFA_DATA(cda[CTA_ID-1]));
>                 if (ct->id != id) {
>                         ip_conntrack_put(ct);
>                         return -ENOENT;
>                 }
>         }       
> *       if (del_timer(&ct->timeout))
> *               ct->timeout.function((unsigned long)ct);
> 
>         ip_conntrack_put(ct);
> ...........
> 
> the tcp_packet() context is:
> ...........
>         case TCP_CONNTRACK_SYN_SENT:
>                 if (old_state < TCP_CONNTRACK_TIME_WAIT)
>                         break;
>                 if ((conntrack->proto.tcp.seen[dir].flags &
>                          IP_CT_TCP_FLAG_CLOSE_INIT)
>                     || after(ntohl(th->seq),
>                              conntrack->proto.tcp.seen[dir].td_end)) {  
>                         /* Attempt to reopen a closed connection.
>                         * Delete this connection and look up again. */
>                         write_unlock_bh(&tcp_lock);
> *                       if (del_timer(&conntrack->timeout))
> *                               conntrack->timeout.function((unsigned long)
> *                                                           conntrack);
>                         return -NF_REPEAT;
> ......
> 
> How the DEADLOOP happened?
> 
>     (1)in ctnetlink_del_conntrack()(runs in system call context): the del_timer
> is called and then goes to timeout.function.
>     (2)before timeout.function finish excution(means the conntrack not
> removed),an interrupt happens and a SYN packet of  the same conntrack
> comes.CPU goes to irq handle and enventually runs tcp_packet().
>     (3)in tcp_packet() ,del_timer() will fail because the timer was
> already deleted. the timeout.function in tcp_packet will not run,
> -NF_REPEAT is returned, the SYN packet will be passed back again.
>     (4)Neither side has the chance to run timeout.function,the
> conntrack remains there,deadloop happen,the SYN packet will be passed back
> again and again.
> 
> The fix maybe,add lock the softirq when doing conntrack removing:
> +++    local_bh_disable();
>       if (del_timer(&ct->timeout))                /*deactive the timer*/
>          ct->timeout.function((unsigned long) ct);/*remove conntrack from
> conntrack table*/
> +++    local_bh_enable();
> 
> Thanks, may this be helpful.
> My email: hemao77@gmail.com
> 
> It is hard to reproduce , but it really happen on our linux box.
> 

Thanks.

Please submit patches via email as described in
Documentation/SubmittingPatches.  The file ./MAINTAINERS can be used to
determine which individuals and mailing lists the patch should be sent to.

But that's for next time - this patch is small enough for the netfilter
developers to be able to type in again ;)

