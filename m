From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and security_socket_post_recv_datagram().
Date: Wed, 22 Apr 2009 14:02:16 +0900
Message-ID: <200904220502.n3M52GQj001957@www262.sakura.ne.jp>
References: <200904220055.n3M0tQ6T048840@www262.sakura.ne.jp> <20090421.181411.26595688.davem@davemloft.net> <200904220149.n3M1ngLa059958@www262.sakura.ne.jp> <20090421.212259.213941533.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090421.212259.213941533.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> So what does your TOMOTO stuff do if the mapping changes again and
> that incoming connection that became unacceptable is now acceptable?
Nothing.

> We've lost the connection, and can never get it back.
TOMOYO won't keep the connection. That's fine.
TOMOYO thinks that dropping the connection/datagram is better than choking
the queue/buffer by keeping the connection/datagram for future policy changes.

I browsed the poll() logic for TCP/IPv4's listening socket.

SYSCALL_DEFINE3(poll, struct pollfd __user *, ufds, unsigned int, nfds,
                long, timeout_msecs)
{
    int do_sys_poll(struct pollfd __user *ufds, unsigned int nfds,
                    struct timespec *end_time)
    {
        static int do_poll(unsigned int nfds,  struct poll_list *list,
                           struct poll_wqueues *wait,
                           struct timespec *end_time)
        {
            static inline unsigned int do_pollfd(struct pollfd *pollfd,
                                                 poll_table *pwait)
            {
                file->f_op->poll(file, pwait);
            }
        }
    }
}

(file->f_op->poll == sock_poll in net/socket.c)

static unsigned int sock_poll(struct file *file, poll_table *wait)
{
    sock->ops->poll(file, sock, wait);
}

(sock->ops->poll == tcp_poll in net/ipv4/af_inet.c)

unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
{
    if (sk->sk_state == TCP_LISTEN) {
        static inline unsigned int inet_csk_listen_poll(const struct sock *sk)
        {
            return !reqsk_queue_empty(&inet_csk(sk)->icsk_accept_queue) ?
                                      (POLLIN | POLLRDNORM) : 0;
        }
    }
}

(and reqsk_queue_empty() is defined as)

static inline int reqsk_queue_empty(struct request_sock_queue *queue)
{
    return queue->rskq_accept_head == NULL;
}

If I read the code correctly, there is no LSM hook called for controlling
whether poll() is allowed to say "connections are ready" or not.
If security_socket_accept() rejects the accept() request, a connection remains
in the listening socket's queue. This will cause the subsequent poll() requests
to say "connections are ready" but the subsequent accept() requests to say
"you are not permitted to pick a connection up", and will continue consuming
100% of CPU resource until security_socket_accept() says "you are permitted to
pick a connection up".

Did I miss something?
