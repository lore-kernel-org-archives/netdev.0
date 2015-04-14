From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 03/17] fs: don't allow to complete sync iocbs through
 aio_complete
Date: Tue, 14 Apr 2015 19:26:33 +0100
Message-ID: <20150414182633.GD889@ZenIV.linux.org.uk>
References: <20150411211742.GJ889@ZenIV.linux.org.uk>
 <1428787108-13650-3-git-send-email-viro@ZenIV.linux.org.uk>
 <552D55D1.2000908@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <552D55D1.2000908@intel.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 14, 2015 at 11:00:49AM -0700, Tadeusz Struk wrote:
> On 04/11/2015 02:18 PM, Al Viro wrote:
> > @@ -766,8 +765,7 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
> >  
> >  	init_sync_kiocb(&iocb, NULL);
> >  	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
> > -	if (-EIOCBQUEUED == ret)
> > -		ret = wait_on_sync_kiocb(&iocb);
> > +	BUG_ON(ret == -EIOCBQUEUED);
> 
> NACK - PF_ALG type sockets support async operations and return -EIOCBQUEUED
> See skcipher_recvmsg_async() in crypto/algif_skcipher.c in net-next

Its only caller is

static int skcipher_recvmsg(struct socket *sock, struct msghdr *msg,
                            size_t ignored, int flags)
{
        return (msg->msg_iocb && !is_sync_kiocb(msg->msg_iocb)) ?
                skcipher_recvmsg_async(sock, msg, flags) :
                skcipher_recvmsg_sync(sock, msg, flags);
}

Note that !is_sync_kiocb() in there.  Compare with init_sync_kiocb() in
sock_recvmsg()...
