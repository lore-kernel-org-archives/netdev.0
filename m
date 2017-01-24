From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net-next 3/3] net/tcp-fastopen: Add new API support
Date: Tue, 24 Jan 2017 08:30:43 +0100
Message-ID: <20170124073043.GA21590@1wt.eu>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
 <20170123185922.48046-4-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>, Wei Wang <weiwan@google.com>
To: Wei Wang <tracywwnj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:63745 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750710AbdAXHau (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 02:30:50 -0500
Content-Disposition: inline
In-Reply-To: <20170123185922.48046-4-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 10:59:22AM -0800, Wei Wang wrote:
> This patch adds a new socket option, TCP_FASTOPEN_CONNECT, as an
> alternative way to perform Fast Open on the active side (client).

Wei, I think that nothing prevents from reusin the original TCP_FASTOPEN
sockopt instead of adding a new one. The original one does this :

        case TCP_FASTOPEN:
                if (val >= 0 && ((1 << sk->sk_state) & (TCPF_CLOSE |
                    TCPF_LISTEN))) {
                        tcp_fastopen_init_key_once(true);

                        fastopen_queue_tune(sk, val);
                } else {
                        err = -EINVAL;
                }
                break;

and your new option does this :

	case TCP_FASTOPEN_CONNECT:
		if (val > 1 || val < 0) {
			err = -EINVAL;
		} else if (sysctl_tcp_fastopen & TFO_CLIENT_ENABLE) {
			if (sk->sk_state == TCP_CLOSE)
				tp->fastopen_connect = val;
			else
				err = -EINVAL;
		} else {
			err = -EOPNOTSUPP;
		}
		break;

Now if we compare :
  - the value ranges are the same (0,1)
  - tcp_fastopen_init_key_once() only performs an initialization once
  - fastopen_queue_tune() only sets sk->max_qlen based on the backlog,
    this has no effect on an outgoing connection ;
  - tp->fastopen_connect can be applied to a listening socket without
    side effect.

Thus I think we can merge them this way :

        case TCP_FASTOPEN:
                if (val >= 0) {
		        if ((sysctl_tcp_fastopen & TFO_CLIENT_ENABLE) &&
			    (sk->sk_state == TCP_CLOSE)
				tp->fastopen_connect = val;

			if ((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_LISTEN))) {
	                        tcp_fastopen_init_key_once(true);
                        	fastopen_queue_tune(sk, val);
			}
                } else {
                        err = -EINVAL;
                }
                break;

And for the userland, the API is even simpler because we can use the
same TCP_FASTOPEN sockopt regardless of the socket direction. Also,
I don't know if TCP_FASTOPEN is supported on simultaneous connect,
but at least if it works it would be easier to understand this way.

Do you think there's a compelling reason for adding a new option or
are you interested in a small patch to perform the change above ?

Regards,
Willy
