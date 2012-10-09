From: Jie Liu <jeff.liu@oracle.com>
Subject: Re: [PATCH] RDS: Fix spinlock recursion for rds over tcp transmit
Date: Tue, 09 Oct 2012 12:40:47 +0800
Message-ID: <5073AACF.5030608@oracle.com>
References: <506FC4CD.7070509@oracle.com> <50730396.1040303@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, Dan Carpenter <dan.carpenter@oracle.com>,
	davem@davemloft.net, James Morris <james.l.morris@oracle.com>,
	netdev@vger.kernel.org
To: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:45541 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636Ab2JIElB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 00:41:01 -0400
In-Reply-To: <50730396.1040303@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Venkat,

On 10/09/12 00:47, Venkat Venkatsubra wrote:
> On 10/6/2012 12:42 AM, Jeff Liu wrote:
>> Hello,
>>
>> RDS ping/pong over TCP feature has broke for years(2.6.39 to 3.6.0)
>> since we have to set TCP cork and
>> call kerenel_sendmsg() to reply a ping requirement which both need to
>> lock "struct sock *sk".
>> However, this lock has already been hold before our
>> rda_tcp_data_ready() callback is triggerred.
>> As a result, we always facing spinlock recursion which would
>> resulting in system panic...
>>
>> Given that RDS ping is a special kind of message, we don't need to
>> reply it as
>> soon as possible, IMHO, we can schedule it to work queue as a delayed
>> response to
>> make TCP transport totally works.  Also, I think we can using the
>> system default
>> work queue to serve it to reduce the possible impact on general TCP
>> transmit.
>>
> Hi Jeff,
>
> I was looking at the history of changes to rds_send_pong.
> At one time rds_send_pong did this to transmit the pong message:
>        queue_delayed_work(rds_wq, &conn->c_send_w, 0);
> instead of the current
>        ret = rds_send_xmit(conn);
> i.e. the older versions did not have the deadlock problem and used to
> work once. ;-)
>
> I have suggestions for fixing it in a couple of other ways which you
> may want to consider
> to reduce the amount of code changes in a transport independent layer
> such as "send.c" for a specific underlying transport (tcp in this case).
Thanks for the feedback!

>
> 1. One option is to move back to the old way for all transports (IB,
> tcp, loopback) since
> queuing delay shouldn't be an issue for a diagnostic tool like
> rds-ping which is typically used just to test the connectivity
> and not for serious performance measurements.
So I prefer to your first suggestions since I have also tried to fix
this issue in this way at that time, of course, it really works fine. :)
And also, it could keep the code change as little as possible.
I changed my mind to queue pong message to the system default queue as
it might reduce the impact on general RDS TCP transmits,
but I turned out to be a bit overkill and with more code changes.

I'll send out the V2 patch for your review after a little while.

Thanks,
-Jeff
>
> 2. The underlying transport such as IB, loopback,TCP tells which
> method it wants to send the pong: queued way or send immediately.
>      And the code change in rds_send_pong could then simply be:
>    if (conn->c_flags & QUEUE_PONG)
>       queue_delayed_work(rds_wq, &conn->c_send_w,0);
>    else
>       ret = rds_send_xmit(conn);
> (The above example codes are not complete. You will need to propagate
> this new flag to "conn" from "rds_transport", etc. at connection setup
> time)
>
> Venkat
