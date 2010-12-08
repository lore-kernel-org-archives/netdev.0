From: Martin Lucina <mato@kotelna.sk>
Subject: Re: Polling on sockets in kernel space and struct file
Date: Wed, 8 Dec 2010 16:16:29 +0100
Message-ID: <20101208151628.GE13666@dezo.moloch.sk>
References: <4CFF9757.3070100@250bpm.com> <1291820573.2883.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Sustrik <sustrik@250bpm.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chrocht.moloch.sk ([62.176.169.44]:33364 "EHLO mail.moloch.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752147Ab0LHP0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 10:26:43 -0500
Content-Disposition: inline
In-Reply-To: <1291820573.2883.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

oddly enough our BUG at fs/inode.c seems to have gone away; may be a race
of some sort...

> you could call sock_map_fd() then :
> 
> 
> 	int fd = sock_map_fd(sock, flags);
> 	struct file *file = NULL;
> 
> 	if (fd != -1) {
> 		file = fget(fd);
> 		sys_close(fd);  /* still racy */
> 	}
> 
> 	if (file) ...
> 
> Take a look at net/9p/trans_fd.c

Interesting approach. 

We're currently doing the following -- we add this function to
net/socket.c:

int sock_map_anon(struct socket *sock, const char *name, int flags)
{
	struct file *newfile;
	
	newfile = anon_inode_getfile(name, &socket_file_ops, sock, flags);
	sock->file = newfile;
	return 0;
}

and then call it instead of sock_map_fd() from our sock_create():

	/* Create peer socket and associated file structure */
	rc = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sp->peer);
	if (rc < 0)
		goto out;
	rc = sock_map_anon(sp->peer, "[sp]", 0);
	if (rc < 0)
		goto out_release;

Is this a valid approach to achieve the same thing?

It's not clear what, if anything special we need to do to correctly release
the anonymous inode when we are releasing our socket...  is
sock_release(sp->peer) sufficient?

Also, I see in 9p/trans_fd.c that it's using get_file() to increment the
file refcount; do we need to do this for all sockets/files we create in
kernel space or is this only for the sys_close() hack?

Thanks,

-mato
