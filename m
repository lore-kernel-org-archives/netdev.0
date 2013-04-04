From: dingtianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 1/2] Revert "af_unix: dont send SCM_CREDENTIAL when dest
 socket is NULL"
Date: Thu, 4 Apr 2013 15:51:18 +0800
Message-ID: <515D30F6.9010004@huawei.com>
References: <20130402221104.163133110@linuxfoundation.org> <20130402221116.307254752@linuxfoundation.org> <87vc833kpf.fsf@turtle.gmx.de> <87k3ojnosa.fsf@xmission.com> <1365034777.13853.46.camel@edumazet-glaptop> <1365035424.13853.48.camel@edumazet-glaptop> <878v4zjei0.fsf@xmission.com> <87li8zhwkw.fsf_-_@xmission.com>
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
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87li8zhwkw.fsf_-_@xmission.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013/4/4 10:13, Eric W. Biederman wrote:
> 
> This reverts commit 14134f6584212d585b310ce95428014b653dfaf6.
> 
> The problem that the above patch was meant to address is that af_unix
> messages are not being coallesced because we are sending unnecesarry
> credentials.  Not sending credentials in maybe_add_creds totally
> breaks unconnected unix domain sockets that wish to send credentails
> to other sockets.
> 

thanks for check the question and make a fix solution, but I still doubt that if unconnected unix
domain socket wish to send credentails to oher sockets, why dont set
SOCK_PASSCRED on sock->flags, I think the user need to decide the param
and shouldnt send creds by default way.

Ding

> In practice this break some versions of udev because they receive a
> message and the sending uid is bogus so they drop the message.
> 
> Cc: stable@vger.kernel.org
> Reported-by: Sven Joachim <svenjoac@gmx.de>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  net/unix/af_unix.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 971282b..f153a8d 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1412,8 +1412,8 @@ static void maybe_add_creds(struct sk_buff *skb, const struct socket *sock,
>  	if (UNIXCB(skb).cred)
>  		return;
>  	if (test_bit(SOCK_PASSCRED, &sock->flags) ||
> -	    (other->sk_socket &&
> -	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags))) {
> +	    !other->sk_socket ||
> +	    test_bit(SOCK_PASSCRED, &other->sk_socket->flags)) {
>  		UNIXCB(skb).pid  = get_pid(task_tgid(current));
>  		UNIXCB(skb).cred = get_current_cred();
>  	}
> 
