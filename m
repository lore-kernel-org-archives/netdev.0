From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 4/5] net: sctp: decouple cleaning socket data
 from endpoint
Date: Thu, 20 Jun 2013 19:29:49 +0200
Message-ID: <51C33C0D.2040902@redhat.com>
References: <1371545720-22950-1-git-send-email-dborkman@redhat.com> <1371545720-22950-5-git-send-email-dborkman@redhat.com> <51C3133A.4000707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43256 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758098Ab3FTR36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 13:29:58 -0400
In-Reply-To: <51C3133A.4000707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2013 04:35 PM, Vlad Yasevich wrote:
> On 06/18/2013 04:55 AM, Daniel Borkmann wrote:
>> Rather instead of having the endpoint clean the garbage for the
>> socket, use a sk_destruct handler sctp_destruct_sock(), that does
>> the job for that when there are no more references on the socket.
>
> With this patch it is possible to run sctp_put_port while the socket
> is not locked.
>
> The flow goes something like this:
>
> sctp_close()
>    sk_bh_lock_sock();
>    sk_common_release()
>      sctp_destroy_sock()
>        endpoint_put()
>          endpoint_destroy() <-- This is where we used to do sctp_put_port
>    sk_bh_unlock_sock();
>    sock_put()
>      sk_free()
>        __sk_free()
>          sctp_destruct_sock()
>            sctp_put_port()
>
> I haven't found any race conditions yet, but that doesn't mean they don't exist.
>
> I think an easy solution would be to do sctp_put_port in sctp_unhash(),
> but I haven't traced all the paths.

Hm, compared to the current (pre-patch) solution, sctp_put_port() does not
necessarily need to be called at sk_common_release() time if refs are still
on the endpoint, so that endpoint_destroy() is further deferred in time. Thus,
if we would do the sctp_put_port() in sctp_unhash(), we could free it at an
earlier time than with endpoint_destroy(). This does not necessarily need to
be a bad or wrong way, but with the current approach it's done at an later
point in time afaik. If it's only about the locking, what if we just hold
that socket lock around sctp_put_port() in the current patch?

But besides that, if at such a late point in time someone still has access to
that socket member (right before we do the kfree(sk)), we would be pretty much
screwed. :-) Despite having the socket lock or not, the port hashtable has it's
own protection from what I see.
