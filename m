From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC v3 01/10] lsm: add security_socket_closed()
Date: Fri, 06 May 2011 15:45:27 +0200
Message-ID: <87oc3glz7s.fsf@synack.fr>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
	<1304432663-1575-2-git-send-email-sam@synack.fr>
	<201105040029.IGA98088.SHOVQFLOMJtOFF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201105040029.IGA98088.SHOVQFLOMJtOFF@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Wed, 4 May 2011 00:29:29 +0900")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Samir Bellabes wrote:
>> Allow a module to update security informations when a socket is closed.
> Is security_inode_free() too late for doing it?
>
> static void ccs_inode_free_security(struct inode *inode)
> {
>         if (inode->i_sb && inode->i_sb->s_magic == SOCKFS_MAGIC)
>                 ccs_update_socket_tag(inode, 0);
> }

this point won't be possible.
security_inode_free() is occuring too late :

static int sock_close(struct inode *inode, struct file *filp)
{
        security_socket_close(SOCKET_I(inode)); 
           ... ->  acces sock->sk infos in this hook

        sock_release(SOCKET_I(inode));
        {
                sock->ops->release(sock);
                {
                        int inet_release(struct socket *sock)
                        {
                                struct sock *sk = sock->sk;

                                if (sk) {
                                sock_rps_reset_flow(sk);
                                sock->sk = NULL;
                                sk->sk_prot->close(sk, timeout);
                                 --> here sk infos are now removed
                        }
                }
                if (!sock->file) {
                   iput(SOCK_INODE(sock));
                --> here we are removing the inode, so
                    security_inode_free is called now, but too late.
                }
        }
}

        return 0;
}
