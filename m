From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 03/17] fs: don't allow to complete sync iocbs through
 aio_complete
Date: Tue, 14 Apr 2015 20:22:01 +0100
Message-ID: <20150414192201.GE889@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
 <1428787108-13650-3-git-send-email-viro@ZenIV.linux.org.uk>
 <552D55D1.2000908@intel.com>
 <20150414182633.GD889@ZenIV.linux.org.uk>
 <552D5E4D.8000909@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <552D5E4D.8000909@intel.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 14, 2015 at 11:37:01AM -0700, Tadeusz Struk wrote:

> The only problem is it calls init_sync_kiocb(&iocb, NULL) on a different iocb.
> The one that isn't even passed to skcipher_recvmsg()
> skcipher_recvmsg() checks is_sync_kiocb(msg->msg_iocb).
> I just want to make sure that after the merging window is closed I can still
> trigger aio_read on PF_ALG socket.
> thanks

... and after the merge with net-next#master that BUG_ON() is gone, so
you are still just fine.

FWIW, in the current for-davem (or in net-next#master, now that Dave has
pulled it) the functions in question are:
static inline int sock_recvmsg_nosec(struct socket *sock, struct msghdr *msg,
                                     size_t size, int flags)
{
        return sock->ops->recvmsg(sock, msg, size, flags);
}

int sock_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
                 int flags) 
{
        int err = security_socket_recvmsg(sock, msg, size, flags);

        return err ?: sock_recvmsg_nosec(sock, msg, size, flags);
}
EXPORT_SYMBOL(sock_recvmsg);
static ssize_t sock_read_iter(struct kiocb *iocb, struct iov_iter *to)
{
        struct file *file = iocb->ki_filp;
        struct socket *sock = file->private_data;
        struct msghdr msg = {.msg_iter = *to,
                             .msg_iocb = iocb};
        ssize_t res;

        if (file->f_flags & O_NONBLOCK)
                msg.msg_flags = MSG_DONTWAIT;

        if (iocb->ki_pos != 0)
                return -ESPIPE; 

        if (!iov_iter_count(to))        /* Match SYS5 behaviour */
                return 0;

        res = sock_recvmsg(sock, &msg, iov_iter_count(to), msg.msg_flags);
        *to = msg.msg_iter;
        return res;
}

AFAICS, everything looks fine.  Now, _another_ BUG_ON() might be worth
eventual removal (one in sock_sendmsg_nosec()), but right now we don't
have async ->sendmsg() instances, so it's not urgent.
