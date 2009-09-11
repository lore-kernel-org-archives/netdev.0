From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Fri, 11 Sep 2009 08:36:10 +0300
Message-ID: <20090911053610.GA10324@redhat.com>
References: <20090910125929.GA32593@redhat.com> <200909110017.27668.paul.moore@hp.com> <20090911045943.GA1613@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13035 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068AbZIKFhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 01:37:54 -0400
Content-Disposition: inline
In-Reply-To: <20090911045943.GA1613@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2009 at 07:59:43AM +0300, Michael S. Tsirkin wrote:
> On Fri, Sep 11, 2009 at 12:17:27AM -0400, Paul Moore wrote:
> > On Thursday 10 September 2009 08:59:29 am Michael S. Tsirkin wrote:
> > > Tun device looks similar to a packet socket
> > > in that both pass complete frames from/to userspace.
> > > 
> > > This patch fills in enough fields in the socket underlying tun driver
> > > to support sendmsg/recvmsg operations, and exports access to this socket
> > > to modules.
> > > 
> > > This way, code using raw sockets to inject packets
> > > into a physical device, can support injecting
> > > packets into host network stack almost without modification.
> > > 
> > > First user of this interface will be vhost virtualization
> > > accelerator.
> > 
> > No comments on the code at this point - I'm just trying to understand the 
> > intended user right now which I'm assuming is the vhost-net bits you sent 
> > previously? 
> 
> Yes - these now use raw socket,

More specifically, vhost would then be patched with:

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index aeffb3a..b54f9d6 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -331,15 +331,26 @@ err:
 	return ERR_PTR(r);
 }
 
+static struct socket *get_tun_socket(int fd)
+{
+	struct file *file = fget(fd);
+	if (!file)
+		return ERR_PTR(-EBADF);
+	return tun_get_socket(file);
+}
+
 static struct socket *get_socket(int fd)
 {
 	struct socket *sock;
 	sock = get_raw_socket(fd);
 	if (!IS_ERR(sock))
 		return sock;
+	sock = get_tun_socket(fd);
+	if (!IS_ERR(sock))
+		return sock;
 	return ERR_PTR(-ENOTSOCK);
 }
 
 static long vhost_net_set_socket(struct vhost_net *n, int fd)
 {
 	struct socket *sock, *oldsock = NULL;
