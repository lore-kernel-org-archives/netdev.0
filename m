From: James Morris <jmorris@namei.org>
Subject: Re: [Patch 1/1] AF_UNIX Datagram getpeersec (with minor fix)
Date: Sun, 18 Jun 2006 04:04:06 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606180313320.22401@d.namei>
References: <20060618061753.GA27681@jiayuguan.watson.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, jmorris@redhat.com,
	chrisw@osdl.org, herbert@gondor.apana.org.au, sds@tycho.nsa.gov,
	tjaeger@cse.psu.edu, akpm@osdl.org, latten@austin.ibm.com,
	sergeh@us.ibm.com, gcwilson@us.ibm.com, czhang.us@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:48348 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932138AbWFRIEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 04:04:09 -0400
To: Catherine Zhang <cxzhang@watson.ibm.com>
In-Reply-To: <20060618061753.GA27681@jiayuguan.watson.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 18 Jun 2006, Catherine Zhang wrote:

> Patch purpose:
> 
> This patch enables a security-aware application to retrieve the
> security context of the peer of a Unix datagram socket.  The application 
> can then use this security context to determine the security context for 
> processing on behalf of the peer who sent the packet. 

I'd also mention here that this is to complement the SO_PEERSEC option for 
stream sockets.

There's an implementation issue, which I'm sure has been mentioned 
previously.  This code should not be calling SELinux API functions.

> @@ -62,6 +70,12 @@ static __inline__ void scm_recv(struct s
>       if (test_bit(SOCK_PASSCRED, &sock->flags))
>               put_cmsg(msg, SOL_SOCKET, SCM_CREDENTIALS, sizeof(scm->creds), &scm->creds);
> 
> +     if (test_bit(SOCK_PASSSEC, &sock->flags)) {
> +             err = selinux_ctxid_to_string(scm->sid, &scontext, &scontext_len);


The above is SELinux-specific code sitting in core networking code.

Look at the peersec stuff, it calls out to LSM hooks:

  socket_getpeersec_stream
  socket_getpeersec_dgram

These are the abstractions to be used for this in the core kernel, and the 
SELinux code can then figure out specifically what to do based on the 
protocol.  Have a look at selinux_socket_getpeersec_stream() and see how 
it behaves based on the protocol, to get an idea of the changes needed for 
_dgram().

This needs to be reworked.

Look at ip_cmsg_recv_security() to see how this is done cleanly via an LSM 
hook, without modifying core networking structures.



- James
-- 
James Morris
<jmorris@namei.org>
