From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: [PATCH 03/17] fs: don't allow to complete sync iocbs through
 aio_complete
Date: Tue, 14 Apr 2015 11:37:01 -0700
Message-ID: <552D5E4D.8000909@intel.com>
References: <20150411211742.GJ889@ZenIV.linux.org.uk> <1428787108-13650-3-git-send-email-viro@ZenIV.linux.org.uk> <552D55D1.2000908@intel.com> <20150414182633.GD889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150414182633.GD889@ZenIV.linux.org.uk>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/14/2015 11:26 AM, Al Viro wrote:
>>> @@ -766,8 +765,7 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
>>> > >  
>>> > >  	init_sync_kiocb(&iocb, NULL);
>>> > >  	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
>>> > > -	if (-EIOCBQUEUED == ret)
>>> > > -		ret = wait_on_sync_kiocb(&iocb);
>>> > > +	BUG_ON(ret == -EIOCBQUEUED);
>> > 
>> > NACK - PF_ALG type sockets support async operations and return -EIOCBQUEUED
>> > See skcipher_recvmsg_async() in crypto/algif_skcipher.c in net-next
> Its only caller is
> 
> static int skcipher_recvmsg(struct socket *sock, struct msghdr *msg,
>                             size_t ignored, int flags)
> {
>         return (msg->msg_iocb && !is_sync_kiocb(msg->msg_iocb)) ?
>                 skcipher_recvmsg_async(sock, msg, flags) :
>                 skcipher_recvmsg_sync(sock, msg, flags);
> }
> 
> Note that !is_sync_kiocb() in there.  Compare with init_sync_kiocb() in
> sock_recvmsg()...

The only problem is it calls init_sync_kiocb(&iocb, NULL) on a different iocb.
The one that isn't even passed to skcipher_recvmsg()
skcipher_recvmsg() checks is_sync_kiocb(msg->msg_iocb).
I just want to make sure that after the merging window is closed I can still
trigger aio_read on PF_ALG socket.
thanks
