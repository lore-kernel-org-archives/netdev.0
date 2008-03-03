From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH 2/4 net-2.6.26] [IPV4]: Cleanup ip_options_compile.
Date: Tue, 04 Mar 2008 01:57:31 +0300
Message-ID: <1204585051.23504.35.camel@iris.sw.ru>
References: <1204559323-19953-2-git-send-email-den@openvz.org>
	 <20080303.115509.71743609.davem@davemloft.net>
	 <1204577698.23504.13.camel@iris.sw.ru>
	 <20080303.132422.64941146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:24853 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755773AbYCCW5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 17:57:47 -0500
In-Reply-To: <20080303.132422.64941146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-03-03 at 13:24 -0800, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Mon, 03 Mar 2008 23:54:58 +0300
> 
> > Though, it seems to me, that this structure does not came from
> > userspace. At least I do not see a way for this. Could you show me how
> > this can happen?
> 
> Sorry, I meant to talk about cases where the options have
> been munged by the input or packet processing path, and
> as a result the kernel intends opt->__data to be used.
> 
> For example, we might parse the options of an incoming
> packet, edit out some things we wish to ignore, and leave
> the result in opt->__data for ip_options_compile() to
> process.
> 
> cipso_v4_sock_setattr() is a similar case.
> 
> Look at how ip_options_get_from_user() works, it copies in the
> user provided IP options into opt->__data and sets
> opt->is_data.  This gets passed down to ip_options_get_finish()
> which passes that down to ip_options_compile().
> 
> Next, look at ip_cmsg_send(), it calls ip_options_get() which
> copies the data into opt->__data and passes this down to
> ip_options_get_finish() and thus ip_options_compile.
> 
> I guess your ip_options_get_finish() changes handle these
> cases, but I cannot prove that the CIPSO is_data setting
> ends up being unused.
> 
> I suppose it gets used by ip_options_build() for outgoing
> packets, which assumes that is_data is always set?

is_data is checked in the only place in the code, in the
ip_options_compile. It, in turn is called twice in the original code:

ip_options_get_finish
        opt->is_data = 1;    <-- !!!
        if (optlen && ip_options_compile(opt, NULL))

ip_rcv_options
   if (ip_options_compile(NULL, skb)) {

So, (opt && !opt->is_data) is impossible in the orignal code where it is
checked.

