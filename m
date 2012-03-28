From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net: reference the ipv4 sysctl table header
Date: Wed, 28 Mar 2012 12:32:20 -0400
Message-ID: <20120328163219.GA19778@home.goodmis.org>
References: <20120326222359.GB28123@dztty>
 <20120326.182411.41401140080225401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tixxdz@opendz.org, ebiederm@xmission.com, viro@zeniv.linux.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:11890 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758508Ab2C1QcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 12:32:24 -0400
Content-Disposition: inline
In-Reply-To: <20120326.182411.41401140080225401.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 06:24:11PM -0400, David Miller wrote:
> From: Djalal Harouni <tixxdz@opendz.org>
> Date: Mon, 26 Mar 2012 23:23:59 +0100
> 
> > +static struct ctl_table_header *ip4_base;
> > +
> >  /*
> >   * We really need to sanitize the damn ipv4 init order, then all
> >   * this nonsense will go away.
> >   */
> > -void __init ip_static_sysctl_init(void)
> > +int __init ip_static_sysctl_init(void)
> >  {
> > -	register_sysctl_paths(ipv4_path, ipv4_skeleton);
> > +	ip4_base = register_sysctl_paths(ipv4_path, ipv4_skeleton);
> 
> This is so incredibly stupid, just panic() or similar if this
> returns NULL.
> 
> And find another way to annotate this for memleak so we don't need to
> waste an entire pointer, which is never used, in the data section.

I just started using kmemleak and notice that it reports false positives
for several __init functions that call register_sysctl_paths(). The fix
you want is:

{
	sturct ctl_table_header *head;

	head = register_sysctl_paths(ipv4_path, ipv4_skeleton);
	BUG_ON(!head);
	kmemleak_ignore(head);


No need to waste a pointer just to keep the reference around for
kmemleak.

-- Steve
