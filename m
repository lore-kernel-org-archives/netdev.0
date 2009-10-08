From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH 2/2] [RFC] Add c/r support for connected INET sockets
Date: Thu, 08 Oct 2009 14:47:13 +0000
Message-ID: <1255013233.8033.14.camel@Maple>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com>
	 <1254932945-12578-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:57977 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756453AbZJHOrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 10:47:31 -0400
Received: by mail-bw0-f210.google.com with SMTP id 6so839225bwz.37
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2009 07:47:20 -0700 (PDT)
In-Reply-To: <1254932945-12578-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-07 at 09:29 -0700, Dan Smith wrote:
> This patch adds basic support for C/R of open INET sockets.  I think
> that
> all the important bits of the TCP and ICSK socket structures is saved,
> but I think there is still some additional IPv6 stuff that needs to be
> handled.

I think this patch breaks code that was already in do_sock_restore():

        struct sock *do_sock_restore(struct ckpt_ctx *ctx)
        {
        	struct ckpt_hdr_socket *h;
        	struct socket *sock;
        	int ret;
        
        	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
        	if (IS_ERR(h))
        		return ERR_PTR(PTR_ERR(h));
        
        	/* silently clear flags, e.g. SOCK_NONBLOCK or SOCK_CLOEXEC */
        	h->sock.type &= SOCK_TYPE_MASK;
        
        	ret = sock_create(h->sock_common.family, h->sock.type, 0, &sock);
        	if (ret < 0)
        		goto err;
        

You're passing 0 as the protocol value to sock_create().  This
ultimately gets passed to the address family's create() function.  

inet_create() (and its IPv6 companion) use that protocol value as the
key when they search for the proper inet_protosw, which in turn gets
mapped to the struct proto and passed to sk_prot_alloc().

In address families INET and AF_INET6, the struct sock is different
sizes for different protocols.  This is implemented by the struct proto
specifying which cache the struct sock comes from.

So by passing in 0 all the time to sock_create(), you're getting a
struct sock that may not be the right size.  Memory corruption and
madness follow.

  --  John

