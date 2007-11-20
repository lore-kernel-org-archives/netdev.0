From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9418] New: Funcation tcp_v6_md5_do_del return
 has error.
Date: Tue, 20 Nov 2007 12:46:18 -0800
Message-ID: <20071120124618.9a348f33.akpm@linux-foundation.org>
References: <bug-9418-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, ming-baini@163.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36392 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762744AbXKTUqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 15:46:24 -0500
In-Reply-To: <bug-9418-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Nov 2007 07:13:00 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9418
> 
>            Summary: Funcation tcp_v6_md5_do_del return has error.
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.23
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: ming-baini@163.com
> 
> 
> Most recent kernel where this bug did not occur:
> None, I always had this problem with the md5 in tcpv6. 
> Distribution:
> Hardware Environment:  
> Software Environment:
> Problem Description:
> When you creat two or more tcpv6 md5 entries,and you may del someone.For
> example, if you added two ipv6 address(2000::9, 2000::10) to a sk, so the sk
> first md5 entry is for 2000::9 and second entry is for 2000::10, and then the
> sk has two entries. If you want to del the second md5 entry , the funcation
> "tcp_v6_md5_do_del"  will not sub the tp->md5sig_info->entries6 for the first
> loop, because this time the address is not 2000::9.For the second loop, the
> tp->md5sig_info->entries6 will sub 1,but this time tp->md5sig_info->entries6 is
> not 0 but 1, so the funcation return -ENOENT.When application get the return
> vlaue may occur error.
> 
> for (i = 0; i < tp->md5sig_info->entries6; i++) {
>     if (ipv6_addr_cmp(&tp->md5sig_info->keys6[i].addr, peer) == 0) {
>         /* Free the key */
>         kfree(tp->md5sig_info->keys6[i].base.key);
>         tp->md5sig_info->entries6--;
> 
>         if (tp->md5sig_info->entries6 == 0) {
>             kfree(tp->md5sig_info->keys6);
>             tp->md5sig_info->keys6 = NULL;
>             tp->md5sig_info->alloced6 = 0;
> 
>             tcp_free_md5sig_pool();
> 
>             /*return 0;*/    /*not in here*/
>         } else {
>             /* shrink the database */
>             if (tp->md5sig_info->entries6 != i)
>                 memmove(&tp->md5sig_info->keys6[i],
>                     &tp->md5sig_info->keys6[i+1],
>                     (tp->md5sig_info->entries6 - i)
>                     * sizeof (tp->md5sig_info->keys6[0]));
>         }
>     }
>     return 0;/*should be return here*/
> }
> 
> 
> Steps to reproduce:
> Create two tcpv6 md5 entry ,and then delete the second.
> 

and

> I have a mistake. The code shoule be :
> static int tcp_v6_md5_do_del(struct sock *sk, struct in6_addr *peer)
> {
>     struct tcp_sock *tp = tcp_sk(sk);
>     int i;
> 
>     for (i = 0; i < tp->md5sig_info->entries6; i++) {
>         if (ipv6_addr_cmp(&tp->md5sig_info->keys6[i].addr, peer) == 0) {
>             /* Free the key */
>             kfree(tp->md5sig_info->keys6[i].base.key);
>             tp->md5sig_info->entries6--;
> 
>             if (tp->md5sig_info->entries6 == 0) {
>                 kfree(tp->md5sig_info->keys6);
>                 tp->md5sig_info->keys6 = NULL;
>                 tp->md5sig_info->alloced6 = 0;
> 
>                 /*tcp_free_md5sig_pool();*/   /*this also wrong*/
> 
>                 /*return 0;*/    /*not in here*/
>             } else {
>                 /* shrink the database */
>                 if (tp->md5sig_info->entries6 != i)
>                     memmove(&tp->md5sig_info->keys6[i],
>                         &tp->md5sig_info->keys6[i+1],
>                         (tp->md5sig_info->entries6 - i)
>                         * sizeof (tp->md5sig_info->keys6[0]));
>             }
>             tcp_free_md5sig_pool();   /*should be put here*/
>             return 0;           /*should be return here*/
>         }
>     }
>     return -ENOENT;
> }
