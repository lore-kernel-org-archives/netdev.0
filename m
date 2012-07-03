From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: Re: [PATCH net-next 09/15] net: bus: Add garbage collector for
 AF_BUS sockets.
Date: Tue, 3 Jul 2012 13:11:26 +0100
Message-ID: <20120703131126.79d0ea05@rainbow.cbg.collabora.co.uk>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
	<1340988354-26981-10-git-send-email-vincent.sanders@collabora.co.uk>
	<1341251063.2590.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vincent Sanders <vincent.sanders@collabora.co.uk>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341251063.2590.5.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, 2 Jul 2012 18:44:23 +0100,
Ben Hutchings <bhutchings@solarflare.com> wrote :

> On Fri, 2012-06-29 at 17:45 +0100, Vincent Sanders wrote:
> > From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> > 
> > This patch adds a garbage collector for AF_BUS sockets.
> [...]
> > +struct sock *bus_get_socket(struct file *filp)
> > +{
> > +	struct sock *u_sock = NULL;
> > +	struct inode *inode = filp->f_path.dentry->d_inode;
> > +
> > +	/*
> > +	 *	Socket ?
> > +	 */
> > +	if (S_ISSOCK(inode->i_mode) && !(filp->f_mode &
> > FMODE_PATH)) {
> > +		struct socket *sock = SOCKET_I(inode);
> > +		struct sock *s = sock->sk;
> > +
> > +		/*
> > +		 *	PF_BUS ?
> > +		 */
> > +		if (s && sock->ops && sock->ops->family == PF_BUS)
> > +			u_sock = s;
> > +	}
> > +	return u_sock;
> > +}
> [...]
> 
> What about references cycles involving both AF_BUS and AF_UNIX
> sockets? I think you must either specifically prevent passing AF_UNIX
> sockets through AF_BUS sockets, or make a single garbage collector
> handle them both.

Indeed. Thanks for the feedback.

As far as I know, the current users of fd passing in D-Bus are Bluez
and Ofono and they pass AF_BLUETOOTH sockets. There might be
others, I am not sure what is in the wild. Passing AF_UNIX sockets in
D-Bus would be useful for Telepathy (for Tubes and File Transfer).

So I would like to be able to pass AF_UNIX sockets through AF_BUS
sockets.

I wrote the following small program to test this bug based on the
previous code <https://lkml.org/lkml/2010/11/25/8> referred by commit
25888e30:
http://people.collabora.com/~alban/d/2012/07/fd-passing/cmsg.c

The effect of the bug is to reach the file limit
in /proc/sys/fs/file-max and print "VFS: file-max limit 101771 reached"
even when the maximum of file descriptors per process ("ulimit -n") is
small.

I am not sure what is the best way to fix this. The easiest could be to
move the garbage collector related fields (recursion_level,
gc_candidate, etc.) from struct unix_sock and struct bus_sock to
struct sock and make a generic garbage collector for all sockets.

Best regards,
Alban
