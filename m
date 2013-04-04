From: dingtianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 2/2] af_unix: If we don't care about credentials coallesce
 all messages
Date: Thu, 4 Apr 2013 15:56:37 +0800
Message-ID: <515D3235.7080608@huawei.com>
References: <20130402221104.163133110@linuxfoundation.org> <20130402221116.307254752@linuxfoundation.org> <87vc833kpf.fsf@turtle.gmx.de> <87k3ojnosa.fsf@xmission.com> <1365034777.13853.46.camel@edumazet-glaptop> <1365035424.13853.48.camel@edumazet-glaptop> <878v4zjei0.fsf@xmission.com> <87li8zhwkw.fsf_-_@xmission.com> <87d2ubhwiw.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Sven Joachim <svenjoac@gmx.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Karel Srot <ksrot@redhat.com>, <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:23327 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932725Ab3DDH4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 03:56:48 -0400
In-Reply-To: <87d2ubhwiw.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/4/4 10:14, Eric W. Biederman wrote:
> 
> It was reported that the following LSB test case failed
> https://lsbbugs.linuxfoundation.org/attachment.cgi?id=2144 because we
> were not coallescing unix stream messages when the application was
> expecting us to.
> 
> The problem was that the first send was before the socket was accepted
> and thus sock->sk_socket was NULL in maybe_add_creds, and the second
> send after the socket was accepted had a non-NULL value for sk->socket
> and thus we could tell the credentials were not needed so we did not
> bother.
> 
> The unnecessary credentials on the first message cause
> unix_stream_recvmsg to start verifying that all messages had the same
> credentials before coallescing and then the coallescing failed because
> the second message had no credentials.
> 
> Ignoring credentials when we don't care in unix_stream_recvmsg fixes a
> long standing pessimization which would fail to coallesce messages when
> reading from a unix stream socket if the senders were different even if
> we did not care about their credentials.
> 
> I have tested this and verified that the in the LSB test case mentioned
> above that the messages do coallesce now, while the were failing to
> coallesce without this change.
> 
> Reported-by: Karel Srot <ksrot@redhat.com>
> Reported-by: Ding Tianhong <dingtianhong@huawei.com>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  net/unix/af_unix.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index f153a8d..2db702d 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1993,7 +1993,7 @@ again:
>  			if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
>  			    (UNIXCB(skb).cred != siocb->scm->cred))
>  				break;
> -		} else {
> +		} else if (test_bit(SOCK_PASSCRED, &sock->flags)) {
>  			/* Copy credentials */
>  			scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
>  			check_creds = 1;
> 

As your opinion, I think the way is better:

		if (test_bit(SOCK_PASSCRED, &sock->flags)) {
                        if (check_creds) {
                                /* Never glue messages from different writers */
                                if ((UNIXCB(skb).pid  != siocb->scm->pid) ||
                                (UNIXCB(skb).cred != siocb->scm->cred))
                                        break;
                        } else {
                                /* Copy credentials */
                                scm_set_cred(siocb->scm, UNIXCB(skb).pid, UNIXCB(skb).cred);
                                check_creds = 1;
                        }
                }

Ding
